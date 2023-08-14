classdef ObserversDispatcher<handle




    methods
        function broadcastChanges(this,m3iReport)


            m3iModel=m3iReport.getModel();
            observers=this.findObservers(m3iModel,m3iReport);
            for obsIdx=1:length(observers)
                observer=observers{obsIdx};
                observer.observeChanges(m3iReport);
            end
        end
    end

    methods(Static,Hidden)


        function modelName=findModelFromMetaModel(modelM3I)
            modelName='';
            openModels=find_system('SearchDepth',0);
            for ii=1:length(openModels)
                m3iModel=[];
                openModel=openModels{ii};



                [isMapped,modelMapping]=autosar.api.Utils.isMapped(openModel);
                if isMapped
                    m3iModel=modelMapping.AUTOSAR_ROOT;
                end
                if~isempty(m3iModel)&&m3iModel==modelM3I
                    modelName=openModels{ii};
                end
            end
        end
    end


    methods(Static,Access=private)
        function observers=findObservers(m3iModel,m3iReport)



            observers={};


            modelName=autosar.mm.observer.ObserversDispatcher.findModelFromMetaModel(m3iModel);
            if~isempty(modelName)
                observers=[observers,{autosar.mm.observer.ObserverModelMapping(modelName)}];
            end



            isSharedM3IModel=autosar.dictionary.Utils.isSharedM3IModel(m3iModel);
            if isSharedM3IModel
                modelsWithRef=autosar.dictionary.Utils.findSLModelsReferencingSharedM3IModel(m3iModel);
                for ii=1:length(modelsWithRef)
                    modelWithRef=modelsWithRef{ii};

                    if Simulink.internal.isArchitectureModel(modelWithRef,'AUTOSARArchitecture')


                        continue;
                    end

                    if autosar.mm.observer.ObserversDispatcher.doesMappingNeedUpdate(m3iReport)
                        observers=[observers,{autosar.mm.observer.ObserverModelMapping(modelWithRef)}];%#ok<AGROW>
                    end




                    arExplorer=autosar.ui.utils.findExplorerForModel(modelWithRef);
                    if~isempty(arExplorer)
                        observers=[observers,{autosar.mm.observer.ObserverARDictionaryUI(arExplorer)}];%#ok<AGROW>
                    end
                end

                dictFile=Simulink.AutosarDictionary.ModelRegistry.getDDFileSpecForM3IModel(m3iModel);
                assert(~isempty(dictFile),'Dict file should be specified now');


                observers=[observers,{autosar.mm.observer.ObserverSharedDictionary(dictFile)}];


                studioApp=sl.interface.dictionaryApp.StudioApp.findStudioAppForDict(dictFile);
                if~isempty(studioApp)&&studioApp.isWindowActive()



                    observers=[observers,{autosar.internal.dictionaryApp.observer.ObserverStudioApp(studioApp)}];
                end
            else





                if~isempty(modelName)
                    autosar.api.Utils.setM3iModelDirty(modelName);
                end



                arExplorer=autosar.ui.utils.findExplorer(m3iModel);
                if~isempty(arExplorer)
                    observers=[observers,{autosar.mm.observer.ObserverARDictionaryUI(arExplorer)}];
                end

                if Simulink.AutosarDictionary.ModelRegistry.hasReferencedModels(m3iModel)



                    observers=[observers,{autosar.mm.observer.ObserverM3IModelChecker(m3iModel)}];
                end
            end
        end

        function mappingNeedUpdate=doesMappingNeedUpdate(m3iReport)
            mappingNeedUpdate=true;
            if m3iReport.getRemoved().isEmpty()&&m3iReport.getAdded().isEmpty()
                changes=m3iReport.getChanged();
                if double(changes.size())==1&&isa(changes.at(1),'Simulink.metamodel.arplatform.common.ImmutableAUTOSAR')


                    mappingNeedUpdate=false;
                end
            end
        end
    end
end


