function shouldHideSS=hideCodeMappingSS(modelName)




    [hasERT_Mapping,~]=Simulink.CodeMapping.isMappedToERTSwComponent(modelName);
    [hasGRT_Mapping,~]=Simulink.CodeMapping.isMappedToGRTSwComponent(modelName);
    [hasArC_Mapping,~]=Simulink.CodeMapping.isMappedToAutosarComponent(modelName);
    [hasArCPP_Mapping,~]=Simulink.CodeMapping.isMappedToAdaptiveApplication(modelName);
    arStf=strcmp(get_param(modelName,'AutosarCompliant'),'on');
    ertStf=strcmp(get_param(modelName,'IsERTTarget'),'on')&&~arStf;
    grtStf=~(arStf||ertStf);
    isCPP=strcmp(get_param(modelName,'TargetLang'),'C++');
    isClassicAUTOSAR=arStf&&~isCPP;
    isAdaptiveAUTOSAR=arStf&&isCPP;



    isClassicAUTOSAR=isClassicAUTOSAR&&autosarinstalled();
    isAdaptiveAUTOSAR=isAdaptiveAUTOSAR&&autosarinstalled();

    shouldHideSS=false;
    if~(isClassicAUTOSAR&&hasArC_Mapping||ertStf&&hasERT_Mapping...
        ||grtStf&&hasGRT_Mapping||isAdaptiveAUTOSAR&&hasArCPP_Mapping)
        shouldHideSS=true;
    end
end


