classdef MultiplexedDeinterleaver<...
    comm.internal.MultiplexedInterleaverBase



































































%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Access=protected,Nontunable)
        pIsInterleaver=false;
    end

    methods
        function obj=MultiplexedDeinterleaver(varargin)
            coder.allowpcode('plain');
            obj@comm.internal.MultiplexedInterleaverBase(varargin{:});
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commcnvintrlv2/General Multiplexed Deinterleaver';
        end

    end

end

