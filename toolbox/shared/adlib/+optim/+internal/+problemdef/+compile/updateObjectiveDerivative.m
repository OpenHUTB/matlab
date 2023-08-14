function probStruct=updateObjectiveDerivative(probStruct,objective,isSumSquares)









    if getSupportsAD(objective)
        switch probStruct.objectiveDerivative
        case 'auto'
            if isSumSquares&&numel(objective)>=probStruct.NumVars
                probStruct.objectiveDerivative="forward-AD";
            else
                probStruct.objectiveDerivative="reverse-AD";
            end
        case 'auto-reverse'
            probStruct.objectiveDerivative="reverse-AD";
        case 'auto-forward'
            probStruct.objectiveDerivative="forward-AD";
        case 'finite-differences'

        end
    else
        probStruct.objectiveDerivative="finite-differences";
    end