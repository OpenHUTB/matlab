classdef SLCompositionBuilder<handle





    properties(Access=private)
        ImporterObj;
        XmlOptsGetter;
        CompositionArgParser;
        IsUpdateMode;
        TopCompositionModel;
        M3IModelSplitter;

        MMChangeLoggers;
        SLChangeLoggers;

        SharedElementsChangeLogger;
    end

    methods
        function this=SLCompositionBuilder(importerObj,xmlOptsGetter,...
            compositionArgParser,varargin)


            argParser=inputParser;
            argParser.addRequired('importerObj',@(x)isa(x,'arxml.importer'));
            argParser.addRequired('xmlOptsGetter',@(x)isa(x,'autosar.mm.util.XmlOptionsGetter'));
            argParser.addRequired('compositionArgParser',@(x)isa(x,'autosar.composition.mm2sl.private.ArgumentParser'));
            argParser.addParameter('IsUpdateMode',false,@(x)(islogical(x)));
            argParser.addParameter('TopCompositionModel','',@(x)(ischar(x)));
            argParser.addParameter('M3IModelSplitter',[]);
            argParser.addParameter('SharedElementsChangeLogger',[]);
            argParser.parse(importerObj,xmlOptsGetter,compositionArgParser,varargin{:});

            this.ImporterObj=importerObj;
            this.XmlOptsGetter=xmlOptsGetter;
            this.CompositionArgParser=compositionArgParser;
            this.IsUpdateMode=argParser.Results.IsUpdateMode;
            this.TopCompositionModel=argParser.Results.TopCompositionModel;
            this.M3IModelSplitter=argParser.Results.M3IModelSplitter;
            this.SharedElementsChangeLogger=argParser.Results.SharedElementsChangeLogger;

            this.MMChangeLoggers=[];
            this.SLChangeLoggers=[];
        end

        function modelNames=importOrUpdateCompositionComponents(this,m3iTopComposition)





            import autosar.composition.mm2sl.SLCompositionBuilder;


            compFinder=autosar.composition.mm2sl.ComponentAndCompositionFinder(m3iTopComposition,this.M3IModelSplitter);
            m3iCompositions=compFinder.getCompositions();

            numCompositions=m3iCompositions.size();


            if this.IsUpdateMode
                compositionToModelMap=SLCompositionBuilder.getCompositionToModelMap(this.TopCompositionModel);
            end


            modelNames=[];
            compositionStr=message('autosarstandard:importer:Composition').getString();
            for idx=1:numCompositions
                m3iComposition=m3iCompositions.at(idx);
                compositionQName=autosar.api.Utils.getQualifiedName(m3iComposition);
                isTopCompositionModel=idx==numCompositions;


                compositionName=m3iComposition.Name;
                modelName=compositionName;
                if this.IsUpdateMode&&compositionToModelMap.isKey(compositionName)
                    modelName=compositionToModelMap(compositionName);
                end

                if autosar.composition.mm2sl.AtomicSwComponentBuilder.modelLoadedOrExists(modelName)
                    if this.IsUpdateMode
                        if~bdIsLoaded(modelName)
                            load_system(modelName);
                        end

                        autosar.mm.util.MessageReporter.print(message(...
                        'autosarstandard:importer:CompositionImportProgressUpdate',...
                        modelName,compositionStr,int2str(idx),int2str(numCompositions),compositionQName).getString());
                        this.callUpdateModel(modelName,m3iComposition,isTopCompositionModel);
                    else


                        autosar.mm.mm2sl.ModelBuilder.checkModelFileName(modelName,'error');
                        assert(false,'checkModelFileName should error out for conflict with model name: %s',modelName);
                    end
                else

                    autosar.mm.util.MessageReporter.print(message(...
                    'autosarstandard:importer:CompositionImportProgress',...
                    modelName,compositionStr,int2str(idx),int2str(numCompositions),compositionQName).getString());
                    this.importCompositionComponent(m3iComposition,...
                    isTopCompositionModel);
                end
                modelNames{end+1}=modelName;%#ok<AGROW>
            end
        end

        function mmChangeLoggers=getMMChangeLoggers(this)
            mmChangeLoggers=this.MMChangeLoggers;
        end

        function slChangeLoggers=getSLChangeLoggers(this)
            slChangeLoggers=this.SLChangeLoggers;
        end
    end

    methods(Static,Access=private)


        function compositionToModelMap=getCompositionToModelMap(topCompositionModel)


            refMdls=find_mdlrefs(topCompositionModel,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'KeepModelsLoaded',true);
            refMdls=unique(refMdls);
            compositionToModelMap=containers.Map();
            for mdlIdx=1:length(refMdls)
                refMdl=refMdls{mdlIdx};
                if autosar.api.Utils.isMapped(refMdl)
                    modelMapping=autosar.api.Utils.modelMapping(refMdl);
                    if isa(modelMapping,'Simulink.AutosarTarget.CompositionModelMapping')
                        componentName=modelMapping.MappedTo.Name;
                        compositionToModelMap(componentName)=refMdl;
                    end
                end
            end
        end
    end

    methods(Access=private)
        function modelName=importCompositionComponent(this,...
            m3iComposition,isTopCompositionModel)


            import autosar.composition.mm2sl.SLCompositionBuilder

            argParser=this.CompositionArgParser;
            importerObj=this.ImporterObj;
            xmlOptsGetter=this.XmlOptsGetter;

            m3iModel=m3iComposition.rootModel;

            isSharingAUTOSARProps=~isempty(this.M3IModelSplitter);
            if~isSharingAUTOSARProps


                autosar.composition.mm2sl.AtomicSwComponentBuilder....
                resetCompuMethodExternalToolInfo(m3iModel);
            end


            changeLogger=autosar.updater.ChangeLogger();
            isUpdateMode=false;
            isAdaptive=false;
            schemaVer=autosar.mm.util.getSchemaVersionForConfigSet(importerObj.getSchemaVer,isAdaptive);
            compositionBuilder=autosar.composition.mm2sl.ModelBuilder(...
            m3iModel,argParser.ShareAUTOSARProperties,schemaVer,...
            changeLogger,xmlOptsGetter,isUpdateMode);


            modelName=m3iComposition.Name;
            modelH=compositionBuilder.createComposition(m3iComposition,...
            modelName,argParser.DataDictionary,argParser.ComponentModels);

            if modelH==-1
                DAStudio.error('autosarstandard:importer:FailedToImportComponent',compositionQName);
            end





            modelName=get_param(modelH,'Name');
            save_system(modelName,modelName,'SaveDirtyReferencedModels','on');








            if~isSharingAUTOSARProps
                mapping=autosar.api.Utils.modelMapping(modelName);
                mapping.AUTOSAR_ROOT=[];
            end

            if isTopCompositionModel
                SLCompositionBuilder.showImportedCompositionModel(modelName);
            end
        end

        function callUpdateModel(this,modelName,m3iComposition,isTopCompositionModel)



            argParser=this.CompositionArgParser;
            importerObj=this.ImporterObj;
            xmlOptsGetter=this.XmlOptsGetter;

            isSharingAUTOSARProps=~isempty(this.M3IModelSplitter);


            if isTopCompositionModel
                args={'LaunchReport',argParser.LaunchReport,'OpenModel',true};
            else
                args={'LaunchReport','off','OpenModel',false};
            end
            args=[args,{'AutoDelete',true,'XmlOptsGetter',xmlOptsGetter}];

            if isSharingAUTOSARProps
                args=[args,{'SharedElementsChangeLogger',this.SharedElementsChangeLogger}];
            end



            if~isSharingAUTOSARProps
                autosar.composition.mm2sl.AtomicSwComponentBuilder....
                resetCompuMethodExternalToolInfo(importerObj.getM3IModel());
            end


            [mmChangeLogger,slChangeLogger]=importerObj.p_component_updateModel(...
            modelName,m3iComposition.rootModel,args{:});
            this.MMChangeLoggers=[this.MMChangeLoggers,mmChangeLogger];
            this.SLChangeLoggers=[this.SLChangeLoggers,slChangeLogger];





            save_system(modelName,modelName,'SaveDirtyReferencedModels','on');



            if~isSharingAUTOSARProps
                mapping=autosar.api.Utils.modelMapping(modelName);
                mapping.AUTOSAR_ROOT=[];
            end



            if~isTopCompositionModel
                importerObj.setNeedReadUpdate(false);
            end
        end
    end

    methods(Static,Access=private)
        function showImportedCompositionModel(modelName)


            ddName=get_param(modelName,'DataDictionary');
            if~isempty(ddName)
                ddObj=Simulink.data.dictionary.open(ddName);
                ddObj.show();
                ddObj.close();
            end


            open_system(modelName);
        end
    end
end



