function dirtyFiles=findDirtyFiles(restoreData)





    dirtyFiles={};
    fileTypeHandler=restorepoint.internal.FileTypeHandler;
    for fileIdx=1:restoreData.OriginalNumDependencies
        currentFullFile=restoreData.OriginalFiles{fileIdx};

        fileData=struct('CurrentFullFile',currentFullFile,'RestoreData',restoreData);
        fileIsDirty=fileTypeHandler.findDirtyFiles(fileData);
        if fileIsDirty
            dirtyFiles{end+1}=currentFullFile;
        end
    end
end
