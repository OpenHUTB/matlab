classdef ZeroCrossingDetector<matlab.system.SFunSystem



































%#function mdspzc

%#ok<*EMCLS>
%#ok<*EMCA>

    methods

        function obj=ZeroCrossingDetector(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mdspzc');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);
            setFrameStatus(obj,true);
        end

    end

    methods(Hidden)
        function setParameters(obj)
            InputProcessing=1;
            obj.compSetParameters({InputProcessing,1,1});
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspsigops/Zero Crossing';
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Access=protected)
        function loadObjectImpl(obj,s,~)
            loadObjectImpl@matlab.system.SFunSystem(obj,s);
        end
    end
end


