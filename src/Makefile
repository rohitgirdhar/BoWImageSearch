APP = bow_computeVocab_main
matlabversion = 8.1
DELETE_FILES =
BIN = ../bin

$(APP): $(APP).m
	mcc -m -v -w enable -R -startmsg -R -completemsg -d $(BIN) $(APP).m

