



function storeHarnessInfo(harnessInfo,modelcovId,testId)


    cv('set',modelcovId,'.canHarnessMapBackToOwner',true);

    if isempty(harnessInfo.ownerModel)
        return
    end


    cv('set',modelcovId,'.ownerModel',harnessInfo.ownerModel);
    cv('set',modelcovId,'.harnessModel',harnessInfo.harnessModel);
    cv('set',modelcovId,'.ownerBlock',harnessInfo.ownerBlock);
    cv('set',modelcovId,'.canHarnessMapBackToOwner',harnessInfo.keepHarnessCvData);


    if nargin<3
        testId=cv('get',modelcovId,'.currentTest');
    end

    if testId==0
        return
    end


    cv('set',testId,'.ownerModel',harnessInfo.ownerModel);
    cv('set',testId,'.harnessModel',harnessInfo.harnessModel);
    cv('set',testId,'.ownerBlock',harnessInfo.ownerBlock);
