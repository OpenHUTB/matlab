function unregisterWorkspaceReader(this)
    wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
    wksParser.unregisterCustomParser(this);
end
