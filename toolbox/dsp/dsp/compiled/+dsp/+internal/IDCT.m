classdef IDCT<dsp.internal.DCT




%#ok<*EMCLS>
%#ok<*EMCA>

    methods
        function obj=IDCT(varargin)
            coder.allowpcode('plain');
            obj@dsp.internal.DCT(varargin{:});
            obj.pIsInverseDCT=true;
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspxfrm3/IDCT';
        end
    end
end
