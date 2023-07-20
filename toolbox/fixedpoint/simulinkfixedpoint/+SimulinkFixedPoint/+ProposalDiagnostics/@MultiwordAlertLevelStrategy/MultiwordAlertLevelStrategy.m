classdef MultiwordAlertLevelStrategy<handle







    methods
        function alertLevel=getAlertLevel(~,proposalSettings)


            if proposalSettings.isWLSelectionPolicy

                alertLevel=SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Yellow;
            else

                alertLevel=SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Green;
            end

        end
    end
end