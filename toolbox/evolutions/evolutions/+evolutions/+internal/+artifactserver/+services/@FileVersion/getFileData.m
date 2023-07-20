function[filePath,dataout]=getFileData(obj,data)






    key=data.Id;


    if~obj.iskeyInDB(key)
        filePath=string.empty;
        dataout=struct.empty;
        return;
    end


    id=obj.getFromDb(key);


    storageService=evolutions.internal.artifactserver.services.internal...
    .ServiceManager.getStorageService(obj.getServerDirectory);
    [filePath,dataout]=storageService.read(id);

end