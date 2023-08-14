function checkForIncorrectDerivativeOption(~,nvPairs,caller)









    errId="optim_problemdef:OptimizationProblem:"+caller+":CannotSpecifyEquationDerivative";
    msgId="optim_problemdef:OptimizationProblem:solve:CannotSpecifyEquationDerivative";
    if any(strcmp(nvPairs,'EquationDerivative'))
        error(errId,getString(message(msgId)));
    end

