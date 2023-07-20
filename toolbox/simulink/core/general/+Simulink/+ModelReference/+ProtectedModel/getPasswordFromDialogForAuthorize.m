function getPasswordFromDialogForAuthorize(modelName,topModelName)



    import Simulink.ModelReference.ProtectedModel.*;

    result=getPasswordFromDialogForUnlock(modelName,true,'',true,topModelName);
    while strcmp(result,'WrongPassword')
        result=getPasswordFromDialogForUnlock(modelName,true,'',false,topModelName);
    end
end
