classdef AtomicSwComponentBuilder<handle





    properties(Access=protected)
        XmlOptsGetter;
        ImporterObj;
        IsUpdateMode;
        TopCompositionModel;
        CompositionArgParser;
        MMChangeLoggers=[];
        SLChangeLoggers=[];
        M3IModelSplitter;
        SharedElementsChangeLogger;
        CompositionQName=[];
        ExistingComponentModels=[];
        ComponentToModelMap=[];
        ProgressTracker=[];
    end

    methods
        function this=AtomicSwComponentBuilder(importerObj,xmlOptsGetter,...
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


            if this.IsUpdateMode
                assert(~isempty(this.TopCompositionModel),'TopCompositionModel is empty.');
                if isempty(find_system('type','block_diagram','name',this.TopCompositionModel))
                    DAStudio.error('RTW:autosar:mdlNotLoaded',this.TopCompositionModel);
                end
            end
        end

        function modelNames=importOrUpdateAtomicComponents(this,m3iComposition)




            import autosar.composition.mm2sl.AtomicSwComponentBuilder;


            compFinder=autosar.composition.mm2sl.ComponentAndCompositionFinder(m3iComposition,this.M3IModelSplitter);
            m3iComponents=compFinder.getAtomicComponents();
            numComponents=m3iComponents.size();

            this.CompositionQName=autosar.api.Utils.getQualifiedName(m3iComposition);


            this.ExistingComponentModels=this.parseComponentModelsArgument(...
            m3iComposition,m3iComponents);


            if this.IsUpdateMode
                this.ComponentToModelMap=AtomicSwComponentBuilder.getComponentToModelMap(this.TopCompositionModel);
            end


            compCounter=numel(this.ExistingComponentModels.keys)+1;
            this.ProgressTracker=this.getProgressTracker(numComponents,compCounter);


            modelNames=this.doImport(numComponents,m3iComponents,m3iComposition);
        end

        function mmChangeLoggers=getMMChangeLoggers(this)
            mmChangeLoggers=this.MMChangeLoggers;
        end

        function slChangeLoggers=getSLChangeLoggers(this)
            slChangeLoggers=this.SLChangeLoggers;
        end
    end

    methods(Access=protected)
        function[compQName,modelName,didImportOrUpdate]=importOrUpdateAtomicComponent(this,m3iComponent,m3iSwcTimings)

            import autosar.composition.mm2sl.AtomicSwComponentBuilder;

            compQName=[];
            modelName=[];
            didImportOrUpdate=false;


            isSupported=this.checkAtomicComponentSupported(m3iComponent);
            if~isSupported
                return;
            end


            compName=m3iComponent.Name;
            modelName=compName;
            if this.IsUpdateMode&&this.ComponentToModelMap.isKey(compName)
                modelName=this.ComponentToModelMap(compName);
            end

            compQName=autosar.api.Utils.getQualifiedName(m3iComponent);
            if this.ExistingComponentModels.isKey(compQName)
                modelName=this.ExistingComponentModels(compQName);
            elseif AtomicSwComponentBuilder.modelLoadedOrExists(modelName)
                if~this.CompositionArgParser.ExcludeInternalBehavior
                    if this.IsUpdateMode
                        if~bdIsLoaded(modelName)
                            load_system(modelName);
                        end


                        this.callUpdateModel(modelName,m3iComponent);
                        didImportOrUpdate=true;
                    else


                        autosar.mm.mm2sl.ModelBuilder.checkModelFileName(modelName,'error');
                        assert(false,'checkModelFileName should error out for conflict with model name: %s',modelName);
                    end
                end
            else
                if~this.CompositionArgParser.ExcludeInternalBehavior

                    m3iSwcTiming=autosar.timing.Utils.findM3iTimingAmongstTimingsForM3iComp(m3iSwcTimings,m3iComponent);
                    this.importAtomicComponent(m3iComponent,m3iSwcTiming);
                    didImportOrUpdate=true;
                end
            end
        end

        function progressTracker=getProgressTracker(this,numComponents,compCounter)
            if~this.IsUpdateMode
                progressTracker=autosar.composition.mm2sl.progresstracker.ImportProgressTracker(numComponents,compCounter);
            else
                progressTracker=autosar.composition.mm2sl.progresstracker.UpdateProgressTracker(numComponents,compCounter);
            end
        end

        function modelNames=doImport(this,numComponents,m3iComponents,m3iComposition)
            modelNames=containers.Map();
            m3iSwcTimings=autosar.timing.Utils.findM3iSwcTimings(m3iComposition.rootModel);

            for idx=1:numComponents
                m3iComponent=m3iComponents.at(idx);
                [compQName,modelName,didImportOrUpdate]=this.importOrUpdateAtomicComponent(m3iComponent,m3iSwcTimings);
                if~isempty(compQName)
                    if didImportOrUpdate
                        this.ProgressTracker.displayAndIncrementProgress(modelName,compQName);
                    end
                    modelNames(compQName)=modelName;
                end
            end
        end
    end

    methods(Static)
        function modelAvailable=modelLoadedOrExists(modelName)


            modelAvailable=bdIsLoaded(modelName)||...
            exist(fullfile(pwd,modelName),'file')==4;
        end


        function resetCompuMethodExternalToolInfo(m3iModel)
            tranaction=M3I.Transaction(m3iModel);
            toolId=autosar.ui.metamodel.PackageString.SlDataTypesToolID;
            m3iCompuMethods=autosar.mm.Model.findChildByTypeName(m3iModel,...
            'Simulink.metamodel.types.CompuMethod',true,true);
            needToCommitTransaction=false;
            for i=1:length(m3iCompuMethods)
                m3iObj=m3iCompuMethods{i};
                slTypeNamesStr=m3iObj.getExternalToolInfo(toolId).externalId;
                if~isempty(slTypeNamesStr)
                    m3iObj.setExternalToolInfo(M3I.ExternalToolInfo(toolId,''));
                    needToCommitTransaction=true;
                end
            end
            if needToCommitTransaction
                tranaction.commit();
            else
                tranaction.cancel();
            end
        end
    end

    methods(Static,Sealed)
        function builder=getBuilder(importerObj,xmlOptsGetter,compositionArgParser,varargin)


            if compositionArgParser.UseParallel
                builder=autosar.composition.mm2sl.parallel.ParallelAtomicSwComponentBuilder(importerObj,xmlOptsGetter,compositionArgParser,varargin{:});
            else
                builder=autosar.composition.mm2sl.AtomicSwComponentBuilder(importerObj,xmlOptsGetter,compositionArgParser,varargin{:});
            end
        end
    end

    methods(Static,Access=protected)


        function componentToModelMap=getComponentToModelMap(topCompositionModel)


            refMdls=find_mdlrefs(topCompositionModel,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'KeepModelsLoaded',true);
            refMdls=unique(refMdls(1:end-1));
            componentToModelMap=containers.Map();
            for mdlIdx=1:length(refMdls)
                refMdl=refMdls{mdlIdx};
                if autosar.api.Utils.isMapped(refMdl)
                    modelMapping=autosar.api.Utils.modelMapping(refMdl);
                    if isa(modelMapping,'Simulink.AutosarTarget.ModelMapping')
                        componentName=modelMapping.MappedTo.Name;
                        componentToModelMap(componentName)=refMdl;
                    end
                end
            end
        end
    end

    methods(Access=private)
        function modelName=importAtomicComponent(this,m3iComponent,m3iSwcTiming)


            import autosar.composition.mm2sl.AtomicSwComponentBuilder;
            argParser=this.CompositionArgParser;
            importerObj=this.ImporterObj;
            xmlOptsGetter=this.XmlOptsGetter;


            args={...
            'ModelPeriodicRunnablesAs',argParser.ModelPeriodicRunnablesAs,...
            'DataDictionary',argParser.DataDictionary,...
            'OpenModel',false,...
            'NameConflictAction','overwrite',...
            'AutoSave',true,...
            'UseBusElementPorts',argParser.UseBusElementPorts,...
            'AutosarSchemaVersion',importerObj.getSchemaVer()};

            m3iModel=m3iComponent.rootModel;
            isSharingAUTOSARProps=~isempty(this.M3IModelSplitter);



            if~isSharingAUTOSARProps
                AtomicSwComponentBuilder.resetCompuMethodExternalToolInfo(m3iModel);
            end


            slChangeLogger=autosar.updater.ChangeLogger();
            builder=autosar.mm.mm2sl.ModelBuilder(m3iModel,argParser.DataDictionary,...
            argParser.ShareAUTOSARProperties,slChangeLogger,xmlOptsGetter,...
            m3iSwcTiming,PredefinedVariant=argParser.PredefinedVariant,SystemConstValueSets=argParser.SystemConstValueSets);
            componentQName=autosar.api.Utils.getQualifiedName(m3iComponent);
            modelH=builder.createApplicationComponent(componentQName,args{:});
            success=modelH~=-1;

            if~success
                DAStudio.error('autosarstandard:importer:FailedToImportComponent',componentQName);
            end


            modelName=get_param(modelH,'Name');
            assert(strcmp(get_param(modelName,'Dirty'),'off'),...
            'model %s should have been saved after call to createComponentAsModel',modelName);








            if~isSharingAUTOSARProps
                mapping=autosar.api.Utils.modelMapping(modelName);
                mapping.AUTOSAR_ROOT=[];
            end
        end

        function callUpdateModel(this,modelName,m3iComponent)



            import autosar.composition.mm2sl.AtomicSwComponentBuilder;
            argParser=this.CompositionArgParser;
            importerObj=this.ImporterObj;
            xmlOptsGetter=this.XmlOptsGetter;

            isSharingAUTOSARProps=~isempty(this.M3IModelSplitter);


            args={...
            'PredefinedVariant',argParser.PredefinedVariant,...
            'SystemConstValueSets',argParser.SystemConstValueSets,...
            'LaunchReport','off'...
            ,'OpenModel',false,...
            'AutoDelete',true,...
            'XmlOptsGetter',xmlOptsGetter};

            if isSharingAUTOSARProps
                args=[args,{'SharedElementsChangeLogger',this.SharedElementsChangeLogger}];
            end



            if~isSharingAUTOSARProps
                AtomicSwComponentBuilder.resetCompuMethodExternalToolInfo(importerObj.getM3IModel());
            end


            [mmChangeLogger,slChangeLogger]=importerObj.p_component_updateModel(...
            modelName,m3iComponent.rootModel,args{:});
            this.MMChangeLoggers=[this.MMChangeLoggers,mmChangeLogger];
            this.SLChangeLoggers=[this.SLChangeLoggers,slChangeLogger];




            save_system(modelName);
            if~isSharingAUTOSARProps
                mapping=autosar.api.Utils.modelMapping(modelName);
                mapping.AUTOSAR_ROOT=[];
            end



            importerObj.setNeedReadUpdate(false);
        end




        function componentToModelMap=parseComponentModelsArgument(...
            this,m3iComposition,m3iComponents)

            compositionArgParser=this.CompositionArgParser;
            componentModelsArg=compositionArgParser.ComponentModels;
            assert(iscell(componentModelsArg),'componentModels argument should be cell array.');

            componentToModelMap=containers.Map;
            if isempty(componentModelsArg)
                return
            end


            componentModelsArg=unique(componentModelsArg);


            compQNamesInComposition=m3i.mapcell(@(x)autosar.api.Utils.getQualifiedName(x),m3iComponents);

            componentModelErrors=[];
            compositionQName=autosar.api.Utils.getQualifiedName(m3iComposition);
            numComponents=m3iComponents.size();
            componentStr=message('autosarstandard:importer:Component').getString();
            for mdlIdx=1:length(componentModelsArg)
                modelName=componentModelsArg{mdlIdx};
                validateattributes(modelName,{'char'},{'row'},'','model');


                if exist(modelName,'file')~=4
                    componentModelErrors{end+1}=message(...
                    'autosarstandard:importer:ComponentModelDoesNotExist',modelName);%#ok<AGROW>
                    continue;
                end

                if~bdIsLoaded(modelName)
                    load_system(modelName);
                end


                if~autosar.api.Utils.isMappedToComponent(modelName)
                    componentModelErrors{end+1}=message(...
                    'autosarstandard:importer:ComponentModelNotMapped',modelName);%#ok<AGROW>
                    continue;
                end



                dataObj=autosar.api.getAUTOSARProperties(modelName,true);
                compQName=dataObj.get('XmlOptions','ComponentQualifiedName');
                if~any(strcmp(compQName,compQNamesInComposition))
                    componentModelErrors{end+1}=message(...
                    'autosarstandard:importer:ComponentModelNotPartOfComposition',...
                    modelName,compQName,compositionQName);%#ok<AGROW>
                    continue;
                end


                if componentToModelMap.isKey(compQName)
                    model1=modelName;
                    model2=componentToModelMap(compQName);
                    componentModelErrors{end+1}=message(...
                    'autosarstandard:importer:ComponentModelMultipleModelsMappedToSameSWC',...
                    model1,model2,compQName);%#ok<AGROW>
                    continue;
                end





                oldM3IComp=autosar.mm.Model.findChildByName(...
                autosar.api.Utils.m3iModel(modelName),compQName);
                newM3IComp=m3iComponents.at(find(strcmp(compQName,compQNamesInComposition)));
                oldM3IPPorts=autosar.mm.Model.findObjectByMetaClass(oldM3IComp,...
                Simulink.metamodel.arplatform.port.ProvidedPort.MetaClass,true,true);
                newM3IPPorts=autosar.mm.Model.findObjectByMetaClass(newM3IComp,...
                Simulink.metamodel.arplatform.port.ProvidedPort.MetaClass,true,true);
                oldM3IRPorts=autosar.mm.Model.findObjectByMetaClass(oldM3IComp,...
                Simulink.metamodel.arplatform.port.RequiredPort.MetaClass,true,true);
                newM3IRPorts=autosar.mm.Model.findObjectByMetaClass(newM3IComp,...
                Simulink.metamodel.arplatform.port.RequiredPort.MetaClass,true,true);

                sameRPorts=isequal(sort(m3i.mapcell(@autosar.api.Utils.getQualifiedName,oldM3IRPorts)),...
                sort(m3i.mapcell(@autosar.api.Utils.getQualifiedName,newM3IRPorts)));
                samePPorts=isequal(sort(m3i.mapcell(@autosar.api.Utils.getQualifiedName,oldM3IPPorts)),...
                sort(m3i.mapcell(@autosar.api.Utils.getQualifiedName,newM3IPPorts)));

                if~sameRPorts||~samePPorts
                    componentModelErrors{end+1}=message(...
                    'autosarstandard:importer:ComponentModelInconsistentPorts',...
                    modelName,compQName);%#ok<AGROW>
                    continue;
                end



                if compositionArgParser.ShareAUTOSARProperties
                    ddConn=Simulink.data.dictionary.open(compositionArgParser.DataDictionary);
                    dictFileForImport=ddConn.filepath();
                    [isSharedDict,modelDictFiles]=autosarcore.ModelUtils.isUsingSharedAutosarDictionary(modelName);
                    if~isempty(modelDictFiles)
                        assert(numel(modelDictFiles)==1,'Expected model to be linked to a single shared AUTOSAR dictionary.');
                        modelDictFile=modelDictFiles{1};
                    end
                    if~isSharedDict||(isSharedDict&&~strcmp(modelDictFile,dictFileForImport))
                        DAStudio.error('autosarstandard:importer:ComponentModelsNotSupportedWithShareAUTOSARProperties',...
                        modelName,dictFileForImport);
                    end
                end

                autosar.mm.util.MessageReporter.print(message(...
                'autosarstandard:importer:CompositionImportProgressReuse',...
                modelName,componentStr,int2str(mdlIdx),int2str(numComponents),compQName).getString());
                componentToModelMap(compQName)=modelName;
            end


            if~isempty(componentModelErrors)
                baseErrId='autosarstandard:importer:ComponentModelsErrorSummary';
                baseME=MException(baseErrId,message(baseErrId).getString());
                for errIdx=1:length(componentModelErrors)
                    baseME=baseME.addCause(MException(componentModelErrors{errIdx}.Identifier,...
                    componentModelErrors{errIdx}.getString()));
                end
                baseME.throw();
            end
        end



        function isSupported=checkAtomicComponentSupported(this,m3iComp)
            isSupported=autosar.composition.Utils.isAtomicComponentSupported(m3iComp);
            if~isSupported
                autosar.mm.util.MessageReporter.createWarning(...
                'autosarstandard:importer:UnsupportedAtomicComponentImport',...
                autosar.api.Utils.getQualifiedName(m3iComp),...
                this.CompositionQName,m3iComp.Kind.toString());
            end
        end
    end
end



