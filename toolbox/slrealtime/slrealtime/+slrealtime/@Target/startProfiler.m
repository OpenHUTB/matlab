function startProfiler(this,appName)







    narginchk(1,2);

    if~this.isConnected()
        this.connect();
    end

    try
        if this.tc.TracingState==slrealtime.internal.TracingState.RUNNING
            slrealtime.internal.throw.Warning('slrealtime:profiling:ProfilingStarted');
            return;
        end
        [running,appRunning]=this.isRunning();
        if~strcmpi(this.status,"loaded")&&~running

            if~this.RunProfiler&&nargin==1
                this.RunProfiler=true;
                return;
            end
        end
        if running&&~isempty(this.getAvailableProfile(appRunning))

            error(message('slrealtime:profiling:ProfilingComplete',...
            [inputname(1),'.getProfilerData'],[inputname(1),'.resetProfiler']));
        end
        if nargin>1

            validateattributes(appName,{'char','string'},{'scalartext'});
        else
            appName=this.tc.ModelProperties.Application;
        end
        appDir=strcat(this.appsDirOnTarget,"/",appName);

        logDir=strcat(appDir,"/profiler");
        logFile=strcat(logDir,"/tracelog.kev");

        try
            this.executeCommand(strcat("mkdir ",logDir));
        catch ME
            if~contains(ME.message,'exists')
                rethrow(ME);
            end
        end


        if~isempty(this.tc.TracingState)&&...
            this.tc.TracingState~=slrealtime.internal.TracingState.STARTING

            this.killProcess("tracelogger");
            traceCmd=strcat("tracelogger -r -b 1024 -D 1 -d1 -E -k 2048 -S 1024M -f ",...
            logFile," > /dev/null 2>&1 &'");

            rootssh=getRootSSHObj(this);
            this.executeCommand(strcat("sh -c 'nohup ",traceCmd),rootssh);
        end
        this.tc.tracingCommand('start');
        maxWait=1.0;
        start=tic;
        while this.tc.TracingState~=slrealtime.internal.TracingState.RUNNING
            pause(0.01);
            if toc(start)>maxWait
                break;
            end
        end
        this.RunProfiler=false;
    catch ME
        throwAsCaller(ME);
    end

end
