classdef(Hidden)InterleaverBase<comm.gpu.internal.GPUSystem
    properties(Abstract=true,Nontunable=true)
PermutationVector
PermutationVectorSource
    end


    properties(Access=protected)
        gpuPermVector;
        gpuBatchCount;
    end


    methods
        function obj=InterleaverBase(varargin)

        end
    end


    methods(Abstract=true,Access=protected)
        y=rhsPermVector(obj);
    end


    methods(Access=protected)
        function num=getNumInputsImpl(~)
            num=1;
        end


        function num=getNumOutputsImpl(~)
            num=1;
        end


        function validatePermutationVector(~,val)

            validateattributes(val,{'double'},...
            {'real','positive','integer','column','nonempty'},'',...
            'PermutationVector');

            tmp=(1:length(val))';
            if~isequal(tmp,sort(val(:)))
                error(message('comm:commblkinterl:InvalidElements1'));
            end

        end


        function setupGPUImpl(obj,varargin)

            e=true;
            sz=size(varargin{1});
            if sz(2)==1
                szInt=floor(sz(1)/length(obj.PermutationVector));
                if szInt*length(obj.PermutationVector)==sz(1)
                    e=false;
                end
            end

            if e
                error(message('comm:system:InterleaverBase:InvalidInputLength'));
            end

            obj.gpuBatchCount=szInt;
            obj.gpuPermVector=gpuArray(obj.rhsPermVector());
        end


        function releaseImpl(obj)
            obj.gpuPermVector=[];
        end


        function y=stepGPUImpl(obj,x)
            in=reshape(x,...
            size(obj.PermutationVector,1),...
            obj.gpuBatchCount);

            out=in(obj.gpuPermVector,:);

            y=reshape(out,size(x));
        end
    end


    methods(Access=protected)

        function varargout=getOutputSizeImpl(obj)
            varargout{1}=propagatedInputSize(obj,1);
        end


        function varargout=getOutputDataTypeImpl(obj)
            varargout{1}=propagatedInputDataType(obj,1);
        end


        function varargout=isOutputComplexImpl(obj)%#ok
            varargout{1}=false;
        end


        function varargout=isOutputFixedSizeImpl(obj)%#ok
            varargout{1}=true;
        end

    end


    methods(Static,Hidden)
        function y=generatesCode()
            y=false;
        end
    end

end





