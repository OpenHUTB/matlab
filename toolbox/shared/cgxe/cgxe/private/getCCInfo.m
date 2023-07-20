function[ccInfo]=getCCInfo(modelName,isSettingOnly,forSLCC,reportTokenizerError)


    if nargin<4
        reportTokenizerError=false;
    end

    if nargin<3
        forSLCC=true;
    end

    if nargin<2
        isSettingOnly=false;
    end

    ccInfo=[];

    if(~ischar(modelName))
        modelName=get_param(modelName,'Name');
    end

    customCodeSettings=CGXE.CustomCode.CustomCodeSettings.createFromModel(modelName);
    if~customCodeSettings.hasSettings(forSLCC)

        return;
    end

    lang=get_param(modelName,'SimTargetLang');
    ccInfo=getCCInfoBase(customCodeSettings,lang,modelName);

    if isSettingOnly
        return;
    end


    projRootDir=[];modelRefRebuildModelRootDir=[];
    ccInfo=tokenizeCCInfo(ccInfo,modelName,projRootDir,modelRefRebuildModelRootDir,reportTokenizerError);




