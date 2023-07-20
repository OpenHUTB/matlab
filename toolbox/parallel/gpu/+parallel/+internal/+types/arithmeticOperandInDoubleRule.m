function[tyo,tyoo]=arithmeticOperandInDoubleRule(ty1,ty2,op,errorMechanism)










    try
        [tyo,tyoo]=feval('_gpu_arithmeticOperandInDoubleRule',op,ty1,ty2);
    catch err
        encounteredError(errorMechanism,err);
    end
