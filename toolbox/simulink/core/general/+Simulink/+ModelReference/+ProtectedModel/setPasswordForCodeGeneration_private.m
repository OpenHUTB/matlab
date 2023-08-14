function setPasswordForCodeGeneration_private(model,password)



    import Simulink.ModelReference.ProtectedModel.*;
    pwManager=PasswordManager.Utils('getManager');
    pwManager.setPasswordForEncryptionCategory(getCharArray(model),'RTW',getCharArray(password));
end


