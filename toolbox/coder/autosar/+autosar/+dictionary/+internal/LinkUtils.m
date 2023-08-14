classdef LinkUtils<handle





    methods(Static)

        function copySharedElementsToModelAndUnlink(modelName)








            saveState=true;
            uiCleanUpObj=autosar.ui.utils.closeUIAndApp(modelName,saveState);%#ok<NASGU>


            [isSharedDict,dictionaryFiles]=autosar.api.Utils.isUsingSharedAutosarDictionary(modelName);
            if~isSharedDict
                DAStudio.error('autosarstandard:dictionary:ModelNotLinkedToDictionary',modelName);
            end


            assert(numel(dictionaryFiles)==1,'Expected model to be linked to a single interface dictionary.');
            dictionaryFile=dictionaryFiles{1};
            ddConn=Simulink.dd.open(dictionaryFile);


            dstM3IModel=autosar.api.Utils.m3iModel(modelName);


            autosarcore.unregisterListenerCB(dstM3IModel);
            rlCleanup=onCleanup(@()autosar.ui.utils.registerListenerCB(dstM3IModel));


            srcM3IModel=Simulink.AutosarDictionary.ModelRegistry.getOrLoadM3IModel(ddConn.filespec());



            tDst=M3I.Transaction(dstM3IModel);

            mover=Simulink.metamodel.arplatform.ElementMover(srcM3IModel,dstM3IModel);
            mover.copyAllSharedElements();

            autosar.dictionary.internal.LinkUtils.unlinkModelFromInterfaceDictionary(...
            modelName,dstM3IModel);


            autosar.dictionary.internal.migrateXmlOptions(srcM3IModel,dstM3IModel,false);

            tDst.commit();
        end

        function removeAssociationsToInterfaceDictionaryAndUnlink(modelName)





            autosarcore.destroyLoadedM3IModel(modelName);
            localM3IModel=autosarcore.M3IModelLoader.loadM3IModel(modelName,LoadReferencedM3IModels=false);


            autosarcore.unregisterListenerCB(localM3IModel);
            rlCleanup=onCleanup(@()autosar.ui.utils.registerListenerCB(localM3IModel));

            tran=M3I.Transaction(localM3IModel);

            autosar.dictionary.internal.LinkUtils.unlinkModelFromInterfaceDictionary(...
            modelName,localM3IModel);


            m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
            componentBuilder=autosar.ui.wizard.builder.Component(modelName,modelName);
            componentBuilder.populateCorePackages(m3iComp,modelName);

            tran.commit();
        end

        function unlinkModelFromInterfaceDictionary(modelName,localM3IModel)


            mapping=autosar.api.Utils.modelMapping(modelName);
            if isempty(autosarcore.ModelUtils.getMappingSharedDictUUID(modelName))
                return
            end



            mapping.SharedAUTOSARDictionaryUUID='';



            Simulink.AutosarDictionary.ModelRegistry.removeAllReferencedModels(localM3IModel);


            autosar.api.Utils.setM3iModelDirty(modelName);
        end

        function linkModelDictM3IModels(modelName,dictName)
            ddConn=Simulink.dd.open(dictName);


            sharedM3IModel=Simulink.AutosarDictionary.ModelRegistry.getOrLoadM3IModel(ddConn.filespec());



            autosar.dictionary.Utils.updateModelMappingWithDictionary(modelName,ddConn.filespec());


            srcM3IModel=autosar.api.Utils.m3iModel(modelName);
            Simulink.AutosarDictionary.ModelRegistry.addReferencedModel(srcM3IModel,sharedM3IModel);
        end
    end
end


