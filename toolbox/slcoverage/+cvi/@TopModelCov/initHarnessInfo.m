



function initHarnessInfo(this,modelcovId,testId)


    if nargin<3
        testId=cv('get',modelcovId,'.currentTest');
    end
    cvi.TopModelCov.storeHarnessInfo(this,modelcovId,testId);
end
