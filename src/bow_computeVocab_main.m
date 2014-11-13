function bow_computeVocab_main(imgsDir, numWords, maxImgsForVocab, resDir)
if nargin < 4
    fprintf(2, 'Usage: ./prog <imgsDir> <numWords> <maxImgsForVocab> <resDir>\n');
    exit;
end
params.numWords = numWords;
params.maxImgsForVocab = maxImgsForVocab; 
try
    params.numWords = str2num(params.numWords);
    params.maxImgsForVocab = str2num(params.maxImgsForVocab);
catch
end

model = bow_computeVocab(imgsDir, params);
save(fullfile(resDir, 'model.mat'), 'model');

