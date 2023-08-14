function tf=read(obj,data)




    try

        key=data.Id;


        if~obj.iskeyInDB(key)
            tf=false;
            return;
        end



        id=obj.getFromDb(key);


        storedfile=getStorageService(obj).read(id);


        obj.unshelveFile(storedfile,data.File);
    catch ME
        if isfield(data,'File')
            [~,name]=fileparts(data.File);
        else
            name='';
        end
        exception=MException...
        ('evolutions:artifacts:FileVersionReadFail',getString(message...
        ('evolutions:artifacts:FileVersionReadFail',name)));
        exception=exception.addCause(ME);
        throw(exception);
    end

    tf=true;
end
