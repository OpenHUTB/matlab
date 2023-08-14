function validationSucceded=verifyDiagnostic(obj,executionInfo,objData)












    checkObj=getCheckObject(obj,objData);




    if checkObj.modelObject.canValidateBlock()

        validationSucceded=checkObj.Validate(executionInfo);
    else



        validationSucceded=false;
    end


end
