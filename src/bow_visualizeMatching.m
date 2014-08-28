function bow_visualizeMatching(I1, I2, f1, f2, matches)

bow_config;

I = appendimages(I1, I2);
figure('Position', [300 300 size(I, 2) size(I, 1)]);
imagesc(I);
hold on;
cols1 = size(I1, 2);
for i = 1 : size(matches, 1)
    X = [f1(2, matches(i, 1)); f2(2, matches(i, 2)) + cols1];
    Y = [f1(1, matches(i, 1)); f2(1, matches(i, 2))];
    line(X, Y, 'Color', 'c');
end
hold off;

