function setArchModelCallbacks(modelH)





    assert(Simulink.internal.isArchitectureModel(modelH,'AUTOSARArchitecture'),...
    'Should be architecture model')

    mdlObj=get_param(modelH,'Object');
    if~mdlObj.hasCallback('PreSave','AutosarArchSave')
        mdlObj.addCallback('PreSave','AutosarArchSave',@()checkModelName());
    end

end

function checkModelName(~)









    modelH=bdroot;
    assert(Simulink.internal.isArchitectureModel(modelH,'AUTOSARArchitecture'),...
    'Should be architecture model')

    saveOptions=Simulink.internal.BDSaveOptions(modelH);

    newModelName=saveOptions.destinationBlockDiagramName;

    m3iComposition=autosar.api.Utils.m3iMappedComponent(modelH);
    maxShortNameLength=get_param(modelH,'AutosarMaxShortNameLength');
    templateName='autosar_composition_model';
    if strcmp(m3iComposition.Name,templateName)&&...
        autosarcore.checkIdentifier(newModelName,'shortname',maxShortNameLength)


        oldCompQName=autosar.api.Utils.getQualifiedName(m3iComposition);
        newCompQName=[autosar.api.Utils.getQualifiedName(m3iComposition.containerM3I),'/',newModelName];
        if~strcmp(oldCompQName,newCompQName)
            arProps=autosar.api.getAUTOSARProperties(modelH);
            arProps.set('XmlOptions','ComponentQualifiedName',newCompQName);
        end
    end

end


