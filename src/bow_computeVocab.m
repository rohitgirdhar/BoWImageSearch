function model = bow_computeVocab(imgsDir, params, varargin)
% Read all images recursively in imgsDir and learn a vocabulary by AKM
% Optional param
% 'imgsListFpath', 'path/to/file.txt' :- File contains a newline separated
% list of image paths (relative to imgsDir) of the image files to 
% build index upon. Typically used to set the train set.
% 'avgSiftsPerImg', <count> :- (default: 1000). Used to pre-allocate the
% storage array. Give an upper bound estimate. But take care that num_imgs
% * avg_sift memory will be allocated.. so it may crash if the machine 
% can't handle it.
% params.numWords = size of voacbulary to learn
% params.maxImgsForVocab = max number of images to use for computing it

bow_config;

p = inputParser;
addOptional(p, 'imgsListFpath', 0);
addOptional(p, 'avgSiftsPerImg', 400);
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

if ~isfield(params, 'maxImgsForVocab')
    params.maxImgsForVocab = 10000;
end
if numel(fullpaths) > params.maxImgsForVocab
    fprintf('Too many images (%d), randomly sampling %d of those\n', ...
            numel(fullpaths), params.maxImgsForVocab);
    fullpaths = fullpaths(randsample(numel(fullpaths), ...
            params.maxImgsForVocab));
end

%% Read images and create set of SIFTs
est_n = p.Results.avgSiftsPerImg * numel(fullpaths); % expected number of sifts
descs = zeros(128, est_n, 'uint8'); % 128 x n dim matrix, for n SIFTs
found_sifts = 0;
textprogressbar('Reading SIFTs ');
for i = 1 : numel(fullpaths)
    % best to read one by one, in case of large number of images
    try
        I = single(rgb2gray(imread(fullpaths{i})));
    catch
        fprintf(2, 'Unable to read %s\n', fullpaths{i});
        continue;
    end
    [~, d] = vl_sift(I);
    if found_sifts + size(d, 2) <= est_n
        descs(:, found_sifts + 1 : found_sifts + size(d, 2)) = d;
    else
        descs = descs(:, 1 : found_sifts);
        descs = [descs, d];
    end
    found_sifts = found_sifts + size(d, 2);
    textprogressbar(i * 100.0 / numel(fullpaths));
end
textprogressbar(' Done');
descs = descs(:, 1 : found_sifts);
fprintf('Found %d descriptors. Clustering now...\n', size(descs, 2));

%% K Means cluster the SIFTs, and create a model
model.vocabSize = params.numWords;
model.vocab = vl_kmeans(double(descs), ...
                        min(size(descs, 2), params.numWords), 'verbose', ...
                        'algorithm', 'ANN');
model.kdtree = vl_kdtreebuild(model.vocab);
