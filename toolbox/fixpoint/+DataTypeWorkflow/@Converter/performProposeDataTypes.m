function performProposeDataTypes(this,runName,dtwProposalSettings)






    this.SystemSettings.captureSettings();


    cleanupShortcut=this.ShortcutManager.CleanupShortcut;
    this.createSettingsMapFromSystem(cleanupShortcut);



    cleanup=onCleanup(@()this.collectCleanup(cleanupShortcut));


    this.SystemSettings.turnOffFastRestart();





    if ismember(runName,this.RunNames)
        this.applySettingsFromRun(runName);
    end


    this.SystemSettings.switchToNormalMode();


    sudObject=get_param(this.SelectedSystemToScale,'Object');
    topModelObject=get_param(this.TopModel,'Object');




    this.ApplicationData.ScaleUsing=runName;
    dtwProposalSettings.scaleUsingRunName=runName;


    engineAction=SimulinkFixedPoint.DataTypingServices.EngineActions.Propose;



    if(dtwProposalSettings.ExecuteConditionalProposal)
        engineAction=SimulinkFixedPoint.DataTypingServices.EngineActions.ConditionalProposal;
    end



    dataLayer=fxptds.DataLayerInterface.getInstance();
    facade=dataLayer.getWorkflowTopologyFacade(this.TopModel);
    [~,baselineFPTID]=dataLayer.getIdFromRunName(this.TopModel,runName);

    data=facade.query(baselineFPTID,'property','Settings','search','exact');
    baselineSettings=data{1};
    simIn=Simulink.SimulationInput.empty();
    if isa(baselineSettings,'struct')
        simIn=baselineSettings.simIn;
    end

    engineContext=SimulinkFixedPoint.DataTypingServices.EngineContext(...
    topModelObject.getFullName,...
    sudObject.getFullName,...
    dtwProposalSettings.getSettings(),...
    engineAction,...
    simIn);

    engineInterface=SimulinkFixedPoint.DataTypingServices.EngineInterface.getInterface();
    engineInterface.run(engineContext);

    SimulinkFixedPoint.ApplicationData.updateResultsInModelsBlocks(this.TopModel,runName);


    this.createSettingsMapFromSystem(runName);


end
