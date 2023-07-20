function insertCommandIntoHistoryWithNoPrompt(command)












    import matlab.internal.lang.capability.Capability;
    useJavaScript=~Capability.isSupported(Capability.LocalClient)||feature('webdesktop');
    if(useJavaScript)
        message.publish('/commandwindow/insertCommandIntoHistoryWithNoPrompt',command);
    else
        com.mathworks.mlservices.MLCommandHistoryServices.add(command);
    end

end