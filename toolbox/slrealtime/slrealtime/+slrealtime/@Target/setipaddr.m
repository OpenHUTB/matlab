function setipaddr(this,addr,netmask)















    notify(this,'SetIPAddressBegin');

    if nargin==2
        netmask='255.255.255.0';
    end

    if~slrealtime.internal.validateIpAddress(addr)
        notify(this,'SetIPAddressFailed');
        this.throwError('slrealtime:target:badipaddr',addr);
    end

    if~slrealtime.internal.validateIpAddress(netmask)
        notify(this,'SetIPAddressFailed');
        this.throwError('slrealtime:target:badnetmask',netmask);
    end

    this.disconnect();

    try
        rootssh=this.getRootSSHObj();





        cmd=sprintf('echo %s netmask %s > /etc/slrtipaddr',addr,netmask);
        this.executeCommand(cmd,rootssh);


        cmd=sprintf('slrealtime stopdaemon; slrealtime stoplogd');
        this.executeCommand(cmd,rootssh);

        cmd=sprintf('ifconfig `get_hostlink.sh` inet `cat /etc/slrtipaddr` up');


        rootssh.execute(cmd);
        pause(1);

        this.TargetSettings.address=convertStringsToChars(addr);


        rootssh=this.getRootSSHObj();

        cmd=sprintf('slrealtime startdaemon; slrealtime startlogd');
        this.executeCommand(cmd,rootssh);

    catch ME
        notify(this,'SetIPAddressFailed');
        this.throwError('slrealtime:target:setIPAddrError',this.TargetSettings.name,ME.message);
    end

    notify(this,'SetIPAddressCompleted',slrealtime.events.TargetIPAddressData(addr));
end
