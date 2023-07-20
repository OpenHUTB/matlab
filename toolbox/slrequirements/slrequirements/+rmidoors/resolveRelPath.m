function fullpath=resolveRelPath(moduleDesPath,hDOORS)




    if nargin<2
        hDOORS=rmidoors.comApp();
    end
    [projName,folder,desName]=rmidoors.pathParts(moduleDesPath,hDOORS);
    if isempty(folder)
        fullpath=['/',projName,'/',desName];
    else
        fullpath=['/',projName,'/',folder,'/',desName];
    end
end
