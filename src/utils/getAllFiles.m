function fileList = getAllFiles(dirName, prependDir)
% Recursive file listing (ls -r)
% @dirName name of directory to list files
% @prependDir is the path to be prepended to files in this dir. initially 
% call with '.' 
% @returns a cell array of all files paths *relative* to the dirName
% 
% From http://stackoverflow.com/a/2654459/1492614
% Modified by Rohit Girdhar

if nargin < 2
    prependDir = '.';
end

dirData = dir(dirName);      %# Get the data for the current directory
dirIndex = [dirData.isdir];  %# Find the index for directories
fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files

if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(prependDir,x),...  %# Prepend path to files
        fileList,'UniformOutput',false);
end
subDirs = {dirData(dirIndex).name};  %# Get a list of the subdirectories
validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
%#   that are not '.' or '..'
for iDir = find(validIndex)                  %# Loop over valid subdirectories
    nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
    fileList = [fileList; getAllFiles(nextDir, ...
                    fullfile(prependDir, subDirs{iDir}))];  %# Recursively call getAllFiles
end

end
