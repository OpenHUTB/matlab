classdef Descrambler<comm.internal.ScramblerBase



















































































%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Constant,GetAccess=protected,Nontunable)
        pIsDescrambler=1
    end

    methods
        function obj=Descrambler(varargin)
            coder.allowpcode('plain');
            obj@comm.internal.ScramblerBase(varargin{:});
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commsequence2/Descrambler';
        end

    end

end

