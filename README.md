# Shotgun Metagenomics Nextflow Pipeline

## Introduction

indrikwijaya/nf-mgx-short is a bioinformatics pipeline that takes raw metagenomic (short reads) **(MGX)** and annotates them at the taxonomic, functional and resistome levels.

The pipeline is built using [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) , a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. 
It uses Docker containers (also compatible with Singularity) for ease of installation and computational reproducibility. 

This pipeline currently only accepts paired-end reads as inputs. 

## Pipeline summary for metagenomic reads
1. Adapter trimming and quality control using fastp (0.22.0)
2. Removal of host (human) reads by mapping to a reference genome using bwa (0.7.17) 
3. Taxonomic classification of non-human reads

   a. using Kraken2 (2.1.2) and taxonomic abundance re-estimation using Bracken (2.6.1)

   b. using Metaphlan4 (4.0.6) 
5. Functional annotation of reads using HUMANN3
6. Resistome annotation of reads using SRST2

## Quick Start

1. Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=21.04.0`) and add the nextflow executable to your $PATH

2. Install [`Docker`](https://docs.docker.com/engine/installation/)   

3. Clone the pipeline and refer to the help message
	```sh
	$ git clone https://github.com/indrikwijaya/nf-mgx-short
	
	$ nextflow run ./nf-mgx-short/main.nf --help
	```
* Add a custom config file which contains the paths to various pre-installed databases. Refer to the test.config file in this repo for an example. 
* Add a custom profile in the nextflow.config file, allowing you to specify the use of docker or singularity, and/or a task scheduler.  

4. Make sure all helper scripts in nf-mgx-short/bin have execute permissions

	```sh
	$ cd bin/
	$ chmod +x *
	```

5. Run the pipeline
	```sh
	$ nextflow run ./nf-mgx-short/main.nf -profile docker,your_profile --profilers metaphlan4 --read_path /path/to/metagenomes --outdir /path/to/results
	```
* You can specifiy multiple profiles separated by comma, e.g. -profile docker,sge.
* The taxonomic classification, nucleotide alignment, translated search and annotation modules can be quite memory intensive depending on the databases used
* Delete the work/ directory after running the pipeline to free up space taken up by intermediate files

Contact: 
Indrik Wijaya
indrik_wijaya@gis.a-star.edu.sg, indrik.wijaya@gmail.com
