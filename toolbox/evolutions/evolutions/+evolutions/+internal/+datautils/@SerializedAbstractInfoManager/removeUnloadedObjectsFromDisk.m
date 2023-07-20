function removeUnloadedObjectsFromDisk(obj)





    xmlFilesOnDisk=obj.getXmlFiles;


    currentLoadedObjects=obj.AllInfos;
    currentLoadedFiles=cell(1,numel(currentLoadedObjects));
    for idx=1:numel(currentLoadedObjects)
        currentLoadedFiles{idx}=currentLoadedObjects(idx).XmlFile;
    end


    unloadedFiles=setdiff(xmlFilesOnDisk,currentLoadedFiles);


    for idx=1:numel(unloadedFiles)
        file=unloadedFiles{idx};
        evolutions.internal.utils.removeAndDeleteFile(obj.Project,file);
        evolutions.internal.utils.removeAndDeleteDir(obj.Project,fileparts(file));
    end

end