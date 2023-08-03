// MEGAHIT ASSEMBLY


process MEGAHIT {
	label "process_highmem"
	label "error_retry"
	tag "${sample_id}"
	publishDir "${params.outdir}/megahit_out/", mode: 'copy'
		
	input:
	tuple val(sample_id), path(reads_file)
	
	output:
	tuple val(sample_id), path("${sample_id}.contigs.fa.gz")				 , emit: megahit_out
	tuple val(sample_id), path("intermediate_contigs/k*.contigs.fa.gz")      , emit: k_contigs
    tuple val(sample_id), path("intermediate_contigs/k*.addi.fa.gz")         , emit: addi_contigs
    tuple val(sample_id), path("intermediate_contigs/k*.local.fa.gz")        , emit: local_contigs
    tuple val(sample_id), path("intermediate_contigs/k*.final.contigs.fa.gz"), emit: kfinal_contigs
	
	when:
	!params.profilers_off

	script:
	"""
	megahit \\
	-1 ${reads_file[0]} -2 ${reads_file[1]} \\
	-t ${task.cpus} \\
	--out-prefix ${sample_id}
	
	"""
}
