function[file,fileData]=read(obj,identifier)




    data=obj.getFromDb(identifier);
    file=fullfile(getDBPath(obj),data.FileURI);

    if~isfile(file)
        exception=MException...
        ('evolutions:artifacts:LocalStorageReadFail',getString(message...
        ('evolutions:artifacts:LocalStorageReadFail',data.FileName)));
        throw(exception);
    end


    fileData=struct;
    fileData.Data=data;
    fileData.Model=mf.zero.getModel(data);
end


