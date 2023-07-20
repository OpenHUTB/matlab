function tf=deleteFile(obj,identifier)




    file=obj.read(identifier);

    markedToBeDeleted=decrementReferenceCount(obj,identifier);


    if markedToBeDeleted
        try
            obj.removeFile(file);
        catch ME
            [~,name]=fileparts(file);
            exception=MException...
            ('evolutions:artifacts:LocalStorageDeleteFail',getString(message...
            ('evolutions:artifacts:LocalStorageDeleteFail',name)));
            exception=exception.addCause(ME);
            throw(exception);
        end
    end
    tf=true;
end
