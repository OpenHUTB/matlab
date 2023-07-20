function fullFileName=getLinkSetFilePath(givenName,mustExist)

    if nargin<2
        mustExist=true;
    end

    [fDir,~,fExt]=fileparts(givenName);
    if isempty(fExt)

        givenName=[givenName,'.slmx'];
    end

    if~isempty(fDir)

        if fDir(1)=='.'

            fullFileName=rmiut.simplifypath(fullfile(pwd,givenName));
        else
            fullFileName=givenName;
        end
        if mustExist&&exist(fullFileName,'file')~=2
            error(message('Slvnv:rmiml:FileNotFound',givenName));
        end

    else




        possibleFullPath=fullfile(pwd,givenName);
        if~mustExist
            fullFileName=possibleFullPath;
        elseif exist(possibleFullPath,'file')==2
            fullFileName=possibleFullPath;
        else
            possibleFullPath=which(givenName);
            if~isempty(possibleFullPath)
                fullFileName=possibleFullPath;
            else
                error(message('Slvnv:slreq:NeedFullPathToFile','.slmx',givenName));
            end
        end
    end
end
