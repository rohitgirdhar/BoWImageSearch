function res = bow_imageSearch(I, model, iindex, config)
% Returns the top matches to I from the inverted index 'iindex' computed
% using bow_buildInvIndex
% Uses TF-IDF based scoring to rank
% config has following flags
% config.geomRerank = n => do geometric reranking for top n results (not
% implemented yet!)
% config.topn = n => output top 'n' results (defaults to 10)
% @return : a cell array with 2 elements: {1} is the list of image paths in
% ranked order, {2} is the corresponding scores.

bow_config;

if ~isfield(config, 'topn')
    config.topn = 10;
end

[~, d] = bow_computeImageRep(I, model);
scores = zeros(1, iindex.numImgs);
for i = 1 : numel(d)
    vw = d(i);
    imgs2count = iindex.vw2imgsList(vw);
    imgsList = imgs2count.keys;
    idf = log10(double(iindex.numImgs / (numel(imgsList) * 1.0)));
    for j = 1 : numel(imgsList)
        imgID = imgsList{j};
        tf = double(imgs2count(imgID)) / iindex.totalDescriptors(imgID);
        scores(1, imgID) = scores(1, imgID) + tf * idf;
    end
end
[scores, imgIDs] = sort(scores, 'descend');
scores = scores(:, 1 : config.topn);
imgIDs = imgIDs(:, 1 : config.topn);
imgPaths = arrayfun(@(x) iindex.imgPaths(x), imgIDs);
res = {imgPaths', scores'};
