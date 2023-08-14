function start(this,varargin)










    if~this.isConnected()
        this.connect;
    end

    parser=inputParser;
    parser.FunctionName="Target.start";
    stopProps=slrealtime.internal.TargetStopProperties;
    isScalarLogical=@(x)islogical(x)&&isscalar(x);
    parser.addParameter('ExportToBaseWorkspace',stopProps.ExportToBaseWorkspace,isScalarLogical);
    parser.addParameter('AutoImportFileLog',stopProps.AutoImportFileLog,isScalarLogical);
    parser.addParameter('ReloadOnStop',stopProps.ReloadOnStop,isScalarLogical);
    parser.addParameter('LogLevel',this.tc.ModelProperties.LogLevel,@(x)ischar(x)||isstring(x));
    parser.addParameter('PollingThreshold',this.tc.ModelProperties.PollingThreshold,@(x)isscalar(x));
    parser.addParameter('RelativeTimer',this.tc.ModelProperties.RelativeTimer,isScalarLogical);
    parser.addParameter('FileLogMaxRuns',this.tc.ModelProperties.FileLogMaxRuns,@(x)isscalar(x));
    parser.addParameter('FileLogUseRAM',this.tc.ModelProperties.FileLogUseRAM,isScalarLogical);
    parser.addParameter('OverrideBaseRatePeriod',this.tc.ModelProperties.OverrideBaseRatePeriod,@(x)isscalar(x));
    parser.addParameter('StopTime',this.tc.ModelProperties.StopTime,@(x)isscalar(x));
    parser.addParameter('StartStimulation','on',@(x)(ischar(x)||isstring(x))&&(strcmpi(x,'on')||strcmpi(x,'off')));
    parser.parse(varargin{:});
    parsed=parser.Results;

    stopProps.ExportToBaseWorkspace=parser.Results.ExportToBaseWorkspace;
    stopProps.AutoImportFileLog=parser.Results.AutoImportFileLog;
    stopProps.ReloadOnStop=parser.Results.ReloadOnStop;






    try
        if startsWith(this.stateChartGetActiveState(),'Status.Connected.Loading')
            this.throwError('slrealtime:target:appLoading');
        end

        if this.isRunning()
            this.throwError('slrealtime:target:startAppRunning');
        end

        if~this.isLoaded()
            this.throwError('slrealtime:target:startFailNoAppLoaded');
        end
    catch ME
        notify(this,'StartFailed');
        this.throwError('slrealtime:target:startError',this.TargetSettings.name,ME.message);
    end




    startComplete=false;
    function cb(~,~)
        startComplete=true;
    end
    l1=addlistener(this,'Started',@cb);
    c1=onCleanup(@()delete(l1));
    l2=addlistener(this,'StartFailed',@cb);
    c2=onCleanup(@()delete(l2));

    if isequal(parsed.StartStimulation,'off')
        this.Stimulation.stop('all');
    end


    this.RecordingOnStart=this.Recording;





    try

        this.tc.updateModelParameters(parsed);



        this.stateChart.starting();
        this.tc.start;















        while~startComplete
            pause(0.01);
        end

    catch ME
        this.stateChart.startFailed();
        this.throwError('slrealtime:target:startError',this.TargetSettings.name,ME.message);
    end

    this.StopProperties=stopProps;
end


