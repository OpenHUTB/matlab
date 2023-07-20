classdef(Sealed)SimulationOptions<hgsetget








    properties(SetAccess=private,Hidden)
SimulationType
DESuiteSolverName
UnitConversion
SensitivityAnalysis
    end

    properties(SetAccess=public,Hidden)
        LogSolverAndOutputTimes=false;
    end

    properties(SetAccess=public,Hidden)
        InitialStep=-1;
    end

    properties(SetAccess=public)
SolverType
    end

    properties(SetAccess=public)

        MaximumNumberOfLogs=inf;
        MaximumWallClock=inf;
        StopTime=10;
        TimeUnits=''


        AbsoluteTolerance=1e-6;
        AbsoluteToleranceScaling=true;
        AbsoluteToleranceStepSize=zeros(0,1);
        MaxStep=zeros(0,1);
        OutputTimes=zeros(0,1);
        RelativeTolerance=1e-3;


        LogDecimation=1;
        RandomState=zeros(0,1);


        MaxIterations=25;


        ErrorTolerance=0.03;
    end

    methods(Access=private)
        function delete(~)

        end
    end

    methods(Hidden)
        function obj=SimulationOptions()
        end
    end

    methods(Static,Access=public,Hidden)
        function obj=export(configset,sensitivityAnalysis)
            obj=SimBiology.internal.SimulationOptions;
            obj.SolverType=configset.SolverType;
            obj.UnitConversion=configset.CompileOptions.UnitConversion;
            obj.MaximumNumberOfLogs=configset.MaximumNumberOfLogs;
            obj.MaximumWallClock=configset.MaximumWallClock;
            obj.StopTime=configset.StopTime;
            obj.TimeUnits=configset.TimeUnits;




            obj.SensitivityAnalysis=sensitivityAnalysis;

            solverOptions=configset.SolverOptions;
            switch configset.SolverType
            case 'expltau'
                obj.SimulationType=obj.SolverType;
                obj.ErrorTolerance=solverOptions.ErrorTolerance;
                obj.LogDecimation=solverOptions.LogDecimation;
                obj.RandomState=solverOptions.RandomState;
            case 'impltau'
                obj.SimulationType=obj.SolverType;
                obj.LogDecimation=solverOptions.LogDecimation;
                obj.RandomState=solverOptions.RandomState;
                obj.MaxIterations=solverOptions.MaxIterations;
                obj.AbsoluteTolerance=solverOptions.AbsoluteTolerance;
                obj.ErrorTolerance=solverOptions.ErrorTolerance;
            case 'ssa'
                obj.SimulationType=obj.SolverType;
                obj.LogDecimation=solverOptions.LogDecimation;
                obj.RandomState=solverOptions.RandomState;
            otherwise
                obj.SimulationType='desuite';
                obj.InitialStep=solverOptions.InitialStep;
                obj.AbsoluteTolerance=solverOptions.AbsoluteTolerance;
                obj.AbsoluteToleranceStepSize=solverOptions.AbsoluteToleranceStepSize;
                obj.AbsoluteToleranceScaling=solverOptions.AbsoluteToleranceScaling;
                obj.MaxStep=solverOptions.MaxStep;
                obj.OutputTimes=solverOptions.OutputTimes;
                obj.LogSolverAndOutputTimes=solverOptions.LogSolverAndOutputTimes;
                obj.RelativeTolerance=solverOptions.RelativeTolerance;
            end
            updateDESuiteSolverName(obj);
        end
    end

    methods
        function set.InitialStep(obj,value)
            validateattributes(value,{'numeric','logical'},{'scalar'});
            obj.InitialStep=double(real(value));
        end

        function set.MaximumNumberOfLogs(obj,value)
            validateattributes(value,{'numeric','logical'},{'scalar','positive','nonnan'});
            obj.MaximumNumberOfLogs=double(real(value));
        end

        function set.MaximumWallClock(obj,value)
            validateattributes(value,{'numeric','logical'},{'scalar','positive','nonnan'});
            obj.MaximumWallClock=double(real(value));
        end

        function set.StopTime(obj,value)
            validateattributes(value,{'numeric','logical'},{'scalar','nonnegative','nonnan'});
            obj.StopTime=double(real(value));
        end

        function set.AbsoluteTolerance(obj,value)
            validateattributes(value,{'numeric','logical'},{'scalar','positive','finite'});
            obj.AbsoluteTolerance=double(real(value));
        end

        function set.AbsoluteToleranceScaling(obj,value)
            SimBiology.internal.ValidationHelper.validateLogicalScalarCompatible(value);
            obj.AbsoluteToleranceScaling=logical(value);
        end

        function set.LogSolverAndOutputTimes(obj,value)
            SimBiology.internal.ValidationHelper.validateLogicalScalarCompatible(value);
            obj.LogSolverAndOutputTimes=logical(value);
        end

        function set.AbsoluteToleranceStepSize(obj,value)
            if isempty(value)
                obj.AbsoluteToleranceStepSize=zeros(0,1);
            else
                validateattributes(value,{'numeric','logical'},{'scalar','positive','finite'});
                obj.AbsoluteToleranceStepSize=double(real(value));
            end
        end

        function set.MaxStep(obj,value)
            if isempty(value)
                obj.MaxStep=zeros(0,1);
            else
                validateattributes(value,{'numeric'},{'scalar','positive','finite'});
                obj.MaxStep=double(real(value));
            end
        end

        function set.OutputTimes(obj,value)
            if isempty(value)
                obj.OutputTimes=zeros(0,1);
            else
                validateattributes(value,{'numeric'},{'vector','nonnegative','real','finite'});
                value=double(real(value(:)));


                if~all(value(2:end)>value(1:end-1))
                    error(message('SimBiology:SimulationOptions:OutputTimesBadFormat'));
                end
                obj.OutputTimes=value;
            end
        end

        function set.RelativeTolerance(obj,value)
            validateattributes(value,{'numeric'},{'scalar','positive','<',1});
            obj.RelativeTolerance=double(real(value));
        end

        function set.LogDecimation(obj,value)
            validateattributes(value,{'numeric'},{'scalar','positive','real','finite'});
            if round(value)~=value
                error(message('SimBiology:SimulationOptions:LogDecimationBadFormat'));
            end
            obj.LogDecimation=double(value);
        end

        function set.RandomState(obj,value)
            if isempty(value)
                obj.RandomState=zeros(0,1);
            else
                validateattributes(value,{'numeric'},{'scalar','positive','real','finite'});
                if round(value)~=value
                    error(message('SimBiology:SimulationOptions:RandomStateBadFormat'));
                end
                obj.RandomState=double(value);
            end
        end

        function set.MaxIterations(obj,value)
            validateattributes(value,{'numeric'},{'scalar','positive','real','finite'});
            if round(value)~=value
                error(message('SimBiology:SimulationOptions:MaxIterationsBadFormat'));
            end
            obj.MaxIterations=double(value);
        end

        function set.ErrorTolerance(obj,value)
            validateattributes(value,{'numeric'},{'scalar','positive','<',1});
            obj.ErrorTolerance=double(real(value));
        end

        function set.SolverType(obj,value)
            deterministicSolvers={'ode45','ode15s','ode23t','sundials'};
            stochasticSolvers={'ssa','impltau','expltau'};
            validateattributes(value,{'char'},{'row'});
            validatestring(value,[deterministicSolvers,stochasticSolvers]);




            assert(isempty(obj.SolverType)||any(strcmp(value,deterministicSolvers)),...
            message('SimBiology:SimulationOptions:SolverTypeError'));
            obj.SolverType=value;
            obj.updateDESuiteSolverName();
        end
    end

    methods(Access=private)
        function updateDESuiteSolverName(obj)

            if obj.SensitivityAnalysis
                obj.DESuiteSolverName='sundials';
                return
            end

            switch obj.SolverType
            case 'ode45'
                obj.DESuiteSolverName='ODE45';
            case 'ode15s'
                obj.DESuiteSolverName='ODE15s';
            case 'ode23t'
                obj.DESuiteSolverName='ODE23t';
            case 'sundials'
                obj.DESuiteSolverName='sundials';
            otherwise
                obj.DESuiteSolverName='';
            end
        end
    end
end
