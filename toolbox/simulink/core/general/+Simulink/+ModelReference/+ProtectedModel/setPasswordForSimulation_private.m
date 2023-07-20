function setPasswordForSimulation_private(model,password)



    import Simulink.ModelReference.ProtectedModel.*;
    pwManager=PasswordManager.Utils('getManager');
    pwManager.setPasswordForEncryptionCategory(getCharArray(model),'SIM',getCharArray(password));

end


