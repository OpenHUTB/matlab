function cvexit







    cv.coder.cvdatamgr.instance().removeAll();

    modelcov_ids=cv('get','all','modelcov.id');
    for modelcovId=modelcov_ids(:)'
        modelname=SlCov.CoverageAPI.getModelcovName(modelcovId);
        if~isempty(find_system('SearchDepth',0,'name',modelname))
            cvmodelclean(modelname);
        end
        cv('ClearModel',modelcovId);
        allTest=cv('find','all','.isa',cv('get','default','testdata.isa'));
        for idx=1:numel(allTest)
            if cv('get',allTest(idx),'.modelcov')==modelcovId
                cv('delete',allTest(idx));
            end
        end

    end


