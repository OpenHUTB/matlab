classdef AlertLevelsEnum<handle














    enumeration
Red
Yellow
Green
    end

    methods(Static)
        function maxLevel=max(levels)



            if isempty(levels)
                maxLevel=SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Green;
            else

                isRed=levels==SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Red;



                if any(isRed)
                    maxLevel=SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Red;
                else



                    isYellow=levels==SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Yellow;
                    if any(isYellow)
                        maxLevel=SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Yellow;
                    else



                        maxLevel=SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Green;
                    end
                end
            end
        end
    end


end