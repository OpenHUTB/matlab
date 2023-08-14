function[result,appName]=status(this)




    if~this.isConnected()
        this.connect();
    end


    if(this.tc.TargetState==slrealtime.TargetState.IDLE)
        result='stopped';
        appName='';
    elseif((this.tc.TargetState==slrealtime.TargetState.BUSY)&&~isempty(this.tc.ModelState))
        if(this.tc.ModelState==slrealtime.ModelState.RUNNING)
            result='running';
            appName=this.tc.ModelProperties.Application;
        elseif(this.tc.ModelState==slrealtime.ModelState.INITIALIZING)
            result='loading';
        elseif(this.tc.ModelState==slrealtime.ModelState.LOADED)
            result='loaded';
            appName=this.tc.ModelProperties.Application;
        elseif(this.tc.ModelState==slrealtime.ModelState.TERMINATING)
            result='terminating';
            appName=this.tc.ModelProperties.Application;
        elseif(this.tc.ModelState==slrealtime.ModelState.DONE)
            result='terminating';
            appName=this.tc.ModelProperties.Application;
        elseif(this.tc.ModelState==slrealtime.ModelState.MODEL_ERROR)
            result='modelError';
            appName=this.tc.ModelProperties.Application;
        else

            error(message('slrealtime:target:invalidModelState',[char(this.tc.TargetState),char(this.tc.ModelState)]));
        end
    elseif(this.tc.TargetState==slrealtime.TargetState.TARGET_ERROR)
        result='targetError';
        corefiles=this.getCoreFiles('nodownload',true);
        if~isempty(corefiles)
            cmd=sprintf("slrealtime.getCrashStack('%s')",this.TargetSettings.name);
            error(message("slrealtime:target:coreFilesFound",cmd));
        end
    elseif((this.tc.TargetState==slrealtime.TargetState.BUSY)&&isempty(this.tc.ModelState))
        result='terminating';
        appName='';
    else

        error(message('slrealtime:target:invalidTargetState',[char(this.tc.TargetState),char(this.tc.ModelState)]));
    end
