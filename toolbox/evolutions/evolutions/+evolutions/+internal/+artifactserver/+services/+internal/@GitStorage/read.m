function[file,fileData]=read(obj,identifier)




    data=obj.getFromDb(identifier);
    file=fullfile(getDBPath(obj),data.FileURI);

    fileData=struct;
    fileData.Data=data;
    fileData.Model=mf.zero.getModel(data);


    obj.checkout(identifier,data.FileURI);

end


