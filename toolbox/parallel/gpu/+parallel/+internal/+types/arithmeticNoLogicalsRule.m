function tyo=arithmeticNoLogicalsRule(ty1,op,errorMechanism)








    try
        tyo=feval('_gpu_arithmeticNoLogicalsRule',op,ty1);
    catch err
        encounteredError(errorMechanism,err);
    end
