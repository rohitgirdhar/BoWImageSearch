function iindex = bow_buildInvIndex(imgsDir, model, varargin)
% Build an inverted index for all image files in 'imgsDir' (recursively
% searched) given the visual word quantization 'model'
% model can be path to mat file too
% Optional Parameters:
% 'imgsListFpath', 'path/to/file.txt' :- File contains a newline separated
% list of image paths (relative to imgsDir) of the image files to 
% build index upon. Typically used to set the train set.

p = inputParser;
addOptional(p, 'imgsListFpath', 0);
parse(p, varargin{:});

bow_config;

if isa(model, 'char')
    model_fpath = model;
    load(model_fpath, 'model');
end

%% Get imgs list
iindex.dirname = fullfile(pwd, imgsDir);
if p.Results.imgsListFpath == 0
    iindex.imgPaths = getImgFilesList(imgsDir);
else
    fid = fopen(p.Results.imgsListFpath, 'r');
    iindex.imgPaths = textscan(fid, '%s', 'Delimiter', '\n');
    iindex.imgPaths = iindex.imgPaths{:};
    fclose(fid);
end
iindex.numImgs = numel(iindex.imgPaths);
% Add these paths to a hash map as well
iindex.imgPath2id = containers.Map(iindex.imgPaths, ...
                        1 : iindex.numImgs);
fullpaths = cellfun2(@(x) fullfile(imgsDir, x), iindex.imgPaths);

%% create inverted index
iindex.totalDescriptors = zeros(iindex.numImgs, 1); % will store the total # of words in each image
% Create a cell array of vocabSize containers.Map (Assuming vocab ids are
% 1..n). Each element stores <imgID : times that VW appears in that image>
% Have to call it multiple times to initialize in a loop.. using 
% `repmat` or `deal` simply makes multiple references to same object and 
% that doesn't work
for i = 1 : model.vocabSize
    iindex.vw2imgsList{i} = ...
        containers.Map('KeyType', 'int64', 'ValueType', 'int64');
end

textprogressbar('Computing inv index over all images: ');
for i = 1 : iindex.numImgs
    try
        I = imread(fullpaths{i});
        [~, d] = bow_computeImageRep(I, model);
        iindex.totalDescriptors(i) = numel(d);
        for j = 1 : numel(d)
        imgsList = iindex.vw2imgsList{d(j)};
            if imgsList.isKey(i)
                imgsList(i) = imgsList(i) + 1;
            else
                imgsList(i) = 1;
            end
            iindex.vw2imgsList{d(j)} = imgsList;
        end
    catch
        continue;
    end
    textprogressbar(i * 100 / iindex.numImgs);
end
textprogressbar(' Done');
