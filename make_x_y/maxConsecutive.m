function [maxCons] = maxConsecutive(x)
% Finds max consecutive elements in a vector that are >0
y = find(~(x>0)); % Indices of elements >0
diffs = diff([0 y numel(x) + 1])-1; % Distance between zero elements
maxCons = max(diffs);
end