function runTests(imgsDir, model, iindex, varargin)
% Run imgSearch for all image files in 'imgsDir' (recursively searched).
% The class of an image is given by the folder it is in.
% Optional Parameters:
% 'imgsListFpath', 'path/to/file.txt' :- File contains a newline separated
% list of image paths (relative to imgsDir) of the image files to 
% build index upon. Typically used to set the train set.

p = inputParser;
addOptional(p, 'imgsListFpath', 0);
parse(p, varargin{:});

bow_config;
addpath(genpath('../src'));

%% Get imgs list
if p.Results.imgsListFpath == 0
    imgPaths = getImgFilesList(imgsDir);
else
    fid = fopen(p.Results.imgsListFpath, 'r');
    imgPaths = textscan(fid, '%s', 'Delimiter', '\n');
    imgPaths = imgPaths{:};
    fclose(fid);
end
fullpaths = cellfun2(@(x) fullfile(imgsDir, x), iindex.imgPaths);

%% Evaluate
sumPrecision = 0;
for imgPath = fullpaths'
    I = imread(imgPath{:});
    img_class = getImgClassFromPath(imgPath{:});
    config.geomRerank = 0;
    [matching_imgs, ~] = bow_imageSearch(I, model, iindex, config);
    matching_classes = cellfun2(@(x) getImgClassFromPath(x), ...
        matching_imgs);
    hit_idx = find(strcmp(matching_classes, img_class));
    Precision = numel(hit_idx) / numel(matching_imgs);
    sumPrecision = sumPrecision + Precision;
end
avgPrecision = sumPrecision / numel(imgPaths);

function class = getImgClassFromPath(path)
[tokens, ~] = regexp(path, ...
    '(\/)?([\w-]+)/[\w-]+\.(jpg|JPG|gif|GIF|png|PNG|jpeg|JPEG)', ...
    'tokens', 'match');
class = tokens{1}{2};
