function proposeDataTypes(this,runName,dtwProposalSettings)















    this.assertDEValid();

    this.loadSystems();

    validateattributes(runName,{'char'},{'nonempty','row'});
    validateattributes(dtwProposalSettings,{'DataTypeWorkflow.ProposalSettings'},{'nonempty','scalar'});


    this.performProposeDataTypes(runName,dtwProposalSettings);


    settings=dtwProposalSettings;
    dataLayer=fxptds.DataLayerInterface.getInstance();
    [~,fptRunID]=dataLayer.getIdFromRunName(this.TopModel,runName);
    context=fxptds.WorkflowTopology.WorkflowContextFactory.getContext(fxptds.UserIntent.AutoscalerProposal,...
    'TopModel',this.TopModel,'FPTRunID',fptRunID,'Settings',settings);
    facade=this.getWorkflowTopologyFacade();
    facade.register(context);

end
