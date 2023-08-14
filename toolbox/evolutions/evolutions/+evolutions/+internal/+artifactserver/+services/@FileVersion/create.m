function tf=create(obj,data)




    try

        key=data.Id;


        [~,storedId]=getStorageService(obj).create(data.File);


        obj.addToDb(key,storedId);

    catch ME
        if isfield(data,'File')
            [~,name]=fileparts(data.File);
        else
            name='';
        end
        exception=MException...
        ('evolutions:artifacts:FileVersionCreateFail',getString(message...
        ('evolutions:artifacts:FileVersionCreateFail',name)));
        exception=exception.addCause(ME);
        throw(exception);
    end

    tf=true;
end
