process downloadFile {
  publishDir "${projectDir}/output", mode: "copy", overwrite: true
  output:
    path "batch1.fasta"
  """
  wget https://tinyurl.com/cqbatch1 -O batch1.fasta
  """
}

workflow {
  downloadFile()
}
