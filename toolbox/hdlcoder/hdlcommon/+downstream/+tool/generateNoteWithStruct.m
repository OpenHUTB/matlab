function validateStruct=generateNoteWithStruct(msgObject,cmdDisplay)





    validateStruct=[];
    if cmdDisplay
        hdldisp(msgObject);
    else
        validateStruct=hdlvalidatestruct('Note',msgObject);
    end

end