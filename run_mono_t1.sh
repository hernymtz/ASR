# Exp_mono
# Open Kaldi  Working directory
cd ~/asrworkdir
source path.sh

# Set environmental variables if path.sh exists
[ -f ./path.sh ] && . ./path.sh

# Gather files for word recognition
#./local/lab3_setup.sh




#Testing
utils/mkgraph.sh --mono data/lang_wsj_test_bg \
my-local/mono_best_t1 my-local/mono_best_t1/graph

steps/decode.sh --nj 4 my-local/mono_best_t1/graph \
data/test_words my-local/mono_best_t1/decode_test 

local/score_words.sh data/test_words my-local/mono_best_t1/graph \
my-local/mono_best_t1/decode_test

#Get WER
cat my-local/mono_best_t1/decode_test/scoring_kaldi/best_wer


#--------------




