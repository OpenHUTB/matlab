classdef GroupedResultDiagnostic<SimulinkFixedPoint.ProposalDiagnostics.AbstractDiagnostic








    methods(Access=public,Hidden)
        function alertLevels=getAllAlertLevels(~,alertDiagnostic,result,group)
            alertLevels=alertDiagnostic.getAlertLevels(result,group);
        end

        function getActionableDiagnostics(this,result,group)
            for diagnosticIndex=1:length(this.alertDiagnostics)
                this.alertDiagnostics{diagnosticIndex}.getWarnings(result,group);
            end
        end

        function registerConditions(this)
            this.alertDiagnostics={







            SimulinkFixedPoint.ProposalDiagnostics.AlertDiagnostic(...
            SimulinkFixedPoint.WarningConditions.CheckLockedResultGroupConflictingRange(),...
            SimulinkFixedPoint.AutoscalerAlertsUtil.getAlertLevelsForRangeDiagnostics())


            SimulinkFixedPoint.ProposalDiagnostics.AlertDiagnostic(...
            SimulinkFixedPoint.WarningConditions.CheckInternalRuleInGroup(),...
            {SimulinkFixedPoint.ProposalDiagnostics.StaticAlertLevel(...
            SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Yellow)})


            SimulinkFixedPoint.ProposalDiagnostics.AlertDiagnostic(...
            SimulinkFixedPoint.WarningConditions.CheckSpecifiedInGroup(),...
            {SimulinkFixedPoint.ProposalDiagnostics.StaticAlertLevel(...
            SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Red)})
            };
        end
    end
end

