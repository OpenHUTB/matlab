function ret=getRegisteredWorkspaceReaders()



    wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
    ret=wksParser.getRegisteredWorkspaceImporters();
end
