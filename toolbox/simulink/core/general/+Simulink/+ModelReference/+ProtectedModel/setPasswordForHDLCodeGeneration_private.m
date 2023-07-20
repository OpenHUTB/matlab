function setPasswordForHDLCodeGeneration_private(model,password)



    import Simulink.ModelReference.ProtectedModel.*;
    pwManager=PasswordManager.Utils('getManager');
    pwManager.setPasswordForEncryptionCategory(getCharArray(model),'HDL',getCharArray(password));
end


