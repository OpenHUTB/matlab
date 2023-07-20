function deleteProfilerData(this,appName)





















    narginchk(2,2);
    validateattributes(appName,{'char','string'},{'scalartext'});

    try
        if~this.isConnected()
            this.connect();
        end

        [running,runningAppName]=this.isRunning;
        if running



            if this.tc.TracingConnected&&...
                this.tc.TracingState==slrealtime.internal.TracingState.RUNNING&&...
                (strcmp(appName,'-all')||strcmp(appName,runningAppName))
                this.throwError('slrealtime:Profiling:CannotDelete');
            end
        end

        availProf=this.getAvailableProfile(appName);
        for i=1:numel(availProf)
            profDir=strcat(this.appsDirOnTarget,"/",availProf{i},"/profiler");
            this.deletefolder(profDir)
        end

    catch ME
        throwAsCaller(ME);
    end

end
