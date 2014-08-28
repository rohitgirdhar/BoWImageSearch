function bow_visualizeMatching(I1, I2, f1, f2, matches)

bow_config;

I = appendimages(I1, I2);
figure('Position', [300 300 size(I, 2) size(I, 1)]);
imagesc(I);
hold on;
cols1 = size(I1, 2);
for i = 1 : size(matches, 2)
    X = [f1(2, matches(1, i)); f2(2, matches(2, i)) + cols1];
    Y = [f1(1, matches(1, i)); f2(1, matches(2, i))];
    line(X, Y, 'Color', 'c');
end
hold off;
