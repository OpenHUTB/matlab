function filePath=locateFile(relPath,ref)

    if rmiut.isCompletePath(relPath)
        filePath=relPath;

    elseif isempty(ref)
        filePath=rmiut.full_path(relPath,pwd);

    elseif ischar(ref)
        switch exist(ref)%#ok<EXIST>
        case 4
            filePath=rmiut.full_path(relPath,getModelDir(ref));
        case 7
            filePath=rmiut.full_path(relPath,ref);
        otherwise
            filePath='';
        end
    else
        filePath=rmiut.full_path(relPath,getModelDir(ref));
    end
end


function modelDir=getModelDir(mdl)
    try
        modelFileName=get_param(mdl,'FileName');
    catch ex %#ok<NASGU>
        modelFileName=which(mdl);
    end
    modelDir=fileparts(modelFileName);
end