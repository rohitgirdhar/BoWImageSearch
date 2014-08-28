function matches = bow_computeMatchesQuantized(d1, d2)
% Compute matches between the quantized descriptors d1 and d2
% matches is 2 x m, each col contains descriptor from image 1 to 2
% (same output format as vl_ubcmatch)

%% Hash one of descriptors
%%% TODO : Same key can be at multiple locations. Handle that.
keyset = d1;
valueset = 1 : size(d1, 2);
c = containers.Map(keyset, valueset);

%% Set matches
matches = zeros(2, size(d1, 2));
matches_count = 1;
for i = 1 : size(d2, 2)
    if c.isKey(d2(1, i))
        matches(1, matches_count) = c(d2(1, i));
        matches(2, matches_count) = i;
        matches_count = matches_count + 1;
    end
end
matches = matches(:, 1:matches_count - 1);
