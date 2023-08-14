function mappingCreated=createMappingAndInitDictIfNecessary(modelName,migrateDictionaryOnly)




    pb=[];
    handle=get_param(modelName,'Name');
    isCpp=strcmp(get_param(modelName,'CodeInterfacePackaging'),'C++ class');
    [hasERT_Mapping,~]=Simulink.CodeMapping.isMappedToERTSwComponent(modelName);
    [hasCppERT_Mapping,~]=Simulink.CodeMapping.isMappedToCppERTSwComponent(modelName);
    [hasArC_Mapping,~]=Simulink.CodeMapping.isMappedToAutosarComponent(modelName);
    [hasArCPP_Mapping,~]=Simulink.CodeMapping.isMappedToAdaptiveApplication(modelName);
    arStf=strcmp(get_param(handle,'AutosarCompliant'),'on');
    ertStf=strcmp(get_param(handle,'IsERTTarget'),'on')&&~arStf;
    isAdaptiveAutosar=arStf&&isCpp;
    isClassicAutosar=arStf&&~isAdaptiveAutosar;
    mappingCreated=false;
    try
        if ertStf


            if hasERT_Mapping&&~isCpp


                if(migrateDictionaryOnly&&~coder.internal.CoderDataStaticAPI.migratedToCoderDictionary(handle))
                    Simulink.CodeMapping.doMigrationFromGUI(modelName,migrateDictionaryOnly);
                end


                if~coder.dictionary.exist(modelName)
                    ddFile=coderdictionary.data.SlCoderDataClient.getSharedCoderDictionarySource(get_param(modelName,'Handle'));
                    if isempty(ddFile)||~coder.dictionary.exist(ddFile)
                        w=warning('backtrace','off');
                        oc=onCleanup(@()warning(w));
                        DAStudio.warning('coderdictionary:mapping:NoCoderDictionaryWarn',modelName);
                    end
                end
            else
                if isCpp
                    if~hasCppERT_Mapping
                        Simulink.CodeMapping.doPostModelLoadMigration(modelName);
                    end
                else
                    Simulink.CodeMapping.doMigrationFromGUI(modelName,migrateDictionaryOnly);
                end
                [hasERT_Mapping,~]=Simulink.CodeMapping.isMappedToERTSwComponent(modelName);
                [hasCppERT_Mapping,~]=Simulink.CodeMapping.isMappedToCppERTSwComponent(modelName);
            end
            mappingCreated=hasERT_Mapping||hasCppERT_Mapping;
        elseif arStf
            if isClassicAutosar
                hasRelevantAr_Mapping=hasArC_Mapping;
            elseif isAdaptiveAutosar
                hasRelevantAr_Mapping=hasArCPP_Mapping;
            else
                assert(false,'did not expect to get here');
            end
            if hasRelevantAr_Mapping
                mappingCreated=hasRelevantAr_Mapping;
            else


                quDlg=findall(0,'Tag',...
                autosar.ui.configuration.PackageString.QuestionDlgTitle);
                if~isempty(quDlg)
                    mappingCreated=false;
                    return;
                else
                    mappingCreated=false;
                end
                autosar.ui.app.quickstart.WizardManager.wizard(modelName);

                mappingCreated=false;
            end
        else

            cleaner=Simulink.PreserveDirtyFlag(modelName,'blockDiagram');
            Simulink.CodeMapping.getOrCreateCMapping(modelName);
            delete(cleaner);
            mappingCreated=true;
        end
        if~isempty(pb)
            delete(pb);
        end
    catch ME
        if~isempty(pb)
            delete(pb);
        end
        errordlg(ME.message,DAStudio.message('coderdictionary:mapping:Error'),'replace');
    end
end


