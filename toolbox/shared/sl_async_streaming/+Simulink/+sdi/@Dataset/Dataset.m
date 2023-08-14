classdef(Hidden=true)Dataset<Simulink.SimulationData.Dataset





    methods

        function obj=Dataset(runID,varargin)
            obj=obj@Simulink.SimulationData.Dataset(varargin{:});
            obj.RunID=runID;
        end



        function ret=getRun(this)
            repo=sdi.Repository(1);
            Simulink.HMI.synchronouslyFlushWorkerQueue(repo);
            ret=Simulink.sdi.Run(repo,this.RunID);
        end
    end

    properties(Access=private)
RunID
    end
end
