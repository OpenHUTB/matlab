classdef StandardDeviation<dsp.internal.StandardDeviationBase















































































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
        function this=StandardDeviation(varargin)
            coder.allowpcode('plain');
            str='XYcoord';
            args=[varargin,str];
            this@dsp.internal.StandardDeviationBase(args{:});
            setFrameStatus(this,false);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='visionstatistics/2-D Standard Deviation';
        end
    end
end


