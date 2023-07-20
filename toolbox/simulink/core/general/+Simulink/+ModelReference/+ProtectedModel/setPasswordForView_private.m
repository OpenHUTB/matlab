function setPasswordForView_private(model,password)



    import Simulink.ModelReference.ProtectedModel.*;
    pwManager=PasswordManager.Utils('getManager');
    pwManager.setPasswordForEncryptionCategory(getCharArray(model),'VIEW',getCharArray(password));

end


