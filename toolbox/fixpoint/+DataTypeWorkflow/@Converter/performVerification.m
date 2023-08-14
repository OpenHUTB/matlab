function simOut=performVerification(this,baselineSettings,verificationSettings)





    dataLayer=fxptds.DataLayerInterface.getInstance();




    verificationRunName=verificationSettings.RunName;
    verificationRunName=this.makeRunNameUnique(verificationRunName);
    verificationSettings.RunName=verificationRunName;

    dataLayer.addEmbeddedRunName(this.TopModel,verificationRunName);


    facade=dataLayer.getWorkflowTopologyFacade(this.TopModel);
    baselineRunName=baselineSettings.RunName;
    [~,baselineFPTID]=dataLayer.getIdFromRunName(this.TopModel,baselineRunName);

    data=facade.query(baselineFPTID,'property','Settings','search','exact');
    baselineSettings=data{1};



    if isa(baselineSettings,'struct')
        verificationSettings.SimulationScenarios=baselineSettings.simIn;
        verificationSettings.ProgressTrackingOptions.ShowSimulationManager=baselineSettings.ShowSimulationManager;
        verificationSettings.ProgressTrackingOptions.ShowProgress=baselineSettings.ShowProgress;
    end

    try
        simOut=this.collect(verificationSettings);
    catch e
        dataLayer.removeEmbeddedRunName(this.TopModel,verificationRunName);
        throw(e)
    end

end
