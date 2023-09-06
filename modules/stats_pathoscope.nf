// Pathoscope stats and cleaning

process STATS_PATHOSCOPE {
	label "process_medium"
	label "error_retry"
	tag "${sample_id}"
	publishDir "${params.outdir}/patho_out/", mode: 'copy'
		
	input:
	tuple val(sample_id), path(patho_sam), path(updated_patho_sam), path(reads_file)
	path windows_bed
	
	output:
	tuple val(sample_id), path("${sample_id}.map.report"), 					emit: patho_map_report
	tuple val(sample_id), path("updated_${sample_id}.sorted.bam"), 			emit: patho_bam	
	tuple val(sample_id), path("${sample_id}.presence_absence_cov.txt"),	emit: patho_presence
	
	when:
	!params.profilers_off

	script:
	"""
	#STATS REPORT
	NUM_READ_times_2=\$(zcat ${reads_file[0]} | wc -l)
    NUM_MAPPED=\$(samtools view -S -F 268 "${patho_sam}" 2> /dev/null | wc -l)
    echo "Number of mapped reads: \${NUM_MAPPED}" > ${sample_id}.map.report
    printf "Mapping rate: " >> ${sample_id}.map.report
    echo "scale=4; \${NUM_MAPPED}/(\${NUM_READ_times_2}/2)" | bc -l >> ${sample_id}.map.report
    
	#COMPRESS SAM
	samtools view -buS ${updated_patho_sam} | samtools sort -o updated_${sample_id}.sorted.bam

	#PRESENCE ABSENCE
	presence_absence_from_cov2.sh updated_${sample_id}.sorted.bam ${windows_bed} > ${sample_id}.presence_absence_cov.txt

	#CLEAN SAM
	rm ${patho_sam}
	rm ${updated_patho_sam}
	
	
	"""
}
