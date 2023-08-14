function[tf,identifier]=create(obj,file)






    storageFile=obj.getFileInStorage(file);


    evolutions.internal.utils.createDirSafe(fileparts(storageFile));
    copyfile(file,storageFile);


    obj.addFile(storageFile);


    identifier=obj.commit;

    obj.addToDb(identifier,storageFile);

    tf=true;
end


