function outTestObj=clone(inTestObj,varargin)




    outTestObj=[];
    if~isempty(varargin)
        outTestObj=varargin{1};
    end
    inId=inTestObj.id;
    modelcov=cv('get',inId,'.modelcov');
    rootPath=cv('GetTestRootPath',inId);

    if isempty(outTestObj)
        testId=cvtest.create(modelcov);

        cv('SetTestRootPath',testId,rootPath);
        cv('PendingTestAdd',modelcov,testId);
        outTestObj=cvtest(testId);
    end
    if~cv('get',cv('get',outTestObj.id,'.modelcov'),'.isScript')
        modelName=SlCov.CoverageAPI.getModelcovName(modelcov);
        copyMetricsFromModel(outTestObj,modelName);
    end
    copySettings(outTestObj,inTestObj);
