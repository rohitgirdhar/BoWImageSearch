function frpaths = getImgFilesList(dirname)
% Returns a list of image files in the dirname, searched recurisively. The
% names are relative paths w.r.t dirname directory.

img_file_endings = '((.jpg)|(.png)|(.gif)|(.JPEG)|(.JPG)|(.jpeg)|(.bmp))$';
frpaths = getAllFiles(dirname); % recursive search img files relative to dirname
imgFilesOrNot = regexp(frpaths, img_file_endings);
frpaths(cellfun(@isempty, imgFilesOrNot)) = []; % keep only image files
