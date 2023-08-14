function checkTopModelBuild(topModelName,isTopModelSIL,resolvedGenCodeOnly)






    if autosar.api.Utils.isMappedToComposition(topModelName)
        if autosar.composition.Utils.isModelInCompositionDomain(topModelName)
            autosar.validation.AutosarUtils.reportErrorWithFixit(...
            'autosarstandard:exporter:BuildNotSupportedForAUTOSARArchitectureModel',topModelName);
        else
            DAStudio.error('autosarstandard:exporter:BuildNotSupportedForLegacyCompositionModel',topModelName);
        end
    elseif autosar.api.Utils.isMappedToComponent(topModelName)
        if~isTopModelSIL&&~resolvedGenCodeOnly
            createSILPILBlock=get_param(topModelName,'CreateSILPILBlock');
            if strcmp(createSILPILBlock,'None')
                DAStudio.error('RTW:autosar:buildError');
            end
        end
    end

end


