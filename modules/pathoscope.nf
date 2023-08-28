// Pathoscope fungal classification

process PATHOSCOPE {
	label "process_medium"
	label "error_retry"
	tag "${sample_id}"
	publishDir "${params.outdir}/patho_out/", mode: 'copy'
		
	input:
	path patho_ref
	path patho_refdir
	path patho_filter
	tuple val(sample_id), path(reads_file)
	
	output:
	tuple val(sample_id), path("${sample_id}.sam"), 							emit: patho_sam
	tuple val(sample_id), path("updated_${sample_id}.sam"), 					emit: updated_patho_sam
	tuple val(sample_id), path("${sample_id}-sam-report.tsv"), 					emit: patho_sam_report

	when:
	!params.profilers_off

	script:
	"""
	#MAP - generate .sam
	python /PathoScope/pathoscope/pathoscope.py MAP -1 ${reads_file[0]} -2 ${reads_file[1]} \\
	-targetRefFiles ${patho_ref} \\
	-indexDir ${patho_refdir} \\
	-outAlign ${sample_id}.sam \\
	-expTag ${sample_id} \\
	-numThreads ${task.cpus} \\
	-filterRefFiles ${patho_filter}

	#ID - generate updated.sam
	python /PathoScope/pathoscope/pathoscope.py ID -alignFile ${sample_id}.sam \\
	-expTag ${sample_id}

	# remove unnecessary files
	rm ${sample_id}-appendAlign.fq
	rm ${sample_id}-malassezia_ref_all_14_w_MT.sam
	rm ${sample_id}-fungi_20130823_w_ustilago*.sam

	"""
}
