function warnings=collectWarnings(groupDiagnostics,resultDiagnostics,alertLevel)







    groupWarnings=SimulinkFixedPoint.AutoscalerAlertsUtil.collectWarningsForAlertLevel(groupDiagnostics,alertLevel);


    resultWarnings=SimulinkFixedPoint.AutoscalerAlertsUtil.collectWarningsForAlertLevel(resultDiagnostics,alertLevel);


    warnings=[groupWarnings,resultWarnings];
end