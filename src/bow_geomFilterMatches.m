function matches = bow_geomFilterMatches(f1, f2, matches)
% @param f1 : feature detections on image 1 (as given by vl_sift)
% @param f2 : feature detections on image 2
% @param matches : matches in f1 and f2, as computed by vl_ubcmatch or
% bow_computeMatchesQuantized
% @return : geometrically conistent matches, in same format as @param 
% matches (a subset of it, actually)

matchedPoints1 = f1(1:2, matches(1, :))';
matchedPoints2 = f2(1:2, matches(2, :))';
if (numel(matchedPoints1) < 10 || numel(matchedPoints2) < 10 || ...
        numel(matchedPoints1) ~= numel(matchedPoints2))
    matches = [];
    return;
end
try
    [~, inliersIndex] = estimateFundamentalMatrix(matchedPoints1, ...
                        matchedPoints2, 'Method', 'RANSAC');
catch
    inliersIndex = [];
end
matches = matches(:, inliersIndex == 1);
