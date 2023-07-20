function enable=enableCodeMappings(sourceModel)





    [mapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(sourceModel);
    if strcmp(mappingType,'AutosarTarget')||strcmp(mappingType,'AutosarTargetCPP')
        show=~isempty(mapping);
        enable=show&&autosar.api.Utils.autosarlicensed();
    elseif strcmp(mappingType,'CoderDictionary')
        show=~isempty(mapping);
        enable=show&&Simulink.CodeMapping.codersLicensed();
    elseif strcmp(mappingType,'SimulinkCoderCTarget')
        show=~isempty(mapping);
        enable=show&&license('test','real-time_workshop');
    elseif strcmp(mappingType,'CppModelMapping')
        show=~isempty(mapping);
        isApp=show&&isequal(mapping.DeploymentType,'Application');
        if isApp
            enable=show&&Simulink.CodeMapping.ddsLicensed();
        else
            enable=show&&Simulink.CodeMapping.codersLicensed();
        end
    else
        enable=false;
    end
end
