


function message=getTempVarEmptyFunctionStatus(funcBodyObj)


    if strcmp(funcBodyObj.getTempVarSubstatus(),'ERROR')
        message='Verification did not complete. Function status cannot be determined';
    else
        message='Function does not have any temporary variable declarations';
    end
end
