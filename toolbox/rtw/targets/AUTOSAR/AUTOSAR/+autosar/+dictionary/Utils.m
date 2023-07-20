classdef(Hidden)Utils<handle




    methods(Static)

        function isShared=isSharedAutosarDictionary(dictFileName)





            [~,~,ext]=fileparts(dictFileName);
            assert(strcmp(ext,'.sldd'),'Unexpected dict file extension: %s',ext);
            isShared=Simulink.AutosarDictionary.ModelRegistry.hasAutosarPart(dictFileName)||...
            Simulink.AutosarDictionary.ModelRegistry.isM3IModelLoaded(dictFileName);
        end

        function isAUTOSARDict=isAUTOSARInterfaceDictionary(dictFileName)


            isAUTOSARDict=sl.interface.dict.api.isInterfaceDictionary(dictFileName)&&...
            autosar.dictionary.Utils.isSharedAutosarDictionary(dictFileName);
        end

        function hasRefModels=hasReferencedModels(m3iModel)



            hasRefModels=Simulink.AutosarDictionary.ModelRegistry.hasReferencedModels(m3iModel);
        end

        function[m3iRefModel,dictFullName]=getUniqueReferencedModel(m3iModelParent)


            m3iRefModels=Simulink.AutosarDictionary.ModelRegistry.getReferencedModels(m3iModelParent);
            assert(m3iRefModels.size()==1,'Expected model to be linked to a single interface dictionary.');
            m3iRefModel=m3iRefModels.front();
            if(nargout>1)
                dictFullName=Simulink.AutosarDictionary.ModelRegistry.getDDFileSpecForM3IModel(m3iRefModel);
            end
        end

        function[isShared,dictFullName]=isSharedM3IModel(m3iModel)


            dictFullName=Simulink.AutosarDictionary.ModelRegistry.getDDFileSpecForM3IModel(m3iModel);
            isShared=~isempty(dictFullName);
        end

        function m3iModel=getM3IModelForDictionaryFile(dictFileName)

            ddConn=Simulink.data.dictionary.open(dictFileName);
            m3iModel=Simulink.AutosarDictionary.ModelRegistry.getOrLoadM3IModel(ddConn.filepath());
        end

        function models=findSLModelsReferencingSharedM3IModel(m3iModel)




            if isempty(Simulink.AutosarDictionary.ModelRegistry.getDDFileSpecForM3IModel(m3iModel))


                models={};
            else
                openModels=find_system('SearchDepth',0);
                models={};
                for ii=1:length(openModels)
                    mdl=openModels{ii};





                    if slInternal('isBDClosing',mdl)
                        continue;
                    end

                    if~autosarcore.ModelUtils.isMapped(mdl)
                        continue;
                    end

                    mapping=autosar.api.Utils.modelMapping(mdl);
                    compM3IModel=mapping.AUTOSAR_ROOT;
                    if isempty(compM3IModel)

                        continue
                    end
                    refM3IModels=Simulink.AutosarDictionary.ModelRegistry.getReferencedModels(compM3IModel);
                    for idx=1:refM3IModels.size()
                        refM3IModel=refM3IModels.at(idx);
                        if~isempty(refM3IModel)&&m3iModel==refM3IModel
                            models{end+1}=openModels{ii};%#ok<AGROW>
                        end
                    end
                end
            end
        end

        function handleDictionaryPreCloseEvent(dictFilePath)






            arExplorerList=find(DAStudio.Root,'-isa','AUTOSAR.Explorer');
            for i=1:length(arExplorerList)
                arExplorer=arExplorerList(i);

                if strcmp(arExplorer.SharedAutosarDictionary,dictFilePath)
                    autosar.ui.utils.closeUI(arExplorer);
                end
            end
        end

        function closeDictUIForModelsReferencingSharedM3IModel(sharedM3IModel)
            models=autosar.dictionary.Utils.findSLModelsReferencingSharedM3IModel(sharedM3IModel);
            for ii=1:length(models)
                autosar_ui_close(models{ii});
            end
        end

        function registerM3IModelWithDictionary(m3iModel,dictFileName)


            ddConn=Simulink.data.dictionary.open(dictFileName);
            dictFullPath=ddConn.filepath();
            assert(~isempty(dictFullPath),'could not find dictionary file: %s',dictFileName);
            Simulink.AutosarDictionary.ModelRegistry.registerM3IModelWithDD(dictFullPath,m3iModel);


            Simulink.AutosarDictionary.ModelRegistry.setAutosarPartDirty(dictFullPath);
        end

        function uuid=getDictionaryUUID(m3iModel)
            uuid=M3I.getModelUUID(m3iModel);
        end

        function updateModelMappingWithDictionary(modelName,ddFileName)
            mapping=autosarcore.ModelUtils.modelMapping(modelName);




            ddConn=Simulink.dd.open(ddFileName);
            ddFilePath=ddConn.filespec();
            mapping.DDConnectionToSharedAUTOSARDictionary=ddConn;

            assert(Simulink.AutosarDictionary.ModelRegistry.isM3IModelLoaded(ddFilePath),...
            'm3iModel is not loaded for dictionary: %s',ddFilePath);
            sharedM3IModel=Simulink.AutosarDictionary.ModelRegistry.getOrLoadM3IModel(ddFilePath);
            assert(sharedM3IModel.isvalid(),'dictionary %s does not have m3iModel',ddFilePath);

            uuid=autosar.dictionary.Utils.getDictionaryUUID(sharedM3IModel);
            assert(~isempty(uuid),'uuid is not set for shared AUTOSAR dictionary m3iModel');
            mapping.SharedAUTOSARDictionaryUUID=uuid;
        end
    end
end


