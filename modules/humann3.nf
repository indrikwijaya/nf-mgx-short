// Kraken2 classification

/*
It is encouraged for users to run kraken2 with at least 10-20 threads. 
*/

process HUMANN3 {
	label "process_high"
	label "error_retry"
	tag "${sample_id}"
	publishDir "${params.outdir}/humann3_out/", mode: 'copy'
		
	input:
	path humann3db
	tuple val(sample_id), path(reads_file)
	
	output:
	tuple val(sample_id), path("${sample_id}_*"), emit: humann3_out
	
	when:
	!params.profilers_off

	script:
	"""
	# merge reads
	cat ${reads_file} > ${sample_id}.fq.gz
	
	humann \\
	--threads ${task.cpus} \\
	-i ${sample_id}.fq.gz \\
	--metaphlan-options "--bowtie2db ${metaphlan4db}/ -x mpa_vOct22_CHOCOPhlAnSGB_202212" \\
    --nucleotide-database ${humann3db}/humann3/chocophlan/ \\
    --protein-database ${humann3db}/humann3/uniref/ \\
	-o .
	
	"""
}
