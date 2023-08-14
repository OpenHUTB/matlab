



















classdef Future<handle
    properties(GetAccess=private,SetAccess=immutable)
        WrappedFuture=parallel.FevalFuture.empty()
        RunId=locGetDefaultFutureID;
ModelName
    end

    properties(Constant,Access=private)


        DefaultFuture=parallel.FevalFuture
    end





    properties(Access=?MultiSim.internal.SimulationRunner)
FinalizeOutputCB
    end

    events
SimulationOutputAvailable
SimulationAborted
    end


    properties(Dependent)


ID






Read





State



Diary
    end

    methods(Hidden=true)



        function obj=Future(future,modelName,runId)
            if nargin>0
                validateattributes(future,{'parallel.FevalFuture'},{'scalar'});
                obj.WrappedFuture=future;
            end

            if nargin>1
                obj.ModelName=modelName;
            end

            if nargin>2
                obj.RunId=runId;
            end
        end
    end

    methods
        function cancel(obj)










            evtData=MultiSim.internal.SimulationAbortedEventData(false,[]);
            obj(1).notify('SimulationAborted',evtData);

            cancel([obj.WrappedFuture]);


            evtData=MultiSim.internal.SimulationAbortedEventData(...
            true,[obj.RunId]);
            obj(1).notify('SimulationAborted',evtData);
        end

        function[completedRunId,simOut]=fetchNext(obj,timeOut)























            if nargin==1
                timeOut=Inf;
            end
            completedRunId=[];
            try
                simOut=[];
                [completedIdx,simOutTmp]=fetchNext([obj.WrappedFuture],timeOut);
                if isempty(completedIdx)
                    return;
                end





                completedRunId=obj(completedIdx).RunId;



                assert(completedRunId~=-1,'Simulink.Simulation.Future:fetchNext invalid RunId');
                simOut=obj(completedIdx).finalizeOutput(simOutTmp);
            catch ME
                throwAsCaller(ME);
            end
        end

        function out=fetchOutputs(obj)














            out=arrayfun(@(F)F.fetchSingleOutput(),obj);
        end

        function OK=wait(obj,varargin)











            OK=wait([obj.WrappedFuture],varargin{:});
        end

        function simOut=Simulink.SimulationOutput(obj)


            simOut=arrayfun(@(F)F.fetchSingleOutputCaptureError(),obj);
        end

        function delete(obj)
            delete(obj.WrappedFuture);
            delete(obj.DefaultFuture);
        end
    end


    methods
        function out=get.ID(obj)
            if~isempty(obj.WrappedFuture)
                out=obj.WrappedFuture.ID;
            else
                out=obj.DefaultFuture.ID;
            end
        end

        function out=get.Read(obj)
            if~isempty(obj.WrappedFuture)
                out=obj.WrappedFuture.Read;
            else
                out=obj.DefaultFuture.Read;
            end
        end

        function out=get.State(obj)
            if~isempty(obj.WrappedFuture)
                out=obj.WrappedFuture.State;
            else
                out=obj.DefaultFuture.State;
            end
        end

        function out=get.Diary(obj)
            if~isempty(obj.WrappedFuture)
                out=obj.WrappedFuture.Diary;
            else
                out='';
            end
        end
    end

    methods(Access=private)
        function out=fetchSingleOutput(obj)
            validateattributes(obj,{'Simulink.Simulation.Future'},{'scalar'});
            out=Simulink.SimulationOutput(obj);
        end

        function newSimOut=finalizeOutput(obj,out)
            if~isempty(obj.FinalizeOutputCB)
                newSimOut=obj.FinalizeOutputCB(out,obj.RunId);
            else
                newSimOut=out;
            end


            evtData=MultiSim.internal.SimulationOutputAvailableEventData(newSimOut,obj.RunId);
            obj.notify('SimulationOutputAvailable',evtData);
        end

        function simOut=fetchSingleOutputCaptureError(obj)
            validateattributes(obj,{'Simulink.Simulation.Future'},{'scalar'});
            F=obj.WrappedFuture;


            while~strcmp(F.State,'finished')
                wait(F,'finished',0.01);
                drawnow;
            end

            if~isempty(F.Error)
                simOut=MultiSim.internal.createSimulationOutput(F.Error,obj.ModelName);
                simInput=F.InputArguments{2};
                simOut=simOut.setUserString(simInput.UserString);


                evtData=MultiSim.internal.SimulationOutputAvailableEventData(simOut,obj.RunId);
                obj.notify('SimulationOutputAvailable',evtData);
            else
                out=fetchOutputs(F);
                simOut=obj.finalizeOutput(out);
            end
        end
    end
end



function ID=locGetDefaultFutureID()
    F=parallel.FevalFuture;
    ID=F.ID;
end
