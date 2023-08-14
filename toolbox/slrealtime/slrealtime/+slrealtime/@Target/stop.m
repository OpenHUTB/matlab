function stop(this)





    if~this.isConnected()
        this.connect();
    end

    if~this.isLoaded()&&~this.isRunning()

        return;
    end

    notify(this,'Stopping');




    stopComplete=false;
    function cb(~,~)
        stopComplete=true;
    end
    l=addlistener(this,'Stopped',@cb);
    c=onCleanup(@()delete(l));




    try
        this.tc.stop;













        while~stopComplete
            pause(0.01);
            if~this.isLoaded()&&~this.isRunning()

                break;
            end
        end

    catch ME
        if strcmp(ME.identifier,'slrealtime:target:appNotConn')



            this.stateChart.stopped();
            return;
        end

        notify(this,'StopFailed');
        this.throwError('slrealtime:target:stopError',this.TargetSettings.name,ME.message);
    end
end
