params.accession = "SRR1777174"
params.storeDir = "${projectDir}/cache"

process prefetch {
  storeDir params.storeDir
  container "https://depot.galaxyproject.org/singularity/sra-tools%3A3.2.1--h4304569_1"
  input:
    val accession
  output:
    path "${accession}/${accession}.sra"
  """
  prefetch ${accession}
  """
}

process fastqdump {
  container "https://depot.galaxyproject.org/singularity/sra-tools%3A3.2.1--h4304569_1"
  input:
    path srafile
  output:
    path "${srafile.getSimpleName()}.fastq"
  """
  fastq-dump --split-3 ${srafile}
  """
}

process fastqstats {
  container "https://depot.galaxyproject.org/singularity/ngsutils%3A0.5.9--py27h9801fc8_5"
  input:
    path fastqfile
  output:
    path "${fastqfile.getSimpleName()}.stats"
  """
  fastqutils stats ${fastqfile} > ${fastqfile.getSimpleName()}.stats
  """
}

workflow {
  channel.fromPath("accessions.txt").splitText().map{it -> it.trim()} | prefetch | fastqdump | fastqstats
} 
