function model = bow_computeVocab(imgsDir, params, varargin)
% Read all images recursively in imgsDir and learn a vocabulary by AKM
% Optional param
% 'imgsListFpath', 'path/to/file.txt' :- File contains a newline separated
% list of image paths (relative to imgsDir) of the image files to 
% build index upon. Typically used to set the train set.

bow_config;

p = inputParser;
addOptional(p, 'imgsListFpath', 0);
parse(p, varargin{:});

%% Get imgs list
if p.Results.imgsListFpath == 0
    frpaths = getImgFilesList(imgsDir);
else
    fid = fopen(p.Results.imgsListFpath, 'r');
    frpaths = textscan(fid, '%s', 'Delimiter', '\n');
    frpaths = frpaths{:};
    fclose(fid);
end
fullpaths = cellfun2(@(x) fullfile(imgsDir, x), frpaths);

%% Read images and create set of SIFTs
descs = []; % 128 x n dim matrix, for n SIFTs
for i = 1 : size(fullpaths, 1)
    % best to read one by one, in case of large number of images
    I = single(rgb2gray(imread(fullpaths{i})));
    [~, d] = vl_sift(I);
    descs = [descs, d]; % not pre-alloc as don't know how many sifts will be found
                        % moreover, this is a one time job
end
fprintf('Found %d descriptors. Clustering now...\n', size(descs, 2));

%% K Means cluster the SIFTs, and create a model
model.vocabSize = params.numWords;
model.vocab = vl_kmeans(double(descs), ...
                        min(size(descs, 2), params.numWords), 'verbose', ...
                        'algorithm', 'ANN');
model.kdtree = vl_kdtreebuild(model.vocab);
