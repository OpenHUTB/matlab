function deregisterDiagViewer(modelName)






    import slvariants.internal.manager.ui.config.VMgrConstants;

    diagMdlName=[VMgrConstants.DiagMdlNamePrefix,modelName];

    slmsgviewer.DeregisterDockedObserver(diagMdlName);
end

