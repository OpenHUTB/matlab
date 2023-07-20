classdef CheckSimulationResults<handle
    properties(SetAccess=private,GetAccess=public)
Model
SimulationModes
StopTime
AbsoluteTolerance
RelativeTolerance
    end


    methods(Access=public)
        function this=CheckSimulationResults(modelName,varargin)
            this.Model=modelName;
            this.updateInputParams(this.parseInputArguments(modelName,varargin{:}));
        end


        function check(this)
            this.exec(this.createModificationObjects);
        end
    end


    methods(Abstract,Access=protected)
        createModificationObjects(this);
    end


    methods(Access=private)
        function updateInputParams(this,params)
            this.SimulationModes=params.SimulationModes;
            assert(numel(this.SimulationModes)>1,'You must specify at least two simulation modes for model blocks!');
            this.StopTime=params.StopTime;
            this.AbsoluteTolerance=params.AbsoluteTolerance;
            this.RelativeTolerance=params.RelativeTolerance;
        end


        function exec(this,modificationObjects)
            if numel(modificationObjects)>1
                sandbox=Simulink.Sandbox(...
                this.Model,modificationObjects,'StopTime',this.StopTime,...
                'RelativeTolerance',this.RelativeTolerance,'AbsoluteTolerance',this.AbsoluteTolerance);
                sandbox.check;
            end
        end
    end


    methods(Static,Access=private)
        function params=parseInputArguments(modelName,varargin)
            p=inputParser;
            defaultAbsoluteTolerance=Simulink.SDIInterface.calculateDefaultAbsoluteTolerance(modelName);
            defaultRelativeTolerance=Simulink.SDIInterface.calculateDefaultRelativeTolerance(modelName);
            addOptional(p,'SimulationModes',{'Normal','Accelerator'},@iscellstr);
            addOptional(p,'AbsoluteTolerance',defaultAbsoluteTolerance,@isfloat);
            addOptional(p,'RelativeTolerance',defaultRelativeTolerance,@isfloat);
            addOptional(p,'StopTime',Simulink.SDIInterface.DefaultStopTime,@isfloat);


            parse(p,varargin{:});
            params=p.Results;
        end
    end
end
