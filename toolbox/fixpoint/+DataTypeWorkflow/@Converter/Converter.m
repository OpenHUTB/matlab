classdef Converter<DataTypeWorkflow.DesignEnvironment


















    properties(Dependent=true)
CurrentRunName
    end

    properties(Dependent=true,SetAccess=private)
        RunNames;
        ShortcutsForSelectedSystem;
    end

    properties(SetAccess=private,Hidden)

ApplicationData
SDIListeners
CloseListener



SystemSettings


ShortcutManager

    end

    methods

        function this=Converter(systemToScale,varargin)











            narginchk(1,3);

            this.setup(systemToScale,varargin{:});

            this.ApplicationData=SimulinkFixedPoint.getApplicationData(this.TopModel);

            this.ShortcutManager=DataTypeWorkflow.ShortcutManager(this.TopModel);


            this.SystemSettings=DataTypeWorkflow.SystemSettings(this.TopModel);

            shortcutName=fxptui.message('lblOriginalSettings');
            this.ShortcutManager.captureCurrentSystemSettings(shortcutName);

            this.initializeListeners();

            this.registerStartWorkflow();
        end

        function v=get.CurrentRunName(this)
            v=get_param(this.TopModel,'FPTRunName');
        end

        function allRunNames=get.RunNames(this)





            this.assertDEValid();






            dataLayer=fxptds.DataLayerInterface.getInstance();
            allRunNames=dataLayer.getAllRunNamesUnderModel(this.TopModel);
        end

        function shortcutNames=get.ShortcutsForSelectedSystem(this)





            this.assertDEValid();



            defaultShortcuts=this.ShortcutManager.DefaultFactoryNames;

            userDefinedShortcuts=this.ShortcutManager.getUserDefinedShortcuts();
            shortcutNames=[defaultShortcuts,userDefinedShortcuts]';
        end

        function set.CurrentRunName(this,v)
            try
                set_param(this.TopModel,'FPTRunName',v);
            catch e
                throw(e);
            end
        end

        simOut=simulateSystem(this,varargin)
        applySettingsFromShortcut(this,shortcutName)
        applySettingsFromRun(this,runName)
        collectedSystems=deriveMinMax(this);
        proposeDataTypes(this,runName,proposalSettings);
        applyDataTypes(this,runName);
        wrapOverflows=wrapOverflows(this,runName)
        saturationOverflows=saturationOverflows(this,runName)
        out=proposalIssues(this,runName)
        out=results(this,runName,returnFunc)
        [verificationResult,simOut]=verify(this,baselineRunName,verificationRunName);

    end

    methods(Hidden)

        function initializeListeners(this)
            this.CloseListener=Simulink.listener(get_param(this.TopModel,'Object'),'CloseEvent',@destroyConverter);
            function destroyConverter(~,~)
                cleanup(this);
            end

            sdiEngine=Simulink.sdi.Instance.engine();

            this.SDIListeners=event.listener(sdiEngine,'runAddedEvent',@timeSeriesDataMatchUp);
            function timeSeriesDataMatchUp(~,e)
                e.modelName=this.TopModel;
                DataTypeWorkflow.SigLogServices.updateFromEventData(e);
            end
        end

        function facade=getWorkflowTopologyFacade(this)
            facade=this.ApplicationData.dataset.WorkflowTopologyFacade;
        end

        function registerStartWorkflow(this)

            facade=this.getWorkflowTopologyFacade();




            context=fxptds.WorkflowTopology.WorkflowContextFactory.getContext(fxptds.UserIntent.DeclareWorkflow,...
            'TopModel',this.TopModel,'ContainerID',1);

            facade.register(context);
        end

        generateReport(this,reportName);

        reportObject=prepareSystemForConversion(this,boolSimOrDerive);
        isCellArrayOfStrings(~,arr)
        cleanup(this)
        results=getAllResultsForRun(this,runName)
        validateRunName(this,runName)
        allDatasets=getAllDatasets(this)
        createSettingsMapFromSystem(this,runName)
        settingsStruct=settingsStructFromProposalSettings(this,ps,runName)

        verificationResult=getVerificationResult(this,verificationRunName);
        uniqueRunName=makeRunNameUnique(this,runName);


        simOut=performSimpleSimulation(this,varargin);
        registerSimpleSimulation(this);
        [simOut,simIn,mergedRunName]=performMultiSimulation(this,simulationSettings);
        registerMultiSimulation(this,simulationSettings,simIn,mergedRunName);
        simOut=performVerification(this,runName,settings);
        simOut=collect(this,varargin);
        performDeriveMinMax(this);
        registerDeriveMinMax(this);
        performProposeDataTypes(this,runName,settings);
        reportObject=performPrepareSystemForConversion(this,boolSimOrDerive);
        performApplyDataTypes(this,runName);
        collectCleanup(this,shortcut);

        scenarioRuns=getMultiSimRunNames(this,varargin);
        deleteRuns(this,mergedRunName,scenarioRunNames);

    end

    methods(Hidden,Static)
        status=createRestorePoint(model,forceSave);
        isValid=hasValidRestorePoint(model);
        status=restoreOriginalModel(model);
    end

    methods(Hidden,Access={?DataTypeWorkflowTestCase})


        simOut=updateSimulationInputObject(this,simIn);
        report=getAnalyzerReport(this);


        function injectShortcutManager(this,shortcutManager)
            this.ShortcutManager=shortcutManager;
        end

        function injectSystemSettings(this,systemSettings)
            this.SystemSettings=systemSettings;
        end

    end

end
