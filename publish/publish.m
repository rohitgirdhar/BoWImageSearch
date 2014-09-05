addpath('../../../htmlWriter');

params.sortableTable = true;
params.numPerPage = 10;
params.pageLinkBreaks = 3;



h = createPagedHtml('bow_matches/bow_matches.html',params); %overwrites existing files by default
[h,t] = createTable(h);

row{1}='<b>query<b>';
for i = 1 : 10
    row{i + 1} = sprintf('<b>match %d</b>', i);
end

[h,t] = addHeader(h,t,row);

res_folder = 'bow_matches/res/';
imgs_folder = 'http://www.andrew.cmu.edu/user/rgirdhar/projects/001_Matching/hussain_corpus/';
test_list_fpath = '../eval/TestSet.txt';
fid = fopen(test_list_fpath);
test_files = textscan(fid, '%s\n');
test_files = sort(test_files{1});
fclose(fid);

for i=1:numel(test_files)
    row = {};
    row{1}=makeImageLink(fullfile(imgs_folder, test_files{i}), 200);
    [img_path, img_name, ~] = fileparts(test_files{i});
    [~, img_class, ~] = fileparts(img_path);
    [top_fid, err] = fopen(strtrim(fullfile(res_folder, img_path, img_name, 'top.txt')));
    if (top_fid == -1)
        continue;
    end
    top_list = textscan(top_fid, '%s\n');
    fclose(top_fid);
    top_list = top_list{1};
    for ii = 1 : 10
        [match_path, match_fname, ~] = fileparts(top_list{ii});
        [~, match_class, ~] = fileparts(match_path);
        if strcmp(match_class, img_class)
            params.check = 1;
        else
            params.check = 0;
        end
        params.hover_width = 500;
        row{ii + 1}=makeImageLinkHover(fullfile(imgs_folder, top_list{ii}), ...
            fullfile('..', res_folder, img_path, img_name, [match_fname, '_matches.jpg']), ...
            200, params);
    end
    
    [h,t] = addRow(h,t,row);
end
[h,t] = writeTable(h,t);
h = endHtml(h);
