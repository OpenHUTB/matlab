classdef MultiplexedInterleaverBase<matlab.system.SFunSystem







%#function mcomgenmuxint

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)



        Delay=[2;0;1;3;10];







        InitialConditions=0;
    end

    properties(Abstract,Access=protected,Nontunable)

pIsInterleaver
    end

    methods
        function obj=MultiplexedInterleaverBase(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomgenmuxint');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);
        end
    end

    methods(Hidden)
        function setParameters(obj)
            if obj.pIsInterleaver
                delay=obj.Delay;
            else
                delay=max(obj.Delay)-obj.Delay;
            end
            obj.compSetParameters({...
            delay,...
            obj.InitialConditions...
            });
        end
    end

    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={...
            'Delay',...
            'InitialConditions'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end
    end

end

