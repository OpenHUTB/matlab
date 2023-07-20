function connect(this)





































    if isempty(this.TargetSettings)
        this.throwError('slrealtime:target:invalidTargetObj');
    end

    if this.isConnected()
        return;
    end

    notify(this,'Connecting');

    reachable=false;
    try

        if(isempty(this.TargetSettings.address))
            this.throwError('slrealtime:target:emptyTargetIpAddr');
        end



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

        reachable=true;



        if~this.checkVersion()
            this.throwError('slrealtime:target:versionMismatch',this.TargetSettings.name);
        end




        if isempty(this.HomeDir)
            out=this.executeCommand("echo $HOME");
            this.HomeDir=strip(out.Output);
        end



        if isempty(this.tc)
            this.tc=slrealtime.internal.TargetControl();
        end


        this.tcLoadedListener=addlistener(this.tc,'ModelState','PostSet',@this.loadedListenerCB);
        this.tcLoadFailedListener=addlistener(this.tc,'ModelState','PostSet',@this.loadFailedListenerCB);
        this.tcStartedListener=addlistener(this.tc,'ModelState','PostSet',@this.startedListenerCB);
        this.tcStoppedListener=[addlistener(this.tc,'ModelConnected','PostSet',@this.stoppedListenerCB),...
        addlistener(this.tc,'ModelState','PostSet',@this.stoppedListenerCB),...
        addlistener(this.tc,'TargetState','PostSet',@this.stoppedListenerCB)];
        this.tcTargetConnListener=addlistener(this.tc,'TargetConnected','PostSet',@this.targetConnListenerCB);

        this.tcTETListener=addlistener(this.tc,'ModelExecProperties','PostSet',@this.tetListenerCB);
        if~this.tetStreamingToSDI
            this.tcTETListener.Enabled=false;
        end

        this.tc.openChannel(this.TargetSettings.address);

        this.tc.waitForTargetConn();
        while isempty(this.tc.TargetState)
            pause(0.01);
        end
        if(this.tc.TargetState==slrealtime.TargetState.BUSY)
            try
                this.tc.waitForModelConn();
                while isempty(this.tc.ModelState)
                    pause(0.01);
                end
            catch ME
                if(this.tc.TargetState==slrealtime.TargetState.BUSY)



                    rethrow(ME);
                end
            end
        end

        if isempty(this.ptpd)
            this.ptpd=slrealtime.internal.PTPControl(this);
        end
        try
            this.ptpd.download;
        catch ME
            warning(ME.identifier,'%s',ME.message);
        end

    catch ME
        notify(this,'ConnectFailed');

        if reachable
            link='web(fullfile(docroot, ''slrealtime/ug/troubleshoot-communication-failure-through-firewall.html''))';
            msg=[ME.message,newline,newline,getString(message('slrealtime:target:firewallIssues',link))];
        else
            msg=ME.message;
        end









        if contains(ME.message,'bind: Only one usage of each socket address')
            this.throwErrorWithCause('slrealtime:target:connectBindError',ME,...
            this.TargetSettings.name);
        else
            this.throwErrorWithCause('slrealtime:target:connectError',ME,...
            this.TargetSettings.name,msg);
        end
    end








    slrealtime.TETMonitor.add(this.TargetSettings.name);

    this.stateChart.connected;
    notify(this,'PostConnected');
end
