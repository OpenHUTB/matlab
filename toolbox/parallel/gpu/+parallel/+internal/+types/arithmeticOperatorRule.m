function[tyo,tyoo]=arithmeticOperatorRule(ty1,ty2,op,errorMechanism)









    try
        [tyo,tyoo]=feval('_gpu_arithmeticOperatorRule',op,ty1,ty2);
    catch err
        encounteredError(errorMechanism,err);
    end
