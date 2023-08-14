function RTWInfoBackup=backup(sourceModel,sourceBlock)





    [~,enableMappingProperties]=Simulink.CodeMapping.isCompatible(sourceModel,sourceBlock);
    [~,mappingType]=Simulink.CodeMapping.getCurrentMapping(sourceModel);
    RTWInfoBackup.ARPortName='';
    RTWInfoBackup.ARElementName='';
    RTWInfoBackup.ARDataAccessMode='';
    RTWInfoBackup.CoderData='';
    RTWInfoBackup.HasCoderData='';
    if enableMappingProperties
        modelMapping=Simulink.CodeMapping.get(sourceModel);
        slPortName=get_param(sourceBlock,'Name');
        modelName=get_param(sourceModel,'Name');
        slPortName=Simulink.CodeMapping.escapeSimulinkName(slPortName);
        inportMappingObj=modelMapping.Inports.findobj('Block',[modelName,'/',slPortName]);
        if strcmp(mappingType,'AutosarTarget')
            mappedToObj=inportMappingObj.MappedTo;
            if~isempty(mappedToObj)
                RTWInfoBackup.ARPortName=mappedToObj.Port;
                RTWInfoBackup.ARElementName=mappedToObj.Element;
                RTWInfoBackup.ARDataAccessMode=mappedToObj.DataAccessMode;
            end
        elseif strcmp(mappingType,'CoderDictionary')
            storageClass=inportMappingObj.MappedTo.StorageClass;
            if~isempty(storageClass)
                RTWInfoBackup.CoderData=storageClass.UUID;
                RTWInfoBackup.HasCoderData=true;
            else
                RTWInfoBackup.CoderData='';
                RTWInfoBackup.HasCoderData=false;
            end
        end
    end
end
