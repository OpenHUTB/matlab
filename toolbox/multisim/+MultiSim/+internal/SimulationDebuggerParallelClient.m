







classdef SimulationDebuggerParallelClient<MultiSim.internal.SimulationDebugger
    properties(Access=private)
Pool
DataQueue
WorkerDataQueues
        IsConnectionSetup=false
    end

    properties
LastOutput
    end

    properties(Transient=true)
        EnabledPorts=containers.Map('KeyType','double','ValueType','any');
    end

    methods
        function obj=SimulationDebuggerParallelClient(modelName,pool)
            obj@MultiSim.internal.SimulationDebugger(modelName);
            obj.Pool=pool;
            obj.setupConnection();
        end

        function connect(obj,runId)
            obj.DebugRunId=runId;
            obj.send(struct('Command','connect','RunId',runId));
        end

        function pause(obj)
            obj.send(struct('Command','pause'));
        end

        function forward(obj)
            obj.send(struct('Command','forward'));
        end

        function resume(obj)
            obj.send(struct('Command','resume'));
        end

        function stop(obj)
            obj.send(struct('Command','stop'));
        end

        function execute(obj,fh)
            obj.send(struct('Command','execute','FunctionHandle',fh));
        end

        function delete(obj)
            delete(obj.DataQueue);
            delete(obj.WorkerDataQueues);
            delete(obj.EnabledPorts);
            delete(obj.SignalSelectionListener);
        end
    end

    methods(Access=private)
        function setupConnection(obj)





            dq=parallel.pool.DataQueue;
            obj.DataQueue=dq;
            dq.afterEach(@obj.handleDqMessage);




            F=parfevalOnAll(obj.Pool,@MultiSim.internal.createSimulationDebuggerParallelWorkers,1,obj.ModelName,dq);
            wait(F);

            if~isempty(F.Error)
                throw(F.Error{1});
            end



            workerDebuggers=fetchOutputs(F);
            obj.WorkerDataQueues=[workerDebuggers.DataQueue];


            obj.IsConnectionSetup=true;
        end

        function send(obj,msg)

            arrayfun(@(x)x.send(msg),obj.WorkerDataQueues)
        end

        function handleDqMessage(obj,msg)



            switch msg.Tag
            case 'IsConnected'
                obj.IsConnected=msg.Data;
                obj.enableSignalSelectionChangeEvent();

            case 'DebugLog'
                if obj.debugLog()
                    disp(msg.Data);
                end

            case 'Output'
                obj.LastOutput=msg.Data;

            otherwise
                disp(msg)
            end
        end
    end

    methods
        function handleSignalSelection(obj,eventSrc,~)
            items=eventSrc.getItems();
            if~isempty(items)
                cellfun(@(x)obj.enableSparklinesForSignal(x.Source),items);
            end
        end

        function enableSparklinesForSignal(obj,source)
            blockPath=source.Block;
            portNumber=source.PortNumber;
            portHandles=get_param(blockPath,'PortHandles');
            portHandle=portHandles.Outport(portNumber);
            set_param(portHandle,'ShowValueLabel','on');
            if~isKey(obj.EnabledPorts,portHandle)
                dq=parallel.pool.DataQueue;
                dq.afterEach(@(msg)obj.populateData(portHandle,msg));
                obj.EnabledPorts(portHandle)=dq;
                obj.send(struct('Command','createPCTDataQueueClient',...
                'BlockPath',blockPath,...
                'PortNumber',portNumber,...
                'DataQueue',dq));
            end
        end

        function populateData(obj,portHandle,msg)
            domain=SLM3I.SLCommonDomain;
            domain.sparklinesPopulateData(obj.ModelHandle,portHandle,msg.Time,msg.Value);
        end
    end
end