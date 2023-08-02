// Bracken classification for metagenomic data. Should not be run on metatranscriptomes

/*
params.kraken2db is the path to a built Kraken2 database which also contains the Bracken database files
*/

process BRACKEN {
	label "process_small"
	label "error_retry"
	tag "${sample_id}"
	publishDir "${params.outdir}/kraken2_out/", mode: 'copy'
	
	input:
	path kraken2db
	val(readlength)
	tuple val(sample_id), path("${sample_id}.kraken2.tax")
	
	output:
	tuple val(sample_id), path("${sample_id}.bracken.g"), emit: btax_g
	tuple val(sample_id), path("${sample_id}.bracken.g.tsv"), emit: btax_g_relab
	tuple val(sample_id), path("${sample_id}.bracken.g.tax"), emit: btax_g_results
	
	tuple val(sample_id), path("${sample_id}.bracken.s"), emit: btax_s
	tuple val(sample_id), path("${sample_id}.bracken.s.tsv"), emit: btax_s_relab
	tuple val(sample_id), path("${sample_id}.bracken.s.tax"), emit: btax_s_results

	when:
	!params.profilers_off
	
	script:
	"""	
	### Genus
	bracken \\
	-d "${kraken2db}" \\
	-i "${sample_id}.kraken2.tax" \\
	-o "${sample_id}.bracken.g" \\
	-w "${sample_id}.bracken.g.tax" \\
	-r "${readlength}" \\
	-l G
	
	### Get relabund
	sed 's/ /_/g' "${sample_id}".bracken.g | \\
    tail -n+2 | \\
    cut -f 1,7 > "${sample_id}".bracken.g.tsv

	### Species
	bracken \\
	-d "${kraken2db}" \\
	-i "${sample_id}.kraken2.tax" \\
	-o "${sample_id}.bracken.s" \\
	-w "${sample_id}.bracken.s.tax" \\
	-r "${readlength}" \\
	-l S

	### Get relabund
	sed 's/ /_/g' "${sample_id}".bracken.s | \\
    tail -n+2 | \\
    cut -f 1,7 > "${sample_id}".bracken.s.tsv

	"""
}
