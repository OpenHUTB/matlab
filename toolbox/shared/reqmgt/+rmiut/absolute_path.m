function filePath=absolute_path(relPath,refPath)







    if rmiut.isCompletePath(relPath)
        filePath=relPath;
    elseif nargin==1||isempty(refPath)
        filePath=which(relPath);
    else
        constructedPath=fullfile(refPath,relPath);
        filePath=rmiut.simplifypath(constructedPath,filesep);
    end
end