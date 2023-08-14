function registerSimpleSimulation(this)





    dataLayer=fxptds.DataLayerInterface.getInstance();

    isEmbedded=dataLayer.isRunVerificationRun(this.TopModel,this.CurrentRunName);
    archiveMode=get_param(this.TopModel,'MinMaxOverflowArchiveMode');


    settings='';
    [sdiRunID,fptRunID]=dataLayer.getIdFromRunName(this.TopModel,this.CurrentRunName);
    if isEmbedded



        context=fxptds.WorkflowTopology.WorkflowContextFactory.getContext(fxptds.UserIntent.AutoscalerVerification,...
        'TopModel',this.TopModel,'SDIRunID',sdiRunID,'FPTRunID',fptRunID,'Settings',settings);
    elseif strcmp('Merge',archiveMode)


        scenarioRunName='';
        [~,scenarioID]=dataLayer.getIdFromRunName(this.TopModel,scenarioRunName);
        context=fxptds.WorkflowTopology.WorkflowContextFactory.getContext(fxptds.UserIntent.MergeSimulation,...
        'TopModel',this.TopModel,'SDIRunID',sdiRunID,...
        'FPTRunID',fptRunID,'Settings',settings,'ScenarioFPTRunID',scenarioID);
    else
        context=fxptds.WorkflowTopology.WorkflowContextFactory.getContext(fxptds.UserIntent.SimpleSimulation,...
        'TopModel',this.TopModel,'SDIRunID',sdiRunID,'FPTRunID',fptRunID,'Settings',settings);
    end


    facade=this.getWorkflowTopologyFacade();
    facade.register(context);
end
