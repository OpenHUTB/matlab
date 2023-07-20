function pd=getProfilerData(this,appName)









    narginchk(1,2);

    try
        if~this.isConnected
            this.connect;
        end
        profStatus=this.ProfilerStatus;
        if isempty(profStatus)

            error(message('slrealtime:profiling:NoProfilerStatus'));
        elseif strcmpi(profStatus,'Running')

            error(message('slrealtime:profiling:ProfilingRunning',...
            [inputname(1),'.stopProfiler']));
        elseif strcmpi(profStatus,'Ready')




            error(message('slrealtime:profiling:ProfilingDataNotAvailable',...
            [inputname(1),'.startProfiler'],[inputname(1),'.stopProfiler']));
        end

        if nargin==2
            validateattributes(appName,{'string','char'},{},1);
        else
            appName=this.getLastApplication;
            if isempty(appName)
                error(message('slrealtime:profiling:NoApplication'));
            end
        end
        appDir=strcat(this.appsDirOnTarget,"/",appName);


        disp(getString(message('slrealtime:profiling:ProcessingDataTarget')));
        cmd=convertStringsToChars(strcat("slrealtime traceparser --AppName ",appName));
        res=this.executeCommand(cmd);
        if contains(res.Output,"ERROR")
            error(message('slrealtime:profiling:ParserError',res.Output));
        end
        if~isempty(res.ErrorOutput)&&startsWith(res.ErrorOutput,"WARNING")

            slrealtime.internal.throw.Warning('slrealtime:profiling:ParserError',res.ErrorOutput);
        end
        pd=slrealtime.internal.ProfilerData(this,appDir,appName);

        this.deletefolder(strcat(appDir,"/profiler"));
    catch ME
        throwAsCaller(ME);
    end
end
