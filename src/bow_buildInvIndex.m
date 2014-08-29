function iindex = bow_buildInvIndex(imgsDir, model)
% Build an inverted index for all image files in 'imgsDir' (recursively
% searched) given the visual word quantization 'model'

bow_config;

%% Get imgs list
iindex.dirname = fullfile(pwd, imgsDir);
iindex.imgPaths = getImgFilesList(imgsDir);
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
    textprogressbar(i * 100 / iindex.numImgs);
end
textprogressbar(' Done');
