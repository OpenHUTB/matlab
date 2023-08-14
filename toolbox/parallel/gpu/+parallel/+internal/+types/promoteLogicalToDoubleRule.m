function tyo=promoteLogicalToDoubleRule(ty1,op,errorMechanism)









    try
        tyo=feval('_gpu_promoteLogicalToDoubleRule',op,ty1);
    catch err
        encounteredError(errorMechanism,err);
    end
