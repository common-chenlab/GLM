function X = get_NMF(X, Y, idx, rank)

Y(idx,:) = [];
[W,H] = nnmf(Y,rank);
X = [X; H];
 
