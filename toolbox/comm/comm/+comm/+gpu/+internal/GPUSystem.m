classdef GPUSystem<comm.gpu.internal.GPUBase

    methods(Access=protected,Abstract)
        varargout=stepGPUImpl(varargin);
        setupGPUImpl(obj,varargin);
    end


    methods(Access=protected,Sealed)
        function setupImpl(obj,varargin)
            detectGPUInputs(obj,varargin{:});
            setupGPUImpl(obj,varargin{:});
        end


        function varargout=stepImpl(obj,varargin)
            [newInputs{1:obj.getNumInputs}]=moveInputsToGPU(obj,varargin{:});
            [varargout{1:obj.getNumOutputs}]=stepGPUImpl(obj,newInputs{:});

            if isOutputCPUArray(obj)
                [varargout{1:obj.getNumOutputs}]=moveOutputsToCPU(obj,varargout{:});
            end
        end
    end
end
