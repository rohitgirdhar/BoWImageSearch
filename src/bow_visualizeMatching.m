function bow_visualizeMatching(I1, I2, f1, f2, matches, varargin)
% @param I1, I2 are the images
% @param f1, f2 are feature keypoints, as detected by vl_sift
% matches are between f1 and f2, as detected by vl_ubcmatch or
% bow_computeMatchesQuantized
% @param (optional): 'save', 'filename' to instead save the matches to a
% file and not show on the screen

bow_config;

p = inputParser;
addOptional(p, 'save', 0);
parse(p, varargin{:});

I = appendimages(I1, I2);
if p.Results.save == 0
    figure('Position', [100 100 size(I, 2) size(I, 1)]);
else
    fig = figure('visible', 'off');
end
imagesc(I);
hold on;
cols1 = size(I1, 2);
ColorSet = lines(size(matches, 2)); % Lines colorset from COLORMAPS
for i = 1 : size(matches, 2)
    X = [f1(1, matches(1, i)); f2(1, matches(2, i)) + cols1];
    Y = [f1(2, matches(1, i)); f2(2, matches(2, i))];
    line(X, Y, 'Color', ColorSet(i, :), 'LineWidth', 2, 'Marker', '*');
end
hold off;

if p.Results.save ~= 0
    saveas(fig, p.Results.save);
end
