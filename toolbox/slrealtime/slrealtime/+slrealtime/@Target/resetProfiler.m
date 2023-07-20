function resetProfiler(this,appName)









    narginchk(1,2);

    try
        this.RunProfiler=false;
        if~isequal(this.ProfilerStatus,'Ready')

            if this.tc.TracingConnected&&...
                this.tc.TracingState==slrealtime.internal.TracingState.RUNNING
                this.stopProfiler;
            end

            this.killProcess("tracelogger");
            if nargin>1
                validateattributes(appName,{'char','string'},{'scalartext'});
                this.deleteProfilerData(appName);
            else
                this.deleteProfilerData('-all');
            end
        end
    catch ME
        throwAsCaller(ME);
    end
end
