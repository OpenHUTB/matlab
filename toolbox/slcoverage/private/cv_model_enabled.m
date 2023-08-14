function modelcovId=cv_model_enabled(model)




    model=bdroot(model);

    [coveng,modelcovId]=cvi.TopModelCov.getInstance(model);
    if isempty(coveng)||modelcovId==0
        modelcovId=0;
        return;
    end
    activeRoot=cv('get',modelcovId,'.activeRoot');
    if activeRoot==0
        modelcovId=0;
    end
end

