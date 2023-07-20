function execute(this)


    topMdl=this.refMdls{end};

    for idx=1:(length(this.refMdls)-1)
        curMdlName=this.refMdls{idx};
        load_system(curMdlName);
        curMdl=get_param(curMdlName,'Object');
        localAppdata=SimulinkFixedPoint.getApplicationData(curMdlName);




        localAppdata.ScaleUsing=this.proposalSettings.scaleUsingRunName;


        localAppdata.AutoscalerProposalSettings=this.proposalSettings;
        curMdlName=SimulinkFixedPoint.AutoscalerUtils.getModelForAutoscaling(curMdl);
        runObj=localAppdata.dataset.getRun(localAppdata.AutoscalerProposalSettings.scaleUsingRunName);
        runObj.deleteInvalidResults();
        this.scale_apply(curMdl,curMdlName,runObj);
    end


    curMdlOrSubsys=get_param(this.sysToScaleName,'Object');
    topAppdata=SimulinkFixedPoint.getApplicationData(topMdl);




    topAppdata.ScaleUsing=this.proposalSettings.scaleUsingRunName;


    topAppdata.AutoscalerProposalSettings=this.proposalSettings;
    curMdlOrSubsysName=SimulinkFixedPoint.AutoscalerUtils.getModelForAutoscaling(curMdlOrSubsys);
    runObj=topAppdata.dataset.getRun(topAppdata.AutoscalerProposalSettings.scaleUsingRunName);
    runObj.deleteInvalidResults()
    this.scale_apply(curMdlOrSubsys,curMdlOrSubsysName,runObj);
    runObj.pushAction(SimulinkFixedPoint.DataTypingServices.EngineActions.Apply);
end
