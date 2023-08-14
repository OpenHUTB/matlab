function customeCodeLibNames=getModelCustomCodeLibraries(mdlName)



    customCodeSettings=cgxeprivate('get_custom_code_settings',mdlName);
    customeCodeLibNames=struct('libName',{},'libPath',{},'libModelName',{},'libExt',{});

    if customCodeSettings.hasSettings(true)&&customCodeSettings.hasCustomCode()
        [libUsage.libPath,libUsage.libName,libUsage.libExt]=...
        fileparts(CGXE.CustomCode.getCustomLibNameFromModel(mdlName,'dynamic'));
        libUsage.libModelName=mdlName;
        customeCodeLibNames(end+1)=libUsage;
    end

    libHandles=slcc('getCachedLinkedLibraryModels',get_param(mdlName,'Handle'));
    if~isempty(libHandles)
        for i=1:numel(libHandles)
            if~is_simulink_handle(libHandles(i))


                continue;
            end
            libMdlName=get_param(libHandles(i),'Name');
            customCodeSettings=cgxeprivate('get_custom_code_settings',libMdlName);
            if customCodeSettings.hasCustomCode()
                [libUsage.libPath,libUsage.libName,libUsage.libExt]=...
                fileparts(CGXE.CustomCode.getCustomLibNameFromModel(libMdlName,'dynamic'));
                libUsage.libModelName=libMdlName;
                customeCodeLibNames(end+1)=libUsage;%#ok<AGROW>
            end
        end
    end

end


