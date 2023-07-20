function mappingType=getMappingType(appName,appLang,codeInterfacePackaging)




    mappingType='';
    if strcmp(appName,'EmbeddedCoder')
        if strcmp(codeInterfacePackaging,'C++ class')
            mappingType='CppModelMapping';
        else
            mappingType='CoderDictionary';
        end
    elseif strcmp(appName,'SimulinkCoder')
        if~strcmp(codeInterfacePackaging,'C++ class')
            mappingType='SimulinkCoderCTarget';
        end
    elseif strcmp(appName,'Autosar')
        if strcmp(appLang,'C++')
            mappingType='AutosarTargetCPP';
        else
            mappingType='AutosarTarget';
        end
    elseif strcmp(appName,'DDS')
        mappingType='CppModelMapping';
    end
end
