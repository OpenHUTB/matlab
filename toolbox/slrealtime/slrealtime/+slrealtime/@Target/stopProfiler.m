function stopProfiler(this)






    try
        if~this.tc.TracingConnected||...
            this.tc.TracingState~=slrealtime.internal.TracingState.RUNNING

            if~this.RunProfiler
                slrealtime.internal.throw.Warning('slrealtime:profiling:ProfilingStopped');
            else
                slrealtime.internal.throw.Warning('slrealtime:profiling:StartCancelled');
            end
        else

            this.tc.tracingCommand('stop');

            maxWait=2.0;
            start=tic;
            while this.tc.TracingState~=slrealtime.internal.TracingState.STOPPED
                pause(0.1);
                if toc(start)>maxWait
                    break;
                end
            end




            [isRunning,~]=this.isRunning();
            if this.isLoaded()&&~isRunning
                this.resetProfiler;
            end



            this.killProcess("tracelogger");
        end
        this.RunProfiler=false;
    catch ME
        throw(ME);
    end

end
