function outputType=mapsToRealRule(inputType,fcnName,errorMechanism)






    try
        outputType=feval('_gpu_mapsToRealRule',fcnName,inputType);
    catch err
        encounteredError(errorMechanism,err);
    end
