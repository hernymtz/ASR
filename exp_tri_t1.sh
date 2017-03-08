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
topWER=100
# Initialize top gaussian value
topGauss=0


# For-loop: Train model and save number of gaussians,  WER value and elapsed time
#-------------

for cluster in 1000 2000 4000 5000 10000
do
# Erase previous models
rm -rf exp/word/mono
# Start timer
START=$(date +%s.%N)
echo "For a cluster of size $cluster."

for gauss in  9700 17000 30000
do
# Report current state
echo "Currently running  step $num ."
echo "Number of Gaussians  is $gauss"

#Training
steps/train_deltas.sh $cluster $gauss data/train_words \
data/lang_wsj exp/word/mono_ali exp/word/tri1

#Testing
utils/mkgraph.sh data/lang_wsj_test_bg \
exp/word/tri1 exp/word/tri1/graph

steps/decode.sh --nj 4 exp/word/tri1/graph \
data/test_words exp/word/tri1/decode_test

local/score_words.sh data/test_words exp/word/tri1/graph \
exp/word/tri1/decode_test

#Get WER
cat exp/word/tri1/decode_test/scoring_kaldi/best_wer
stringWER=$(cat exp/word/tri1/decode_test/scoring_kaldi/best_wer)
WER=${stringWER:5:4}

#///////////////////

WER10=$(echo "scale=4; $WER*10"|bc)
WER10=$(printf "%.0f" $WER10 )

if [ "${WER10:-0}" -lt "${topWER:-0}" ];then
topWER=$WER
topGauss=$gauss
topCluster=$cluster
fi

#///////////////////
# End timer
END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)

#Set comma variable
comma=","

# Set values for Gaussians, WER and time
allWERval=$allWERval$initComma$cluster$comma$gauss$comma$WER$comma$DIFF

#Save all WER values to CSV file
FILE="/afs/inf.ed.ac.uk/user/s13/s1351989/asrworkdir/my-local/newlogfile.csv"
/bin/cat <<EOM>>$FILE
$allWERval
EOM

#Save top WER value and Gauss number
FILE="/afs/inf.ed.ac.uk/user/s13/s1351989/asrworkdir/my-local/topClusterGauss.txt"
/bin/cat <<EOM>>$FILE
$topWER
$topGauss
$topCluster
EOM

# Increase num counter
num=$((num+1))
initComma=","
done
done
#--------------
# End for-loop
