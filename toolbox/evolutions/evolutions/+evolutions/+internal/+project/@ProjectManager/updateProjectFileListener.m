function updateProjectFileListener(obj,projectInfo)





    if(obj.FileListenerCatalog.isKey(projectInfo))


        listener=obj.FileListenerCatalog(projectInfo);
        listener.clearAllListeners;
    else

        obj.FileListenerCatalog(projectInfo)=evolutions.internal.FileChangeListener;
    end

    projectFiles={projectInfo.Project.Files(:).Path};

    foldersInProject=cellfun(@(x)isfolder(x),projectFiles);
    projectFiles(foldersInProject)=[];

    fileListenerCatalog=obj.FileListenerCatalog(projectInfo);
    for idx=1:numel(projectFiles)
        path=projectFiles{idx};
        listenerFilePath=fileListenerCatalog.addListener(path,@obj.fileChangedCallback);


        obj.FileListenerData(listenerFilePath)=...
        struct('file',path,'project',projectInfo.Project.RootFolder);
    end
end
