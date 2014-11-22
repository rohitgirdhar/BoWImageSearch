function iindex = bow_buildInvIndex(imgsDir, model, resDir, varargin)
% Build an inverted index for all image files in 'imgsDir' (recursively
% searched) given the visual word quantization 'model'
% model can be path to mat file too
% Optional Parameters:
% 'imgsListFpath', 'path/to/file.txt' :- File contains a newline separated
% 'resDir', 'path/to/results'
% list of image paths (relative to imgsDir) of the image files to 
% build index upon. Typically used to set the train set.

p = inputParser;
addOptional(p, 'imgsListFpath', 0);
addOptional(p, 'SIFTPeakThresh', 3);
parse(p, varargin{:});
indexfpath = fullfile(resDir, 'iindex.mat');
if exist(indexfpath, 'file')
    fprintf(2, 'The iindex file already exists. Remove it first\n');
    return;
end
index = matfile(indexfpath, 'Writable', true);

bow_config;

if isa(model, 'char')
    model_fpath = model;
    load(model_fpath, 'model');
end

%% Get imgs list
index.dirname = fullfile(pwd, imgsDir);
if p.Results.imgsListFpath == 0
    index.imgPaths = getImgFilesList(imgsDir);
else
    fid = fopen(p.Results.imgsListFpath, 'r');
    index.imgPaths = textscan(fid, '%s', 'Delimiter', '\n');
    index.imgPaths = iindex.imgPaths{:};
    fclose(fid);
end
index.numImgs = numel(index.imgPaths);
% Add these paths to a hash map as well
index.imgPath2id = containers.Map(index.imgPaths, ...
                        1 : index.numImgs);
fullpaths = cellfun2(@(x) fullfile(imgsDir, x), index.imgPaths);

%% create inverted index
index.totalDescriptors = zeros(index.numImgs, 1); % will store the total # of words in each image
% Create a cell array of vocabSize containers.Map (Assuming vocab ids are
% 1..n). Each element stores <imgID : times that VW appears in that image>
% Have to call it multiple times to initialize in a loop.. using 
% `repmat` or `deal` simply makes multiple references to same object and 
% that doesn't work
for i = 1 : model.vocabSize
    vw2imgsList{i} = containers.Map('KeyType', 'int64', 'ValueType', 'int64');
end

for i = 1 : index.numImgs
    try
        I = imread(fullpaths{i});
        [~, d] = bow_computeImageRep(I, model, 'PeakThresh', p.Results.SIFTPeakThresh);
        index.totalDescriptors(i, 1) = numel(d);
        for j = 1 : numel(d)
            imgsList = vw2imgsList{d(j)};
            if imgsList.isKey(i)
                imgsList(i) = imgsList(i) + 1;
            else
                imgsList(i) = 1;
            end
            vw2imgsList{d(j)} = imgsList;
        end
    catch e
        disp(getReport(e));
        continue;
    end
    fprintf(2, 'nFeat = %d. Indexed (%d / %d)\n', numel(d), i, index.numImgs);
    if mod(i, 1000) == 0
        index.vw2imgsList = vw2imgsList;
    end
end
index.vw2imgsList = vw2imgsList;


if 0
    resDir = p.Results.resDir;
    fprintf('Saving to %s after %d files\n', fullfile(resDir, 'iindex.mat'), i);
    save(fullfile(resDir, 'iindex.mat'), 'iindex', '-v7.3');
end
