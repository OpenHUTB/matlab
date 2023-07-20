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
    end

    methods(Access=protected)
        function s=saveObjectImpl(obj)
            s.base=saveObjectImpl@matlab.System(obj);
            if isLocked(obj)
                s.pInputIsGPUArray=obj.pInputIsGPUArray;
                s.pCPUOutputMode=obj.pCPUOutputMode;
                s.pGPUInputVectorSet=obj.pGPUInputVectorSet;
                s.pCheckGPUArraySpecs=obj.pCheckGPUArraySpecs;
                s.pGPUArraySizeCache=obj.pGPUArraySizeCache;
                s.pGPUArrayClassCache=obj.pGPUArrayClassCache;
                s.pGPUArrayComplexityCache=obj.pGPUArrayComplexityCache;
            end
        end

        function loadObjectImpl(obj,s,wasLocked)

            loadObjectImpl@matlab.System(obj,s.base,wasLocked);
            s=rmfield(s,'base');


            fn=fieldnames(s);
            for ii=1:numel(fn),
                obj.(fn{ii})=s.(fn{ii});
            end

        end


        function flag=isInputSizeMutableImpl(~,~)
            flag=false;
        end
        function flag=isInputComplexityMutableImpl(~,~)
            flag=false;
        end
        function detectGPUInputs(obj,varargin)

            if~matlab.internal.parallel.isPCTInstalled()...
                ||~builtin('license','checkout','distrib_computing_toolbox')
                error(message('MATLAB:gpusystem:noPCT'));
            end


            if~parallel.gpu.GPUDevice.isAvailable()
                error(message('MATLAB:gpusystem:noGPU'));
            end

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
                error(message('MATLAB:gpusystem:incorrectBaseSetup'));
            end
            varargout=cell(size(varargin));
            for ix=1:numel(varargin)
                if obj.pInputIsGPUArray(ix)
                    varargout{ix}=varargin{ix};
                    if obj.pCheckGPUArraySpecs

                        theSize=size(varargin{ix});
                        oldSize=obj.pGPUArraySizeCache{ix};


                        if~isInputSizeMutableImpl(obj,ix),
                            if(numel(theSize)~=numel(oldSize))||...
                                (~all(theSize==obj.pGPUArraySizeCache{ix}))
                                error(message('MATLAB:gpusystem:inputSpecsChanged',...
                                ix));
                            end
                        end


                        if~strcmp(underlyingType(varargin{ix}),...
                            obj.pGPUArrayClassCache{ix})
                            error(message('MATLAB:gpusystem:inputSpecsChanged',...
                            ix));
                        end


                        if~isInputComplexityMutableImpl(obj,ix)
                            if obj.pGPUArrayComplexityCache{ix}&&...
                                ~isreal(varargin{ix})



                                error(message('MATLAB:gpusystem:inputComplexityChanged',...
                                ix));
                            end
                        end
                    end
                else
                    varargout{ix}=gpuArray(varargin{ix});
                end
            end
        end
        function varargout=moveOutputsToCPU(obj,varargin)

            varargout=cell(size(varargin));
            for ix=1:obj.getNumOutputs()
                varargout{ix}=gather(varargin{ix});
            end
        end
        function flag=isInputGPUArray(obj,idx)
            if~obj.pGPUInputVectorSet
                error(message('MATLAB:gpusystem:incorrectBaseSetup'));
            end
            flag=obj.pInputIsGPUArray(idx);
        end
        function flag=isOutputCPUArray(obj)
            flag=obj.pCPUOutputMode;
        end
        function varargout=moveOutputsIfNeeded(obj,varargin)


            varargout=cell(size(varargin));
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
    end


    methods(Access=protected)
        function tf=isInputFi(obj,x)
            if isa(x,'gpuArray'),
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

        function tf=isdouble(x)
            tf=isUnderlyingType(x,'double');
        end

        function tf=islogical(x)
            tf=islogical(x);
        end

        function tf=isRealBuiltinFloat(x)


            tf=(matlab.system.internal.gpu.GPUBase.isfloat(x)&&...
            isreal(x));
        end

    end
end


