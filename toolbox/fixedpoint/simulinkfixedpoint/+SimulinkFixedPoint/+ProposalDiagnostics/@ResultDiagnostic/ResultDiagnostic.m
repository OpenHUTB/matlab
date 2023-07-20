classdef ResultDiagnostic<SimulinkFixedPoint.ProposalDiagnostics.AbstractDiagnostic







    methods(Access=public,Hidden)

        function alertLevels=getAllAlertLevels(~,alertDiagnostic,result,~)



            alertLevels=alertDiagnostic.getAlertLevels(result,[]);
        end

        function getActionableDiagnostics(this,result,~)



            for diagnosticIndex=1:length(this.alertDiagnostics)
                this.alertDiagnostics{diagnosticIndex}.getWarnings(result,[]);
            end
        end

        function registerConditions(this)
            this.alertDiagnostics={






            SimulinkFixedPoint.ProposalDiagnostics.AlertDiagnostic(...
            SimulinkFixedPoint.WarningConditions.CheckPredeterminedAlertRed(),...
            {SimulinkFixedPoint.ProposalDiagnostics.StaticAlertLevel(...
            SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Red)})


            SimulinkFixedPoint.ProposalDiagnostics.AlertDiagnostic(...
            SimulinkFixedPoint.WarningConditions.CheckPredeterminedAlertYellow(),...
            {SimulinkFixedPoint.ProposalDiagnostics.StaticAlertLevel(...
            SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Yellow)})


            SimulinkFixedPoint.ProposalDiagnostics.AlertDiagnostic(...
            SimulinkFixedPoint.WarningConditions.CheckWordlengthExceeds(),...
            {SimulinkFixedPoint.ProposalDiagnostics.MultiwordAlertLevelStrategy})


            SimulinkFixedPoint.ProposalDiagnostics.AlertDiagnostic(...
            SimulinkFixedPoint.WarningConditions.CheckDesignVersusInitialValueRange(),...
            {SimulinkFixedPoint.ProposalDiagnostics.StaticAlertLevel(...
            SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Yellow)})


            SimulinkFixedPoint.ProposalDiagnostics.AlertDiagnostic(...
            SimulinkFixedPoint.WarningConditions.CheckDesignVersusInitialValueRangeUsingProposedDT(),...
            {SimulinkFixedPoint.ProposalDiagnostics.StaticAlertLevel(...
            SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Red)})


            SimulinkFixedPoint.ProposalDiagnostics.AlertDiagnostic(...
            SimulinkFixedPoint.WarningConditions.CheckDesignVersusSimulationRange(),...
            {SimulinkFixedPoint.ProposalDiagnostics.StaticAlertLevel(...
            SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Yellow)})


            SimulinkFixedPoint.ProposalDiagnostics.AlertDiagnostic(...
            SimulinkFixedPoint.WarningConditions.CheckLockedResultConflictingRange(),...
            SimulinkFixedPoint.AutoscalerAlertsUtil.getAlertLevelsForRangeDiagnostics())


            SimulinkFixedPoint.ProposalDiagnostics.AlertDiagnostic(...
            SimulinkFixedPoint.WarningConditions.CheckResultConflictingRange(),...
            SimulinkFixedPoint.AutoscalerAlertsUtil.getAlertLevelsForRangeDiagnostics())


            SimulinkFixedPoint.ProposalDiagnostics.AlertDiagnostic(...
            SimulinkFixedPoint.WarningConditions.CheckResultSignedness(),...
            SimulinkFixedPoint.AutoscalerAlertsUtil.getAlertLevelsForRangeDiagnostics())
            };
        end
    end
end
