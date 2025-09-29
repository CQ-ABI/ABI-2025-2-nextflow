params.out = "${projectDir}/output"
params.store = "${projectDir}/downloads"
params.indir = null
params.downloadurl = null

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
  split -d -l 2 --additional-suffix _${fastafile.getSimpleName()}.fasta ${fastafile} split_
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
  for i in \$(ls ${infiles}); do
    echo -n "\$i" | cut -d "_" -f 2 | tr -d "\n" 
    echo -n ", "
    cat \$i
  done > summary_unsorted.csv
  cat summary_unsorted.csv | sort > summary.csv
  """ 
}

workflow {
  if(params.downloadurl != null && params.indir == null) {
    c_download = downloadFile()
  }
  else if(params.indir != null && params.downloadurl == null) {
    c_download = channel.fromPath("${params.indir}/*.fasta")
  }
  else {
    print("Error: Please provide either --downloadurl or --indir on the commandline.")
    System.exit(1)
  }
  countSeqs(c_download)
  c_split_flat = splitSeqs(c_download).flatten()
  c_basecounts = countBases(c_split_flat)
  c_repcounts = countRepeats(c_split_flat)
  makeSummary(c_repcounts.collect())
}
