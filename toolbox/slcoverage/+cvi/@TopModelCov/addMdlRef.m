function addMdlRef(coveng,modelName,isAccel)





    if nargin<3
        isAccel=false;
    end

    modelH=get_param(modelName,'handle');
    coveng.covModelRefData.recordingModels{end+1}=modelName;
    coveng.covModelRefData.override{end+1}=modelName;
    if isAccel
        coveng.covModelRefData.accelModels{end+1}=modelName;
    end

    topModelcovId=get_param(coveng.topModelH,'CoverageId');
    cvi.TopModelCov.setup(modelH,topModelcovId,isAccel);
