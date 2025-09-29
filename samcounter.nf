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

process countStarts {
  input:
    path fastafile
  output: 
    path "${fastafile.getSimpleName()}.startcounts"
  """
  head -n 1 ${fastafile} > ${fastafile.getSimpleName()}.startcounts
  cat ${fastafile} | grep -o "ATG" | wc -l >> ${fastafile.getSimpleName()}.startcounts
  """
}

process countStops {
  input:
    path fastafile
  output: 
    path "${fastafile.getSimpleName()}.stopcounts"
  """
  head -n 1 ${fastafile} > ${fastafile.getSimpleName()}.stopcounts
  cat ${fastafile} | grep -o -E "TAA|TGA|TAG" | wc -l >> ${fastafile.getSimpleName()}.stopcounts
  """
}

process makeSummary {
  publishDir "${projectDir}/output", overwrite: true, mode: "copy"
  input:
    path startcounts
    path stopcounts
  output:
    path "summary.csv"
  """
  python ${projectDir}/scripts/makeRepeatSummary.py
  """
}

workflow {
  c_fasta = (downloadFile | splitSAM | flatten | convertToFasta)
  c_starts = countStarts(c_fasta)
  c_stops = countStops(c_fasta)
  makeSummary(c_starts.collect(), c_stops.collect())
}
