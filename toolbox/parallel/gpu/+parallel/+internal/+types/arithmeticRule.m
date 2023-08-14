function tyo=arithmeticRule(ty1,op,errorMechanism)









    try
        tyo=feval('_gpu_arithmeticRule',op,ty1);
    catch err
        encounteredError(errorMechanism,err);
    end
