classdef MassiveSimRunnerWorker<handle
    properties(Constant,Access=private)
        Instance=simulink.multisim.internal.runner.MassiveSimRunnerWorker
    end

    properties(SetAccess=private)
ModelName
        DesignStudy=simulink.multisim.mm.design.DesignStudy.empty
RunIds
ClientDataQ
ReduceFcn
Decimation
    end

    properties(Access=private)
DataModel
DataQ
Sampler
CachedK
CachedIdx
CachedOut
    end

    methods(Access=private)
        function obj=MassiveSimRunnerWorker()
        end
    end

    methods
        function reset(obj,modelName,designStudyStr,clientDataQ,runIds,reduceFcn,decimation)
            obj.ModelName=modelName;
            xmlParser=mf.zero.io.XmlParser;
            obj.DesignStudy=xmlParser.parseString(designStudyStr);
            obj.DataModel=xmlParser.Model;
            obj.ClientDataQ=clientDataQ;
            obj.Sampler=simulink.multisim.internal.sampler.CombinatorialParameterSpace(obj.DesignStudy.ParameterSpace);
            obj.RunIds=runIds;
            obj.ReduceFcn=reduceFcn;
            obj.Decimation=decimation;
        end

        function run(obj)
            for i=1:numel(obj.RunIds)
                obj.runSim(obj.RunIds(i));
            end
            obj.sendCachedOutput();
        end
    end

    methods(Access=private)
        function runSim(obj,simIdx)
            try
                designPoint=obj.Sampler.createDesignPointAtIndex(simIdx);
                simInput=simulink.multisim.internal.createSimulationInputsFromDesignPoints(obj.ModelName,designPoint);
                out=sim(simInput);

                reducedOut=obj.ReduceFcn(simIdx,simInput,out);
                obj.CachedIdx=[obj.CachedIdx,simIdx];
                obj.CachedOut=[obj.CachedOut,struct("simOut",reducedOut,"error",[])];
            catch ME
                obj.CachedIdx=[obj.CachedIdx,simIdx];
                obj.CachedOut=[obj.CachedOut,struct("simOut",[],"error",ME)];
            end

            if mod(numel(obj.CachedOut),obj.Decimation)==0
                obj.sendCachedOutput();
            end
        end

        function sendCachedOutput(obj)
            msgData=struct("msg","done","idx",obj.CachedIdx,"output",obj.CachedOut);
            obj.CachedIdx=[];
            obj.CachedOut=[];
            obj.ClientDataQ.send(msgData);
        end
    end

    methods(Static)
        function instance=getInstance()
            instance=simulink.multisim.internal.runner.MassiveSimRunnerWorker.Instance;
        end
    end
end