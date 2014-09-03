function [imgPaths, scores, all_matches] = ...
    bow_imageSearch(I, model, iindex, config)
% Returns the top matches to I from the inverted index 'iindex' computed
% using bow_buildInvIndex
% Uses TF-IDF based scoring to rank
% config has following flags
% config.geomRerank = m => do geometric reranking for top m results
% config.topn = n => output top 'n' results (defaults to 10)
% config.saveMatchesImageDir = 'dir/' => store the matches images in the
% dir
% @return : imgPaths is the list of image paths in ranked order
% @return scores : is the corresponding scores - tf-idf in general, or
% number of inliers (of top m images) if doing geometric reranking
% @return all_matches : Only returned if the config.geomRerank = 1. A
% cell array with {i} element = matches of I with the i^th image

bow_config;

if ~isfield(config, 'topn')
    config.topn = 10;
end

[f, d] = bow_computeImageRep(I, model);
scores = zeros(1, iindex.numImgs);
textprogressbar('Tf-Idf based search ');
for i = 1 : numel(d)
    vw = d(i);
    imgs2count = iindex.vw2imgsList{vw};
    imgsList = imgs2count.keys;
    idf = log10(double(iindex.numImgs / (numel(imgsList) * 1.0)));
    for j = 1 : numel(imgsList)
        imgID = imgsList{j};
        tf = double(imgs2count(imgID)) / iindex.totalDescriptors(imgID);
        scores(1, imgID) = scores(1, imgID) + tf * idf;
    end
    textprogressbar(i * 100.0 / numel(d));
end
textprogressbar(' Done');
[scores, imgIDs] = sort(scores, 'descend');
scores = scores(:, 1 : config.topn);
imgIDs = imgIDs(:, 1 : config.topn);
imgPaths = arrayfun(@(x) iindex.imgPaths(x), imgIDs);
if isfield(config, 'geomRerank') && config.geomRerank > 0
    [imgPaths, scores, all_matches] = ...
        bow_geomRerank(imgPaths, iindex.dirname, model, I, f, d, config);
end

function [imgPaths, scores, all_matches] = ...
        bow_geomRerank(imgPaths, dirname, model, I, f, d, config)
% rerranks the rank list (only topn of it) based on number of geometrically
% consistent inliers
% @param imgPaths : full paths of images
% @param f, d of the query image
% @param config.geomRerank = n (number of top images to rerank)
% @param config.saveMatchesImageDir = directory in which to save the
% matches images. Unset if not want to generate such images
% @returns imgs list, number of inliers and a cell array with matches
% objects, indexed by the img list

topm = config.geomRerank;

topm_imgPaths = imgPaths(1 : topm);
numInliers = zeros(1, topm);
fullpaths = cellfun2(@(x) fullfile(dirname, x), topm_imgPaths);
textprogressbar('Geometric Reranking ');
all_matches = cell(1, numel(fullpaths));
for i = 1 : numel(fullpaths)
    imgPath = fullpaths{i};
    I2 = imread(imgPath);
    [f2, d2] = bow_computeImageRep(I2, model);
    matches = bow_computeMatchesQuantized(d, d2);
    matches = bow_geomFilterMatches(f, f2, matches);
    if isfield(config, 'saveMatchesImageDir')
        [~, imgName, ~] = fileparts(imgPaths{i});
        bow_visualizeMatching(I, I2, f, f2, matches, 'save', ...
            fullfile(config.saveMatchesImageDir, ...
                [imgName, '_matches.jpg']));
    end
    all_matches{i} = matches;
    numInliers(1, i) = size(matches, 2);
    textprogressbar(i * 100.0 / numel(fullpaths));
end
textprogressbar(' Done');
[numInliers, indexes] = sort(numInliers, 'descend');
imgPaths = imgPaths([indexes, topm + 1 : end]);
all_matches = all_matches(indexes);
scores = numInliers;
