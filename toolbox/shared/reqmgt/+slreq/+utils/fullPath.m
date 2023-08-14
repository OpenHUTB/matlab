function pathToFile=fullPath(rmFile)

    pathToFile='';

    [~,~,fExt]=fileparts(rmFile);
    if isempty(fExt)
        rmFile=[rmFile,'.slreqx'];
    end

    if rmiut.isCompletePath(rmFile)
        if exist(rmFile,'file')==2
            pathToFile=rmFile;
        end
    else
        onMatlabPath=which(rmFile);
        if~isempty(onMatlabPath)
            pathToFile=onMatlabPath;
        else

            resolvedFromRelative=rmiut.absolute_path(rmFile,pwd);
            if exist(resolvedFromRelative,'file')==2
                pathToFile=resolvedFromRelative;
            end
        end
    end

end