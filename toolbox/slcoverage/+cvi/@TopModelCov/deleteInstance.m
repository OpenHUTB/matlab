




function deleteInstance(modelH)

    modelcovId=get_param(modelH,'CoverageId');

    if~cv('ishandle',modelcovId)
        return;
    end

    topModelcovId=cv('get',modelcovId,'.topModelcovId');
    if cv('ishandle',topModelcovId)
        mcid=topModelcovId;
    else
        mcid=modelcovId;
    end
    coveng=cv('get',mcid,'.topModelCov');
    delete(coveng);
    cv('set',mcid,'.topModelCov',[]);


