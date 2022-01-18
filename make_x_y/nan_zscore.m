function z = nan_zscore(X)

z = (X - nanmean(X))/nanstd(X);
end