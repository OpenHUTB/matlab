classdef Variance<dsp.internal.VarianceBase
















































































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
        function this=Variance(varargin)
            coder.allowpcode('plain');
            str='XYcoord';
            args=[varargin,str];
            this@dsp.internal.VarianceBase(args{:});
            setFrameStatus(this,false);
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('vision.Variance',...
            vision.Variance.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='visionstatistics/2-D Variance';
        end
    end

end


