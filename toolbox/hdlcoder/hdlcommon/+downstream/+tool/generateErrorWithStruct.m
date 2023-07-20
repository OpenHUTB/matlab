function validateStruct=generateErrorWithStruct(msgObject,cmdDisplay)





    validateStruct=[];
    if cmdDisplay
        error(msgObject);
    else
        validateStruct=hdlvalidatestruct('Error',msgObject);
    end

end