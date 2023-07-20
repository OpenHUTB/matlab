function tyo=floatingPointRestrictedDomainRule(ty1,op,errorMechanism)








    try
        tyo=feval('_gpu_floatingPointRestrictedDomainRule',op,ty1);
    catch err
        encounteredError(errorMechanism,err);
    end
