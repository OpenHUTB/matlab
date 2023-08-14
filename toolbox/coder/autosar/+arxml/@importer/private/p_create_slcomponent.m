function[slhandle,success]=p_create_slcomponent(this,argParser)





    import autosar.composition.mm2sl.ComponentAndCompositionBuilder


    p_update_read(this);



    this.needReadUpdate=true;


    if isempty(argParser.Results.ResetRunnables)
        lResetRunnables={};
    elseif ischar(argParser.Results.ResetRunnables)

        lResetRunnables={argParser.Results.ResetRunnables};
    else
        lResetRunnables=argParser.Results.ResetRunnables;
    end



    m3iModel=this.arModel;
    isAdaptive=isAdaptiveComponent(m3iModel,argParser.Results.ComponentName);
    if isAdaptive
        loc_validateInputArgumentsForAdaptive(argParser.Results);
    end

    args={...
    'NameConflictAction',argParser.Results.NameConflictAction,...
    'CreateSimulinkObject',argParser.Results.CreateSimulinkObject,...
    'AutoSave',argParser.Results.AutoSave,...
    'ModelPeriodicRunnablesAs',loc_resolveModelPeriodicRunnablesAs(argParser,isAdaptive),...
    'InitializationRunnable',argParser.Results.InitializationRunnable,...
    'ResetRunnables',lResetRunnables,...
    'TerminateRunnable',argParser.Results.TerminateRunnable,...
    'ImportInternalTriggers',argParser.Results.ImportInternalTriggers,...
    'UseBusElementPorts',argParser.Results.UseBusElementPorts,...
    'DataDictionary',argParser.Results.DataDictionary,...
    'OpenModel',argParser.Results.OpenModel,...
    'ForceLegacyWorkspaceBehavior',argParser.Results.ForceLegacyWorkspaceBehavior,...
    'PredefinedVariant',argParser.Results.PredefinedVariant,...
    'UseValueTypes',argParser.Results.UseValueTypes};

    autosarSchemaVersion=validateAndTranslateSchemaVersion(...
    this.arSchemaVer,isAdaptive);


    builderChangeLogger=autosar.updater.ChangeLogger();

    m3iComponent=autosar.mm.mm2sl.ModelBuilder.getM3IComp(m3iModel,argParser.Results.ComponentName);
    if slfeature('ImportComponentModelsUsingSharedAUTOSARDictionary')>0
        shareAUTOSARProperties=argParser.Results.ShareAUTOSARProperties;
    else
        shareAUTOSARProperties=false;
    end
    dataDictionary=argParser.Results.DataDictionary;

    if shareAUTOSARProperties
        [m3iModelSplitter,m3iComponent]=ComponentAndCompositionBuilder.splitAllUnder(...
        m3iComponent,dataDictionary,...
        argParser.Results.CreateDictionaryChangesReport);




        xmlOptsM3IModel=m3iModelSplitter.getSharedM3IModel();
    else
        xmlOptsM3IModel=m3iModel;
    end

    xmlOptsGetter=autosar.mm.util.XmlOptionsGetter(xmlOptsM3IModel);
    m3iSwcTiming=autosar.timing.Utils.findM3iTimingForM3iComponent(m3iComponent.rootModel,m3iComponent);
    builder=autosar.mm.mm2sl.ModelBuilder(m3iComponent.rootModel,dataDictionary,...
    shareAUTOSARProperties,builderChangeLogger,...
    xmlOptsGetter,m3iSwcTiming,PredefinedVariant=argParser.Results.PredefinedVariant,...
    SystemConstValueSets=argParser.Results.SystemConstValueSets,UseValueTypes=argParser.Results.UseValueTypes);
    slhandle=builder.createApplicationComponent(argParser.Results.ComponentName,args{:},'AutosarSchemaVersion',autosarSchemaVersion);

    success=slhandle~=-1;
end

function resolvedValue=loc_resolveModelPeriodicRunnablesAs(argParser,isAdaptive)
    isCreateInternalBehaviorSpecified=~any(strcmp(argParser.UsingDefaults,'CreateInternalBehavior'));
    isModelPeriodicRunnablesAsSpecified=~any(strcmp(argParser.UsingDefaults,'ModelPeriodicRunnablesAs'));



    if isCreateInternalBehaviorSpecified&&isModelPeriodicRunnablesAsSpecified
        DAStudio.error('autosarstandard:importer:InternalBehaviorAndPeriodicRunnablesSpecified')
    end


    if isCreateInternalBehaviorSpecified
        if argParser.Results.CreateInternalBehavior
            suggestedParamValue='{''ModelPeriodicRunnablesAs'',''FunctionCallSubsystem''}';
            resolvedValue='FunctionCallSubsystem';
        else
            suggestedParamValue='{''ModelPeriodicRunnablesAs'',''AtomicSubsystem''}';
            resolvedValue='AtomicSubsystem';
        end



        autosar.mm.util.MessageReporter.print(...
        message('autosarstandard:importer:ObsoleteCreateInternalBehavior',...
        suggestedParamValue).getString());
    else
        if isModelPeriodicRunnablesAsSpecified
            resolvedValue=argParser.Results.ModelPeriodicRunnablesAs;
        elseif~isAdaptive

            autosar.mm.util.MessageReporter.print(...
            message('autosarstandard:importer:ModelPeriodicRunnablesAsNotSpecified').getString());
            resolvedValue='AtomicSubsystem';
        else

            resolvedValue='AtomicSubsystem';
        end
    end
end

function loc_validateInputArgumentsForAdaptive(argParserResult)


    errParam={};
    if~any(strcmp(argParserResult.ModelPeriodicRunnablesAs,{'AtomicSubsystem'}))
        errParam{end+1}='ModelPeriodicRunnablesAs';
    end

    if~isempty(argParserResult.InitializationRunnable)
        errParam{end+1}='InitializationRunnable';
    end

    if~isempty(argParserResult.PredefinedVariant)
        errParam{end+1}='PredefinedVariant';
    end

    if~isempty(argParserResult.SystemConstValueSets)
        errParam{end+1}='SystemConstValueSets';
    end

    if~isempty(errParam)
        DAStudio.error('autosarstandard:importer:adaptiveErrParam',strjoin(errParam,', '));
    end
end

function isAdaptive=isAdaptiveComponent(m3iModel,componentName)

    m3iComp=autosar.mm.mm2sl.ModelBuilder.getM3IComp(m3iModel,componentName);
    isAdaptive=isa(m3iComp,'Simulink.metamodel.arplatform.component.AdaptiveApplication');
end

function autosarSchemaVersion=validateAndTranslateSchemaVersion(rawSchemaVer,isAdaptive)
    autosarSchemaVersion=rawSchemaVer;

    if any(strcmp(autosarSchemaVersion,{'00044','00045','4.3'}))
        if isAdaptive
            supportedVersions=arxml.getSupportedAdaptiveSchemas();
            DAStudio.error('autosarstandard:importer:badAdaptiveSchema',...
            autosarSchemaVersion,...
            autosar.api.Utils.cell2str(supportedVersions));
        else


            autosarSchemaVersion=...
            autosar.mm.util.getSchemaVersionForConfigSet(...
            autosarSchemaVersion,isAdaptive);
        end
    elseif~isAdaptive&&...
        (strcmp(autosarSchemaVersion,'00049')&&~slfeature('AutosarClassicR2011'))



        [~,supportedVersions]=arxml.getSupportedSchemaVersions();
        DAStudio.error('autosarstandard:importer:badClassicSchema',...
        autosarSchemaVersion,...
        supportedVersions);
    end
end


