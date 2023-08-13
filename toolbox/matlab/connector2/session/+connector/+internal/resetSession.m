function resetSession(sessionName,sessionHomeDir,userDir,addonsDir)

    if nargin==2
        userDir=connector.internal.userdir;
        addonsDir=connector.internal.addonsdir;
    end


    if nargin==3
        addonsDir=connector.internal.addonsdir;
    end

    if(strcmp(sessionHomeDir,''))
        sessionDir=fullfile(userDir,'.session',sessionName);
    else
        sessionDir=fullfile(sessionHomeDir,'.session',sessionName);
    end

    session=mls.internal.MatlabSession(sessionDir,userDir,addonsDir);
    session.resetSession();