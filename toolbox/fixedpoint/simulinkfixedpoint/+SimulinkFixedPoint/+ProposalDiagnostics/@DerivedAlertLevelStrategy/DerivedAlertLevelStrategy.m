classdef DerivedAlertLevelStrategy<handle






    methods
        function alertLevel=getAlertLevel(~,proposalSettings)


            if proposalSettings.isUsingDerivedMinMax


                alertLevel=SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Red;
            else


                alertLevel=SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Yellow;
            end

        end
    end

end

