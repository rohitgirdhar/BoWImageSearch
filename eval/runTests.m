function runTests(imgsDir, model, iindex, outputDir, varargin)
% Run imgSearch for all image files in 'imgsDir' (recursively searched).
% The class of an image is given by the folder it is in.
% outputDir: contains the matching image files and matches images
% Optional Parameters:
% 'imgsListFpath', 'path/to/file.txt' :- File contains a newline separated
% list of image paths (relative to imgsDir) of the image files to 
% build index upon. Typically used to set the train set.
% All the code in this file is specific to dataset arranged as:
% -imgsDir
%   |--class1
%        |--img1.jpg
%        |--img2.jpg
%   |--class2 ...

p = inputParser;
addOptional(p, 'imgsListFpath', 0);
parse(p, varargin{:});

addpath(genpath('../src'));
bow_config;

%% Get imgs list
if p.Results.imgsListFpath == 0
    imgPaths = getImgFilesList(imgsDir);
else
    fid = fopen(p.Results.imgsListFpath, 'r');
    imgPaths = textscan(fid, '%s', 'Delimiter', '\n');
    imgPaths = imgPaths{:};
    fclose(fid);
end
fullpaths = cellfun2(@(x) fullfile(imgsDir, x), imgPaths);

%% Evaluate
sumPrecision = zeros(1, 20);
sumAP = 0;
for i = 1 : numel(fullpaths)
    imgPathFull = fullpaths{i};
    fprintf('Searching for %s\n', imgPaths{i});
    [class, imgName] = getImgClassFromPath(imgPaths{i});
    curOutputDir = fullfile(outputDir, class, imgName);
    mkdir(curOutputDir);
    
    I = imread(imgPathFull);
    img_class = getImgClassFromPath(imgPathFull);
    config.geomRerank = 10;
    config.topn = 2658; % all images
    config.saveMatchesImageDir = fullfile(pwd, curOutputDir);
    [matching_imgs, ~] = bow_imageSearch(I, model, iindex, config);
    
    % write out to file
    fid = fopen(fullfile(curOutputDir, 'top.txt'), 'w');
    for img = matching_imgs
        fprintf(fid, '%s\n', img{:});
    end
    fclose(fid);
    
    matching_classes = cellfun2(@(x) getImgClassFromPath(x), ...
        matching_imgs);
    hit_idx = find(strcmp(matching_classes, img_class));
    sumPrecision(1) = sumPrecision(1) + ...
        sum(hit_idx <= 1) / 1;
    sumPrecision(3) = sumPrecision(3) + ...
        sum(hit_idx <= 3) / 3;
    sumPrecision(5) = sumPrecision(5) + ...
        sum(hit_idx <= 5) / 5;
    sumPrecision(10) = sumPrecision(10) + ...
        sum(hit_idx <= 10) / 10;
    sumPrecision(20) = sumPrecision(20) + ...
        sum(hit_idx <= 20) / 20;
    AP = computeAP(hit_idx);
    fprintf('AP : %f\n', AP);
    sumAP = sumAP + AP;
end
meanPrecision = sumPrecision / numel(imgPaths);
fprintf('Mean Precision: @1: %f, @3: %f. @5: %f. @10: %f, @20: %f\n', ...
    meanPrecision(1), meanPrecision(3), meanPrecision(5), ...
    meanPrecision(10), meanPrecision(20));
mAP = sumAP / numel(imgPaths);
fprintf('mAP: %f\n', mAP);

function [class, imgName] = getImgClassFromPath(path)
[path, imgName, ~] = fileparts(path);
[~, class, ~] = fileparts(path);

function AP = computeAP(match_idx)
% Given list of indexes where a match occurs, compute the average precision
match_num = 1 : numel(match_idx);
Ps = match_num ./ match_idx;
AP = mean(Ps);