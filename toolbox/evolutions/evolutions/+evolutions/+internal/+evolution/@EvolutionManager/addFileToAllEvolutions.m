function bfi=addFileToAllEvolutions(obj,files)




    if~iscell(files)
        files={files};
    end

    bfi=obj.BaseFileManager.create(files);

    for eiIdx=1:numel(obj.Infos)
        curEi=obj.Infos(eiIdx);

        addBaseFile(curEi,bfi);
    end
end

function addBaseFile(evolution,baseFiles)

    existingBfis=evolutions.internal.utils.getBaseToArtifactsKeyValues...
    (evolution);

    for idx=1:numel(baseFiles)
        if~ismember(existingBfis,baseFiles(idx))
            evolution.addBaseFile(baseFiles(idx));
        end
    end

end


