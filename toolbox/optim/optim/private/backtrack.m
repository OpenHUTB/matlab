function[beta,betaInit]=...
    backtrack(backtrackCount,prevUseDirect,trRadius,betaInit,initStepPrimal)













    if backtrackCount==1
        if~prevUseDirect


            normInitStepPrimal=norm(initStepPrimal);
            if normInitStepPrimal>=eps
                betaInit=min(0.5,trRadius/normInitStepPrimal);
            else
                betaInit=0.5;
            end
        else
            betaInit=0.5;
        end
        beta=betaInit;
    else
        beta=betaInit*0.5^(backtrackCount-1);
    end

