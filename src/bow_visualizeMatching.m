function bow_visualizeMatching(I1, I2, f1, f2, matches)
% I1, I2 are the images
% f1, f2 are feature keypoints, as detected by vl_sift
% matches are between f1 and f2, as detected by vl_ubcmatch or
% bow_computeMatchesQuantized

bow_config;

I = appendimages(I1, I2);
figure('Position', [100 100 size(I, 2) size(I, 1)]);
imagesc(I);
hold on;
cols1 = size(I1, 2);
for i = 1 : size(matches, 2)
    X = [f1(1, matches(1, i)); f2(1, matches(2, i)) + cols1];
    Y = [f1(2, matches(1, i)); f2(2, matches(2, i))];
    line(X, Y, 'Color', 'c');
end
hold off;
