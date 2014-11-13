run('~/software/vlfeat/toolbox/vl_setup');
run('~/software/vlg/toolbox/vlg_setup');

mcc -m -v -w enable -R startmsg -R completemsg -d ../bin bow_computeVocab_main;
exit;

