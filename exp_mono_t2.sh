# Exp_mono
# Open Kaldi  Working directory
cd ~/asrworkdir
source path.sh

# Set environmental variables if path.sh exists
[ -f ./path.sh ] && . ./path.sh

# Gather files for word recognition
#./local/lab3_setup.sh

# Create filterbank and pitch features

#for dir in train_words test_words; do
#steps/make_fbank_pitch.sh data_fbank/$dir exp/make_fbank/$dir fbank
#done


#for dir in train_words test_words; do
#steps/compute_cmvn_stats.sh data_fbank/$dir exp/make_fbank/$dir fbank
#done



# Counter variable
num=1

# All WER Values variable
allWERval=""

# Comma variable for CSV files
initComma=""



# For-loop: Train model and save number of gaussians,  WER value and elapsed time
#-------------
for gauss in 500000
do

# Erase previous models
rm -rf exp/word/mono

# Start timer
START=$(date +%s.%N)

# Report current state
echo "Currently running  step $num ."
echo "Number of Gaussians  is $gauss"


#Training
steps/train_mono.sh --totgauss $gauss  --nj 4 data_fbank/train_words data_fbank/lang_wsj exp/word/mono


#Testing
utils/mkgraph.sh --mono data_fbank/lang_wsj_test_bg \
exp/word/mono exp/word/mono/graph
steps/decode.sh --nj 4 exp/word/mono/graph \
data_fbank/test_words exp/word/mono/decode_test 

local/score_words.sh data_fbank/test_words exp/word/mono/graph \
exp/word/mono/decode_test

#Get WER
cat exp/word/mono/decode_test/scoring_kaldi/best_wer
stringWER=$(cat exp/word/mono/decode_test/scoring_kaldi/best_wer)
WER=${stringWER:5:4}

# Set comma variable
comma=","


# End timer
END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)

# Set values for Gaussians, WER and time
allWERval=$allWERval$initComma$gauss$comma$WER$comma$DIFF

#Save to CSV file
FILE="/afs/inf.ed.ac.uk/user/s16/s1659809/asrworkdir/my-local/logfile.csv"
/bin/cat <<EOM>$FILE
$allWERval
EOM

# Increase num counter
num=$((num+1))
initComma=","

done
#--------------
# End for-loop



