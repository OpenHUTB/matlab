






classdef SimulationDebuggerParallelWorker<handle
    properties(SetAccess=private)
ModelHandle
CurrentSimRunId
DebugRunId
    end

    properties(Access=private)
DataQueueClient
    end

    properties(Access={?MultiSim.internal.SimulationDebuggerParallelClient})
DataQueue
    end

    properties(Access=private,Transient=true)
SimRunningListener
Stepper
    end

    methods
        function obj=SimulationDebuggerParallelWorker(modelName,dqClient)
            obj.DataQueueClient=dqClient;

            obj.sendDebugLog('Loading model');
            load_system(modelName);
            obj.ModelHandle=get_param(modelName,'Handle');


            obj.sendDebugLog('Creating Worker DataQueue');
            dq=parallel.pool.DataQueue;
            obj.DataQueue=dq;
            dq.afterEach(@obj.handleRequest);

            obj.DataQueueClient=dqClient;



            obj.sendDebugLog('Creating listener');
            cosObj=get_param(modelName,'InternalObject');
            obj.SimRunningListener=addlistener(cosObj,'SLExecEvent::SIMSTATUS_RUNNING',@obj.handleSimRunning);

            obj.sendDebugLog('Creating stepper');

            obj.Stepper=Simulink.SimulationStepper(modelName);
        end

        function handleRequest(obj,msg)
            obj.sendDebugLog('Message received on parallel worker');
            obj.sendDebugLog(msg);
            try
                switch msg.Command
                case 'connect'
                    obj.connect(msg.RunId);

                case 'pause'
                    obj.pause();

                case 'forward'
                    obj.forward()

                case 'resume'
                    obj.resume();

                case 'stop'
                    obj.stop();

                case 'execute'
                    obj.execute(msg.FunctionHandle);

                case 'createPCTDataQueueClient'
                    obj.createPCTDataQueueClient(msg.BlockPath,msg.PortNumber,msg.DataQueue);

                end
            catch ME
                obj.sendDebugLog(ME);
                rethrow(ME);
            end
        end

        function delete(obj)
            delete(obj.SimRunningListener);
        end
    end

    methods(Access=private)
        function connect(obj,runId)
            obj.DebugRunId=runId;


            if(obj.CurrentSimRunId==runId)
                obj.pause();
                obj.DataQueueClient.send(struct('Tag','IsConnected','Data',true));
            end
        end

        function pause(obj)
            if(obj.CurrentSimRunId==obj.DebugRunId)
                obj.sendDebugLog('pausing');
                set_param(obj.ModelHandle,'SimulationCommand','pause')
            end
        end

        function forward(obj)
            if(obj.CurrentSimRunId==obj.DebugRunId)
                obj.sendDebugLog('stepping');


                obj.Stepper.forward();
            end
        end

        function resume(obj)
            if(obj.CurrentSimRunId==obj.DebugRunId)
                obj.sendDebugLog('resuming');
                set_param(obj.ModelHandle,'SimulationCommand','continue')
            end
        end

        function stop(obj)
            if(obj.CurrentSimRunId==obj.DebugRunId)
                obj.sendDebugLog('stopping');
                set_param(obj.ModelHandle,'SimulationCommand','stop')
            end
        end

        function execute(obj,fh)
            if(obj.CurrentSimRunId==obj.DebugRunId)
                obj.sendDebugLog('executing');
                out=feval(fh);
                obj.DataQueueClient.send(struct('Tag','Output','Data',out));
            end
        end

        function handleSimRunning(obj,~,eventData)
            try
                assert(isstruct(eventData)&&isfield(eventData,'RunId'),...
                'handleSimRunning: eventData must have RunId')
                runId=eventData.RunId;
                obj.CurrentSimRunId=runId;
                obj.sendDebugLog(['Running Sim',num2str(runId)]);
                if obj.DebugRunId==runId
                    obj.DataQueueClient.send(struct('Tag','IsConnected','Data',true));
                    obj.pause();
                end
            catch ME
                obj.sendDebugLog(ME);
                rethrow(ME);
            end
        end

        function sendDebugLog(obj,msg)
            if obj.debugLog()
                obj.DataQueueClient.send(struct('Tag','DebugLog',...
                'Timestamp',datestr(now),'Data',msg));
            end
        end

        function createPCTDataQueueClient(obj,blockPath,portNumber,dq)
            try
                if(obj.CurrentSimRunId==obj.DebugRunId)
                    portHandles=get_param(blockPath,'PortHandles');
                    portHandle=portHandles.Outport(portNumber);
                    slInternal('createPCTDataQueueClient',obj.ModelHandle,portHandle,dq);
                end
            catch ME
                obj.sendDebugLog(ME);
                rethrow(ME);
            end
        end
    end

    methods(Static)
        function out=debugLog(status)


            persistent DebugLogVal
            if nargin
                DebugLogVal=status;
            end
            out=DebugLogVal;
        end
    end
end