function performDeriveMinMax(this)




    selectedRunName=this.CurrentRunName;


    allDataset=this.getAllDatasets();
    for idx=1:length(allDataset)
        run=allDataset{idx}.getRun(selectedRunName);
        run.deleteInvalidResults();
        run.cleanupOnDerivation();
    end


    this.SystemSettings.turnOffFastRestart;
    try
        sudObject=get_param(this.SelectedSystemToScale,'Object');
        SimulinkFixedPoint.Autoscaler.collectModelDerivedRange(sudObject,selectedRunName);
        SimulinkFixedPoint.Autoscaler.collectModelCompiledDesignRange(sudObject,selectedRunName);
        topObject=get_param(this.TopModel,'Object');
        SimulinkFixedPoint.ApplicationData.mergeModelReferenceData(topObject,selectedRunName);
    catch fpt_exception

        this.SystemSettings.restoreFastRestart;
        throw(fpt_exception);
    end

    this.SystemSettings.restoreFastRestart;


    this.createSettingsMapFromSystem(this.CurrentRunName);



    sHandler=fxptds.SimulinkDataArrayHandler;
    systemID=sHandler.getUniqueIdentifier(struct('Path',this.SelectedSystemToScale));
    curRootName=systemID.getHighestLevelParent;
    if~strcmp(this.TopModel,curRootName)
        this.ApplicationData.updateResultsInModelsBlocks(this.TopModel,selectedRunName);
    end


    settings='';
    dataLayer=fxptds.DataLayerInterface.getInstance();
    [~,fptRunID]=dataLayer.getIdFromRunName(this.TopModel,this.CurrentRunName);
    context=fxptds.WorkflowTopology.WorkflowContextFactory.getContext(fxptds.UserIntent.DeriveMinMax,...
    'TopModel',this.TopModel,'FPTRunID',fptRunID,'Settings',settings);
    facade=this.getWorkflowTopologyFacade();
    facade.register(context);

end


