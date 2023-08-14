function[tyo,tyoo]=relationalOperatorRule(ty1,ty2,op,errorMechanism)










    try
        [tyo,tyoo]=feval('_gpu_relationalOperatorRule',op,ty1,ty2);
    catch err
        encounteredError(errorMechanism,err);
    end
