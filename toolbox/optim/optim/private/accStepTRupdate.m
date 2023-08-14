function trRadius=accStepTRupdate(trRadius,trialStep,modelDecrease,meritDecrease)













    if~strcmpi(trialStep.type,'cgfeas')
        normStepPrimal=norm(trialStep.primal);
    else
        normStepPrimal=norm(trialStep.stepFeasPrimal);
    end

    if trialStep.useDirect
        trRadius=2*normStepPrimal;
    else
        if modelDecrease>0
            ratio=meritDecrease/modelDecrease;
        else
            ratio=0;
        end
        if ratio>=0.9
            trRadius=max(trRadius,7*normStepPrimal);
        elseif ratio>=0.3
            trRadius=max(trRadius,2*normStepPrimal);
        end
    end

