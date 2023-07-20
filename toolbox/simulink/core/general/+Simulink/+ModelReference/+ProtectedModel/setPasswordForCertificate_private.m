function setPasswordForCertificate_private(certificate,password)




    import Simulink.ModelReference.ProtectedModel.getCharArray

    pwManager=Simulink.ModelReference.ProtectedModel.PasswordManager.Utils('getManager');
    pwManager.setPasswordForCertificate(getCharArray(certificate),getCharArray(password));
