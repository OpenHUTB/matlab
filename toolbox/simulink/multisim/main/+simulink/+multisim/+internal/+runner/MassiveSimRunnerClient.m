classdef MassiveSimRunnerClient<handle
    properties(SetAccess=immutable)
ModelName
        DesignStudy=simulink.multisim.mm.design.DesignStudy.empty
ReduceFcn
SimCompletedFcn
Decimation
    end

    properties(Access=private)
Pool
        CurrentSimIdx=0
NumDesignPoints
ClientToWorkerDataQ
SimulationManagerEngine
    end

    properties(SetAccess=private)
        Output=[]
SimIdx
        CompletedSims=0
    end

    methods
        function obj=MassiveSimRunnerClient(modelName,designStudy,reduceFcn,simCompletedFcn,decimation,simMgrOptions)
            obj.ModelName=modelName;
            obj.DesignStudy=designStudy;
            obj.ReduceFcn=reduceFcn;
            obj.SimCompletedFcn=simCompletedFcn;
            obj.Decimation=decimation;

            paramSpaceSampler=simulink.multisim.internal.sampler.CombinatorialParameterSpace(designStudy.ParameterSpace);
            obj.NumDesignPoints=paramSpaceSampler.getNumDesignPoints();

            xmlSerializer=mf.zero.io.XmlSerializer;
            designStudyStr=xmlSerializer.serializeToString(designStudy);

            obj.Pool=gcp;
            numWorkers=obj.Pool.NumWorkers;
            numSims=obj.NumDesignPoints;
            randomIdx=randperm(numSims);
            obj.SimIdx=randomIdx;
            numSimsOnEachWorkers=ceil(numSims/numWorkers);
            startIdx=1:numSimsOnEachWorkers:numSims;
            endIdx=numSimsOnEachWorkers:numSimsOnEachWorkers:numSims;
            obj.Output=struct("simOut",{},"error",{});
            if numel(endIdx)<numel(startIdx)
                endIdx(end+1)=numSims;
            end

            clientToWorkerDataQ=parallel.pool.DataQueue;
            clientToWorkerDataQ.afterEach(@(msg)obj.clientDataQCallbackHandler(msg));
            obj.ClientToWorkerDataQ=clientToWorkerDataQ;

            obj.setupWorkers(modelName,simMgrOptions);
            spmd

                if(spmdIndex<=numel(startIdx)&&spmdIndex<=numel(endIdx))
                    simulink.multisim.internal.runner.setupWorkers(modelName,designStudyStr,clientToWorkerDataQ,randomIdx(startIdx(spmdIndex):endIdx(spmdIndex)),reduceFcn,decimation);
                    simulink.multisim.internal.runner.runOnWorker();
                end
            end
        end
    end

    methods(Access=private)
        function clientDataQCallbackHandler(obj,msgData)
            drawnow;
            switch(msgData.msg)
            case "done"
                obj.CompletedSims=obj.CompletedSims+numel(msgData.idx);
                if isfield(msgData,"output")
                    if isa(obj.SimCompletedFcn,"function_handle")&&~isempty(obj.SimCompletedFcn)
                        obj.SimCompletedFcn(msgData.output);
                        drawnow limitrate;
                    end

                    obj.Output(msgData.idx)=msgData.output;
                    assignin("base","out",obj.Output)
                end
            end
        end


        function setupWorkers(obj,modelName,simMgrOptions)
            simMgr=Simulink.SimulationManager(convertStringsToChars(modelName));
            simMgr.Options.UseParallel=true;
            simMgr.Options=simMgrOptions;
            engine=simMgr.SimulationManagerEngine;
            engine.setup();
            obj.SimulationManagerEngine=engine;
        end
    end
end