params.out = "${projectDir}/output"
params.store = "${projectDir}/downloads"
params.downloadurl = "https://tinyurl.com/cqbatch1"

process downloadFile {
  storeDir params.store
  publishDir params.out, mode: "copy", overwrite: true
  output:
    path "*.fasta"
  """
  wget ${params.downloadurl} -O mysequences.fasta
  """
}

process countSeqs {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path inputfile 
  output:
    path "numseqs.txt"
  """
  grep ">" ${inputfile} | wc -l > numseqs.txt
  """
}

process splitSeqs {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path fastafile
  output:
    path "split_*.fasta"
  """
  split -d -l 2 --additional-suffix .fasta ${fastafile} split_
  """
}

process countBases {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path fastafile
  output:
    path "${fastafile.getSimpleName()}_count.txt"
  """
  echo -n "-1+" > calc.txt
  tail -n 1 ${fastafile} | wc -m >> calc.txt
  cat calc.txt | bc > ${fastafile.getSimpleName()}_count.txt
  """
}

process countRepeats {
  input:
    path fastafile
  output:
    path "${fastafile.getSimpleName()}_repeatcount.txt"
  """
  grep -o "GCCGCG" ${fastafile} | wc -l > ${fastafile.getSimpleName()}_repeatcount.txt
  echo \$(which fish) > fishlocation.txt
  """
}

process makeSummary {
  publishDir params.out, mode: "copy", overwrite: true
  input: 
    path infiles
  output:
    path "summary.csv"
  """
  ${projectDir}/scripts/makeSummary.sh > summary.csv
  """
}

workflow {
  c_download = downloadFile()
  countSeqs(c_download)
  c_split_flat = splitSeqs(c_download).flatten()
  c_basecounts = countBases(c_split_flat)
  c_repcounts = countRepeats(c_split_flat)
  makeSummary(c_repcounts.collect())
}
