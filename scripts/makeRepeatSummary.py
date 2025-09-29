import os

codondata = dict()

for filename in os.listdir("."):
    if filename.endswith("stopcounts"):
        f = open(filename, "r")
        seqname = f.readline().strip()[1:]
        numstops = f.readline().strip()
        codondata[seqname] = ["", numstops]
        f.close()

for filename in os.listdir("."):
    if filename.endswith("startcounts"):
        f = open(filename, "r")
        seqname = f.readline().strip()[1:]
        numstarts = f.readline().strip()
        codondata[seqname][0] = numstarts
        f.close()

f = open("summary.csv", "w")
f.write("#Sequence name, number of start codons, number of stop codons\n")
for key in codondata:
    f.write(key + ", " + codondata[key][0] + ", " + codondata[key][1] + "\n")
f.close()
