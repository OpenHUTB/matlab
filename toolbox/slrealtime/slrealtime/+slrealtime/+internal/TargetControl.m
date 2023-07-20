classdef TargetControl<handle






    properties(Constant,Hidden)

        ConverterPlugin=fullfile(toolboxdir(fullfile('shared','networklib','bin',computer('arch'))),'sshmlconverter');


        DevicePlugin=fullfile(toolboxdir(fullfile('slrealtime','bin',computer('arch'))),'targetRTPSDevice');
    end

    properties
        Timeout=20;
    end

    properties(SetObservable,AbortSet)
        TargetState='';
        TargetProperties=struct('Error','');

        ModelState='';
        ModelProperties;
        ModelExecProperties;

        TracingState='';
        TracingProperties=struct('Error','');
        StimulationState={};
        StimulationIsFinished={};
        StimulationProperties=struct('Error','');

        LoggingState='';
        LoggingProperties=struct('Error','');

        PTPStatus=struct('Running',false,'Devctl',false,'Error','',...
        'OneWayDelay',0,'OffsetFromMaster',0,'SlaveToMaster',0,'MasterToSlave',0,...
        'Options',struct('State',slrealtime.internal.PTPOptionsState.READY,...
        'Command','','AutoStart',false));

        SystemLog=struct('Message','','Process','','SequenceNumber',-1);

        ParamSetState='';
        ParamSetProperties=struct('Error','');
        isParamSetRunning=false;
    end

    properties(SetObservable,AbortSet)
        TargetConnected=false;
        ModelConnected=false;
        TracingConnected=false;
        StimulationConnected=false;
        LoggingConnected=false;
        SystemLogConnected=false;
        ParamSetConnected=false;
    end

    properties(Transient=true)
AsyncIOChannel
    end

    properties(GetAccess=private,SetAccess=private)
TargetConnLis
ModelConnLis
TracingConnLis
StimulationConnLis
LoggingConnLis
SystemLogConnLis
ParamSetConnLis

StatusListener

        cleanupObj;
    end

    events
