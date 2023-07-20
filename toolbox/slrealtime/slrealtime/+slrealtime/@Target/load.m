function load(this,app,varargin)






















    if this.StopRecordingBusy
        return;
    end

    p=inputParser;
    isScalarLogical=@(x)islogical(x)&&isscalar(x);
    addParameter(p,'AsynchronousLoad',false,isScalarLogical);
    addParameter(p,'SkipInstall',false,isScalarLogical);
    parse(p,varargin{:});
    asyncLoad=p.Results.AsynchronousLoad;
    skipInstall=p.Results.SkipInstall;

    if(nargin<2)||isempty(app)
        this.throwError('slrealtime:target:emptyAppName');
    end
    validateattributes(app,{'char','string'},{'scalartext'});
    app=convertStringsToChars(app);

    [appPath,appName,appExt]=fileparts(app);
    if isempty(appExt)
        appExt='.mldatx';
    end
    appNameWithExt=strcat(appName,appExt);

    if isempty(appPath)
        appFile=which(appNameWithExt);
    else
        appFile=fullfile(appPath,appNameWithExt);
    end

    if isdeployed&&~isfile(appFile)
        this.throwError('slrealtime:target:appDoesNotExistInMCR',app);
        return;
    end

    if~this.isConnected()
        this.connect;
    end



    if~isfile(appFile)
        apps=this.getInstalledApplications();
        if~any(strcmp(apps,appName))
            this.throwError('slrealtime:target:appDoesNotExist');
            return;
        end
    end






    try




        if this.isRunning()
            this.throwError('slrealtime:target:loadAppRunning');
        elseif this.isLoaded()



            tmp=this.SDIRunId;
            this.SDIRunId=[];


            autoImportFlag=this.StopProperties.AutoImportFileLog;
            this.StopProperties.AutoImportFileLog=false;

            this.stop;
            this.SDIRunId=tmp;
            this.StopProperties.AutoImportFileLog=autoImportFlag;
        end

















        while this.tc.ModelConnected()||(this.tc.TargetState==slrealtime.TargetState.BUSY)
            pause(0.01);
        end



        if~skipInstall
            try
                this.install(app);
            catch ME
                if isempty(appPath)&&~isempty(ME.cause)&&strcmp(ME.cause{1}.identifier,'slrealtime:target:appDoesNotExist')






                else
                    rethrow(ME);
                end
            end
        else





            pause(0.5);
        end
    catch ME
        notify(this,'LoadFailed');
        this.throwError('slrealtime:target:loadError',appName,this.TargetSettings.name,ME.message);
    end




    loadComplete=false;
    function cb(~,~)
        loadComplete=true;
    end
    l1=addlistener(this,'Loaded',@cb);
    c1=onCleanup(@()delete(l1));
    l2=addlistener(this,'LoadFailed',@cb);
    c2=onCleanup(@()delete(l2));





    try


        this.stateChart.loading();
        this.tc.load(appName,'AsynchronousLoad',asyncLoad);



















        if~asyncLoad
            while~loadComplete
                pause(0.01);
            end
        end

    catch ME
        this.stateChart.loadFailed();
        this.throwError('slrealtime:target:loadError',appName,this.TargetSettings.name,ME.message);
    end
end
