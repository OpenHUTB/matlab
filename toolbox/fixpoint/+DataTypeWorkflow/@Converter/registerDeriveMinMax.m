function registerDeriveMinMax(this)








    settings='';
    dataLayer=fxptds.DataLayerInterface.getInstance();
    [~,fptRunID]=dataLayer.getIdFromRunName(this.TopModel,this.CurrentRunName);
    context=fxptds.WorkflowTopology.WorkflowContextFactory.getContext(fxptds.UserIntent.DeriveMinMax,...
    'TopModel',this.TopModel,'FPTRunID',fptRunID,'Settings',settings);
    facade=this.getWorkflowTopologyFacade();
    facade.register(context);

end