StatusChanged
    end

    methods
        function obj=TargetControl()






            if strcmpi(computer('arch'),'win64')
                curPath=getenv('PATH');
                clnUp=onCleanup(@()setenv('PATH',curPath));
                setenv('PATH',[fullfile(matlabroot,'sys','FastDDS',computer('arch'),'bin'),pathsep,curPath]);
            end

            obj.AsyncIOChannel=matlabshared.asyncio.internal.Channel(obj.DevicePlugin,obj.ConverterPlugin);
            obj.resetModelProperties;


            obj.TargetConnLis=addlistener(obj.AsyncIOChannel,...
            'TargetConnection','PostSet',@obj.handleTargetConnection);

            obj.ModelConnLis=addlistener(obj.AsyncIOChannel,...
            'ModelConnection','PostSet',@obj.handleModelConnection);

            obj.TracingConnLis=addlistener(obj.AsyncIOChannel,...
            'TracingConnection','PostSet',@obj.handleTracingConnection);

            obj.StimulationConnLis=addlistener(obj.AsyncIOChannel,...
            'StimulationConnection','PostSet',@obj.handleStimulationConnection);

            obj.LoggingConnLis=addlistener(obj.AsyncIOChannel,...
            'LoggingConnection','PostSet',@obj.handleLoggingConnection);

            obj.SystemLogConnLis=addlistener(obj.AsyncIOChannel,...
            'SystemLogConnection','PostSet',@obj.handleSystemLogConn);

            obj.ParamSetConnLis=addlistener(obj.AsyncIOChannel,...
            'ParamSetConnection','PostSet',@obj.handleParamSetConnection);




            obj.StatusListener=addlistener(obj.AsyncIOChannel,...
            'Custom',@obj.handleCustomEvent);
        end

        function openChannel(obj,address)
            options.IPAddress=address;
            obj.AsyncIOChannel.open(options);
        end

        function closeChannel(obj)
            obj.AsyncIOChannel.close();

            obj.TargetConnected=false;
            obj.ModelConnected=false;
            obj.TargetState='';
            obj.TargetProperties=struct('Error','');
            obj.ModelState='';
            obj.resetModelProperties;
        end

        function waitForTargetConn(obj,varargin)
            warn=false;
            if(nargin==2)
                if strcmp(varargin{1},"warn")
                    warn=true;
                end
            end

            try
                obj.AsyncIOChannel.execute("waitForTargetConn");
            catch ME
                msg=message('slrealtime:target:error',ME.message);
                if warn
                    warning(msg);
                else
                    error(msg);
                end
            end
        end

        function waitForModelConn(obj)
            try
                obj.AsyncIOChannel.execute("waitForModelConn");
            catch ME
                msg=message('slrealtime:target:error',ME.message);
                error(msg);
            end
        end

        function load(obj,appName,varargin)

            p=inputParser;
            isScalarLogical=@(x)islogical(x)&&isscalar(x);
            addParameter(p,'AsynchronousLoad',false,isScalarLogical);
            parse(p,varargin{:});
            asyncLoad=p.Results.AsynchronousLoad;

            if(obj.TargetState==slrealtime.TargetState.TARGET_ERROR)
                obj.ackError;
            end

            if obj.ModelConnected
                error(message('slrealtime:target:appLoadedLoad',appName,obj.ModelProperties.Application));
            end
            options.action='load';
            options.app=appName;
            options.asyncLoad=asyncLoad;
            try
                obj.AsyncIOChannel.execute("targetControl",options);
            catch ME
                obj.ackError;
                rethrow(ME);
            end

        end

        function ackError(obj)
            options.action='ackError';
            obj.AsyncIOChannel.execute("targetControl",options);
            obj.TargetProperties.Error='';
            obj.resetModelProperties();
        end

        function setStopTime(obj,stopTime)
            validateattributes(stopTime,{'double'},{'scalar'})

            if(stopTime~=obj.ModelProperties.StopTime)
                obj.setModelParameters('StopTime',stopTime);
            end

        end

        function updateModelParameters(obj,parsed)


            if~strcmp(parsed.LogLevel,obj.ModelProperties.LogLevel)
                obj.setModelParameters('LogLevel',parsed.LogLevel);
            end

            if(parsed.PollingThreshold~=obj.ModelProperties.PollingThreshold)
                obj.setModelParameters('PollingThreshold',parsed.PollingThreshold);
            end

            if(parsed.RelativeTimer~=obj.ModelProperties.RelativeTimer)
                obj.setModelParameters('RelativeTimer',parsed.RelativeTimer);
            end

            if(parsed.FileLogMaxRuns~=obj.ModelProperties.FileLogMaxRuns)
                obj.setModelParameters('FileLogMaxRuns',parsed.FileLogMaxRuns);
            end

            if(parsed.FileLogUseRAM~=obj.ModelProperties.FileLogUseRAM)
                obj.setModelParameters('FileLogUseRAM',parsed.FileLogUseRAM);
            end

            if(parsed.OverrideBaseRatePeriod~=obj.ModelProperties.OverrideBaseRatePeriod)
                obj.setModelParameters('OverrideBaseRatePeriod',parsed.OverrideBaseRatePeriod);
            end

            if(parsed.StopTime~=obj.ModelProperties.StopTime)
                obj.setModelParameters('StopTime',parsed.StopTime);
            end
        end

        function start(obj)
            options.action='start';
            obj.AsyncIOChannel.execute("modelControl",options);
        end

        function stop(obj)
            options.action='stop';
            obj.AsyncIOChannel.execute("modelControl",options);
        end


        function tracingCommand(obj,cmd)
            if obj.TracingConnected
                opt.action=cmd;
                obj.AsyncIOChannel.execute("tracingControl",opt);
            end
        end

        function stimulationCommand(obj,cmd,blockNames)
            if obj.StimulationConnected
                opt.action=cmd;
                opt.blockNames=blockNames;
                obj.AsyncIOChannel.execute("stimulationControl",opt);
            end
        end


        function loggingCommand(obj,cmd)
            if obj.LoggingConnected
                opt.action=cmd;
                obj.AsyncIOChannel.execute("loggingControl",opt);
            end
        end


        function ptpPubControl(obj,action,ptpdCmd,autoStart)
            opt.action=action;
            if exist('ptpdCmd','var')
                opt.cmd=ptpdCmd;
            end
            if exist('autoStart','var')
                opt.autoStart=autoStart;
            end

            obj.AsyncIOChannel.execute("PTPControl",opt);
        end


        function paramSetCommand(obj,cmd,val,segment,page)
            if obj.ParamSetConnected
                opt.action=cmd;
                opt.val=val;
                opt.segment=segment;
                opt.page=page;
                obj.AsyncIOChannel.execute("paramSetControl",opt);
            end
        end

        function delete(obj)
            terminateChannel(obj);
        end

    end

    methods(Access=private)
        function resetModelProperties(obj)
            obj.ModelProperties.Application='';
            obj.ModelProperties.ModelName='';
            obj.ModelState='';
            obj.ModelProperties.ErrorDesc='';
            obj.ModelProperties.StopTime=0;
            obj.ModelProperties.LogLevel='';
            obj.ModelProperties.PollingThreshold=0.0;
            obj.ModelProperties.RelativeTimer=false;
            obj.ModelProperties.FileLogMaxRuns=0;
            obj.ModelProperties.FileLogUseRAM=false;
            obj.ModelProperties.OverrideBaseRatePeriod=0.0;

            obj.ModelExecProperties.ExecTime=0;
            obj.ModelExecProperties.TETInfo=struct('Rate',NaN,'TETMin',NaN,...
            'TETMinTime',NaN,'TETMax',NaN,'TETMaxTime',NaN,'TETAvg',NaN);
        end

        function handleTargetConnection(obj,~,eventData)
            obj.TargetConnected=eventData.AffectedObject.TargetConnection;
        end

        function handleModelConnection(obj,~,eventData)
            obj.ModelConnected=eventData.AffectedObject.ModelConnection;
        end

        function handleTracingConnection(obj,~,eventData)
            obj.TracingConnected=eventData.AffectedObject.TracingConnection;
        end
        function handleStimulationConnection(obj,~,eventData)
            obj.StimulationConnected=eventData.AffectedObject.StimulationConnection;
        end

        function handleLoggingConnection(obj,~,eventData)
            obj.LoggingConnected=eventData.AffectedObject.LoggingConnection;
        end

        function handleSystemLogConn(obj,~,eventData)
            obj.SystemLogConnected=eventData.AffectedObject.SystemLogConnection;
        end

        function handleParamSetConnection(obj,~,eventData)
            obj.ParamSetConnected=eventData.AffectedObject.ParamSetConnection;
        end

        function handleCustomEvent(obj,~,eventData)


            switch eventData.Type
            case 'TargetStatus'
                obj.TargetState=eventData.Data.State;
                obj.TargetProperties.Error=eventData.Data.Error;

            case 'ModelStatus'
                obj.ModelProperties.Application=eventData.Data.Application;
                obj.ModelProperties.ModelName=eventData.Data.ModelName;
                obj.ModelProperties.ErrorDesc=eventData.Data.ErrorDesc;
                obj.ModelProperties.StopTime=eventData.Data.StopTime;
                obj.ModelProperties.LogLevel=eventData.Data.LogLevel;
                obj.ModelProperties.PollingThreshold=eventData.Data.PollingThreshold;
                obj.ModelProperties.RelativeTimer=eventData.Data.RelativeTimer;
                obj.ModelProperties.FileLogMaxRuns=eventData.Data.FileLogMaxRuns;
                obj.ModelProperties.FileLogUseRAM=eventData.Data.FileLogUseRAM;
                obj.ModelProperties.OverrideBaseRatePeriod=eventData.Data.OverrideBaseRatePeriod;

                obj.ModelState=eventData.Data.State;

            case 'TETInfo'
                v.ExecTime=eventData.Data.ExecTime;
                for ctr=1:length(eventData.Data.TETMin)
                    v.TETInfo(ctr).Rate=eventData.Data.Rate(ctr);
                    v.TETInfo(ctr).TETMin=eventData.Data.TETMin(ctr);
                    v.TETInfo(ctr).TETMax=eventData.Data.TETMax(ctr);
                    v.TETInfo(ctr).TETAvg=eventData.Data.TETAvg(ctr);
                    v.TETInfo(ctr).TETMinTime=eventData.Data.TETMinTime(ctr);
                    v.TETInfo(ctr).TETMaxTime=eventData.Data.TETMaxTime(ctr);
                end

                obj.ModelExecProperties=v;

            case 'TracingStatus'
                obj.TracingState=eventData.Data.State;
                obj.TracingProperties.Error=eventData.Data.Error;
            case 'StimulationStatus'
                for ctr=1:length(eventData.Data)
                    obj.StimulationState{ctr}=eventData.Data(ctr).State;
                    obj.StimulationIsFinished{ctr}=eventData.Data(ctr).IsFinished;
                    obj.StimulationProperties.Error=eventData.Data(ctr).Error;
                end

            case 'LoggingStatus'
                obj.LoggingState=eventData.Data.State;
                obj.LoggingProperties.Error=eventData.Data.Error;

            case 'PTPStatus'
                obj.PTPStatus=eventData.Data;

            case 'SystemLog'
                obj.SystemLog=eventData.Data;

            case 'ParamSetStatus'
                obj.ParamSetState=eventData.Data.State;
                obj.ParamSetProperties.Error=eventData.Data.Error;
                if obj.ParamSetState==slrealtime.internal.ParamSetState.PROCESSING
                    obj.isParamSetRunning=true;
                else
                    obj.isParamSetRunning=false;
                end
            end
        end

        function terminateChannel(obj)
            if(~isempty(obj.AsyncIOChannel))
                obj.AsyncIOChannel.close();
                delete(obj.AsyncIOChannel);
                delete(obj.TargetConnLis);
                delete(obj.ModelConnLis);
                delete(obj.TracingConnLis);
                delete(obj.StimulationConnLis);
                delete(obj.LoggingConnLis);
                delete(obj.SystemLogConnLis);
                delete(obj.ParamSetConnLis);

                obj.AsyncIOChannel=[];
                obj.AsyncIOChannel=[];
                obj.TargetConnLis=[];
                obj.ModelConnLis=[];
                obj.TracingConnLis=[];
                obj.StimulationConnLis=[];
                obj.SystemLogConnLis=[];
                obj.ParamSetConnLis=[];
            end
        end

        function setModelParameters(obj,param,val)
            cmd=strcat('set',param);
            options.action=cmd;
            if(isstring(val)||ischar(val))
                options.stringVal=val;
            elseif islogical(val)
                options.boolVal=val;
            else
                options.numVal=val;
            end
            obj.AsyncIOChannel.execute("modelControl",options);
        end

    end
end



