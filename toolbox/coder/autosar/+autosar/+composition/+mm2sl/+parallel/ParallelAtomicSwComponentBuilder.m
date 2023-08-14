classdef ParallelAtomicSwComponentBuilder<autosar.composition.mm2sl.AtomicSwComponentBuilder





    properties(Access=private)
        ImporterObjValueContainer=[];
    end

    methods
        function this=ParallelAtomicSwComponentBuilder(importerObj,xmlOptsGetter,...
            compositionArgParser,varargin)

            this=this@autosar.composition.mm2sl.AtomicSwComponentBuilder(importerObj,xmlOptsGetter,...
            compositionArgParser,varargin{:});

            if this.IsUpdateMode
                assert(false,'Parallel import in update mode is not supported');
            end

        end
    end

    methods(Access=protected)
        function modelNames=doImport(this,numComponents,~,~)

            import autosar.composition.mm2sl.parallel.ParallelAtomicSwComponentBuilder;

            poolObj=ParallelAtomicSwComponentBuilder.findOrCreateParallelPool();


            this.ImporterObjValueContainer=parallel.pool.Constant(@()this.readDataModel());
            m3iTopCompositionValueContainer=parallel.pool.Constant(@()this.getTopComposition());
            m3iComponentsValueContainer=parallel.pool.Constant(@()this.findComponentsToImport(m3iTopCompositionValueContainer));
            m3iSwcTimingsValueContainer=parallel.pool.Constant(@()this.getM3iSwcTimings(m3iTopCompositionValueContainer));




            future(1:numComponents)=parallel.FevalFuture;
            [modelNames,baseException]=this.doImportAtWorker(poolObj,future,numComponents,m3iComponentsValueContainer,m3iSwcTimingsValueContainer);

            if~isempty(baseException)
                autosar.mm.util.MessageReporter.throwException(baseException);
            end


            load_system(modelNames.values);
        end

        function[compQName,modelName,status]=importOrUpdateAtomicComponent(this,idx,m3iComponentsValueContainer,m3iSwcTimingsValueContainer)


            status=autosar.composition.mm2sl.parallel.ParallelTaskStatus();

            this.ImporterObj=this.ImporterObjValueContainer.Value;
            m3iComponents=m3iComponentsValueContainer.Value;
            m3iSwcTimings=m3iSwcTimingsValueContainer.Value;
            m3iComponent=m3iComponents.at(idx);
            componentName=autosar.api.Utils.getQualifiedName(m3iComponent);

            try
                cleanupObj=onCleanup(@()bdclose(componentName));
                [compQName,modelName,didImport]=importOrUpdateAtomicComponent@autosar.composition.mm2sl.AtomicSwComponentBuilder(...
                this,m3iComponent,m3iSwcTimings);
                status.setImportState(didImport);
            catch E
                compQName=componentName;
                modelName=[];
                status.setError(E);
            end

        end
    end

    methods(Static,Access=private)
        function poolObj=findOrCreateParallelPool()
            if isempty(gcp('nocreate'))
                poolObj=parpool;
            else
                poolObj=gcp;
            end
        end

        function m3iSwcTimings=getM3iSwcTimings(m3iTopCompositionValueContainer)
            m3iTopComposition=m3iTopCompositionValueContainer.Value;
            m3iSwcTimings=autosar.timing.Utils.findM3iSwcTimings(m3iTopComposition.rootModel);
        end

        function displayWarnings(warnings)
            for i=1:length(warnings)
                DAStudio.warning(warnings(i).identifier,warnings(i).arguments{:});
            end
        end
    end

    methods(Access=private)
        function importerObj=readDataModel(this)
            importerObj=this.ImporterObj;
            importerObj.getComponentNames;
        end

        function m3iTopComposition=getTopComposition(this)
            importerObj=this.ImporterObjValueContainer.Value;
            m3iModel=importerObj.getM3IModel;
            m3iTopComposition=autosar.mm.Model.findChildByName(m3iModel,this.CompositionQName);
        end

        function m3iComponents=findComponentsToImport(this,m3iCompositionValueContainer)
            m3iComposition=m3iCompositionValueContainer.Value;
            compFinder=autosar.composition.mm2sl.ComponentAndCompositionFinder(m3iComposition,this.M3IModelSplitter);
            m3iComponents=compFinder.getAtomicComponents();
        end

        function[modelNames,baseException]=doImportAtWorker(this,poolObj,future,numComponents,m3iComponentsValueContainer,m3iSwcTimingsValueContainer)

            import autosar.composition.mm2sl.parallel.ParallelAtomicSwComponentBuilder;

            cleanupObj=onCleanup(@()cancel([poolObj.FevalQueue.RunningFutures,poolObj.FevalQueue.QueuedFutures]));


            expectedOutputArgs=3;
            for idx=1:numComponents
                future(idx)=parfeval(@this.importOrUpdateAtomicComponent,expectedOutputArgs,idx,m3iComponentsValueContainer,m3iSwcTimingsValueContainer);
            end

            modelNames=containers.Map();
            errID='autosarstandard:importer:MissingComponentsForCompositionImport';
            baseException=MException(errID,message(errID,this.CompositionQName).getString());


            for idx=1:numComponents
                [~,compQName,modelName,status]=fetchNext(future);
                if status.IsSuccess
                    if~isempty(compQName)
                        if status.DidImport
                            this.ProgressTracker.displayAndIncrementProgress(modelName,compQName);
                        end
                        modelNames(compQName)=modelName;
                    end
                    ParallelAtomicSwComponentBuilder.displayWarnings(status.Warnings);

                else
                    exception=status.Error;
                    importErrID='autosarstandard:importer:FailedToImport';
                    baseException=baseException.addCause(MSLException([],importErrID,message(importErrID,compQName,exception.message).getString()));
                    DAStudio.warning(importErrID,compQName,exception.message);
                end
            end

            if isempty(baseException.cause)
                baseException=[];
            end
        end
    end
end


