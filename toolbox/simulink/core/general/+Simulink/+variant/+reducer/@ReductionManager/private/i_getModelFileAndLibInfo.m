




function[modelFileName,isLibrary]=i_getModelFileAndLibInfo(modelName)

    if bdIsLoaded(modelName)
        isLibrary=strcmp(get_param(modelName,'BlockDiagramType'),'library');
        modelFileName=get_param(modelName,'FileName');
    else
        try
            mdlInfo=Simulink.MDLInfo(modelName,'isExtractInterface',false,'isExtractMetadata',false);
        catch err
            if strcmp(err.identifier,'Simulink:LoadSave:FileNotFound')
                errid='Simulink:Variants:ModelFileNotFound';
                err=MException(message(errid,modelName));
            end
            throwAsCaller(err);
        end
        isLibrary=mdlInfo.IsLibrary;
        modelFileName=mdlInfo.FileName;
    end
end
