function [out, caughterror] = run_partial_model(out, X, yt, numLambda, nCV, taskfactor)

out.dev2 = out.stats2.Deviance(out.stats2.IndexMinDeviance);

caughterror = 0;
for i = 1:size(taskfactor,1)    %partial model
    temp = X;
    temp_exclude = taskfactor{i,2};    
    temp(:,temp_exclude) = [];
    if caughterror == 0
        try
            [wreg1{i}, stats1{i}] = lassoglm_test(temp, yt, ...
                'poisson', 'numlambda', numLambda, 'cv', nCV, 'MaxIter',2e3);
            dof = length(temp_exclude);
            dev1 = stats1{i}.Deviance(stats1{i}.IndexMinDeviance); %partial model
            
            storedev1(i) = dev1;
            dAIC(i) = 2*(dof) + dev1 - out.dev2;
            pval(i) = 1 - chi2cdf(dev1 - out.dev2,  dof);            
        catch
            disp('partial model caught error, max iter reached');
            caughterror = 1;
        end
    end
end

if caughterror == 0
    out.wreg1 = wreg1;
    out.stats1 = stats1;
    out.dev2 = out.stats2.Deviance(out.stats2.IndexMinDeviance);
    out.dev1 = storedev1;
    out.dAIC = dAIC;
    out.pval = pval;
else
    out.wreg1 = [];
    out.stats1 = [];
    out.dev2 = [];
    out.dev1 = [];
    out.dAIC = [];
    out.pval = [];
end
 

