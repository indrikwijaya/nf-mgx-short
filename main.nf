#!/usr/bin/env nextflow

/*
========================================================================================
    Shotgun metagenomics and metatranscriptomics 
========================================================================================
    Github : https://github.com/indrikwijaya/shotgunmetagenomics-nf
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl=2

/*
========================================================================================
    Help messages and warnings
========================================================================================
*/

//https://www.baeldung.com/groovy-def-keyword
//https://www.nextflow.io/blog/2020/cli-docs-release.html

// Constants
def profilers_expected = ['kraken2', 'metaphlan3', 'metaphlan4', 'humann3', 'srst2', 'megahit', 'pathoscope'] as Set

def helpMessage() {
  // adapted from nf-core
    log.info"""
    
    Usage for main workflow:
    The typical command for running the pipeline is as follows:
      nextflow run main.nf
      --read_path FOLDER_FOR_read_path
      --bwaidx_path FOLDER_FOR_HUMAN_GENOME_AND_BWA_INDEX
      --bwaidx NAME_OF_BWA_INDEX
      --kraken2db FOLDER_FOR_KRAKEN2_AND_BRACKEN_DB
      --metaphlan4db FOLDER_FOR_METAPHLAN4
      --humann3db FOLDER_FOR_HUMANN3
      --srst2db FOLDER_FOR_SRST2

    
	NOTE: A more user-friendly approach is to specify these parameters in a *.config file under a custom profile 
    
    The main workflow can take up a lot of disk space with intermediate fastq files. 
    
    If this is a problem, the workflow can be run as two separate modules.
    
    Input and database arguments are null by default.
    Rather than manually specifying the paths to so many databases, it is best to create a custom nextflow config file.
     
    Input arguments:
      --read_path                   Path to a folder containing all input metagenomic reads (this will be recursively searched for *fastq.gz/*fq.gz/*fq/*fastq files)

    Output arguments:
      --outdir                      Output directory [Default: ./pipeline_output/]

    Decont arguments:
      --bwaidx_path                 Path to the folder with host (human/mouse) reference genome and bwa index
      --bwaidx			                Name of the bwa index e.g. hg38.fa
     
    Profilers options:
      --profilers                   Metagenomic profilers to run [Default: kraken2, metaphlan4, humann3, srst2]
   
   Kraken2 options:
      --kraken2db                   Path to Kraken2 and Bracken databases

    Bracken options:
      --readlength                  Length of Bracken k-mers to use [default: 150]

    MetaPhlAn4 arguments:
      --metaphlan4db          Path to the metaphlan4 database
      --metaphlan4_index            Bowtie2 index prefix for the marker genes [Default: mpa_vOct22_CHOCOPhlAnSGB_202212]
      --metaphlan4_pkl              Python pickle file for marker genes [mpa_vOct22_CHOCOPhlAnSGB_202212.pkl]

    HUMAnN3 arguments:
      --humann3_nt                  Path to humann3 chocophlan database
      --humann3_protein             Path to humann3 protein database

    SRST2 arguments:
      --srst2_ref                   Fasta file used for srst2

    Output arguments:
      --outdir                      The output directory where the results will be saved [Default: ./pipeline_results]
      --tracedir                    The directory where nextflow logs will be saved [Default: ./pipeline_results/pipeline_info]

    AWSBatch arguments:
      --awsregion                   The AWS Region for your AWS Batch job to run on [Default: false]
      --awsqueue                    The AWS queue for your AWS Batch job to run on [Default: false]

    Others:
      --help		            Display this help message
    """
}

if (params.help){
    helpMessage()
    exit 0
}

// Parameters sanity checking
//def parameter_diff = params.keySet() - parameters_expected
//if (parameter_diff.size() != 0){
//   exit 1, "[Pipeline error] Parameter(s) $parameter_diff is/are not valid in the pipeline!\n"
//}

// AWSBatch sanity checking
if(workflow.profile.contains('awsbatch')){
    if (!params.awsqueue || !params.awsregion) exit 1, "Specify correct --awsqueue and --awsregion parameters on AWSBatch!"
    //if (!params.outdir.startsWith('s3')) exit 1, "Specify S3 URLs for outdir parameters on AWSBatch!"
}

// Nextflow version sanity checking
//if( ! nextflow.version.matches("$workflow.manifest.nextflowVersion") ){
//    exit 1, "[Pipeline error] Nextflow version $workflow.manifest.nextflowVersion required! You are running v$workflow.nextflow.version!\n" 
//}

