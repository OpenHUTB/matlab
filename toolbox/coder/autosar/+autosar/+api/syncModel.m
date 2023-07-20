function syncModel(mdlName)























    narginchk(1,1);

    mdlName=convertStringsToChars(mdlName);

    [isMappedToSubComponent,~]=Simulink.CodeMapping.isMappedToAutosarSubComponent(mdlName);
    if isMappedToSubComponent
        DAStudio.error('autosarstandard:api:subComponentNotSupported');
    end


    if autosar.composition.Utils.isModelInCompositionDomain(mdlName)
        DAStudio.error('autosarstandard:api:CapabilityNotSupportForAUTOSARArchitectureModel',...
        'autosar.api.syncModel');
    end

    try

        cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>


        mapping=autosar.api.Utils.modelMapping(mdlName);


        compiledModelCleanupObj=autosar.validation.CompiledModelUtils.forceCompiledModel(mdlName);

        isAdaptive=autosar.api.Utils.isMappedToAdaptiveApplication(mdlName);
        if isAdaptive
            autosar.internal.adaptive.manifest.ManifestUtilities.syncManifestMetaModelWithAutosarDictionary(mdlName);
        else
            i_mapCallersWithSameNameToExistingCallers(mapping.FunctionCallers);
            autosar.bsw.BasicSoftwareCaller.syncModel(getfullname(mdlName));
        end


        if~isempty(compiledModelCleanupObj)
            compiledModelCleanupObj.delete();
        end


        autosar.utils.SyncMapping.syncStatesSignalsAndDSMs(mdlName);

    catch Me

        autosar.mm.util.MessageReporter.throwException(Me);
    end

    function i_mapCallersWithSameNameToExistingCallers(functionCallersMap)
        for dtMapIdx=1:length(functionCallersMap)
            blkMap=functionCallersMap(dtMapIdx);


            fcnCall=get_param(blkMap.Block,'FunctionPrototype');
            if isempty(blkMap.MappedTo.ClientPort)&&...
                isempty(blkMap.MappedTo.Operation)
                for ii=1:length(functionCallersMap)
                    candidateBlkMap=functionCallersMap(ii);
                    if ii~=dtMapIdx&&...
                        strcmp(fcnCall,get_param(candidateBlkMap.Block,'FunctionPrototype'))&&...
                        ~isempty(candidateBlkMap.MappedTo.ClientPort)&&...
                        ~isempty(candidateBlkMap.MappedTo.Operation)
                        blkMap.mapPortOperation(...
                        functionCallersMap(ii).MappedTo.ClientPort,...
                        functionCallersMap(ii).MappedTo.Operation);
                        break;
                    end
                end
            end
        end


