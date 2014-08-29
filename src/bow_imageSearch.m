function res = bow_imageSearch(I, model, iindex, config)
% Returns the top matches to I from the inverted index 'iindex' computed
% using bow_buildInvIndex
% Uses TF-IDF based scoring to rank
% config has following flags
% config.geomRerank = 1 => do geometric reranking for topn results
% config.topn = n => output top 'n' results (defaults to 10)
% @return : a cell array with 2 elements: {1} is the list of image paths in
% ranked order, {2} is the corresponding scores.

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
if isfield(config, 'geomRerank') && config.geomRerank
    res = bow_geomRerank(imgPaths, iindex.dirname, model, f, d);
else
    res = {imgPaths, scores};
end

function res = bow_geomRerank(imgPaths, dirname, model, f, d)
% rerranks the rank list (only topn of it) based on number of geometrically
% consistent inliers
% @param imgPaths : full paths of images
% @param f, d of the query image
% returns cell array with following elements: {1} = imgs list, {2} = number
% of inliers

numInliers = zeros(1, numel(imgPaths));
fullpaths = cellfun2(@(x) fullfile(dirname, x), imgPaths);
textprogressbar('Geometric Reranking ');
for i = 1 : numel(fullpaths)
    imgPath = fullpaths{i};
    I = imread(imgPath);
    [f2, d2] = bow_computeImageRep(I, model);
    matches = bow_computeMatchesQuantized(d, d2);
    matches = bow_geomFilterMatches(f, f2, matches);
    numInliers(1, i) = size(matches, 2);
    textprogressbar(i * 100.0 / numel(fullpaths));
end
textprogressbar(' Done');
[numInliers, indexes] = sort(numInliers, 'descend');
res = {imgPaths(indexes), numInliers};
