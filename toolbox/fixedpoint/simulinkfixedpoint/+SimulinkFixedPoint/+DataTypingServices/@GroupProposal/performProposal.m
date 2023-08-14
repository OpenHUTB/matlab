function performProposal(this)









    topMdl=this.refMdls{end};
    topAppdata=SimulinkFixedPoint.getApplicationData(topMdl);




    topAppdata.ScaleUsing=this.proposalSettings.scaleUsingRunName;

    topAppdata.AutoscalerProposalSettings=this.proposalSettings;


    runObj=topAppdata.dataset.getRun(topAppdata.ScaleUsing);




    if~isempty(runObj.dataTypeGroupInterface.nodes)

        results=runObj.dataTypeGroupInterface.nodes.values;


        this.resultsScope=SimulinkFixedPoint.AutoscalerUtils.getResultsScopeMap(results,this.sysToScaleName);


        this.getProposals(runObj);


        this.determineWarnings(runObj);
    end

    runObj.pushAction(SimulinkFixedPoint.DataTypingServices.EngineActions.Propose);
end
