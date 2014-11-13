bow_config; % add all paths

mcc -m -v -w enable -R startmsg -R completemsg -d ../bin bow_computeVocab_main;
mcc -m -v -w enable -R startmsg -R completemsg -d ../bin bow_buildInvIndex;
exit;

