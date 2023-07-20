


function[newPath,success]=resolveFile(projectRoot,oldPath)





    oldPath=convertCharsToStrings(oldPath);


    if ispc
        path=strrep(oldPath,"/","\");
        parts=strsplit(path,"\");
        name=parts(end);
        [tempPath,tempSuccess]=resolve(projectRoot,path,parts,name);
        if tempSuccess
            newPath=tempPath;
            success=true;
            return;
        end
    else
        path=strrep(oldPath,"\","/");
        parts=strsplit(path,"/");
        name=parts(end);
        [tempPath,tempSuccess]=resolve(projectRoot,path,parts,name);
        if tempSuccess
            newPath=tempPath;
            success=true;
            return;
        end
    end


    if isfile(oldPath)
        newPath=oldPath;
        success=true;
        return;
    end

    newPath=oldPath;
    success=false;

end

function[newPath,success]=resolve(projectRoot,path,parts,name)










    match=false;
    for i=1:numel(parts)
        tryFolder=fullfile(projectRoot,parts{i:end});
        if isfile(tryFolder)
            match=true;
            break;
        end
    end
    if match
        newPath=tryFolder;
        success=true;
        return;
    end


    if isfile(path)
        newPath=path;
        success=true;
        return;
    end


    match=which(name,"-all");
    if numel(match)==1
        newPath=string(match{1});
        success=true;
        return;
    end

    newPath=path;
    success=false;

end

