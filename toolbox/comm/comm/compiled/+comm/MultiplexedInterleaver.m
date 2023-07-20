classdef MultiplexedInterleaver<...
    comm.internal.MultiplexedInterleaverBase



























































%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Access=protected,Nontunable)
        pIsInterleaver=true;
    end

    methods
        function obj=MultiplexedInterleaver(varargin)
            coder.allowpcode('plain');
            obj@comm.internal.MultiplexedInterleaverBase(varargin{:});
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commcnvintrlv2/General Multiplexed Interleaver';
        end

    end

end

