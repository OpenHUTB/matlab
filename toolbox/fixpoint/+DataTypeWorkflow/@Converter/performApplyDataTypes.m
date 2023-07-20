function performApplyDataTypes(this,runName)







    this.ApplicationData.ScaleUsing=runName;

    proposalSettings=this.ApplicationData.AutoscalerProposalSettings;
    proposalSettings.scaleUsingRunName=runName;

    sudObject=get_param(this.SelectedSystemToScale,'Object');
    topModelObject=get_param(this.TopModel,'Object');

    engineContext=SimulinkFixedPoint.DataTypingServices.EngineContext(...
    topModelObject.getFullName,...
    sudObject.getFullName,...
    proposalSettings,...
    SimulinkFixedPoint.DataTypingServices.EngineActions.Apply);


    this.SystemSettings.turnOffFastRestart;

    engineInterface=SimulinkFixedPoint.DataTypingServices.EngineInterface.getInterface();
    engineInterface.run(engineContext);



    this.SystemSettings.restoreFastRestart;

end
