function updateQNX(this,p,info)



    force=p.Results.force;
    usesecondpartition=p.Results.secondpartition;


    if usesecondpartition==1
        rootpath='/mnt/qnx';
        doroot=1;
    else
        rootpath='';
        doroot=0;
    end

    if force==1
        imageok=0;
        qnxok=0;
        slrtok=0;
        sgok=0;
    else


        maxTries=10;
        for i=1:maxTries
            if ispc
                cmd=['ping -n 1 ',this.TargetSettings.address];
            else
                cmd=['ping -c 1 ',this.TargetSettings.address];
            end
            [status,result]=system(cmd);
            if~status
                break;
            end
        end
        if(i==maxTries)||~contains(result,'TTL','IgnoreCase',true)
            this.throwError('slrealtime:target:targetNotAlive',maxTries,result);
        end

        [imageok,qnxok,slrtok,~]=this.checkVersion();
        sgok=0;
    end

    notify(this,'UpdateBegin');

    if imageok&&qnxok&&slrtok&&sgok

        msg=message('slrealtime:target:updateUpToDate',this.TargetSettings.name);
        disp(msg.getString());
        notify(this,'UpdateCompleted');
        return;
    end




    if isdeployed
        isAccepted=slrealtime.internal.spLicenseDialog;

        if(~isAccepted)
            return;
        end
    end


    if this.isConnected
        if(this.TargetStatus.State==slrealtime.TargetState.BUSY)
            error(message('slrealtime:target:updateTargetNotIdle',this.TargetSettings.name));
        end
    else

        try
            cmd='slrealtime stop';
            this.executeCommand(cmd);
        catch

        end
    end

    this.disconnect();

    try
        rootssh=this.getRootSSHObj();

        if(doroot)
            try
                cmd='umount /mnt/qnx';
                this.executeCommand(cmd,rootssh);
            catch

            end
            cmd='mount -t qnx6 /dev/hd0t178.1 /mnt/qnx';
            this.executeCommand(cmd,rootssh);
        end


        if isempty(this.HomeDir)
            out=this.executeCommand("echo $HOME");
            this.HomeDir=strip(out.Output);
        end




        cmd=['rm -f ',rootpath,this.HomeDir,'/.slrealtimeModel; rm -rf ',rootpath,this.appsDirOnTarget()];
        if(doroot)
            this.executeCommand(cmd,rootssh);
        else
            this.executeCommand(cmd);
        end




        this.clearStartupApp();

        info.userConfigDir=[rootpath,info.userConfigDir];
        info.ImageFile.target.file=[rootpath,info.ImageFile.target.file];
        info.SlrtTarFile.target.file=[rootpath,info.SlrtTarFile.target.file];
        info.QNXTarFile.target.file=[rootpath,info.QNXTarFile.target.file];

        if(doroot)
            cmd=sprintf("mkdir -p %s",[rootpath,this.HomeDir]);
            this.executeCommand(cmd,rootssh);
            this.executeCommand(['chown  slrt ',[rootpath,this.HomeDir]],rootssh)
        end


        cmd=sprintf("mkdir -p %s",[info.userConfigDir]);
        this.executeCommand(cmd);

        if imageok~=1
            try
                msg=message('slrealtime:target:bootImage');
                [~,fname,ext]=fileparts(info.ImageFile.host.file);
                xferImageFile=[info.userConfigDir,fname,ext];
                locTransfer(this,info.ImageFile.host.file,xferImageFile,msg.getString(),info.userConfigDir);
                moveCommand=sprintf("mv %s %s",xferImageFile,info.ImageFile.target.file);
                this.executeCommand(moveCommand,rootssh);


            catch err
                cmd=sprintf('cd %s;rm -f slrtssd.cksum',info.userConfigDir);
                try

                    this.executeCommand(cmd,rootssh);
                catch
                end
                rethrow(err);
            end
        end

        if slrtok~=1
            try




                msg=message('slrealtime:target:slrtFiles');
                locTransfer(this,info.SlrtTarFile.host.file,info.SlrtTarFile.target.file,msg.getString(),info.userConfigDir);



                cmd=['rm -f ',rootpath,'/usr/target/bin/* ',rootpath,'/usr/target/lib/*'];
                this.executeCommand(cmd,rootssh);



                cmd=sprintf('cd %s/usr;tar xf %s',rootpath,info.SlrtTarFile.target.file);
                this.executeCommand(cmd,rootssh);



                pname=fullfile(matlabroot,'toolbox','slrealtime','target','qnx_images','suidlist.txt');
                [fd,errmsg]=fopen(pname);
                if fd==-1
                    this.throwError('slrealtime:target:updateFileOpenError',pname,errmsg);
                end
                cleanup1=onCleanup(@()fclose(fd));




                count=0;
                filelines=[];
                while~feof(fd)
                    fileline=fgetl(fd);

                    stripped_line=strtrim(fileline);
                    if isempty(stripped_line)||stripped_line(1)=='#'

                        continue;
                    end
                    count=count+1;
                    filelines=[filelines,string(stripped_line)];%#ok<AGROW>
                end
                if~isempty(filelines)
                    str=sprintf('%s ',filelines(:));
                    cmd=['cd ',rootpath,'/usr/target/bin;chmod u+s ',str];
                    this.executeCommand(cmd,rootssh);
                end

            catch err
                cmd=sprintf('cd %s;rm -f slrttools.cksum',info.userConfigDir);
                try

                    this.executeCommand(cmd,rootssh);
                catch
                end
                rethrow(err)
            end
        end



        if true
            if exist('updateSGtools','file')

                if force==1
                    cmd=['rm -Rf ',rootpath,'/usr/speedgoat/!(config)'];
                    this.executeCommand(cmd,rootssh);
                end

                updateSGtools(this,rootssh);
            else
                if~imageok
















                    cmd=['ls ',rootpath,'/usr/speedgoat/bin'];
                    try
                        res=this.executeCommand(cmd,rootssh);
                        sgdir=contains(res.Output,'sg_getHostLinkInterface');
                    catch
                        sgdir=0;
                    end
                    if sgdir
                        try
                            cmd='sg_getHostLinkInterface';
                            res=this.executeCommand(cmd,rootssh);
                            hostlink=res.Output;

                            hostlink(hostlink==10)=[];
                        catch er


                            hostlink='wm0';
                        end
                    end










                    cmd=['rm -Rf ',rootpath,'/usr/speedgoat/!(config)'];
                    this.executeCommand(cmd,rootssh);

                    if sgdir


                        cmd=['mkdir ',rootpath,'/usr/speedgoat/bin;echo ''#! /bin/sh'' > ',rootpath,'/usr/speedgoat/bin/sg_getHostLinkInterface'];
                        this.executeCommand(cmd,rootssh);
                        cmd=['echo echo ',hostlink,' >> ',rootpath,'/usr/speedgoat/bin/sg_getHostLinkInterface'];
                        this.executeCommand(cmd,rootssh);
                        cmd=['chmod uga+x ',rootpath,'/usr/speedgoat/bin/sg_getHostLinkInterface'];
                        this.executeCommand(cmd,rootssh);
                    end
                end
            end
        end

        if qnxok~=1
            try




                msg=message('slrealtime:target:qnxTools');
                locTransfer(this,info.QNXTarFile.host.file,info.QNXTarFile.target.file,msg.getString(),info.userConfigDir);








                cmd=['rm -rf ',rootpath,'/bin ',rootpath,'/sbin ',rootpath,'/lib ',rootpath,'/usr/bin/* ',rootpath,'/usr/include/* ',rootpath,'/usr/lib/lib*'];
                cmd=[cmd,[' ',rootpath,'/usr/libexec/* ',rootpath,'/usr/local/* ',rootpath,'/usr/sbin']];
                try
                    this.executeCommand(cmd,rootssh);
                catch err
                    strs=strsplit(err.message,'\n');




                    for idx=1:length(strs)-1
                        if~isempty(strfind(strs{idx},'Read-only'))
                            continue;
                        else
                            rethrow(err);
                        end
                    end
                end



                cmd=['mkdir -p ',rootpath,'/bin ',rootpath,'/sbin ',rootpath,'/lib ',...
                rootpath,'/lib/dll ',rootpath,'/lib/gcc/8.3.0 ',rootpath,'/lib/dll/pubs '];
                cmd=[cmd,[rootpath,'/usr/bin ',rootpath,'/usr/include/python3.8 ',...
                rootpath,'/usr/lib ',rootpath,'/usr/libexec/awk ',rootpath,'/usr/local/lib ',...
                rootpath,'/usr/local/share/ntp/lib/NTP ',rootpath,'/usr/sbin']];
                try
                    this.executeCommand(cmd,rootssh);
                catch err


                end

                if(doroot)
                    cmd=sprintf(['cd ',rootpath,' && tar xf "%s"'],info.QNXTarFile.target.file);
                else
                    cmd=sprintf('cd / && tar xf "%s"',info.QNXTarFile.target.file);
                end

                this.executeCommand(cmd,rootssh);


                qconnFileSrcPath=fullfile(getenv('SLREALTIME_QNX_SP_ROOT'),...
                getenv('SLREALTIME_QNX_VERSION'),...
                'target','qnx7','x86_64','usr','sbin','qconn');

                if exist(qconnFileSrcPath,'file')
                    this.sendFile(qconnFileSrcPath,'/tmp/qconn');
                    this.executeCommand(['/proc/boot/cp /tmp/qconn ',rootpath,'/usr/sbin/qconn'],rootssh);
                    this.executeCommand(['cd ',rootpath,'/usr/sbin;chmod 755 qconn'],rootssh);
                end





                qconnFileSrcPath=fullfile(getenv('SLREALTIME_QNX_SP_ROOT'),...
                getenv('SLREALTIME_QNX_VERSION'),...
                'target','qnx7','x86_64','usr','sbin','telnetd');

                if exist(qconnFileSrcPath,'file')
                    this.sendFile(qconnFileSrcPath,'/tmp/telnetd');
                    this.executeCommand(['/proc/boot/cp /tmp/telnetd ',rootpath,'/usr/sbin/telnetd'],rootssh);
                    this.executeCommand(['cd ',rootpath,'/usr/sbin;chmod 755 telnetd'],rootssh);
                end
            catch err
                cmd=sprintf('cd %s;rm -f qnxtools.cksum',info.userConfigDir);
                try

                    this.executeCommand(cmd,rootssh);
                catch
                end
                rethrow(err)
            end
        end


        if~imageok
            msg=message('slrealtime:target:updateRestart');
            disp(msg.getString());
            notify(this,'UpdateMessage',slrealtime.events.MessageData(msg.getString()));
            rebootTarget(this,rootssh);
        else


            try
                cmd='slrealtime stopdaemon; slrealtime stoplogd';
                this.executeCommand(cmd,rootssh);

                pause(0.2);

                cmd='slrealtime startdaemon; slrealtime startlogd';
                this.executeCommand(cmd,rootssh);




                cmd='slay -9 -Q statusmonitor || true';
                this.executeCommand(cmd,rootssh);
            catch err
                if contains(err.message,'Could not find slrtd process')
                    msg=message('slrealtime:target:updateRestart');
                    disp(msg.getString());
                    notify(this,'UpdateMessage',slrealtime.events.MessageData(msg.getString()));
                    rebootTarget(this,rootssh);
                else
                    rethrow(err);
                end
            end
        end

    catch err
        notify(this,'UpdateFailed');
        this.throwError('slrealtime:target:updateError',this.TargetSettings.name,err.message);
    end

    msg=message('slrealtime:target:updateUpToDate',this.TargetSettings.name);
    disp(msg.getString());

    notify(this,'UpdateCompleted');
