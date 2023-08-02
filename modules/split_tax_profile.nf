// Metaphlan4 classification


process SPLIT_PROFILE {
	label "process_low"
	label "error_retry"
	tag "${sample_id}"
	publishDir "${params.outdir}/split_metaphlan4_out/", mode: 'copy'
		
	input:
	tuple val(sample_id), path(profile)
	
	output:
	tuple val(sample_id), path("${sample_id}*.tsv")
	
	script:
	"""
	grep -v '^#' ${profile}   \\
      | sed -E 's/.*\\|//'  \\
      | awk -v prefix=${sample_id} '{var=substr(\$0, 1,1); print >sample_id"."var".tsv"} '
	"""
}
