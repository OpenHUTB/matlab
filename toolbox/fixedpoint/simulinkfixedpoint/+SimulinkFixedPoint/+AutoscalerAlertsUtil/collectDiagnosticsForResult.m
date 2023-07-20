function[errors,warnings]=collectDiagnosticsForResult(result)
















    appData=SimulinkFixedPoint.getApplicationData(result.getHighestLevelParent);


    proposalDiagnosticsInterface=SimulinkFixedPoint.ProposalDiagnosticInterface.getInterface(appData.AutoscalerProposalSettings);

    if result.hasDTGroup

        runObj=appData.dataset.getRun(result.getRunName);


        group=runObj.dataTypeGroupInterface.getGroupForResult(result);


        groupDiagnostics=proposalDiagnosticsInterface.getGroupDiagnostics(group);
    else


        group=fxptds.DataTypeGroup.empty();



        groupDiagnostics=SimulinkFixedPoint.ProposalDiagnostics.AlertDiagnostic.empty();
    end


    resultDiagnostics=proposalDiagnosticsInterface.getResultDiagnostics(result,group);


    errors=SimulinkFixedPoint.AutoscalerAlertsUtil.collectWarnings(...
    groupDiagnostics,...
    resultDiagnostics,...
    SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Red);


    warnings=SimulinkFixedPoint.AutoscalerAlertsUtil.collectWarnings(...
    groupDiagnostics,...
    resultDiagnostics,...
    SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Yellow);


end