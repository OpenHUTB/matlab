function pathToMatlabFile=cmdToPath(cmd)

    pathToMatlabFile=which(cmd);

    if isempty(pathToMatlabFile)
        allDots=find(cmd=='.');
        if length(allDots)>1&&allDots(end)<length(cmd)

            lastDot=allDots(end);
            possibleClass=cmd(1:lastDot-1);
            classFile=which(possibleClass);
            if~isempty(classFile)
                [classDir,~,ext]=fileparts(classFile);
                if strcmp(ext,'.m')&&~isempty(classDir)
                    memberFile=fullfile(classDir,[cmd(lastDot+1:end),'.m']);
                    if exist(memberFile,'file')==2
                        pathToMatlabFile=memberFile;
                    else
                        pathToMatlabFile=classFile;
                    end
                end
            end
        end
    end

end
