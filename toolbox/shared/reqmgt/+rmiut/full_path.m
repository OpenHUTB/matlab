function filePath=full_path(relPath,refPath)








    if rmiut.isCompletePath(relPath)
        filePath=relPath;
        return;
    end



    if isempty(fileparts(relPath))
        try
            onPath=which(relPath);
            if~isempty(onPath)
                filePath=onPath;
                return;
            end
        catch Mex %#ok<NASGU>
        end
    end


    if ispc
        relPath(relPath=='/')=filesep;
        if nargin>1
            refPath(refPath=='/')=filesep;
        end
    else
        relPath(relPath=='\')=filesep;
        if nargin>1
            refPath(refPath=='\')=filesep;
        end
    end


    if nargin==2
        constructedPath=fullfile(refPath,relPath);
        constructedPath=rmiut.simplifypath(constructedPath,filesep);
        if exist(constructedPath,'file')
            filePath=constructedPath;
            return;
        end
    end



    if exist(relPath,'file')
        currPath=pwd;
        filePath=rmiut.simplifypath(fullfile(currPath,relPath),filesep);
        return;
    end


    rmiut.warnNoBacktrace('Slvnv:reqmgt:full_path:UnresolvedPath',relPath);
    filePath='';
end
