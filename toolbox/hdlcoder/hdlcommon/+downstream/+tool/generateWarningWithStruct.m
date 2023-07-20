function validateStruct=generateWarningWithStruct(msgObject,cmdDisplay)





    validateStruct=[];
    if cmdDisplay
        warning(msgObject);
    else
        validateStruct=hdlvalidatestruct('Warning',msgObject);
    end

end