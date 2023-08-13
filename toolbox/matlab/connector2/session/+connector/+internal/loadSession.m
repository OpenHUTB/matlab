function loadSession(sessionName,sessionHomeDir,userDir,addonsDir,updatePath)

    if nargin==2
        userDir=connector.internal.userdir;
        addonsDir=connector.internal.addonsdir;
        updatePath=matlab.internal.environment.context.isMATLABOnline;
    end



    if nargin==3
        addonsDir=connector.internal.addonsdir;
        updatePath=matlab.internal.environment.context.isMATLABOnline;
    end



    if nargin==4
        if(strcmp(userDir,''))
            userDir=connector.internal.userdir;
        end

        updatePath=matlab.internal.environment.context.isMATLABOnline;
    end




    if nargin==5
        if(strcmp(userDir,''))
            userDir=connector.internal.userdir;
        end
        if(strcmp(addonsDir,''))
            addonsDir=connector.internal.addonsdir;
        end
    end

    if(strcmp(sessionHomeDir,''))
        sessionDir=fullfile(userDir,'.session',sessionName);
    else
        sessionDir=fullfile(sessionHomeDir,'.session',sessionName);
    end

    session=mls.internal.MatlabSession(sessionDir,userDir,addonsDir);
    session.loadSession(updatePath);
end
