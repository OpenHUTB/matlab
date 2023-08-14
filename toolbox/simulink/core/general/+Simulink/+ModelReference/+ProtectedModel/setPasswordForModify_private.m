function setPasswordForModify_private(model,password)



    import Simulink.ModelReference.ProtectedModel.*;
    pwManager=PasswordManager.Utils('getManager');
    pwManager.setPasswordForEncryptionCategory(getCharArray(model),'MODIFY',getCharArray(password));

end


