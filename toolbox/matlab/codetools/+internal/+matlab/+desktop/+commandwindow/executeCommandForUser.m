function executeCommandForUser(command)










    import matlab.internal.lang.capability.Capability;
    useJavaScript=~Capability.isSupported(Capability.LocalClient)||feature('webdesktop');

    if(useJavaScript)
        message.publish('/commandwindow/executeCommandForUser',command);
    else
        com.mathworks.mlservices.MLExecuteServices.executeCommand(command);
    end
end