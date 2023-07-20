function[imageok,qnxok,slrtok,sgok]=checkVersion(this)














    platform=this.detectTargetPlatform();
    if(platform=="Linux")
        imageok=true;
        qnxok=true;
        slrtok=true;
        sgok=true;
        return;
    end

    info=slrealtime.Target.getSoftwareInfo();

    isSpeedgoatLibInstalled=~isempty(info.SpeedgoatLibraryFiles);


    imageok=0;
    qnxok=0;
    slrtok=0;
    if isSpeedgoatLibInstalled
        sgok=0;
    else
        sgok=1;
    end



    cmd=[];
    cmd=[cmd,'/proc/boot/cat ',info.ImageFile.target.chksumFile,';'];
    cmd=[cmd,'/proc/boot/cat ',info.QNXTarFile.target.chksumFile,';'];
    cmd=[cmd,'/proc/boot/cat ',info.SlrtTarFile.target.chksumFile,';'];
    for i=1:length(info.SpeedgoatLibraryFiles)
        cmd=[cmd,'/proc/boot/cat ',info.SpeedgoatLibraryFiles(i).target.chksumFile,';'];%#ok
    end



    err=false;
    try
        rootssh=this.getRootSSHObj();
        rootssh.execute(cmd);
        res=rootssh.waitForResult();
    catch

        if~exist('rootssh','var')&&~isempty(this.TargetSettings.address)
            firewallDocCmd=sprintf("web(fullfile(docroot, 'slrealtime/ug/troubleshoot-communication-failure-through-firewall.html'))");
            this.throwError('slrealtime:target:isOnTime',firewallDocCmd);
        end
        err=true;
    end
    if err||~isempty(res.ErrorOutput)

        if nargout==0||nargout==1
            imageok=imageok&&qnxok&&slrtok&&sgok;
        end
        return;
    end



    outputs=split(res.Output,newline);

    if all(info.ImageFile.host.chksumValue==sscanf(outputs{1},'%u %u'))
        imageok=1;
    end
    if all(info.QNXTarFile.host.chksumValue==sscanf(outputs{2},'%u %u'))
        qnxok=1;
    end
    if all(info.SlrtTarFile.host.chksumValue==sscanf(outputs{3},'%u %u'))
        slrtok=1;
    end

    if isSpeedgoatLibInstalled
        sgok=1;
        for i=1:length(info.SpeedgoatLibraryFiles)
            if any(info.SpeedgoatLibraryFiles(i).host.chksumValue~=sscanf(outputs{3+i},'%u %u'))
                sgok=0;
                break;
            end
        end
    end



    if nargout==0||nargout==1
        imageok=imageok&&qnxok&&slrtok&&sgok;
    end
end
