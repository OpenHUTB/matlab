function[tyo,tyoo]=equalityOperatorRule(ty1,ty2,op,errorMechanism)









    try
        [tyo,tyoo]=feval('_gpu_equalityOperatorRule',op,ty1,ty2);
    catch err
        encounteredError(errorMechanism,err);
    end
