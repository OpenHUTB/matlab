function[show,enable]=isRootIOCompatible(sourceModel,sourceBlock,propertyName)%#ok<INUSD>






    [mapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(sourceModel);
    isRootLevelBlock=strcmp(get_param(sourceBlock,'Parent'),sourceModel);
    isInport=strcmp(get_param(sourceBlock,'BlockType'),'Inport');
    if strcmp(mappingType,'AutosarTarget')||strcmp(mappingType,'AutosarTargetCPP')
        show=~isempty(mapping);
        enable=show&&isRootLevelBlock&&autosar.api.Utils.autosarlicensed();
        if isInport
            enable=enable&&~strcmp(get_param(sourceBlock,'OutputFunctionCall'),'on');
        end
    elseif strcmp(mappingType,'CoderDictionary')
        show=~isempty(mapping);
        enable=show&&isRootLevelBlock&&Simulink.CodeMapping.codersLicensed();
    elseif strcmp(mappingType,'SimulinkCoderCTarget')
        show=~isempty(mapping);
        enable=show&&license('test','real-time_workshop');
    elseif strcmp(mappingType,'CppModelMapping')
        show=slfeature('CppIOCustomization')>0...
        &&~isempty(mapping);
        isApp=show&&isequal(mapping.DeploymentType,'Application');
        if isApp
            enable=show&&Simulink.CodeMapping.ddsLicensed();
        else
            enable=show&&Simulink.CodeMapping.codersLicensed();
        end
    else
        show=false;
        enable=false;
    end
end
