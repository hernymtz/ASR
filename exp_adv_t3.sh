# Experiment to determine how Language Model Weights (lmwt) influence WER
# Open Kaldi  Working directory
cd ~/asrworkdir
source path.sh

# Set environmental variables if path.sh exists
[ -f ./path.sh ] && . ./path.sh

#//////////////////////////////////////////////////

# All WER Values variable
allWERval=""
# Comma variable for CSV files
initComma=""
# Initialize top WER value variable
topWER=0
# Initialize best minimum value
topmin=0
# Initialize best maximum value
topmax=0

#////////////////////////////////////////////////


# Training the Gaussian with a value of 9700
steps/train_mono.sh --totgauss 9700  --nj 4 data/train_words data/lang_wsj exp/word/mono

# Testing
utils/mkgraph.sh --mono data/lang_wsj_test_bg \
exp/word/mono exp/word/mono/graph

#Decoding
for min in 1 3 5 9 12
do
echo "lmwt(min)= $min."
for max in 10 30 70 101
do
echo "lmwt(max)= $max."

steps/decode.sh  --scoring-opts \"--min-lmwt $min --max-lmwt $max\" --nj 4 exp/word/mono/graph \
data/test_words exp/word/mono/decode_test

#Get WER
cat exp/word/mono/decode_test/scoring_kaldi/best_wer
stringWER=$(cat exp/word/mono/decode_test/scoring_kaldi/best_wer)
WER=${stringWER:5:4}

#///////////////////
WER10=$(echo "scale=4; $WER*10" |bc)
WER10=$( printf "%.0f" $WER10 )

if [ "${WER10:-0}" -lt "${topWER:-0}" ];then
topWER=$WER
topmin=$min
topmax=$max
fi
#///////////////////

# Set comma variable
comma=","

# Set values for Gaussians, WER and time
allWERval=$allWERval$initComma$min$max$WER$comma

#Save all WER values to CSV file
FILE="/afs/inf.ed.ac.uk/user/s13/s1351989/asrworkdir/my-local/lmwtlogfile.csv"
/bin/cat <<EOM>$FILE
$allWERval
EOM

#Save top WER value and Gauss number
FILE="/afs/inf.ed.ac.uk/user/s13/s1351989/asrworkdir/my-local/toplmwt.txt"
/bin/cat <<EOM>$FILE
$topWER
$topmin
$topmax
EOM

initComma=","
done
done
