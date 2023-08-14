classdef ComponentAndCompositionBuilder<handle






    properties(Access=private)
        ImporterObj;
        ArgParser;
        IsUpdateMode;
        MMChangeLoggers;
        SLChangeLoggers;
    end

    methods
        function this=ComponentAndCompositionBuilder(importerObj,compositionArgParser,varargin)

            argParser=inputParser;
            argParser.addRequired('importerObj',@(x)isa(x,'arxml.importer'));
            argParser.addRequired('compositionArgParser',@(x)isa(x,'autosar.composition.mm2sl.private.ArgumentParser'));
            argParser.addParameter('IsUpdateMode',false,@(x)(islogical(x)));
            argParser.parse(importerObj,compositionArgParser,varargin{:});

            this.ImporterObj=importerObj;
            this.ArgParser=compositionArgParser;
            this.IsUpdateMode=argParser.Results.IsUpdateMode;
        end
    end

    methods(Access=public)
        function modelNames=importAllUnder(this,m3iComposition)
            modelNames=this.importOrUpdateAllUnder(m3iComposition,'');
        end

        function updateAllUnder(this,compositionModelName)
            oldM3IComposition=autosar.api.Utils.m3iMappedComponent(compositionModelName);
            m3iComposition=autosar.mm.Model.findChildByName(this.ImporterObj.getM3IModel(),...
            autosar.api.Utils.getQualifiedName(oldM3IComposition));
            this.importOrUpdateAllUnder(m3iComposition,compositionModelName);
        end


        function[mmChangeLoggers,slChangeLoggers]=getUpdateModelLoggers(this)
            mmChangeLoggers=this.MMChangeLoggers;
            slChangeLoggers=this.SLChangeLoggers;
        end

    end

    methods(Access=private)
        function modelNames=importOrUpdateAllUnder(this,m3iComposition,compositionModelName)
            import autosar.composition.mm2sl.ComponentAndCompositionBuilder


            m3iModelSplitter=[];
            if this.ArgParser.ShareAUTOSARProperties


                existingDDConn=Simulink.data.dictionary.open(this.ArgParser.DataDictionary);
                saveDictionaryAfterImport=~existingDDConn.HasUnsavedChanges;

                if this.IsUpdateMode

                    autosar.utils.DataDictionaryCloner.backupDictionary(this.ArgParser.DataDictionary);



                    [ddConn,deleteTempDict]=ComponentAndCompositionBuilder.createTempDictionary();%#ok<ASGLU>


                    oldSharedM3IModel=Simulink.AutosarDictionary.ModelRegistry.getOrLoadM3IModel(existingDDConn.filepath);
                else
                    ddConn=Simulink.data.dictionary.open(this.ArgParser.DataDictionary);
                end




                [m3iModelSplitter,m3iComposition]=ComponentAndCompositionBuilder.splitAllUnder(...
                m3iComposition,ddConn.filepath,...
                this.ArgParser.CreateDictionaryChangesReport);

                if this.IsUpdateMode




                    modelsInsideOrigComposition=find_mdlrefs(compositionModelName,...
                    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                    'KeepModelsLoaded',true);




                    mmChangeLogger=autosar.updater.ChangeLogger();
                    newSharedM3IModel=m3iModelSplitter.getSharedM3IModel();
                    ComponentAndCompositionBuilder.compareAndUpdateSharedElementsMapping(...
                    compositionModelName,mmChangeLogger,...
                    oldSharedM3IModel,newSharedM3IModel);
                end




                xmlOptsM3IModel=m3iModelSplitter.getSharedM3IModel();
            else
                xmlOptsM3IModel=this.ImporterObj.getM3IModel();
            end


            xmlOptsGetter=autosar.mm.util.XmlOptionsGetter(xmlOptsM3IModel);

            args={this.ImporterObj,xmlOptsGetter,this.ArgParser,...
            'M3IModelSplitter',m3iModelSplitter};

            if this.IsUpdateMode
                args=[args,{'TopCompositionModel',compositionModelName,...
                'IsUpdateMode',true}];
                if this.ArgParser.ShareAUTOSARProperties
                    args=[args,{'SharedElementsChangeLogger',mmChangeLogger}];
                end
            end


            componentBuilder=autosar.composition.mm2sl.AtomicSwComponentBuilder(args{:});
            componentBuilder.importOrUpdateAtomicComponents(m3iComposition);


            compositionBuilder=autosar.composition.mm2sl.SLCompositionBuilder(args{:});
            modelNames=compositionBuilder.importOrUpdateCompositionComponents(m3iComposition);

            if this.IsUpdateMode
                this.MMChangeLoggers=[componentBuilder.getMMChangeLoggers(),compositionBuilder.getMMChangeLoggers()];
                this.SLChangeLoggers=[componentBuilder.getSLChangeLoggers(),compositionBuilder.getSLChangeLoggers()];

                if this.ArgParser.ShareAUTOSARProperties

                    ComponentAndCompositionBuilder.registerNewSharedM3IModelWithDictionary(...
                    compositionModelName,modelsInsideOrigComposition,...
                    oldSharedM3IModel,newSharedM3IModel,...
                    existingDDConn,ddConn);
                end
            end


            if this.ArgParser.ShareAUTOSARProperties&&saveDictionaryAfterImport
                existingDDConn.saveChanges();
            end
        end
    end

    methods(Static)
        function[m3iModelSplitter,m3iClonedComp]=splitAllUnder(m3iComp,...
            dataDictionary,createChangesReport)
            m3iModelSplitter=autosar.composition.mm2sl.M3IModelSplitter(...
            m3iComp.rootModel(),dataDictionary,...
            'CreateDictionaryChangesReport',createChangesReport);
            m3iClonedComp=m3iModelSplitter.splitAllUnder(m3iComp);


            autosar.dictionary.Utils.closeDictUIForModelsReferencingSharedM3IModel(...
            m3iModelSplitter.getSharedM3IModel());
        end
    end

    methods(Static,Access=private)
        function compareAndUpdateSharedElementsMapping(compositionModelName,...
            mmChangeLogger,oldSharedM3IModel,newSharedM3IModel)

            import autosar.composition.mm2sl.ComponentAndCompositionBuilder

            newSharedM3ITransaction=M3I.Transaction(newSharedM3IModel);
            oldSharedM3ITransaction=M3I.Transaction(oldSharedM3IModel);


            sharedElementsMatcher=Simulink.metamodel.arplatform.ElementMatcher(...
            newSharedM3IModel,oldSharedM3IModel);
            sharedElementsMatcher.match();


            autosar.updater.copyCSErrorArgs(sharedElementsMatcher,oldSharedM3IModel);


            sharedElementsComparator=autosar.updater.Comparator(...
            newSharedM3IModel,oldSharedM3IModel,sharedElementsMatcher,mmChangeLogger);
            sharedElementsComparator.compare();


            oldSharedM3ITransaction.cancel();




            ComponentAndCompositionBuilder.activateM3IModelListener(compositionModelName);
            autosar.updater.updateMappingForSharedElements(sharedElementsMatcher,...
            newSharedM3IModel,oldSharedM3IModel);


            newSharedM3ITransaction.cancel();


            newM3ITransaction=M3I.Transaction(newSharedM3IModel);
            autosar.updater.copyXmlOptions(oldSharedM3IModel,newSharedM3IModel);
            autosar.updater.copyCSErrorArgs(sharedElementsMatcher,oldSharedM3IModel);
            newM3ITransaction.commit();
        end

        function[ddConn,deleteTempDict]=createTempDictionary()
            import autosar.composition.mm2sl.ComponentAndCompositionBuilder

            tempDictName=[tempname,'.sldd'];
            ddConn=Simulink.data.dictionary.create(tempDictName);
            deleteTempDict=onCleanup(@()ComponentAndCompositionBuilder.deleteTempDictionary(ddConn.filepath));
        end

        function deleteTempDictionary(dictPath)
            [~,f,e]=fileparts(dictPath);
            Simulink.data.dictionary.closeAll([f,e],'-discard');
            delete(dictPath);
        end

        function activateM3IModelListener(compositionModelName)


            refMdls=find_mdlrefs(compositionModelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'KeepModelsLoaded',true);
            for mdlIdx=1:length(refMdls)
                refMdl=refMdls{mdlIdx};
                if autosar.api.Utils.isMapped(refMdl)
                    compM3IModel=autosar.api.Utils.m3iModel(refMdl);
                    autosar.ui.utils.registerListenerCB(compM3IModel);
                end
            end
        end

        function registerNewSharedM3IModelWithDictionary(compositionModelName,...
            modelsInsideOrigComposition,oldSharedM3IModel,newSharedM3IModel,...
            existingDDConn,newDDConn)

            autosar.dictionary.Utils.registerM3IModelWithDictionary(...
            newSharedM3IModel,existingDDConn.filepath);
            autosar.dictionary.Utils.registerM3IModelWithDictionary(...
            oldSharedM3IModel,newDDConn.filepath);





            modelsInsideNewComposition=find_mdlrefs(compositionModelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'KeepModelsLoaded',true);
            refMdls=unique([modelsInsideNewComposition;modelsInsideOrigComposition],'stable');
            for mdlIdx=1:length(refMdls)
                refMdl=refMdls{mdlIdx};
                if autosar.api.Utils.isMapped(refMdl)
                    autosar.dictionary.Utils.updateModelMappingWithDictionary(...
                    refMdl,existingDDConn.filepath);
                    set_param(refMdl,'Dirty','on');
                end
                save_system(refMdl);
            end
        end
    end
end


