function[tyo,tyoo]=floatingPointAndLogicalArithmeticRule(ty1,ty2,op,errorMechanism)









    try
        tyo=feval('_gpu_floatingPointAndLogicalArithmeticRule',op,ty1,ty2);
    catch err
        encounteredError(errorMechanism,err);
    end
    tyoo=tyo;
