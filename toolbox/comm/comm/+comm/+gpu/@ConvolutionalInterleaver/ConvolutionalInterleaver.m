classdef(StrictDefaults)ConvolutionalInterleaver<comm.gpu.internal.ConvolutionalInterleaverBase











































































    properties(Nontunable)



        NumRegisters=6;





        RegisterLengthStep=2;










        InitialConditions=0;
    end

    methods
        function obj=ConvolutionalInterleaver(varargin)
            obj=obj@comm.gpu.internal.ConvolutionalInterleaverBase(varargin);
            setProperties(obj,nargin,varargin{:},...
            'NumRegisters','RegisterLengthStep','InitialConditions');
        end

        function set.NumRegisters(obj,value)
            validateattributes(value,{'numeric'},...
            {'finite','nonempty','positive','integer','scalar'},'',...
            'NumRegisters');
            obj.NumRegisters=value;
        end

        function set.RegisterLengthStep(obj,value)
            validateattributes(value,{'numeric'},...
            {'finite','nonempty','positive','integer','scalar'},'',...
            'RegisterLengthStep');
            obj.RegisterLengthStep=value;
        end

        function set.InitialConditions(obj,value)
            validateattributes(value,{'numeric'},{'finite','nonempty'},...
            '','InitialConditions');
            obj.InitialConditions=value;
        end
    end

    methods(Access=protected)
        function dp=generateDelayPattern(obj)
            dp=(0:obj.NumRegisters-1)*obj.NumRegisters*...
            obj.RegisterLengthStep;
        end
    end
end




