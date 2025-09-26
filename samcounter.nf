process downloadFile {
  output:
    path "sequences.sam"
  """
  wget https://gitlab.com/dabrowskiw/cq-examples/-/raw/master/data/sequences.sam?inline=false -O sequences.sam
  """
}

process splitSAM {
  input:
    path samfile
  output:
    path "x*.sam"
  """
    tail -n +3  ${samfile} | split -l 1 --additional-suffix .sam
  """
}

process convertToFasta {
  input:
    path samfile
  output:
    path "${samfile.getSimpleName()}.fasta"
  """
  echo -n ">" > ${samfile.getSimpleName()}.fasta
  cat ${samfile} | cut -f 1 >> ${samfile.getSimpleName()}.fasta
  cat ${samfile} | cut -f 10 >> ${samfile.getSimpleName()}.fasta
  """
}

workflow {
  downloadFile | splitSAM | flatten | convertToFasta
}
