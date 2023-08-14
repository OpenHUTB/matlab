function[title,expectedTabSuffix]=getTitle(modelHandle)




    cp=simulinkcoder.internal.CodePerspective.getInstance;
    appName=cp.getInfo(modelHandle);
    appLang=get_param(modelHandle,"TargetLang");
    codeInterfacePackaging=get_param(modelHandle,"CodeInterfacePackaging");
    mappingType=Simulink.CodeMapping.getMappingType(appName,appLang,codeInterfacePackaging);

    readOnlyText='';
    if~Simulink.CodeMapping.enableCodeMappings(modelHandle)
        readOnlyText=DAStudio.message('coderdictionary:mapping:ReadOnly');
    end
    switch mappingType
    case 'CoderDictionary'
        expectedTabSuffix='ERT';
        title=Simulink.CodeMapping.getTitleForEmbeddedCoderC(modelHandle,readOnlyText);
    case 'SimulinkCoderCTarget'
        expectedTabSuffix='GRT';
        title=DAStudio.message('coderdictionary:mapping:CodeMappingsC',readOnlyText);
    case 'CppModelMapping'
        if strcmp(appName,'DDS')
            expectedTabSuffix='CPP_MSG';
            title=DAStudio.message('coderdictionary:mapping:CodeMappingsDDS',readOnlyText);
        else
            expectedTabSuffix='CPP_ert';
            title=Simulink.CodeMapping.getTitleForEmbeddedCoderCPP(modelHandle,readOnlyText);
        end
    case 'AutosarTarget'
        expectedTabSuffix='ClassicAutosar';
        mapping=Simulink.CodeMapping.getCurrentMapping(modelHandle);
        if~isempty(mapping)&&mapping.IsSubComponent
            title=DAStudio.message('coderdictionary:mapping:CodeMappingsAutosarSubComponent');
        else
            title=DAStudio.message('coderdictionary:mapping:CodeMappingsAutosar',readOnlyText);
        end
    case 'AutosarTargetCPP'
        expectedTabSuffix='AdaptiveAutosar';
        title=DAStudio.message('coderdictionary:mapping:CodeMappingsAdaptiveAutosar',readOnlyText);
    otherwise
        expectedTabSuffix='';
        title=DAStudio.message('Simulink:studio:CodeViewSS');
    end
end
