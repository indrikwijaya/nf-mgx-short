// Kraken2 classification

/*
It is encouraged for users to run kraken2 with at least 10-20 threads. 
*/

process KRAKEN2 {
	label "process_high"
	label "error_retry"
	tag "${sample_id}"
	publishDir "${params.outdir}/kraken2_out/", mode: 'copy'
		
	input:
	path kraken2db
	tuple val(sample_id), path(reads_file)
	
	output:
	tuple val(sample_id), path("${sample_id}.kraken2.tax"), emit: k2tax
	//tuple val(sample_id), path("${sample_id}.kraken2.out"), emit: k2out
	tuple val(sample_id), path("${sample_id}.k2.s.tsv"), emit: speciesreport
	tuple val(sample_id), path("${sample_id}.kraken2_minimizer.tax"), emit: k2mintax
	
	when:
	!params.profilers_off

	script:
	"""
	kraken2 \\
	--use-names \\
	--threads $task.cpus \\
	--db "${kraken2db}" \\
	--report "${sample_id}.kraken2_minimizer.tax" \\
	--report-minimizer-data \\
	--output "${sample_id}.kraken2.out" \\
	--gzip-compressed \\
	--paired ${reads_file[0]} ${reads_file[1]}
	
	k2_helper.sh "${sample_id}"

	### Remove .out large file
	rm "${sample_id}".kraken2.out
	"""
}
