function value=evaluate(expr,varVal)


























    varVal=optim.internal.problemdef.checkEvaluateInputs(expr,varVal);


    value=evaluateNoCheck(expr,varVal);

end
