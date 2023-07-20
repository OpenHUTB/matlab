function install(this,app,varargin)























    if~this.isConnected()
        this.connect();
    end



    validateattributes(app,{'char','string'},{'scalartext'});
    app=convertStringsToChars(app);

    force=false;
    if~isempty(varargin)
        if length(varargin)>1
            this.throwError('slrealtime:target:installInvalidArg');
        end
        arg=varargin{1};
        try
            validateattributes(arg,{'char','string'},{'scalartext'});
        catch
            this.throwError('slrealtime:target:installInvalidArg');
        end
        arg=convertStringsToChars(arg);
        if~strcmpi(arg,'force')
            this.throwError('slrealtime:target:installInvalidArg');
        end
        force=true;
    end

    notify(this,'Installing');

    [appPath,appName,appExt]=fileparts(app);
    if isempty(appExt)
        appExt='.mldatx';
    end
    appNameWithExt=strcat(appName,appExt);

    try
        if isdeployed



            appFile=which(appNameWithExt);
            if~exist(appFile,'file')
                this.throwError('slrealtime:target:appDoesNotExistInMCR',appNameWithExt);
            end
        else


            if isempty(appPath)
                appFile=which(appNameWithExt);
            else
                appFile=fullfile(appPath,appNameWithExt);
            end
            if~exist(appFile,'file')
                this.throwError('slrealtime:target:appDoesNotExist');
            end
        end

        if this.isVerbose
            disp(['Installing application file: ',appFile]);
        end









        info=slrealtime.Target.getSoftwareInfo();
        appObj=slrealtime.Application(appFile);
        modelDesc=slrealtime.internal.deserializeMetadata(appObj,'/misc/','modelDescription');
        if~isfield(modelDesc,'ChecksumInfo')||isempty(modelDesc.ChecksumInfo)
            imageok=false;
            qnxok=false;
            slrtok=false;
            sgok=false;
        else
            imageok=all(info.ImageFile.host.chksumValue==modelDesc.ChecksumInfo.ImageFile);
            qnxok=all(info.QNXTarFile.host.chksumValue==modelDesc.ChecksumInfo.QNXTarFile);
            slrtok=all(info.SlrtTarFile.host.chksumValue==modelDesc.ChecksumInfo.SlrtTarFile);
            sgok=true;
            if~isempty(modelDesc.ChecksumInfo.SpeedgoatLibraryFiles)
                len=length(modelDesc.ChecksumInfo.SpeedgoatLibraryFiles)-1;
                if len~=length(info.SpeedgoatLibraryFiles)
                    sgok=false;
                else
                    for i=1:len
                        if any(info.SpeedgoatLibraryFiles(i).host.chksumValue~=modelDesc.ChecksumInfo.SpeedgoatLibraryFiles{i})
                            sgok=false;
                            break;
                        end
                    end
                end
            end
        end
        if~imageok||~qnxok||~slrtok||~sgok



            if~strcmp(version,modelDesc.MatlabVersion)
                this.throwError('slrealtime:target:appNeedsRebuild',app);
            end
        end





        app=slrealtime.Application(appFile);
        if~force
            reader=Simulink.loadsave.SLXPackageReader(app.File);
            hostUUID=reader.readPartToString('/misc/UUID','US-ASCII');
            tgUUID=this.getUUIDFromTarget(appName);
            if strcmp(hostUUID,tgUUID)
                if this.isVerbose
                    disp('Application with same checksum found on target, skipping install');
                end
                notify(this,'Installed',slrealtime.events.TargetInstallData(appName));
                return;
            end
        end



        targetAppFile=strcat(strcat("/tmp/",appNameWithExt));
        this.sendFile(appFile,targetAppFile);



        this.executeCommand(strcat("slrealtime install --AppName ",targetAppFile));

    catch ME
        notify(this,'InstallFailed');

        this.throwErrorWithCause('slrealtime:target:installError',ME,...
        appName,this.TargetSettings.name,ME.message);
    end

    notify(this,'Installed',slrealtime.events.TargetInstallData(appName));
end
