function registerMultiSimulation(this,simulationSettings,simIn,mergedRunName)






    dataLayer=fxptds.DataLayerInterface.getInstance();
    facade=this.getWorkflowTopologyFacade();


    isEmbedded=dataLayer.isRunVerificationRun(this.TopModel,mergedRunName);


    numScenarios=numel(simIn);


    for idx=1:numScenarios
        scenarioRunName=simIn(idx).getModelParameter('FPTRunName');


        settings=idx;
        [sdiRunID,fptRunID]=dataLayer.getIdFromRunName(this.TopModel,scenarioRunName);
        if isEmbedded
            context=fxptds.WorkflowTopology.WorkflowContextFactory.getContext(fxptds.UserIntent.AutoscalerVerification,...
            'TopModel',this.TopModel,'SDIRunID',sdiRunID,'FPTRunID',fptRunID,'Settings',settings);
        else
            context=fxptds.WorkflowTopology.WorkflowContextFactory.getContext(fxptds.UserIntent.SimpleSimulation,...
            'TopModel',this.TopModel,'SDIRunID',sdiRunID,'FPTRunID',fptRunID,'Settings',settings);
        end
        facade.register(context);




        settingsMerge=simulationSettings;
        [sdiRunIDMerge,fptRunIDMerge]=dataLayer.getIdFromRunName(this.TopModel,mergedRunName);
        [~,scenarioID]=dataLayer.getIdFromRunName(this.TopModel,scenarioRunName);
        context=fxptds.WorkflowTopology.WorkflowContextFactory.getContext(fxptds.UserIntent.MergeSimulation,...
        'TopModel',this.TopModel,'SDIRunID',sdiRunIDMerge,...
        'FPTRunID',fptRunIDMerge,'Settings',settingsMerge,'ScenarioFPTRunID',scenarioID);
        facade.register(context);

    end

end

