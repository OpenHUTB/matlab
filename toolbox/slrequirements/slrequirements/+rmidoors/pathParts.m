function[projName,folder,desName]=pathParts(moduleDesPath,hDOORS)

    [desPath,desName,~]=fileparts(moduleDesPath);
    hasRelativePath=(moduleDesPath(1)~='/');
    if~hasRelativePath
        [projName,folder]=strtok(desPath,'/');
        if~isempty(folder)
            folder(1)=[];
        end
    else
        folder=desPath;
        projName=rmidoors.currentFolder(hDOORS);
        projName=strtok(projName,'/');
    end
end
