function slcoverage_callback(method,modelH)





    persistent covInstalledAndLicensed
    if isempty(covInstalledAndLicensed)||strcmp(method,'reset')
        covInstalledAndLicensed=exist('cv','file')==3&&license('test',SlCov.CoverageAPI.getLicenseName());
        if strcmp(method,'reset')
            return;
        end
    end

    if~covInstalledAndLicensed
        return;
    end

    switch(method)


    case{'postLoad'}

        refreshInformer(modelH);

    case 'preSave'




        modelcovId=get_param(modelH,'CoverageId');
        topModelCovId=cv('get',modelcovId,'.topModelcovId');
        topModelH=cv('get',topModelCovId,'.handle');
        if topModelH==modelH
            removeCoverage(modelH);
        end
        cvi.TopModelCov.closeResultsExplorer(modelH);
        cvi.Informer.markHighlightingAvailable(modelH,false);

    case{'unhighlight','init'}

        removeCoverage(modelH);
    case{'open'}
        handleHarnessInformer(modelH);
    case{'close','forceClose'}
        cvi.TopModelCov.closeResultsExplorer(modelH);

    otherwise
        error(message('Slvnv:vnvcallback:UnexpectedNotificationCov',method));
    end
end

function handleHarnessInformer(modelH)
    [~,mexFiles]=inmem;



    if~any(strcmp(mexFiles,'cv'))
        return;
    end
    ownerModel=Simulink.harness.internal.getHarnessOwnerBD(modelH);
    if~isempty(ownerModel)
        removeCoverage(ownerModel);
    end
end

function refreshInformer(modelH)
    [~,mexFiles]=inmem;



    if~any(strcmp(mexFiles,'cv'))
        return;
    end

    cvi.Informer.refreshReopenedRefModel(modelH);
end

function removeCoverage(modelH)
    modelcovId=get_param(modelH,'CoverageId');
    if modelcovId~=0
        cvi.Informer.close(modelcovId);
    end
end


