classdef Scrambler<comm.internal.ScramblerBase



















































































%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Constant,GetAccess=protected,Nontunable)
        pIsDescrambler=0
    end

    methods
        function obj=Scrambler(varargin)
            coder.allowpcode('plain');
            obj@comm.internal.ScramblerBase(varargin{:});
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commsequence2/Scrambler';
        end

    end

end

