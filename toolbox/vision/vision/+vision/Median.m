classdef Median<dsp.internal.MedianBase









































%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)



        Dimension='All';
    end
    properties(Constant,Hidden)
        DimensionSet=dsp.CommonSets.getSet('Dimension');
    end

    methods

        function obj=Median(varargin)
            coder.allowpcode('plain');
            obj@dsp.internal.MedianBase(varargin{:});
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('vision.Median',vision.Median.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='visionstatistics/2-D Median';
        end
    end

end

