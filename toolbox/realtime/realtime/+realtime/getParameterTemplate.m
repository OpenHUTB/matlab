function infoOut=getParameterTemplate(hObj)









    persistent info;



    persistent OnTargetOneClickLastSetting;
    if isempty(OnTargetOneClickLastSetting)
        OnTargetOneClickLastSetting=slfeature('OnTargetOneClick');
    end
    OnTargetOneClickCurrentSetting=slfeature('OnTargetOneClick');

    OnTargetOneClickSettingHasChanged=false;
    if~isequal(OnTargetOneClickLastSetting,OnTargetOneClickCurrentSetting)
        OnTargetOneClickLastSetting=OnTargetOneClickCurrentSetting;
        OnTargetOneClickSettingHasChanged=true;
    end

    fNames={'preferencesSettings','targetSettings','buildSettings','toolsSettings'};
    cNames={'PreferencesSettings','TargetSettings','BuildSettings','ToolsSettings'};
    if((~isempty(info)&&...
        ~isequal(get_param(hObj,'TargetExtensionPlatform'),info.selectedPlatform))||...
        OnTargetOneClickSettingHasChanged)
        info=[];
    end

    hCS=hObj;
    modelName=hCS.getModel;
    if isempty(info)||isempty(get_param(hObj,'TargetExtensionData'))
        info.selectedPlatform=get_param(hObj,'TargetExtensionPlatform');
        for i=1:length(fNames)
            targetExtensionPlatform=get_param(hObj,'TargetExtensionPlatform');
            filePathName=realtime.getDataFileName(fNames{i},targetExtensionPlatform);
            settings=realtime.(cNames{i})(filePathName,targetExtensionPlatform,modelName);
            if~isempty(settings.Data)
                parameters=settings.Data.Parameters;
                parametersGroup=settings.Data.ParametersGroup;
                info.(['parameters',num2str(i)])=parameters;
                info.(['parametersGroup',num2str(i)])=parametersGroup;
            else
                info.(['parameters',num2str(i)])={};
                info.(['parametersGroup',num2str(i)])={};
            end
        end
    end
    infoOut=info;
end
