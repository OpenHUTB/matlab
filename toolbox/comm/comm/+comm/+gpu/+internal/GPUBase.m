classdef GPUBase<matlab.System

    properties(Access=private)
pInputIsGPUArray
pCPUOutputMode
        pGPUInputVectorSet=false;
        pCheckGPUArraySpecs=true;
pGPUArraySizeCache
pGPUArrayClassCache
pGPUArrayComplexityCache
    end


    properties(GetAccess=protected,Constant)
        kGPUArrayString='gpuArray';
        kMaxGridSize=65535;
    end


    methods
        function obj=GPUBase(varargin)
            if~(builtin('license','checkout','Distrib_Computing_Toolbox'))||...
                isempty(ver('parallel'))
                error(message('comm:system:gpuBase:noPCT'));
            end
            if~parallel.gpu.GPUDevice.isAvailable()
                error(message('comm:system:gpuBase:badGPU'));
            end
        end
    end


    methods(Access=protected)

        function flag=isInputSizeMutableImpl(~,~)
            flag=false;
        end


        function flag=isInputComplexityMutableImpl(~,~)
            flag=false;
        end


        function detectGPUInputs(obj,varargin)
            nIn=numel(varargin);
            obj.pInputIsGPUArray=false(1,nIn);
            if obj.pCheckGPUArraySpecs
                obj.pGPUArraySizeCache=cell(1,nIn);
                obj.pGPUArrayClassCache=cell(1,nIn);
                obj.pGPUArrayComplexityCache=cell(1,nIn);
            end
            for ix=1:nIn
                obj.pInputIsGPUArray(ix)=strcmp(class(varargin{ix}),...
                obj.kGPUArrayString);
                if obj.pCheckGPUArraySpecs&&obj.pInputIsGPUArray(ix)
                    obj.pGPUArraySizeCache{ix}=size(varargin{ix});
                    obj.pGPUArrayClassCache{ix}=underlyingType(varargin{ix});
                    obj.pGPUArrayComplexityCache{ix}=isreal(varargin{ix});
                end
            end
            obj.pCPUOutputMode=~any(obj.pInputIsGPUArray);
            obj.pGPUInputVectorSet=true;
        end


        function varargout=moveInputsToGPU(obj,varargin)
            if~obj.pGPUInputVectorSet
                error(message('comm:system:gpuBase:incorrectSetup'));
            end
            for ix=1:numel(varargin)
                if obj.pInputIsGPUArray(ix)
                    varargout{ix}=varargin{ix};
                    if obj.pCheckGPUArraySpecs

                        theSize=size(varargin{ix});
                        oldSize=obj.pGPUArraySizeCache{ix};
                        if~isInputSizeMutableImpl(obj,ix)
                            if(numel(theSize)~=numel(oldSize))||...
                                (~all(theSize==obj.pGPUArraySizeCache{ix}))
                                error(message('comm:system:gpuBase:inputSizeChanged',num2str(ix)));
                            end
                        end
                        if~strcmp(underlyingType(varargin{ix}),...
                            obj.pGPUArrayClassCache{ix})
                            error(message('comm:system:gpuBase:inputDataTypeChanged',num2str(ix)));
                        end
                        if~isInputComplexityMutableImpl(obj,ix)
                            if obj.pGPUArrayComplexityCache{ix}&&...
                                ~isreal(varargin{ix})
                                error(message('comm:system:gpuBase:inputComplexityChanged',num2str(ix)));
                            end
                        end
                    end
                else
                    varargout{ix}=gpuArray(varargin{ix});
                end
            end
        end


        function varargout=moveOutputsToCPU(obj,varargin)

            for ix=1:obj.getNumOutputs()
                varargout{ix}=gather(varargin{ix});
            end
        end


        function flag=isInputGPUArray(obj,idx)
            if~obj.pGPUInputVectorSet
                error(message('comm:system:gpuBase:incorrectSetup'));
            end
            flag=obj.pInputIsGPUArray(idx);
        end


        function flag=isOutputCPUArray(obj)
            flag=obj.pCPUOutputMode;
        end


        function varargout=moveOutputsIfNeeded(obj,varargin)

            if obj.pCPUOutputMode

                for ix=1:numel(varargin)
                    varargout{ix}=gather(varargin{ix});
                end
            else

                for ix=1:numel(varargin)
                    varargout{ix}=varargin{ix};
                end
            end
        end


        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.System(obj);
            s.SaveLockedData=false;
        end
    end


    methods(Access=protected)
        function tf=isInputFi(obj,x)
            if isa(x,'gpuArray')
                tf=false;
            else

                tf=isa(x,'embedded.fi');
            end
        end
    end


    methods(Static,Hidden)

        function tf=isfloat(x)
            tf=isfloat(x)&&~isa(x,'embedded.fi');
        end


        function tf=islogical(x)
            tf=islogical(x);
        end


        function tf=isRealBuiltinFloat(x)
            tf=(comm.gpu.internal.GPUBase.isfloat(x)&&...
            isreal(x));
        end

    end
end


