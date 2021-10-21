// Kraken2 classification

/*
It is encouraged for users to run kraken2 with at least 10-20 threads. 
*/

process KRAKEN2_DNA {
	label "process_high"
	label "error_retry"
	tag "${sample_id}"
	publishDir "${params.outdir}/kraken2_out/DNA", mode: 'copy'
		
	input:
	path kraken2db
	tuple val(sample_id), path(reads_file)
	
	output:
	tuple val(sample_id), path("${sample_id}_kraken2.tax"), emit: k2tax
	tuple val(sample_id), path("${sample_id}_kraken2.out"), emit: k2out
	
	when:
	!params.profilers_off && params.process_dna

	script:
	"""
	kraken2 --use-names --threads $task.cpus --db "${kraken2db}" \\
	--report "${sample_id}_kraken2.tax" --output "${sample_id}_kraken2.out" \\
	--gzip-compressed --paired ${reads_file[0]} ${reads_file[1]}
	
	"""
}
