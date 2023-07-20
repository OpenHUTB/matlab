function removeFileFromAllEvolutions(obj,file)




    if~iscell(file)
        file={file};
    end

    bfi=obj.BaseFileManager.create(file);

    for eiIdx=1:numel(obj.Infos)
        curEi=obj.Infos(eiIdx);
        curEi.removeBaseFile(bfi);
    end

end
