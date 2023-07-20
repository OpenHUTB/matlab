function collectInfoToDataset(this)












    topAppData=SimulinkFixedPoint.getApplicationData(this.TopModel);




    topAppData.ScaleUsing=this.SingleConverterRunName;

    proposalSettings=topAppData.AutoscalerProposalSettings;
    proposalSettings.scaleUsingRunName=this.SingleConverterRunName;

    try
        engineContext=SimulinkFixedPoint.DataTypingServices.EngineContext(...
        this.SelectedSystem,...
        this.SelectedSystem,...
        proposalSettings,...
        SimulinkFixedPoint.DataTypingServices.EngineActions.Collect);
        engineInterface=SimulinkFixedPoint.DataTypingServices.EngineInterface.getInterface();
        engineInterface.run(engineContext);

        allModels=this.AllSystemsToScale;
        cellfun(@(x)(SimulinkFixedPoint.Autoscaler.collectModelCompiledDesignRange(...
        get_param(x,'Object'),this.SingleConverterRunName)),allModels);

    catch collectException



        rethrow(collectException);
    end
end
