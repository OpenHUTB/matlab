function createProjectFromImport(obj,filesToAdd,dirsToAdd,projectFullPath)


    if(~isfile(projectFullPath))
        errmsg=MException(message('Simulink:CodeImporter:NonexistentProjectFile',projectFullPath));
        throw(errmsg);
    end

    importProject=matlab.project.loadProject(projectFullPath);
    ProjectFolder=importProject.RootFolder;

    allFilesAndDirsToCheck=[filesToAdd{:},dirsToAdd{:}];
    isWitinProjectFolder=contains(lower(allFilesAndDirsToCheck),lower(ProjectFolder));

    if~all(isWitinProjectFolder)

        fileNotWitinProjectFolder=allFilesAndDirsToCheck(find(~isWitinProjectFolder,1));
        errmsg=MException(message('Simulink:CodeImporter:ProjectWithinIncludeDir',fileNotWitinProjectFolder,ProjectFolder));
        throw(errmsg);
    end


    for i=1:length(filesToAdd)
        arrayfun(@(filesIt)importProject.addFile(filesIt),filesToAdd{i});
    end

    for i=1:length(dirsToAdd)
        arrayfun(@(dirsIt)importProject.addFolderIncludingChildFiles(dirsIt),dirsToAdd{i});
    end

end