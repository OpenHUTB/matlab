classdef Maximum<dsp.internal.MaximumBase





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

        function obj=Maximum(varargin)
            str='Xcoord';
            args=[varargin,str];
            obj@dsp.internal.MaximumBase(args{:});
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






            matlab.system.dispFixptHelp('dsp.internal.Maximum',...
            dsp.internal.Maximum.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspstat3/Maximum';
        end
    end

end
