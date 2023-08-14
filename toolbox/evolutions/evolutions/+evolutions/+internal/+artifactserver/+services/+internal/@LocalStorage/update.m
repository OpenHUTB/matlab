function tf=update(obj,identifier,file)






    try

        storageFile=obj.read(identifier);
        obj.storeFile(file,storageFile);


        obj.updateDb(identifier,storageFile);
    catch ME
        [~,name]=fileparts(file);
        exception=MException...
        ('evolutions:artifacts:LocalStorageUpdateFail',getString(message...
        ('evolutions:artifacts:LocalStorageUpdateFail',name)));
        exception=exception.addCause(ME);
        throw(exception);
    end

    tf=true;
end
