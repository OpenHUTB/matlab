classdef ConvolutionalInterleaverBase<comm.gpu.internal.GPUSystem













    properties(Abstract=true,Nontunable=true)
        NumRegisters;
        RegisterLengthStep;
        InitialConditions;
    end

    methods(Abstract=true,Access=protected)
        dp=generateDelayPattern(obj);
    end

    properties(Access=private)

        pStateSize;
        pInputSize;
        pDelayShiftStep;
        pInitialConditions;
        pIdxFH;
        pStepFH;

        pWindowOffset;
        pDelayShift;

        gBaseIdx;
        gState;
        gDelayPattern;
    end

    methods(Access=protected)

        function obj=ConvolutionalInterleaverBase(varargin)
            obj=obj@comm.gpu.internal.GPUSystem();
        end

        function validatePropertiesImpl(obj)


            [m,n]=size(obj.InitialConditions);
            if((m>1)&&(m~=obj.NumRegisters))||(n~=1)
                error(message('comm:system:ConvolutionalInterleaver:InitialConditions'));
            end
        end

        function validateInputsImpl(obj,x)%#ok<MANU>


            if isa(x,'gpuArray');
                gatherFcn=@gather;
            else
                gatherFcn=@(x)(x);
            end


            validateattributes(gatherFcn(x),...
            {'single','double','int32','uint32','logical'},...
            {'column','nonempty'},'','the input sequence X',1);
        end

        function setupGPUImpl(obj,x)

            delayPattern=obj.generateDelayPattern();


            sz=size(x,1);
            obj.pInputSize=sz;



            windowCount=1+ceil((obj.NumRegisters-1)*obj.NumRegisters...
            *obj.RegisterLengthStep/sz);

            obj.pStateSize=windowCount*sz;



            obj.gBaseIdx=gpuArray((1:sz)');



            repCount=ceil(sz/obj.NumRegisters);




            obj.pDelayShiftStep=mod(sz,obj.NumRegisters);


            if obj.pDelayShiftStep==0

                obj.pStepFH=@obj.stepBasic;

                obj.pIdxFH=@genConvIntrlvIdxBasic;

                baseDelay=repmat(delayPattern,1,repCount);


                obj.gBaseIdx=obj.gBaseIdx-gpuArray(baseDelay');
            else

                obj.pStepFH=@obj.stepGeneral;

                obj.pIdxFH=@genConvIntrlvIdx;


                baseDelay=repmat(delayPattern,1,repCount+1);


                obj.gDelayPattern=gpuArray(baseDelay');
            end

            if islogical(x)
                obj.gState=gpuArray.false(obj.pStateSize,1);
            else
                obj.gState=zeros(obj.pStateSize,1,'like',gpuArray(x([])));
            end

            obj.pInitialConditions=cast(obj.InitialConditions,'like',x);
        end

        function resetImpl(obj)
            obj.resetState();
        end

        function y=stepGPUImpl(obj,x)

            y=obj.pStepFH(x);
        end

        function num=getNumInputsImpl(obj)%#ok<MANU>
            num=1;
        end

        function num=getNumOutputsImpl(obj)%#ok<MANU>
            num=1;
        end
    end

    methods(Access=private)
        function resetState(obj)

            if numel(obj.pInitialConditions)==1

                obj.gState(:)=obj.pInitialConditions;
            else




                ic=repmat(obj.pInitialConditions,...
                ceil(obj.pStateSize/obj.NumRegisters),1);


                obj.gState(:)=ic(end-obj.pStateSize+1:end);
            end


            obj.pWindowOffset=0;
            obj.pDelayShift=0;
        end

        function y=stepBasic(obj,x)


            offset=obj.pWindowOffset;
            obj.gState(offset+1:offset+obj.pInputSize)=x;


            outIdx=arrayfun(obj.pIdxFH,obj.gBaseIdx,offset,obj.pStateSize);


            y=obj.gState(outIdx);


            offset=offset+obj.pInputSize;
            if(offset>=obj.pStateSize)
                obj.pWindowOffset=0;
            else
                obj.pWindowOffset=offset;
            end
        end

        function y=stepGeneral(obj,x)


            offset=obj.pWindowOffset;
            obj.gState(offset+1:offset+obj.pInputSize)=x;



            outIdx=arrayfun(obj.pIdxFH,obj.gBaseIdx,offset,...
            obj.gDelayPattern(1+obj.pDelayShift:obj.pInputSize+obj.pDelayShift),...
            obj.pStateSize);


            y=obj.gState(outIdx);


            offset=offset+obj.pInputSize;
            if(offset>=obj.pStateSize)
                obj.pWindowOffset=0;
            else
                obj.pWindowOffset=offset;
            end


            obj.pDelayShift=mod(obj.pDelayShift+obj.pDelayShiftStep,...
            obj.NumRegisters);
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
        function flag=generatesCode()
            flag=false;
        end
    end

end
