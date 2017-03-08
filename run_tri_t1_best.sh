Exp_mono
# Open Kaldi  Working directory
cd ~/asrworkdir
source path.sh

# Set environmental variables if path.sh exists
[ -f ./path.sh ] && . ./path.sh

#Training
steps/train_deltas.sh 1000 9700 data/train_words \
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
