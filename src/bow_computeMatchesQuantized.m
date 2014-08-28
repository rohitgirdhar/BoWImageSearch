function matches = bow_computeMatchesQuantized(d1, d2)
% Compute matches between the quantized descriptors d1 and d2
% matches is 2 x m, each col contains descriptor from image 1 to 2
% (same output format as vl_ubcmatch)

%% Hash one of descriptors
c = containers.Map('KeyType', 'int64', 'ValueType', 'any');
for i = 1 : numel(d1)
    if c.isKey(d1(i))
        c(d1(i)) = [c(d1(i)), i];
    else
        c(d1(i)) = i;
    end
end

%% Set matches
matches_count = 1;
for i = 1 : size(d2, 2)
    if c.isKey(d2(i))
        matches_list = c(d2(i));
        for j = 1 : numel(matches_list)
            matches(1, matches_count) = matches_list(j);
            matches(2, matches_count) = i;
            matches_count = matches_count + 1;
        end
    end
end
