function matches = bow_computeMatchesQuantized(d1, d2)
% Compute matches between the quantized descriptors d1 and d2
% matches is m x 2, each row contains descriptor from image 1 to 2

%% Hash one of descriptors
%%% TODO : Same key can be at multiple locations. Handle that.
keyset = d1;
valueset = 1 : size(d1, 2);
c = containers.Map(keyset, valueset);

%% Set matches
matches = zeros(size(d1, 2), 2);
matches_count = 1;
for i = 1 : size(d2, 2)
    if c.isKey(d2(1, i))
        matches(matches_count, 1) = c(d2(1, i));
        matches(matches_count, 2) = i;
        matches_count = matches_count + 1;
    end
end
matches = matches(1:matches_count - 1, :);
