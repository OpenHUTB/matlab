function tf=deleteArtifact(obj,data)




    try

        key=data.Id;


        if~obj.iskeyInDB(key)
            tf=false;
            return;
        end


        id=obj.getFromDb(key);


        tf=getStorageService(obj).deleteFile(id);


        removeFromDb(obj,key);
    catch ME
        exception=MException...
        ('evolutions:artifacts:FileVersionDeleteFail',getString(message...
        ('evolutions:artifacts:FileVersionDeleteFail')));
        exception=exception.addCause(ME);
        throw(exception);
    end

end
