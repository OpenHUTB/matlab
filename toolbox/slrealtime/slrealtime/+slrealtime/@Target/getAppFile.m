function filename=getAppFile(this,appName)




    filename=[];

    if~this.isConnected()
        this.connect();
    end

    try
        validateattributes(appName,{'char','string'},{'scalartext'});
        appName=convertStringsToChars(appName);
        appNameWithExt=strcat(appName,'.mldatx');

        targetUUID=this.getUUIDFromTarget(appName);
        if isempty(targetUUID)
            filename=[];
            return;
        end




        filename=locGetHostFileOnPathMatchingTargetUUID(appNameWithExt,targetUUID);
        if~isempty(filename)
            return;
        end




        if~isempty(this.uploadedMLDATXFolder)
            origdir=pwd;
            cd(this.uploadedMLDATXFolder);
            c=onCleanup(@()cd(origdir));
            filename=locGetHostFileOnPathMatchingTargetUUID(appNameWithExt,targetUUID);
            if~isempty(filename)
                return;
            end
            delete(c);
        end




        if isempty(this.uploadedMLDATXFolder)
            this.uploadedMLDATXFolder=tempname;
            mkdir(this.uploadedMLDATXFolder);
        end
        targetMLDATXFileOnTarget=strcat(this.appsDirOnTarget,"/",appName,"/",appNameWithExt);
        targetMLDATXFileOnHost=fullfile(this.uploadedMLDATXFolder,appNameWithExt);
        try
            this.receiveFile(targetMLDATXFileOnTarget,targetMLDATXFileOnHost);
        catch
            filename=[];
            return;
        end
        filename=targetMLDATXFileOnHost;

    catch ME
        this.throwError('slrealtime:target:getAppFileError',appName,this.TargetSettings.name,ME.message);
    end
end

function filename=locGetHostFileOnPathMatchingTargetUUID(appNameWithExt,targetUUID)
    filename=[];
    appFile=which(appNameWithExt);
    if~isempty(appFile)
        reader=Simulink.loadsave.SLXPackageReader(appFile);
        hostUUID=reader.readPartToString('/misc/UUID','US-ASCII');
        if strcmp(hostUUID,targetUUID)
            filename=appFile;
            return;
        end
    end
end