// // Input sanity checking
// if (params.containsKey('read_path') && params.containsKey('reads') && params.read_path && params.reads){
//    exit 1, "[Pipeline error] Please specify your input using ONLY ONE of `--read_path` and `--reads`!\n"
// }
// if (params.containsKey('read_path') && params.read_path){
//    ch_reads = Channel
//         .fromFilePairs([params.read_path + '/**{R,.,_}{1,2}*f*q*'], flat: true, checkIfExists: true) {file -> file.name.replaceAll(/[-_].*/, '')}
// } else if (params.containsKey('reads') && params.reads) {
//    ch_reads = Channel
//         .fromFilePairs(params.reads, flat: true, checkIfExists: true) {file -> file.name.replaceAll(/[-_].*/, '')}
// } else {
//    exit 1, "[Pipeline error] Please specify your input using `--read_path` or `--reads`!\n"
// }

// Profiler sanity checking
def profilers = [] as Set
if(params.profilers.getClass() != Boolean){
    def profilers_input = params.profilers.split(',') as Set
    def profiler_diff = profilers_input - profilers_expected
    profilers = profilers_input.intersect(profilers_expected)
    if( profiler_diff.size() != 0 ) {
    	log.warn "[Pipeline warning] Profiler $profiler_diff is not supported yet! Will only run $profilers.\n"
    }
}

// Decont
if (!params.bwaidx_path && !params.decont_off){
    helpMessage()
    log.info"""
    [Error] --bwaidx_path is required for removal of host (human) reads from metagenomic sequences (decontamination step)
    """.stripIndent()
    exit 0
}

// Kraken2
if (!params.kraken2db && !params.profilers_off){
    helpMessage()
    log.info"""
    [Error] --kraken2db is required for taxonomic classification
    """.stripIndent()
    exit 0
}

/*
========================================================================================
    Define channels for read pairs
========================================================================================
*/

Channel.fromFilePairs( [params.read_path + '/**{R,.,_}{1,2}*{fastq,fastq.gz,fq,fq.gz}'], checkIfExists:true ).set{ ch_reads }

// import modules
include { DECONT } from './modules/decont.nf' 
include { KRAKEN2 } from './modules/kraken2.nf'
include { BRACKEN } from './modules/bracken.nf' 
include { METAPHLAN3 } from './modules/metaphlan3.nf' 
include { METAPHLAN4 } from './modules/metaphlan4.nf' 
include { HUMANN3 } from './modules/humann3.nf' 
include { MEGAHIT } from './modules/megahit.nf'
include { PATHOSCOPE } from './modules/pathoscope.nf'
include { STATS_PATHOSCOPE } from './modules/stats_pathoscope.nf'
//include { SRST2 } from './modules/srst2.nf' 

// TODO: is there any elegant method to do this?
include { SPLIT_PROFILE } from './modules/split_tax_profile.nf' 
//include { SPLIT_PROFILE } as SPLIT_KRAKEN2 from './modules/split_tax_profile.nf'


// processes
workflow {
  
  //DECONT
    if(!params.decont_off){
	    DECONT(params.bwaidx_path, ch_reads)
	    ch_reads_qc = DECONT.out.reads
    } else{
      ch_reads_qc = ch_reads
    }

  //KRAKEN2
    if(profilers.contains('kraken2')){
        KRAKEN2(params.kraken2db, ch_reads_qc)
        BRACKEN(params.kraken2db, params.readlength, KRAKEN2.out.k2tax)
    }

  //METAPHLAN3
    if(profilers.contains('metaphlan3')){
        METAPHLAN3(params.metaphlan3db, ch_reads_qc)
        SPLIT_PROFILE(METAPHLAN3.out.m3tax)
    }

  //METAPHLAN4
    if(profilers.contains('metaphlan4')){
        METAPHLAN4(params.metaphlan4db, ch_reads_qc)
        SPLIT_PROFILE(METAPHLAN4.out.m4tax)
    }
  
  //HUMANN3
    if(profilers.contains('humann3')){
        humann3_INDEX(params.humann3_nt, metaphlan4.out)
        humann3(params.humann3_protein, ch_reads_qc.join(humann3_INDEX.out))
    }
  
  //PATHOSCOPE
    if(profilers.contains('pathoscope')){
      PATHOSCOPE(params.patho_ref, params.patho_refdir, params.patho_filter, ch_reads_qc)
      STATS_PATHOSCOPE(PATHOSCOPE.out.patho_sam, PATHOSCOPE.out.updated_patho_sam, ch_reads_qc, params.windows_bed)
    }
  //MEGAHIT
    if(profilers.contains('megahit')) {
      MEGAHIT(ch_reads_qc)
    }

  //SRST2
    // if(profilers.contains('srst2')){
    //     SRST2(params.srst2db, ch_reads_qc)
    // }
}
