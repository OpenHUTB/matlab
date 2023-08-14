function[outType,operandType]=colonOperatorRule(tya,tyd,tyb,op,errorMechanism)






    try
        [outType,operandType]=feval('_gpu_colonOperatorRule',op,tya,tyd,tyb);
    catch err
        encounteredError(errorMechanism,err);
    end
