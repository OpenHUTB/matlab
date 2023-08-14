classdef Minimum<dsp.internal.MinimumBase





%#function mdspstatminmax

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)





        IndexBase='One';





        Dimension='Column';
    end

    properties(Constant,Hidden)
        DimensionSet=dsp.CommonSets.getSet('Dimension');
        IndexBaseSet=matlab.system.StringSet({'Zero','One'});
    end

    methods
        function obj=Minimum(varargin)
            str='Xcoord';
            args=[varargin,str];
            obj@dsp.internal.MinimumBase(args{:});
            setFrameStatus(obj,true);
        end
    end

    methods(Access=protected)
        function flag=isFrameBasedProcessing(~)
            flag=true;
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('dsp.internal.Minimum',...
            dsp.internal.Minimum.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspstat3/Minimum';
        end
    end
end
