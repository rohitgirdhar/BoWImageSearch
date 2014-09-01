function [train_set, test_set] = splitTestTrain(imgsDir, numTest)
% For each image file in imgs dir, put into test or train set and write out
% into output fpath files

addpath(genpath('..'));
imgPaths = getImgFilesList(imgsDir);
test_idx = randperm(numel(imgPaths), numTest);
test_set = imgPaths(test_idx);
train_set = imgPaths(setdiff(1 : numel(imgPaths), test_idx));
