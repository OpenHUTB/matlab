function reportObject=prepareSystemForConversion(this,enumSimOrDerive)





    this.assertDEValid();

    reportObject=this.performPrepareSystemForConversion(enumSimOrDerive);


    facade=this.getWorkflowTopologyFacade();
    context=fxptds.WorkflowTopology.WorkflowContextFactory.getContext(fxptds.UserIntent.PrepareModel,...
    'TopModel',this.TopModel,'Settings',enumSimOrDerive,'Results',reportObject);
    facade.register(context);

end