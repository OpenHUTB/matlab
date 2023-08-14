function pInterfaceLoadCallback(modelHandle,loadOptions,partName,bdAccessMethod,templateModel)






    if~loadOptions.readerHandle.hasPart(partName)
        return;
    end

    try
        filename=Simulink.slx.getUnpackedFileNameForPart(modelHandle,part.name);
        loadOptions.readPartToFile(partName,filename);
        data=m3iload(filename,templateModel);

        mdlname=get_param(obj.modelHandle,'Name');
        bdAccessMethod(mdlname,data);
    catch ME %#ok<NASGU>


        warning('Simulink:SlSystemArchitecture:LoadFailure',...
        DAStudio.message('Simulink:SlSystemArchitecture:LoadFailure'))
    end

end
