function[tyo,tyoo]=binaryBitFcnRule(ty1,ty2,op,errorMechanism)









    try
        [tyo,tyoo]=feval('_gpu_binaryBitFcnRule',op,ty1,ty2);
    catch err
        encounteredError(errorMechanism,err);
    end
