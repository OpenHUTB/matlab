classdef Maximum<dsp.internal.MaximumBase




























































































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
        function this=Maximum(varargin)
            coder.allowpcode('plain');
            str='XYcoord';
            args=[varargin,str];
            this@dsp.internal.MaximumBase(args{:});
            setFrameStatus(this,false);
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('vision.Maximum',vision.Maximum.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='visionstatistics/2-D Maximum';
        end
    end

end

