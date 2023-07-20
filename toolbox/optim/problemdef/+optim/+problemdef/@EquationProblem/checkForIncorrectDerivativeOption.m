function checkForIncorrectDerivativeOption(~,nvPairs,caller)











    errId="optim_problemdef:EquationProblem:"+caller+":CannotSpecifyDerivative";
    msgId="optim_problemdef:EquationProblem:solve:CannotSpecifyDerivative";
    if any(strcmp(nvPairs,'ObjectiveDerivative'))
        error(errId,getString(message(msgId,'ObjectiveDerivative')));
    end
    if any(strcmp(nvPairs,'ConstraintDerivative'))
        error(errId,getString(message(msgId,'ConstraintDerivative')));
    end


