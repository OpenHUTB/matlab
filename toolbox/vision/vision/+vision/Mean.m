classdef Mean<dsp.internal.MeanBase














































































%#function mvipstatfcns

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)




        Dimension='All';
    end
    properties(Constant,Hidden)
        DimensionSet=dsp.CommonSets.getSet('Dimension');
    end

    methods
        function this=Mean(varargin)
            coder.allowpcode('plain');
            str='XYcoord';
            args=[varargin,str];
            this@dsp.internal.MeanBase(args{:});
            setFrameStatus(this,false);
        end
    end

    methods(Static)
        function helpFixedPoint





            matlab.system.dispFixptHelp('vision.Mean',vision.Mean.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='visionstatistics/2-D Mean';
        end
    end
end
