function alertLevels=getAlertLevelsForRangeDiagnostics()










    rangeTypes=SimulinkFixedPoint.AutoscalerAlertsUtil.getRangeTypesForWarnings();

    alertLevels=cell(length(rangeTypes),1);
    for index=1:length(rangeTypes)
        switch(rangeTypes{index})

        case fxptds.RangeType.Simulation


            alertLevels{index}=SimulinkFixedPoint.ProposalDiagnostics.SimulationAlertLevelStrategy();

        case fxptds.RangeType.Derived


            alertLevels{index}=SimulinkFixedPoint.ProposalDiagnostics.DerivedAlertLevelStrategy();

        case fxptds.RangeType.Design

            alertLevels{index}=SimulinkFixedPoint.ProposalDiagnostics.StaticAlertLevel(...
            SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Red);

        case fxptds.RangeType.ModelRequired

            alertLevels{index}=SimulinkFixedPoint.ProposalDiagnostics.StaticAlertLevel(...
            SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Red);
        end
    end

end
