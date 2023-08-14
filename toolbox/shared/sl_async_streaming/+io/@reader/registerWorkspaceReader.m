function registerWorkspaceReader(this)
    wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
    wksParser.registerCustomParser(this);
end