end

function locTransfer(tg,localfn,remotefn,name,configDir)




    if~exist(localfn,'file')
        [~,f,t]=fileparts(localfn);
        tg.throwError('slrealtime:target:noHostFile',[f,t]);
    end
    str=message('slrealtime:target:updatingFile',name);
    disp(str.getString);
    notify(tg,'UpdateMessage',slrealtime.events.MessageData(str.getString()));

    tg.sendFile(localfn,remotefn);


    [~,f,~]=fileparts(localfn);
    cksumFile=[configDir,f,'.cksum'];
    cmd=sprintf("/proc/boot/cksum %s > %s",...
    remotefn,cksumFile);
    tg.executeCommand(cmd);



    newtarok=tg.checkFile(localfn,remotefn,configDir,[]);
    if newtarok~=1
        tg.throwError('slrealtime:target:fileXferFail',remotefn,newtarok);
    end
end

function rebootTarget(tg,ssh)

























    notify(tg,'Rebooting');
    try

        if tg.isConnected
            if(tg.TargetStatus.State==slrealtime.TargetState.BUSY)
                tg.stop;
            end
        end
    catch

    end

    try

        cmd='hamctrl -stop';
        tg.executeCommand(cmd,ssh);


        cmd='slay -9 -Q slrtd; slay -9 -Q logd';
        tg.executeCommand(cmd,ssh);
    catch err1


        try
            cmd='slay -9 -Q ham; slay -9 -Q slrtd; slay -9 logd';
            tg.executeCommand(cmd,ssh);
        catch err2

        end
    end

    try
        cmd='slay -9 -Q tinit';
        tg.executeCommand(cmd,ssh);
    catch err3
    end

    try
        cmd='slay -9 -Q statusmonitor';
        tg.executeCommand(cmd,ssh);
    catch err4

    end


    try




        tg.executeCommand('shutdown >/dev/null 2>/dev/null',ssh);
    catch

    end

    notify(tg,'RebootIssued');


    tg.disconnect;
end

