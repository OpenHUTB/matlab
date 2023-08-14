
classdef(Hidden=true)Worker<handle

    properties(Constant,Access=private)
        This=connector.internal.Worker;
    end

    properties
        Started=false;
        Warmed=false;
        OverrideConfigFile='';
        StartFolder='';
        PreInitLog='';
        SecurePortFile='';
    end

    methods(Access=private)
        function this=Worker
            mlock;
        end

        function delete(this)
            this.doStop();
        end

        function doStart(this,varargin)

            if(getenv('MATLAB_THREAD_OBSERVABILITY')=='1')
                logger=connector.internal.Logger('worker::profile');
                logger.info('Turning MATLAB profiler on...');
                profile off
                profile('on','-timestamp','-detail','builtin','-historySize',20000000);
                setenv('NEW_PROFILE_VIEWER','1')
                logger.info('Enabled MATLAB profiler and new profile viewer option');
            end

            if~this.Started
                disp('Starting CPP Connector on Worker');

                logDir=getenv('MATLAB_LOG_DIR');
                if~isempty(logDir)
                    this.PreInitLog=fullfile(logDir,'setupcomputeserver.preInit.log');
                    this.SecurePortFile=fullfile(logDir,'connector.securePort');
                end


                if numel(varargin)>0&&exist(varargin{1},'file')
                    this.OverrideConfigFile=varargin{1};
                else

                    this.OverrideConfigFile=getenv('WORKER_CONFIG');
                end

                this.StartFolder=pwd;


                clear('javaonly');





                rng('default');


                this.setupConnector();

                disp('Warming up worker');

                connector.internal.lifecycle.callAllWorkerStarting();

                this.registerWithMcg();

                this.Started=true;

                disp('CPP Connector on Worker Started');
            end
        end

        function doStop(this)
            munlock;

            if(this.Started)
                disp('Stopping CPP Connector on Worker');

                this.deregisterWithMcg();

                if~isempty(this.StartFolder)
                    cd(this.StartFolder);
                    this.StartFolder='';
                end

                connector.internal.lifecycle.callAllWorkerStopping();

                setenv('MATLAB_CONNECTOR_HOSTING_ENVIRONMENT','');


                if exist(this.PreInitLog,'file')
                    delete(this.PreInitLog);
                end

                if exist(this.SecurePortFile,'file')
                    delete(this.SecurePortFile);
                end



                msg=struct('type','connector/v1/EnableNonce','enabled',true);
                future=connector.internal.synchronousNativeBridgeServiceProviderDeliver(msg,...
                {'connector/json/deserialize','connector/v1/nonce'});
                future.get();

                this.Started=false;

                disp('CPP Connector on Worker Stopped');
            end
        end


        function setupConnector(this)

            connector.ensureServiceOn;
            if usejava('jvm')
                feval('com.mathworks.matlabserver.connector.api.Connector.ensureServiceOn');
            end


            matlab.internal.yield

            if~isempty(this.OverrideConfigFile)&&exist(this.OverrideConfigFile,'file')
                disp('Loading worker override config file');
                name='connectorWorkerOverride';
                group='connector';
                order=10;
                readOnly=true;
                path=this.OverrideConfigFile;
                connector.internal.configurationAddPropertiesFileSource(name,group,order,readOnly,path);
            end



            if~strcmp(getenv('CONNECTOR_WARMUP'),'true')
                msg=struct('type','connector/v1/EnableNonce','enabled',false);
                future=connector.internal.synchronousNativeBridgeServiceProviderDeliver(msg,...
                {'connector/json/deserialize','connector/v1/nonce'});
                future.get();
            end



            connector.internal.configurationSet('connector.enableOriginFilter',false).get();



            setenv('MATLAB_CONNECTOR_HOSTING_ENVIRONMENT','tmw');

            setappdata(groot,'MATLAB_SERVER_ROOT',fullfile(matlabroot,'toolbox','matlab','connector2'));



            connector.internal.StoreGrootAppdata.saveAppdata();
        end


        function registerWithMcg(this)
            fid=fopen(this.SecurePortFile,'w');
            if fid>0
                disp('Writing port number file');
                fprintf(fid,'%d',connector.securePort);
                fclose(fid);
            end

            if strcmp(getenv('REGISTER_WORKER'),'true')
                disp('Registering worker with SetConnectorStatus');
                msg=struct('type','connector/v1/SetConnectorStatus','status','started');
                future=connector.internal.synchronousNativeBridgeServiceProviderDeliver(msg,...
                {'connector/json/deserialize','connector/v1/worker'});
                future.get();

            elseif~isempty(this.PreInitLog)
                disp('Ready to snapshot, creating pre init log file');

                fid=fopen(this.PreInitLog,'w+');
                if fid>0
                    fclose(fid);
                else
                    warning(['Not able to create setupcomputeserver log: ',this.PreInitLog]);
                end
            else
                disp('Not performing any MCG registration');
            end
        end

        function deregisterWithMcg(~)
            msg=struct('type','connector/v1/SetConnectorStatus','status','notset');
            future=connector.internal.synchronousNativeBridgeServiceProviderDeliver(msg,...
            {'connector/json/deserialize','connector/v1/worker'});
            future.get();
        end
    end

    methods(Static)

        function start(varargin)
            try
                connector.internal.Worker.This.doStart(varargin{:});
            catch ex
                disp(ex);
            end
        end

        function stop()
            connector.internal.Worker.This.doStop();
        end

        function retVal=isMATLABOnline()
            retVal=connector.internal.Worker.This.Started;
        end

    end
end

