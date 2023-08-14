function errorString=internalValidateLicense(hThis,hBlock)%#ok










    errorString='';
    [isValid,errorStruct]=simscape.compiler.sli.internal.checklicense(hBlock);
    if~isValid
        errorString=errorStruct.message;
    end

end
