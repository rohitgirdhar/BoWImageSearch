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

fprintf('Tf-Idf...'); tic;
vw2imgs2count = iindex.vw2imgsList(d);
vw2imgsCount = cellfun2(@(x) x.Count, vw2imgs2count);
idfs = log10(double(iindex.numImgs ./ cell2mat(vw2imgsCount)));
vw2imgs2count_array = ...
    cellfun2(@(x) container2sparse(x, iindex.numImgs), vw2imgs2count);
vw2imgs_tf = ...
    cellfun2(@(x) x ./ iindex.totalDescriptors', vw2imgs2count_array);
vw2imgs_tfidf = ...
    cellfun(@(x, y) x .* y, vw2imgs_tf, num2cell(idfs), 'UniformOutput', false);
scores = sum(cell2mat(vw2imgs_tfidf'), 1);
time_elap = toc; fprintf('Done in %0.2fs\n', time_elap);

[scores, imgIDs] = sort(scores, 'descend');
scores = scores(:, 1 : config.topn);
imgIDs = imgIDs(:, 1 : config.topn);
imgPaths = arrayfun(@(x) iindex.imgPaths(x), imgIDs);
if isfield(config, 'geomRerank') && config.geomRerank > 0
    all_idfs = log10(double(iindex.numImgs ./ ...
        cell2mat(cellfun2(@(x) x.Count, iindex.vw2imgsList))));
    [imgPaths, scores, all_matches] = ...
        bow_geomRerank(imgPaths, iindex.dirname, model, all_idfs, ...
            I, f, d, config);
end

function [imgPaths, scores, all_matches] = ...
        bow_geomRerank(imgPaths, dirname, model, idfs, I, f, d, config)
% rerranks the rank list (only topn of it) based on number of geometrically
% consistent inliers
% @param imgPaths : full paths of images
% @param idfs: IDF for each visual word
% @param I, f, d of the query image
% @param config.geomRerank = n (number of top images to rerank)
% @param config.saveMatchesImageDir = directory in which to save the
% matches images. Unset if not want to generate such images
% @returns imgs list, number of inliers and a cell array with matches
% objects, indexed by the img list

topm = config.geomRerank;

topm_imgPaths = imgPaths(1 : topm);
inliersIDF = zeros(1, topm);
fullpaths = cellfun2(@(x) fullfile(dirname, x), topm_imgPaths);
fprintf('Geometric Reranking...'); tic;
all_matches = cell(1, numel(fullpaths));
parfor i = 1 : numel(fullpaths)
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
    inliersIDF(1, i) = sum(idfs(d2(matches(2, :))));
end
time_elap = toc; fprintf('Done in %0.2fs\n', time_elap);
[inliersIDF, indexes] = sort(inliersIDF, 'descend');
imgPaths = imgPaths([indexes, topm + 1 : end]);
all_matches = all_matches(indexes);
scores = inliersIDF;
