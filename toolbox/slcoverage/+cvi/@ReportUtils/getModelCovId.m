function[modelcovId,scriptName]=getModelCovId(covdata)




    covdata=covdata(1);
    scriptName='';
    modelcovId=cv('get',covdata.rootId,'.modelcov');

    if cv('get',modelcovId,'.isScript')
        scriptName=SlCov.CoverageAPI.getModelcovName(modelcovId);
        modelcovId=[];
    end
