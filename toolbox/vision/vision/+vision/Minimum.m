classdef Minimum<dsp.internal.MinimumBase




























































































%#function mvipstatminmax

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable,Hidden)
        IndexBase='One';
    end
    properties(Nontunable)




        Dimension='All';
    end
    properties(Constant,Hidden)
        DimensionSet=dsp.CommonSets.getSet('Dimension');
        IndexBaseSet=matlab.system.StringSet({'One'});
    end

    methods
        function this=Minimum(varargin)
            coder.allowpcode('plain');
            str='XYcoord';
            args=[varargin,str];
            this@dsp.internal.MinimumBase(args{:});
            setFrameStatus(this,false);
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('vision.Minimum',vision.Minimum.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='visionstatistics/2-D Minimum';
        end
    end
end

