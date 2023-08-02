// Metaphlan4 classification


process METAPHLAN4 {
	label "process_high"
	label "error_retry"
	tag "${sample_id}"
	publishDir "${params.outdir}/metaphlan4_out/", mode: 'copy'
		
	input:
	path metaphlan4db
	tuple val(sample_id), path(reads_file)
	
	output:
	tuple val(sample_id), path("${sample_id}.metaphlan4.tax"), 			emit: m4tax
	//tuple val(sample_id), path("${sample_id}.metaphlan4.sam.bz2"), 				emit: m4sam
	tuple val(sample_id), path("${sample_id}.bt2.bz2"), optional:true, 	emit: bt2out
	
	when:
	!params.profilers_off

	script:
	"""
	metaphlan \\
	${reads_file[0]},${reads_file[1]} \\
	--nproc $task.cpus \\
	--input_type fastq \\
	-t rel_ab_w_read_stats \\
	--bowtie2out "${sample_id}.bt2.bz2" \\
	--bowtie2db "${metaphlan4db}" \\
	--output_file "${sample_id}.metaphlan4.tax"
	
	"""
}
