function[settingsChecksum,interfaceChecksum,fullCheckSum,dllFullPath,ccSettingInfo]=computeCCChecksumFromModel(modelName,reportTokenizerError)


    if nargin<2
        reportTokenizerError=false;
    end

    if~ischar(modelName)

        modelName=get_param(modelName,'Name');
    end
    [fullCheckSum,settingsChecksum,interfaceChecksum,dllFullPath]=deal('');
    if nargout==1
        ccSettingInfo=getCCInfo(modelName,true);
        if~isempty(ccSettingInfo)
            settingsChecksum=ccSettingInfo.settingsChecksum;
        end

    elseif nargout>=4
        isSettingOnly=false;forSLCC=true;
        ccSettingInfo=getCCInfo(modelName,isSettingOnly,forSLCC,reportTokenizerError);
        [settingsChecksum,interfaceChecksum,fullCheckSum,dllFullPath]=computeCCChecksumfromCCInfo(ccSettingInfo);
    else
        assert(false);
    end

