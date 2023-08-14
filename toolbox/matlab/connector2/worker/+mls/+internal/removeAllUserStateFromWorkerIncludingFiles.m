







function removeAllUserStateFromWorkerIncludingFiles(varargin)





![ -d /users ] && find /users -name 'builtin*' -execdir chmod 700 -f '{}' \; -delete



    builtin('evalin','base','builtin(''clear'', ''variables'')');
    builtin('evalin','base','builtin(''clear'', ''globals'')');

    userHomeDir=connector.internal.userdir();

    if builtin('nargin')==0
        varargin=[varargin,userHomeDir];
    end

    gdsCacheDir='/tmp/GDS-CACHE';
    gdsCacheFlag=builtin('exist',gdsCacheDir);

    builtin('cellfun',@deleteAllFilesFromFolder,varargin);


    if gdsCacheFlag==7&&~exist(gdsCacheDir)
        mkdir(gdsCacheDir);
    end



    if~exist(userHomeDir)
        mkdir(userHomeDir);
    end



    if~strcmp(pwd,userHomeDir)
        cd(userHomeDir);
    end


    connector.internal.resetState;



    clear globals;
end

function deleteAllFilesFromFolder(dir)


    if builtin('exist',dir)
        builtin('cd',dir);

        if strcmp('/tmp',dir)



!find . ! \( -path './matlabpref/*' -o -path './matlabpref' -o -path './hsperfdata_mcguser/*' -o -path './hsperfdata_mcguser' -o -path './hsperfdata_wguser/*' -o -path './hsperfdata_wguser' -o -path './jetty-0.0.0.0-8080-worker-webapp-_-any-/*' -o -path './jetty-0.0.0.0-8080-worker-webapp-_-any-' -o -name worker.properties -o -name ws_override.properties -o -name info.json \) -execdir chmod 700 -f {} \; 
!find . ! \( -path './matlabpref/*' -o -path './matlabpref' -o -path './hsperfdata_mcguser/*' -o -path './hsperfdata_mcguser' -o -path './hsperfdata_wguser/*' -o -path './hsperfdata_wguser' -o -path './jetty-0.0.0.0-8080-worker-webapp-_-any-/*' -o -path './jetty-0.0.0.0-8080-worker-webapp-_-any-' -o -name worker.properties -o -name ws_override.properties -o -name info.json \) -delete
        else

!find . -execdir chmod 700 -f {} \;
!find . -delete
        end
    end
end
