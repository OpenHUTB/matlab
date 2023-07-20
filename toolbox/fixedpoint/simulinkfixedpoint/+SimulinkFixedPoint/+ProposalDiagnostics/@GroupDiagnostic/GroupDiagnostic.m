classdef GroupDiagnostic<SimulinkFixedPoint.ProposalDiagnostics.AbstractDiagnostic







    methods(Access=public,Hidden)
        function alertLevels=getAllAlertLevels(~,alertDiagnostic,~,group)
            alertLevels=alertDiagnostic.getAlertLevels([],group);
        end

        function getActionableDiagnostics(this,~,group)
            for diagnosticIndex=1:length(this.alertDiagnostics)
                this.alertDiagnostics{diagnosticIndex}.getWarnings([],group);
            end
        end

        function registerConditions(this)
            this.alertDiagnostics={






            SimulinkFixedPoint.ProposalDiagnostics.AlertDiagnostic(...
            SimulinkFixedPoint.WarningConditions.CheckGroupConflictingRange(),...
            SimulinkFixedPoint.AutoscalerAlertsUtil.getAlertLevelsForRangeDiagnostics())


            SimulinkFixedPoint.ProposalDiagnostics.AlertDiagnostic(...
            SimulinkFixedPoint.WarningConditions.CheckGroupHasIncompatibleConstraints(),...
            {SimulinkFixedPoint.ProposalDiagnostics.StaticAlertLevel(...
            SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Red)})


            SimulinkFixedPoint.ProposalDiagnostics.AlertDiagnostic(...
            SimulinkFixedPoint.WarningConditions.CheckGroupSignedness(),...
            SimulinkFixedPoint.AutoscalerAlertsUtil.getAlertLevelsForRangeDiagnostics())

            };
        end
    end
end

