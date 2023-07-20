function[tf,identifier]=create(obj,file)






    fileId=isFileInStorage(obj,file);

    if~isempty(fileId)

        incrementReferenceCount(obj,fileId);
        identifier=fileId;
    else


        identifier=matlab.lang.internal.uuid();


        try
            evolutions.internal.utils.createDirSafe(getStorageDir(obj));
            storageFile=getFileInStorage(obj,identifier,file);
            obj.storeFile(file,storageFile);
        catch ME
            [~,name]=fileparts(file);
            exception=MException...
            ('evolutions:artifacts:LocalStorageCreateFail',getString(message...
            ('evolutions:artifacts:LocalStorageCreateFail',name)));
            exception=exception.addCause(ME);
            throw(exception);
        end


        obj.addToDb(identifier,storageFile);
    end

    tf=true;
end
