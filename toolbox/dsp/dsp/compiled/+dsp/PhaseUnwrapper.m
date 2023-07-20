classdef PhaseUnwrapper<matlab.system.SFunSystem














































%#function mdspunwrap2

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)






        Tolerance=pi;







        InterFrameUnwrap(1,1)logical=true;
    end

    methods

        function obj=PhaseUnwrapper(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mdspunwrap2');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);
            setFrameStatus(obj,true);
        end

    end

    methods(Hidden)
        function setParameters(obj)

            resetBetweenSteps=double(1-obj.InterFrameUnwrap);
            InputProcessing=1;
            obj.compSetParameters({...
            obj.Tolerance,...
            resetBetweenSteps,...
            InputProcessing});
        end
    end

    methods(Access=protected)
        function loadObjectImpl(obj,s,~)
            loadObjectImpl@matlab.system.SFunSystem(obj,s);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspsigops/Unwrap';
        end

        function props=getDisplayPropertiesImpl()
            props={...
'InterFrameUnwrap'...
            ,'Tolerance'...
            };
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
