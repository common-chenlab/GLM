function out = run_full_model(ROI_name, NrnNum, NrnArea, numLambda, nCV, X, yt)

%%%%%%%%%%%%%%%%%%%%%%%

[out.wreg2, out.stats2] = lassoglm_test(X, yt, ...
    'poisson', 'numlambda', numLambda, 'cv', nCV, 'MaxIter',2e3);   % run GLM

out.Area = NrnArea;
out.NrnNum = NrnNum;
out.cellid = ROI_name;
out.b0 = out.stats2.Intercept(out.stats2.IndexMinDeviance);
out.w = out.wreg2(:,out.stats2.IndexMinDeviance);
out.lam = exp(out.b0 + X*out.w);
out.LAM = [];
out.spk_neuron = yt;
out.X = X;
end
