function ids=getArtifactIdsForFile(obj,file)




    if~iscell(file)
        file={file};
    end

    bfi=obj.BaseFileManager.create(file);

    ids=cell.empty;

    for eiIdx=1:numel(obj.Infos)
        curEi=obj.Infos(eiIdx);

        ids{end+1}=curEi.BaseIdtoArtifactId.at(bfi.Id);%#ok<AGROW> 
    end

end
