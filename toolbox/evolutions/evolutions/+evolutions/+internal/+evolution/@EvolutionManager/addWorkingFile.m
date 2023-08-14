function bfi=addWorkingFile(obj,files)




    if~iscell(files)
        files={files};
    end


    findNonExistentFile=cellfun(@(x)isfolder(x),files);
    files(findNonExistentFile)=[];

    bfi=obj.BaseFileManager.create(files);

    obj.WorkingEvolution.addBaseFile(bfi);

end
