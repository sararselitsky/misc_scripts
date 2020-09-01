# this script takes in a BAM and gives you:
# the mean insert size for PCR dups
# the mean insert size for ERCC reads


# get input
echo -e "========================="
echo -e "obtain inputs\n"
bam=$1
threads=$2
echo -e "BAM: $bam"
echo -e "THREADS: $threads"
echo -e "=========================\n\n"


# define output
echo -e "========================="
echo -e "define outputs\n"
dup_bam="dup.bam"
dup_stats="dup.stats.txt"
dup_insert_size="dup.insert_size.txt"
ercc_bam="ercc.bam"
ercc_stats="ercc.stats.txt"
ercc_insert_size="ercc.insert_size.txt"
non_dup_bam="non_dup_bam"
non_dup_stats="non_dup.status.txt"
non_dup_insert_size="non_dup.insert_size.txt"
echo -e "DUP_BAM: $dup_bam"
echo -e "DUP_STATS: $dup_stats"
echo -e "DUP_INSERT_SIZE: $dup_insert_size"
echo -e "ERCC_BAM: $ercc_bam"
echo -e "ERCC_STATS: $ercc_stats"
echo -e "ERCC_INSERT_SIZE: $ercc_insert_size"
echo -e "NON_DUP_BAM: $non_dup_bam"
echo -e "NON_DUP_STATS: $non_dup_stats"
echo -e "NON_DUP_INSERT_SIZE: $non_dup_insert_size"
echo -e "=========================\n\n"


# get PCR duplicates
echo -e "========================="
echo -e "obtain PCR duplicates\n"
echo -e "COMMAND: samtools view -h -f 1024 BAM | samtools view -Sb - > DUP_BAM"
samtools view -h -@ "$threads" -f 1024 "$bam" | samtools view -@ "$threads" -Sb - > "$dup_bam"
echo -e "=========================\n\n"

# get non pcr dups
echo -e "========================="
echo -e "obtain nonPCR duplicates\n"
echo -e "COMMAND: samtools view -h -F 1024 BAM | samtools view -Sb - > NON_DUP_BAM"
samtools view -h -@ "$threads" -F 1024 "$bam" | samtools view -@ "$threads" -Sb - > "$non_dup_bam"

# get insert size statistics
echo -e "========================="
echo -e "obtain dup insert size\n"
echo -e "COMMAND: samtools stats DUP_BAM > DUP_STATS"
samtools stats "$dup_bam" > "$dup_stats"
echo -e "COMMAND: grep \"insert size \" DUP_STATS | cut -f 2- > DUP_INSERT_SIZE"
grep "insert size " "$dup_stats" | cut -f 2- > "$dup_insert_size"
echo -e "=========================\n\n"


# get insert size statistics, non dup
echo -e "========================="
echo -e "obtain dup insert size\n"
echo -e "COMMAND: samtools stats NON_DUP_BAM > NON_DUP_STATS"
samtools stats "$non_dup_bam" > "$non_dup_stats"
echo -e "COMMAND: grep \"insert size \" NON_DUP_STATS | cut -f 2- > NON_DUP_INSERT_SIZE"
grep "insert size " "$non_dup_stats" | cut -f 2- > "$non_dup_insert_size"
echo -e "=========================\n\n"

# get ERCC percentage
echo -e "========================="
echo -e "obtain percentage of ERCC reads in PCR duplicate reads\n"
all_pcr=$(samtools view -@ "$threads" "$dup_bam" | wc -l)
ercc_pcr=$(samtools view -@ "$threads" "$dup_bam" | grep -c "ERCC")
ercc_pcr_percent=$(echo "scale=6;100*$ercc_pcr/$all_pcr" | bc)
echo -e "Number of all PCR duplicates: $all_pcr" | tee -a "$dup_insert_size"
echo -e "Number of ERCC reads in PCR duplicates: $ercc_pcr" | tee -a "$dup_insert_size"
echo -e "Percentage of PCR duplicates that are ERCC reads: $ercc_pcr_percent" | tee -a "$dup_insert_size"
echo -e "=========================\n\n"


# get ERCC reads
echo -e "========================="
echo -e "obtain BAM header\n"
echo -e "COMMAND: samtools view -H BAM > HEADER"
samtools view -@ "$threads" -H "$bam" > header.sam
echo -e "obtain ERCC reads\n"
echo -e "COMMAND: samtools view BAM | grep \"ERCC\" > ERCC_SAM; cat HEADER ERCC_SAM | samtools -Sb - > ERCC_BAM"
samtools view -@ "$threads" "$bam" | grep "ERCC" > ercc.sam
cat header.sam ercc.sam | samtools view -@ "$threads" -Sb - > "$ercc_bam"
echo -e "=========================\n\n"


# get insert size statistics

echo -e "========================="
echo -e "obtain ercc insert size\n"
echo -e "COMMAND: samtools stats ERCC_BAM > ERCC_STATS"
samtools stats "$ercc_bam" > "$ercc_stats"
echo -e "COMMAND: grep \"insert size \" ERCC_STATS | cut -f 2- > ERCC_INSERT_SIZE"
grep "insert size " "$ercc_stats" | cut -f 2- > "$ercc_insert_size"
echo -e "=========================\n\n"


# get dup percentage
echo -e "========================="
echo -e "obtain percentage of PCR duplicate reads in ERCC reads\n"
all_ercc=$(samtools view -@ "$threads" "$ercc_bam" | wc -l)
pcr_ercc=$(samtools view -@ "$threads" -f 1024 "$ercc_bam" | wc -l)
pcr_ercc_percent=$(echo "scale=6;100*$pcr_ercc/$all_ercc" | bc)
echo -e "Number of all ERCC reads: $all_ercc" | tee -a "$ercc_insert_size"
echo -e "Number of PCR duplicates in ERCC reads: $pcr_ercc" | tee -a "$ercc_insert_size"
echo -e "Percentage of ERCC reads that are PCR duplicates: $pcr_ercc_percent" | tee -a "$ercc_insert_size"
echo -e "=========================\n\n"


