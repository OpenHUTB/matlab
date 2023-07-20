function verificationResult=getVerificationResult(this,verificationRunName)






    dataLayer=fxptds.DataLayerInterface.getInstance();
    facade=dataLayer.getWorkflowTopologyFacade(this.TopModel);

    [~,verificationFPTRunID]=dataLayer.getIdFromRunName(this.TopModel,verificationRunName);
    report=facade.query(verificationFPTRunID,'property','Report','search','exact');
    report=report{:};

    if isempty(report)



        report=struct(...
        'TopModel',this.TopModel,...
        'VerificationStatus',fxptds.VerificationStatus.UnknownBaseline,...
        'MaxDifference',NaN,...
        'BaselineFPTID',verificationFPTRunID,...
        'VerificationFPTID',verificationFPTRunID,...
        'ProposalSettings',DataTypeWorkflow.ProposalSettings...
        );



        report.ScenarioReports={};
    end

    verificationResult=DataTypeWorkflow.VerificationResult(report);

end
