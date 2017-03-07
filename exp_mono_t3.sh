# Exp_mono
# Open Kaldi  Working directory
cd ~/asrworkdir
source path.sh

# Set environmental variables if path.sh exists
[ -f ./path.sh ] && . ./path.sh

# Gather files for word recognition
#./local/lab3_setup.sh

# Counter variable
num=1

# All WER Values variable
allWERval=""

# Comma variable for CSV files
initComma=""

# Initialize top WER value variable
topWER=0

# Initialize top gaussian value
topGauss=0

# Set delta configuration
deltaNum=0

# For-loop: Train model and save number of gaussians,  WER value and elapsed time
#-------------
for gauss in  10
do

# Erase previous models
rm -rf exp/word/mono

# Start timer
START=$(date +%s.%N)

# Report current state
echo "Currently running  step $num ."
echo "Number of Gaussians  is $gauss"


#Training
my-local/train_monoDelta.sh --delta_opts\"--delta-order=$deltaNum --totgauss $gauss  --nj 4 data/train_words data/lang_wsj exp/word/mono


#Testing
utils/mkgraph.sh --mono data/lang_wsj_test_bg \
exp/word/mono exp/word/mono/graph

steps/decode.sh --nj 4 exp/word/mono/graph \
data/test_words exp/word/mono/decode_test 

local/score_words.sh data/test_words exp/word/mono/graph \
exp/word/mono/decode_test

#Get WER
cat exp/word/mono/decode_test/scoring_kaldi/best_wer
stringWER=$(cat exp/word/mono/decode_test/scoring_kaldi/best_wer)
WER=${stringWER:5:4}

#///////////////////


WER10=$(echo "scale=4; $WER*10" |bc)
WER10=$( printf "%.0f" $WER10 )

if [ "${WER10:-0}" -lt "${topWER:-0}" ];then
topWER=$WER
topGauss=$gauss
fi


#///////////////////




# Set comma variable
comma=","

# End timer
END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)

# Set values for Gaussians, WER and time
allWERval=$allWERval$initComma$gauss$comma$WER$comma$DIFF

#Save all WER values to CSV file
FILE="/afs/inf.ed.ac.uk/user/s16/s1659809/asrworkdir/my-local/logfile.csv"
/bin/cat <<EOM>$FILE
$allWERval
EOM

#Save top WER value and Gauss number
FILE="/afs/inf.ed.ac.uk/user/s16/s1659809/asrworkdir/my-local/topGauss.txt"
/bin/cat <<EOM>$FILE
$topGauss
EOM


# Increase num counter
num=$((num+1))
initComma=","

done
#--------------
# End for-loop



