function initialFolders=getInitialProjectFolders()




    initialFolders.defaultProjectFolder=...
    matlab.internal.project.creation.getDefaultFolder();
    initialFolders.currentFolder=pwd;

end