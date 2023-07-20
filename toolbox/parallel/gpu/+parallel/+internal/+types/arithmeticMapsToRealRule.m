function outputType=arithmeticMapsToRealRule(inputType,fcnName,errorMechanism)






    try
        outputType=feval('_gpu_arithmeticMapsToRealRule',fcnName,inputType);
    catch err
        encounteredError(errorMechanism,err);
    end
