// Metaphlan4 classification


process METAPHLAN3 {
	label "process_high"
	label "error_retry"
	tag "${sample_id}"
	publishDir "${params.outdir}/metaphlan3_out/", mode: 'copy'
		
	input:
	path metaphlan3db
	tuple val(sample_id), path(reads_file)
	
	output:
	tuple val(sample_id), path("${sample_id}.metaphlan3.tax"), 			emit: m3tax
	//tuple val(sample_id), path("${sample_id}.metaphlan3.sam.bz2"), 				emit: m4sam
	tuple val(sample_id), path("${sample_id}.bt2.bz2"), optional:true, 	emit: bt2out
	
	when:
	!params.profilers_off

	script:
	"""
	metaphlan \\
	${reads_file[0]},${reads_file[1]} \\
	--nproc ${task.cpus} \\
	--input_type fastq \\
	-t rel_ab_w_read_stats \\
	--bowtie2out "${sample_id}.bt2.bz2" \\
	--bowtie2db "${metaphlan3db}" \\
	--index mpa_v30_CHOCOPhlAn_201901 \\
	--add_viruses \\
	--output_file "${sample_id}.metaphlan3.tax"
	
	"""
}
