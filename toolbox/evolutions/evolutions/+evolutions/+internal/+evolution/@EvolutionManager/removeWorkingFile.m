function removeWorkingFile(obj,files)




    if~iscell(files)
        files={files};
    end


    findNonExistentFile=cellfun(@(x)isfolder(x),files);
    files(findNonExistentFile)=[];

    bfi=obj.BaseFileManager.create(files);

    obj.WorkingEvolution.removeBaseFile(bfi);
end
