function model = bow_computeVocab(imgsDir, params)
% Read all images recursively in imgsDir and learn a vocabulary by AKM

bow_config;

%% Get the image files
img_file_endings = '((.jpg)|(.png)|(.gif)|(.JPEG)|(.JPG)|(.jpeg)|(.bmp))$';
frpaths = getAllFiles(imgsDir); % recursive search img files relative to imgsDir
imgFilesOrNot = regexp(frpaths, img_file_endings);
frpaths(cellfun(@isempty, imgFilesOrNot)) = []; % keep only image files
fullpaths = cellfun2(@(x) fullfile(imgsDir, x), frpaths);

%% Read images and create set of SIFTs
descs = []; % 128 x n dim matrix, for n SIFTs
for i = 1 : size(fullpaths, 1)
    % best to read one by one, in case of large number of images
    I = single(rgb2gray(imread(fullpaths{i})));
    [~, d] = vl_sift(I);
    descs = [descs, d];
end

%% K Means cluster the SIFTs, and create a model
model.vocab = vl_kmeans(double(descs), ...
                        min(size(descs, 2), params.numWords), 'verbose', ...
                        'algorithm', 'ANN');
model.kdtree = vl_kdtreebuild(model.vocab);
