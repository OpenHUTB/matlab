classdef ConvolutionalInterleaver<...
    comm.internal.ConvolutionalInterleaverBase




































































%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)





        RegisterLengthStep=2;










        InitialConditions=0;
    end

    properties(Access=protected,Nontunable)

        pIsInterleaver=true;
    end

    methods

        function obj=ConvolutionalInterleaver(varargin)
            coder.allowpcode('plain');
            obj@comm.internal.ConvolutionalInterleaverBase(varargin{:});
        end

        function set.RegisterLengthStep(obj,value)
            validateattributes(value,{'numeric'},{'finite','nonempty','positive','integer','scalar'},'','RegisterLengthStep');
            obj.RegisterLengthStep=value;
        end

        function set.InitialConditions(obj,value)
            validateattributes(value,{'numeric'},{'finite','nonempty'},'','InitialConditions');
            obj.InitialConditions=value;
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commcnvintrlv2/Convolutional Interleaver';
        end

    end

end

