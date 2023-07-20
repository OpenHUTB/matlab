function uuid=getUUIDFromTarget(this,appName)













    uuid=[];%#ok

    if~this.isConnected()
        this.connect();
    end

    validateattributes(appName,{'char','string'},{'scalartext'});
    appName=convertStringsToChars(appName);

    targetUUIDFileOnTarget=strcat(this.appsDirOnTarget,"/",appName,"/misc/UUID");
    folder=tempname;
    mkdir(folder);
    targetUUIDFileOnHost=fullfile(folder,"UUID");
    try
        this.receiveFile(targetUUIDFileOnTarget,targetUUIDFileOnHost);
    catch
        uuid=[];
        return;
    end

    fid=fopen(targetUUIDFileOnHost);
    c=onCleanup(@()fclose(fid));

    uuid=textscan(fid,'%s');
    while iscell(uuid)
        uuid=uuid{1};
    end
end
