function[mmChangeLogger,slChangeLogger]=p_component_updateModel(this,modelName,newM3IModel,varargin)





    import autosar.mm.Model;
    import autosar.api.getAUTOSARProperties;

    argParser=inputParser;
    argParser.addParameter('LaunchReport','off',@(x)(any(validatestring(x,{'on','off'}))));
    argParser.addParameter('PredefinedVariant','',@(x)(ischar(x)||isStringScalar(x)));
    argParser.addParameter('SystemConstValueSets','',@(x)(iscell(x)));
    argParser.addParameter('OpenModel',true,@(x)(islogical(x)));
    argParser.addParameter('AutoDelete',false,@(x)(islogical(x)));
    argParser.addParameter('XmlOptsGetter',...
    autosar.mm.util.XmlOptionsGetter.empty(),@(x)(isa(x,'autosar.mm.util.XmlOptionsGetter')));
    argParser.addParameter('ForceLegacyWorkspaceBehavior',false,@(x)(islogical(x)));
    argParser.addParameter('ImportInternalTriggers',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
    argParser.addParameter('SharedElementsChangeLogger',[],@(x)(isa(x,'autosar.updater.ChangeLogger')));
    argParser.parse(varargin{:});


    systems=find_system('type','block_diagram','name',modelName);
    if isempty(systems)
        DAStudio.error('RTW:autosar:mdlNotLoaded',modelName);
    end


    isCompliant=strcmp(get_param(modelName,'AutosarCompliant'),'on');
    if~isCompliant
        DAStudio.error('RTW:autosar:nonAutosarCompliant');
    end

    isAdaptiveApplication=autosar.api.Utils.isMappedToAdaptiveApplication(modelName);
    if isAdaptiveApplication
        DAStudio.error('autosarstandard:importer:updateModelAdaptive');
    end


    interfaceDicts=SLDictAPI.getTransitiveInterfaceDictsForModel(modelName);
    if~isempty(interfaceDicts)
        dictsNoPath=autosar.utils.File.dropPath(interfaceDicts);
        DAStudio.error('interface_dictionary:workflows:NotSupportedForModelLinkedToInterfaceDict',...
        'arxml.importer.updateModel',modelName,autosar.api.Utils.cell2str(dictsNoPath));
    end


    autosar_ui_close(modelName);



    this.needReadUpdate=true;


    autosar.mm.util.MessageReporter.print(...
    message('RTW:autosar:updatingModel',modelName).getString());


    modelNameForBackup=autosar.utils.SimulinkModelCloner.backupModel(modelName);


    oldM3IModel=autosar.api.Utils.m3iModel(modelName);


    oldM3ITransaction=M3I.Transaction(oldM3IModel);
    newM3ITransaction=M3I.Transaction(newM3IModel);

    dataObj=getAUTOSARProperties(modelName,true);
    oldM3IComp=Model.findChildByName(oldM3IModel,...
    dataObj.get('XmlOptions','ComponentQualifiedName'));


    isSharingAUTOSARProps=Simulink.AutosarDictionary.ModelRegistry.hasReferencedModels(oldM3IModel);
    if isSharingAUTOSARProps



        sharedElementsChangeLogger=argParser.Results.SharedElementsChangeLogger;
        assert(~isempty(sharedElementsChangeLogger),'empty logger for shared props');
        mmChangeLogger=sharedElementsChangeLogger.clone();
    else
        mmChangeLogger=autosar.updater.ChangeLogger();
    end

    isCompositionComponent=autosar.composition.Utils.isM3IComposition(oldM3IComp);



    matcher=Simulink.metamodel.arplatform.ElementMatcher(newM3IModel,oldM3IModel);
    matcher.match();




    if~isSharingAUTOSARProps
        autosar.updater.copyCSErrorArgs(matcher,oldM3IModel);
    end


    comparator=autosar.updater.Comparator(newM3IModel,oldM3IModel,matcher,mmChangeLogger);
    comparator.compare();


    newM3IComp=matcher.getFirst(oldM3IComp);
    if~newM3IComp.isvalid()
        DAStudio.error('autosarstandard:importer:updateUnmatchedComponent',autosar.api.Utils.getQualifiedName(oldM3IComp),...
        autosar.api.Utils.getUUID(oldM3IComp));
    end

    if~isCompositionComponent

        mappingObj=autosar.api.getSimulinkMapping(modelName);
        oldInitRunnableName=mappingObj.getFunction('Initialize');
        oldResetRunnableNames=i_getResetFunctions(modelName);
        oldTerminateRunnableName=i_getTerminateFunction(modelName);

        initializationRunnable=i_matchIRTRunnable(oldInitRunnableName,oldM3IComp,matcher);
        resetRunnables=cellfun(@(x)i_matchIRTRunnable(x,oldM3IComp,matcher),oldResetRunnableNames,'UniformOutput',false);
        terminateRunnable=i_matchIRTRunnable(oldTerminateRunnableName,oldM3IComp,matcher);


        newM3iSwcTiming=autosar.timing.Utils.findM3iTimingForM3iComponent(newM3IModel,newM3IComp);



        modelingStyleDeterminer=autosar.mm.mm2sl.PeriodicRunnablesModelingStyleDeterminer(...
        newM3IComp,initializationRunnable,resetRunnables,terminateRunnable,newM3iSwcTiming);
        isExportFcnModel=autosar.validation.ExportFcnValidator.isExportFcn(modelName);
        if isExportFcnModel
            modelingStyle='FunctionCallSubsystem';
        else
            modelingStyle='AtomicSubsystem';
        end
        [isStyleSupported,~,limitationMsgObj]=modelingStyleDeterminer.isStyleSupported(modelingStyle);

        if~isStyleSupported
            msgId='autosarstandard:importer:NonCompatibleModelingStyles';
            newException=MException(msgId,DAStudio.message(msgId,modelName));
            arguments=[limitationMsgObj.Arguments,{''}];
            causeME=MException(limitationMsgObj.Identifier,DAStudio.message(limitationMsgObj.Identifier,...
            arguments{:}));
            throw(addCause(newException,causeME));
        end

        if strcmp(modelingStyle,'AtomicSubsystem')&&...
            (autosar.mm.mm2sl.RunnableHelper.getPeriodicRunnablesCount(newM3IComp)==1)
            oldStepRunnableName=mappingObj.getFunction('Periodic');
            for rIndex=1:oldM3IComp.Behavior.Runnables.size()
                oldStepRunnable=oldM3IComp.Behavior.Runnables.at(rIndex);
                if strcmp(oldStepRunnable.Name,oldStepRunnableName)

                    newStepRunnable=matcher.getFirst(oldStepRunnable);
                    if newStepRunnable.isvalid()
                        stepRunnable=newStepRunnable.Name;
                    else
                        stepRunnable='';
                    end
                end
            end

            if isempty(stepRunnable)
                DAStudio.error('RTW:autosar:updateUnmatchedStepRunnable',...
                autosar.api.Utils.getQualifiedName(oldStepRunnable),...
                autosar.api.Utils.getUUID(oldStepRunnable));
            end
        end
    end


    oldM3ITransaction.cancel();




    if~isSharingAUTOSARProps
        autosar.updater.updateMappingForSharedElements(matcher,...
        newM3IModel,oldM3IModel);
    end
    autosar.updater.updateMappingForComp(matcher,oldM3IModel,newM3IComp);


    newM3ITransaction.cancel();


    newM3ITransaction=M3I.Transaction(newM3IModel);
    autosar.updater.copyXmlOptions(oldM3IModel,newM3IModel,oldM3IComp,newM3IComp);
    autosar.updater.copyCSErrorArgs(matcher,oldM3IModel);
    newM3ITransaction.commit();

    componentQualifiedName=autosar.api.Utils.getQualifiedName(newM3IComp);


    dataDictionary=get_param(modelName,'DataDictionary');

    slChangeLogger=autosar.updater.ChangeLogger();
    xmlOptsGetter=argParser.Results.XmlOptsGetter;

    if isCompositionComponent

        schemaVer=autosar.mm.util.getSchemaVersionForConfigSet(this.arSchemaVer,isAdaptiveApplication);
        compositionBuilder=autosar.composition.mm2sl.ModelBuilder(...
        newM3IModel,isSharingAUTOSARProps,schemaVer,slChangeLogger,...
        xmlOptsGetter,true);
        existingComponentModels={};
        compositionBuilder.createComposition(newM3IComp,...
        modelName,dataDictionary,existingComponentModels);
    else
        args={...
        'NameConflictAction','overwrite',...
        'CreateSimulinkObject',true,...
        'AutoSave',false,...
        'ModelPeriodicRunnablesAs',modelingStyle,...
        'InitializationRunnable',initializationRunnable,...
        'ResetRunnables',resetRunnables,...
        'TerminateRunnable',terminateRunnable,...
        'ImportInternalTriggers',argParser.Results.ImportInternalTriggers,...
        'AutosarSchemaVersion',this.arSchemaVer,...
        'UpdateMode',true,...
        'AutoDelete',argParser.Results.AutoDelete,...
        'ModelName',modelName,...
        'DataDictionary',dataDictionary,...
        'OpenModel',argParser.Results.OpenModel,...
        'ForceLegacyWorkspaceBehavior',argParser.Results.ForceLegacyWorkspaceBehavior};


        if isempty(xmlOptsGetter)
            xmlOptsGetter=autosar.mm.util.XmlOptionsGetter(newM3IModel);
        end


        builder=autosar.mm.mm2sl.ModelBuilder(newM3IModel,dataDictionary,isSharingAUTOSARProps,...
        slChangeLogger,xmlOptsGetter,newM3iSwcTiming,PredefinedVariant=argParser.Results.PredefinedVariant,...
        SystemConstValueSets=argParser.Results.SystemConstValueSets);
        builder.createApplicationComponent(componentQualifiedName,args{:});




        if isSharingAUTOSARProps
            newSharedM3IModel=autosar.dictionary.Utils.getUniqueReferencedModel(newM3IModel);
            oldSharedM3IModel=autosar.dictionary.Utils.getUniqueReferencedModel(oldM3IModel);
            comparator=autosar.updater.XmlOptionsComparator(newSharedM3IModel,oldSharedM3IModel,...
            newM3IComp,oldM3IComp,mmChangeLogger);
        else
            comparator=autosar.updater.XmlOptionsComparator(newM3IModel,oldM3IModel,...
            newM3IComp,oldM3IComp,mmChangeLogger);
        end
        comparator.compare();
    end



    report=autosar.updater.Report();
    [~,reportName]=fileparts(modelNameForBackup);
    report.build(mmChangeLogger,slChangeLogger,modelName,componentQualifiedName,reportName);
    report.dispHelpLine(modelName);
    if strcmp(argParser.Results.LaunchReport,'on')
        autosar.updater.Report.launchReport(modelName);
    end


    function lNewRunnableName=i_matchIRTRunnable(lOldRunnableName,oldM3IComp,matcher)

        lNewRunnableName='';
        if isempty(lOldRunnableName)
            return;
        end

        for rIndex=1:oldM3IComp.Behavior.Runnables.size()
            oldRunnable=oldM3IComp.Behavior.Runnables.at(rIndex);
            if strcmp(oldRunnable.Name,lOldRunnableName)
                newRunnable=matcher.getFirst(oldRunnable);
                if newRunnable.isvalid()
                    lNewRunnableName=newRunnable.Name;
                else
                    lNewRunnableName='';
                end
            end
        end

        function lResetFunctionNames=i_getResetFunctions(lModelName)

            lMapping=autosar.api.Utils.modelMapping(lModelName);
            lResetFunctionNames=arrayfun(@(x)x.MappedTo.Runnable,lMapping.ResetFunctions,'UniformOutput',false);

            function lTerminateFunction=i_getTerminateFunction(lModelName)


                lMapping=autosar.api.Utils.modelMapping(lModelName);
                if numel(lMapping.TerminateFunctions)>0
                    lTerminateFunction=lMapping.TerminateFunctions.MappedTo.Runnable;
                else
                    lTerminateFunction='';
                end



