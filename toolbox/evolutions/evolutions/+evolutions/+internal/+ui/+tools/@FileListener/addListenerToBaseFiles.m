function addListenerToBaseFiles(this,evolution)






    this.clearListenerToBaseFiles;

    baseFiles=evolutions.internal.utils.getBaseToArtifactsKeyValues(evolution);
    for idx=1:numel(baseFiles)
        path=baseFiles(idx).File;
        if~isfile(path)
            return;
        end
        canonizedPath=this.ChangeListener.addListener(path,@this.fileChangedCallback);

        this.FilePathMap(canonizedPath)=path;
    end
end
