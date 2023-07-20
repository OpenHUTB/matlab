





function sysHandle=createApplicationComponent(self,m3iComp,varargin)


    if ischar(m3iComp)||isStringScalar(m3iComp)
        m3iComp=autosar.mm.mm2sl.ModelBuilder.getM3IComp(self.m3iModel,m3iComp);
    end

    isAdaptiveApplication=isa(m3iComp,'Simulink.metamodel.arplatform.component.AdaptiveApplication');
    argParser=createArgParser(isAdaptiveApplication);


    argParser.parse(self,m3iComp,varargin{:});


    if~m3iComp.isvalid()
        msg=DAStudio.message('RTW:autosar:mmInvalidArgObject',2,...
        'Simulink.metamodel.arplatform.component.AtomicComponent');
        assert(false,msg);
    end



    if~argParser.Results.ImportInternalTriggers&&m3iComp.Behavior.isvalid()
        m3iTrigPoints=autosar.mm.Model.findObjectByMetaClass(m3iComp.Behavior,...
        Simulink.metamodel.arplatform.behavior.InternalTrigger.MetaClass);
        if m3iTrigPoints.size()>0
            trigPointQNames=m3i.mapcell(@autosar.api.Utils.getQualifiedName,m3iTrigPoints);
            DAStudio.error('autosarstandard:importer:InternalTriggersNotSupported',...
            autosar.api.Utils.getQualifiedName(m3iComp),...
            autosar.api.Utils.cell2str(trigPointQNames));
        end
    end

    if argParser.Results.UpdateMode

        Simulink.findVars(argParser.Results.ModelName);


        [~]=Simulink.AutosarTarget.Component('','');
        mmgr=get_param(argParser.Results.ModelName,'MappingManager');
        if isAdaptiveApplication
            mappingType='AutosarTargetCPP';
        else
            mappingType='AutosarTarget';
        end
        if isempty(mmgr.getActiveMappingFor(mappingType))
            mappingName=autosar.api.Utils.createMappingName(argParser.Results.ModelName,mappingType);
            mmgr.createMapping(mappingName,mappingType);
            mmgr.activateMapping(mappingName);
        end
        mapping=mmgr.getActiveMappingFor(mappingType);


        mapping.AUTOSAR_ROOT=self.m3iModel;
    end

    self.schemaVersion=argParser.Results.AutosarSchemaVersion;


    ddName=argParser.Results.DataDictionary;
    sysHandle=self.createComponent(...
    m3iComp,...
    argParser.Results.CreateSimulinkObject,...
    argParser.Results.NameConflictAction,...
    argParser.Results.CreateTypes,...
    argParser.Results.CreateCalPrms,...
    argParser.Results.ModelPeriodicRunnablesAs,...
    argParser.Results.InitializationRunnable,...
    argParser.Results.ResetRunnables,...
    argParser.Results.TerminateRunnable,...
    ddName,...
    argParser.Results.UpdateMode,...
    argParser.Results.AutoDelete,...
    argParser.Results.ModelName,...
    argParser.Results.OpenModel,...
    argParser.Results.UseBusElementPorts,...
    argParser.Results.ForceLegacyWorkspaceBehavior,...
    argParser.Results.PredefinedVariant);

    autosarSchemaVersion=autosar.mm.util.getSchemaVersionForConfigSet(...
    argParser.Results.AutosarSchemaVersion,isAdaptiveApplication);

    autosar.mm.mm2sl.SLModelBuilder.set_param(self.ChangeLogger,...
    self.slModelName,'AutosarSchemaVersion',autosarSchemaVersion);


    [~]=Simulink.AutosarTarget.Component('','');
    if isAdaptiveApplication
        mappingType='AutosarTargetCPP';
    else
        mappingType='AutosarTarget';
    end
    mappingName=autosar.api.Utils.createMappingName(self.slModelName,mappingType);
    mmgr=get_param(self.slModelName,'MappingManager');
    if isempty(mmgr.getActiveMappingFor(mappingType))
        mmgr.createMapping(mappingName,mappingType);
        mmgr.activateMapping(mappingName);
    end
    mapping=mmgr.getActiveMappingFor(mappingType);


    mapping.AUTOSAR_ROOT=self.m3iModel;

    modelLookupTables=autosar.mm.util.ModelLookupTables(m3iComp,self.slModelName);

    if modelLookupTables.HasNDLookupTable
        if modelLookupTables.HasAllRowMajorNDLookupTables
            autosar.mm.mm2sl.SLModelBuilder.set_param(self.ChangeLogger,...
            self.slModelName,'ArrayLayout','Row-major',...
            'UseRowMajorAlgorithm','on');
        else
            autosar.mm.mm2sl.SLModelBuilder.set_param(self.ChangeLogger,...
            self.slModelName,'ArrayLayout','Column-major',...
            'UseRowMajorAlgorithm','off');
        end
    end

    self.SLModelBuilder.populateMapping(mapping,...
    self.slPort2RefBiMap,...
    self.slPort2AccessMap,...
    self.slIrvRef2RunnableMap,...
    self.SlParam2RefMap,...
    self.SlParamMap,...
    self.DsmBlockMap,...
    self.m3iComponent,...
    self.InitRunnable,...
    self.ResetRunnables,...
    self.TerminateRunnable,...
    self.SampleTimes,...
    self.ComponentHasBehavior,...
    self.m3iSwcTiming);


    autosar.api.Utils.setM3iModelDirty(self.slModelName);
    if self.ShareAUTOSARProperties
        assert(~isempty(ddName),'DataDictionary must be set for sharing AUTOSAR properties.');
        Simulink.AutosarDictionary.ModelRegistry.setAutosarPartDirty(ddName);
        autosar.dictionary.Utils.updateModelMappingWithDictionary(self.slModelName,ddName);
    end


    if argParser.Results.AutoSave
        save_system(self.slModelName);
    end

    function argParser=createArgParser(isAdaptiveApplication)

        argParser=inputParser();
        argParser.addRequired('self',@(x)isa(x,class(x)));
        argParser.addRequired('m3iComp',@(x)(ischar(x)||isStringScalar(x)||...
        isa(x,'Simulink.metamodel.arplatform.component.AtomicComponent')||...
        isa(x,'Simulink.metamodel.arplatform.component.AdaptiveApplication')));
        argParser.addOptional('CreateSimulinkObject',true,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
        argParser.addOptional('NameConflictAction','makenameunique',@(x)any(strcmpi(x,{'overwrite','makenameunique','update','error'})));
        argParser.addOptional('AutoSave',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
        argParser.addOptional('ModelPeriodicRunnablesAs','Auto',@(x)any(strcmp(x,{'Auto','AtomicSubsystem','FunctionCallSubsystem'})));
        argParser.addOptional('InitializationRunnable','',@(x)(ischar(x)||isStringScalar(x)));
        argParser.addOptional('ResetRunnables',{},@(x)(isstring(x)||iscellstr(x)));
        argParser.addOptional('TerminateRunnable','',@(x)(ischar(x)||isStringScalar(x)));
        argParser.addOptional('CreateTypes',true,@(x)(islogical(x)||(x==1)||(x==0)));
        argParser.addOptional('CreateCalPrms',~isAdaptiveApplication,@(x)(islogical(x)||(x==1)||(x==0)));
        argParser.addOptional('AutosarSchemaVersion',arxml.getDefaultSchemaVersion(),@(x)(ischar(x)||isStringScalar(x)));
        argParser.addOptional('DataDictionary','',@(x)(ischar(x)||isStringScalar(x)));
        argParser.addOptional('UpdateMode',false,@islogical);
        argParser.addParameter('AutoDelete',false,@(x)(islogical(x)));
        argParser.addOptional('ModelName','',@(x)(ischar(x)||isStringScalar(x)));
        argParser.addParameter('OpenModel',true,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
        argParser.addParameter('ForceLegacyWorkspaceBehavior',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
        argParser.addParameter('ImportInternalTriggers',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
        argParser.addParameter('UseBusElementPorts',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
        argParser.addParameter('PredefinedVariant','',@(x)(ischar(x)||isStringScalar(x)));
        argParser.addOptional('UseValueTypes',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));




