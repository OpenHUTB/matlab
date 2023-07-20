classdef(Hidden,StrictDefaults)AbstractFFT<matlab.System




%#codegen
%#ok<*EMCLS>




    properties(Nontunable,Constant,Hidden)




        TwiddleFactorDataType='Same word length as input';







        CustomTwiddleFactorDataType=numerictype([],16);






        ProductDataType='Full precision';








        CustomProductDataType=numerictype([],33,30);




        AccumulatorDataType='Same as input';








        CustomAccumulatorDataType=numerictype([],16,15);




        OutputDataType='Same as input';








        CustomOutputDataType=numerictype([],16,15);




        BitGrowthVector=numerictype([],1,0);


        MaxInputVectorSize=64;

        MinWordLength=2;

        MaxWordLength=128;
    end

    properties(Nontunable,Hidden)


        InverseFFT(1,1)logical=false;


        VariableFFTLength(1,1)logical=false;
    end


    properties(Nontunable)


        Architecture='Streaming Radix 2^2';





        ComplexMultiplication='Use 4 multipliers and 2 adders';





        FFTLength=1024;





        RoundingMethod='Floor';








        BitReversedOutput(1,1)logical=true;





        BitReversedInput(1,1)logical=false;



    end

    properties(Nontunable,Hidden)





        FFTLengthSource='Property';



        OverflowAction='Wrap';






        RemoveFFTLatency(1,1)logical=false;

    end



    properties(Nontunable)


        ResetInputPort(1,1)logical=false;


        StartOutputPort(1,1)logical=false;


        EndOutputPort(1,1)logical=false;
    end
    properties(Nontunable,Hidden)


        ValidInputPort(1,1)logical=true;

        StartInputPort(1,1)logical=false;

        EndInputPort(1,1)logical=false;
    end

    properties(Nontunable,Constant,Hidden)

        ValidOutputPort(1,1)logical=true;


        ReadyOutputPort(1,1)logical=false;


        ExpOutputPort(1,1)logical=false;
    end





    properties(Constant,Hidden)

        RoundingMethodSet=matlab.system.StringSet({'Ceiling','Convergent','Floor','Nearest','Round','Zero'});
        OverflowActionSet=matlab.system.StringSet({'Wrap','Saturate'});
        FFTLengthSourceSet=matlab.system.StringSet({'Property','Auto'});
        ArchitectureSet=matlab.system.StringSet({'Streaming Radix 2^2',...
        'Burst Radix 2'});
        ComplexMultiplicationSet=matlab.system.StringSet({'Use 3 multipliers and 5 adders',...
        'Use 4 multipliers and 2 adders'});
    end
    properties(Access=private)
        pWrOutBuffer_index;
        pRdOutBuffer_index;
        pInBufferIndex;
        pInBuffer_re;
        pInBuffer_im;
        pInBuffer_valid;
        pLatencyCnt;
        pInitLatencyCnt;
        pOutBuffer_valid;
        pOutBuffer_cmplx;
        pBitReverseTable_H;
        pBitReverseTable_F;
        pStartOutputPort;
        pEndOutputPort;
        pOverflowStage;
        pEOFFifo;
        pSimTime;
        pSOF;
        pCurSOF;
        pSOFFifo;
        pWrFifoAddr;
        pRdFifoAddr;
        pLastData;
        pHoldTime;
        pHoldSample;
        pInitialValue;
        pInputLen=1;
    end
    properties(Nontunable,Access=private)
        pFFTLatency;
        pFFTLength;
        pOutput;

        pFimath;
        pUserFimath;
        pAccumulator;
        pProduct;
        pTwiddleFactor;
        pNormalize;
        pRemoveFFTLatency;
        pInBufferSize;
        pOutBufferSize;
        pBitGrowthVector;
        pInputVectorSize;
        pOutputDataFirst;
        pBitReversedOutput(1,1)logical;
        pBitReversedInput(1,1)logical;
    end
    properties(Access=private)
        pWrOutBuffer_roll(1,1)logical;
        pRdOutBuffer_roll(1,1)logical;
        pEvenSample(1,1)logical;
        pResetStart(1,1)logical;
        pOverflowFlag(1,1)logical;



        pState;
        pSampleCnt;
        pOutCnt;
        pWrEnb(1,1)logical;
        pRdyReg(1,1)logical;
        pInitialize(1,1)logical=true;
    end



    methods(Static)
        function helpFixedPoint





            matlab.system.dispFixptHelp('dsp.FFT',...
            dsp.FFT.getDisplayFixedPointPropertiesImpl);
        end

    end
    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={...
'FFTLength'...
            ,'BitReversedOutput',...
            'BitReversedInput',...
'Normalize'...
            };

        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'RoundingMethod','OverflowAction',...
            };
        end
    end




    methods(Access=public)
        function latency=getLatency(obj,varargin)




            if nargin==3
                if isempty(varargin{1})
                    len=obj.FFTLength;
                else
                    len=varargin{1};
                end
                inVectSize=varargin{2};
            elseif nargin==2
                inVectSize=obj.pInputVectorSize;
                if isempty(inVectSize)
                    inVectSize=1;
                end
                len=varargin{1};
            else
                inVectSize=obj.pInputVectorSize;
                if isempty(inVectSize)
                    inVectSize=1;
                end
                len=obj.pFFTLength;
                if isempty(len)
                    len=obj.FFTLength;
                end
            end

            if strcmpi(obj.Architecture,'Streaming Radix 2^2')||obj.FFTLength<8
                latency=obj.waitCycle4dVld(len,inVectSize)+len/inVectSize-3;
            elseif strcmpi(obj.Architecture,'Burst Radix 2')
                latency=obj.waitCycle4dVld(len)-1;
            else
                latency=obj.waitCycle4dVld(len)+len-2;
            end
        end

    end
    methods(Access=public,Hidden)
        function inputVectorSize=getInputVectorSize(obj)
            inputVectorSize=obj.pInputVectorSize;
        end
        function outputDT=getOutputDT(obj,inputDT)
            if obj.Normalize
                BitGrowth=zeros(log2f(obj,obj.FFTLength),1);
            else
                BitGrowth=ones(log2f(obj,obj.FFTLength),1);
            end
            totalBitGrowth=sum(BitGrowth);
            if isnumerictype(inputDT)||isfi(inputDT)
                if inputDT.Signed
                    outputDT=numerictype(1,inputDT.WordLength+totalBitGrowth,inputDT.FractionLength);
                else
                    outputDT=numerictype(1,inputDT.WordLength+totalBitGrowth+1,inputDT.FractionLength);
                end
            elseif strncmpi(inputDT,'uint',4)
                n=numerictype(inputDT);
                outputDT=numerictype(1,n.WordLength+1+totalBitGrowth,0);
            elseif totalBitGrowth==0
                outputDT=inputDT;
            elseif strncmpi(inputDT,'int',3)
                n=numerictype(inputDT);
                outputDT=numerictype(1,n.WordLength+totalBitGrowth,0);
            else
                outputDT=inputDT;
            end
        end
    end


    methods(Static,Access=protected)
        function header=getHeaderImpl

            header=matlab.system.display.Header('dsphdl.FFT',...
            'ShowSourceLink',false,...
            'Title','FFT');
        end
        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end

        function groups=getPropertyGroupsImpl

            FFTProp=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'FFTLength','Architecture','ComplexMultiplication','BitReversedOutput','BitReversedInput','Normalize'});






            main=matlab.system.display.SectionGroup(...
            'TitleSource','Auto',...
            'Sections',FFTProp);

            arithmeticProp=matlab.system.display.Section(...
            'Title','',...
            'PropertyList',{'RoundingMethod'});

            arithmetic=matlab.system.display.SectionGroup(...
            'Title','Data Types',...
            'Sections',arithmeticProp);

            controlIn=matlab.system.display.Section(...
            'Title','Input Control Ports',...
            'PropertyList',{'ResetInputPort'});

            controlOut=matlab.system.display.Section(...
            'Title','Output Control Ports',...
            'PropertyList',{'StartOutputPort','EndOutputPort'});

            control=matlab.system.display.SectionGroup(...
            'Title','Control Ports',...
            'Sections',[controlIn,controlOut]);

            groups=[main,arithmetic,control];
        end
    end
    methods(Access=protected)
        function num=getNumInputsImpl(obj)
            num=2;
            if obj.StartInputPort
                num=num+1;
            end
            if obj.EndInputPort
                num=num+1;
            end
            if obj.ResetInputPort
                num=num+1;
            end
        end
        function varargout=getInputNamesImpl(obj)

            varargout=cell(1,getNumInputs(obj));
            inputPortInd=1;
            varargout{inputPortInd}='data';

            inputPortInd=inputPortInd+1;
            varargout{inputPortInd}='valid';

            if obj.ResetInputPort
                inputPortInd=inputPortInd+1;
                varargout{inputPortInd}='reset';
            end
        end
        function num=getNumOutputsImpl(obj)
            num=2;



            if obj.StartOutputPort
                num=num+1;
            end
            if obj.EndOutputPort
                num=num+1;
            end
            if strcmpi(obj.Architecture,'Burst Radix 2')
                num=num+1;
            end
        end
        function varargout=getOutputNamesImpl(obj)

            varargout=cell(1,getNumOutputs(obj));
            outputPortInd=1;
            varargout{outputPortInd}='data';






            if obj.StartOutputPort
                outputPortInd=outputPortInd+1;
                varargout{outputPortInd}='start';
            end

            if obj.EndOutputPort
                outputPortInd=outputPortInd+1;
                varargout{outputPortInd}='end';
            end

            outputPortInd=outputPortInd+1;
            varargout{outputPortInd}='valid';

            if strcmpi(obj.Architecture,'Burst Radix 2')
                outputPortInd=outputPortInd+1;
                varargout{outputPortInd}='ready';
            end
        end

        function varargout=getOutputDataTypeImpl(obj)
            inputDT=propagatedInputDataType(obj,1);
            if~isempty(inputDT)
                outputDT=getOutputDT(obj,inputDT);
                varargout{1}=outputDT;

                for ii=2:getNumOutputs(obj)
                    varargout{ii}=numerictype('boolean');
                end
            else
                for ii=1:getNumOutputs(obj)
                    varargout{ii}=[];
                end
            end
        end

        function varargout=isOutputComplexImpl(obj)
            varargout{1}=true;
            for ii=2:getNumOutputs(obj)
                varargout{ii}=false;
            end

        end

        function varargout=isOutputFixedSizeImpl(obj)
            for ii=1:getNumOutputs(obj)
                varargout{ii}=true;
            end
        end

        function varargout=getOutputSizeImpl(obj)
            varargout{1}=propagatedInputSize(obj,1);
            for ii=2:getNumOutputs(obj)
                varargout{ii}=1;
            end
        end

        function varargout=isInputDirectFeedthroughImpl(obj,varargin)



            if size(varargin{1},1)==obj.pFFTLength
                removeFFTLatency=obj.RemoveFFTLatency;
            else
                removeFFTLatency=false;
            end

            if removeFFTLatency
                for ii=1:nargout
                    varargout{ii}=true;
                end
            else
                for ii=1:nargout
                    varargout{ii}=false;
                end
            end
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.pWrOutBuffer_index=obj.pWrOutBuffer_index;
                s.pRdOutBuffer_index=obj.pRdOutBuffer_index;
                s.pWrOutBuffer_roll=obj.pWrOutBuffer_roll;
                s.pRdOutBuffer_roll=obj.pRdOutBuffer_roll;
                s.pInBufferIndex=obj.pInBufferIndex;
                s.pInBuffer_re=obj.pInBuffer_re;
                s.pInBuffer_im=obj.pInBuffer_im;
                s.pInBuffer_valid=obj.pInBuffer_valid;
                s.pLatencyCnt=obj.pLatencyCnt;
                s.pInitLatencyCnt=obj.pInitLatencyCnt;
                s.pOutBuffer_valid=obj.pOutBuffer_valid;
                s.pOutBuffer_cmplx=obj.pOutBuffer_cmplx;
                s.pBitReverseTable_H=obj.pBitReverseTable_H;
                s.pBitReverseTable_F=obj.pBitReverseTable_F;
                s.pFFTLatency=obj.pFFTLatency;
                s.pFFTLength=obj.pFFTLength;
                s.pOutput=obj.pOutput;
                s.pInputLen=obj.pInputLen;
                s.pFimath=obj.pFimath;
                s.pUserFimath=obj.pUserFimath;
                s.pBitReversedOutput=obj.pBitReversedOutput;
                s.pBitReversedInput=obj.pBitReversedInput;
                s.pNormalize=obj.pNormalize;
                s.pRemoveFFTLatency=obj.pRemoveFFTLatency;
                s.pInBufferSize=obj.pInBufferSize;
                s.pOutBufferSize=obj.pOutBufferSize;
                s.pStartOutputPort=obj.pStartOutputPort;
                s.pEndOutputPort=obj.pEndOutputPort;
                s.pEvenSample=obj.pEvenSample;
                s.pResetStart=obj.pResetStart;
                s.pHoldTime=obj.pHoldTime;
                s.pHoldSample=obj.pHoldSample;
                s.pOverflowStage=obj.pOverflowStage;
                s.pOverflowFlag=obj.pOverflowFlag;
                s.pSimTime=obj.pSimTime;
                s.pSOF=obj.pSOF;
                s.pCurSOF=obj.pCurSOF;
                s.pSOFFifo=obj.pSOFFifo;
                s.pWrFifoAddr=obj.pWrFifoAddr;
                s.pRdFifoAddr=obj.pRdFifoAddr;
                s.pLastData=obj.pLastData;
                s.pInitialValue=obj.pInitialValue;
                s.pBitGrowthVector=obj.pBitGrowthVector;
                s.pInputVectorSize=obj.pInputVectorSize;
                s.pOutputDataFirst=obj.pOutputDataFirst;
                s.pState=obj.pState;
                s.pSampleCnt=obj.pSampleCnt;
                s.pOutCnt=obj.pOutCnt;
                s.pWrEnb=obj.pWrEnb;
                s.pRdyReg=obj.pRdyReg;
                s.pInitialize=obj.pInitialize;
            end

        end

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case 'FFTLength'
                if strcmpi(obj.FFTLengthSource,'Auto')
                    flag=true;
                end




            end
        end


        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            removedProperty={'pTransmittedPoints','FFTLatency','OverflowAction','FFTLengthSource'};
            tmp={};
            for ii=1:numel(fn)
                found=false;
                for jj=1:numel(removedProperty)
                    if strcmpi(fn{ii},removedProperty{jj})
                        found=true;
                        break;
                    end
                end
                if~found
                    tmp{end+1}=fn{ii};
                end
            end
            fn=tmp;
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end

        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end

        function icon=getIconImpl(obj)
            if isempty(obj.pInputVectorSize)
                icon=sprintf('FFT\nLatency = --');
            else
                icon=sprintf('FFT\nLatency = %d',obj.getLatency(obj.FFTLength,obj.pInputVectorSize));
            end
        end


    end

    methods

        function obj=AbstractFFT(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','DSP_HDL_Toolbox'))
                    error(message('dsphdl:dsphdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','DSP_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:});
        end





        function set.FFTLength(obj,val)
            coder.extrinsic('dsphdl.private.AbstractFFT.isFeatureOn');
            blkname=class(obj);
            blkname=blkname(8:end);
            validateattributes(val,{'double'},{'scalar','positive','integer'},blkname,'NumFrequencyBands');
            if floor(log2f(obj,val))~=log2f(obj,val)
                coder.internal.error('dspshared:system:lenFFTNotPowTwo');
            else
                if coder.const(dsphdl.private.AbstractFFT.isFeatureOn('ExtendedFFTLength'))
                    validateattributes(val,{'numeric'},{'integer','scalar','>=',2^2},blkname,'FFTLength');
                else
                    validateattributes(val,{'numeric'},{'integer','scalar','>=',2^2,'<=',2^16},blkname,'FFTLength');
                end
            end
            obj.FFTLength=val;
        end



        function set.RoundingMethod(obj,val)
            blkname=class(obj);
            blkname=blkname(8:end);
            validatestring(val,{'Ceiling','Convergent','Floor',...
            'Nearest','Round','Zero'},blkname,'Rounding mode');
            obj.RoundingMethod=val;
        end

        function set.Architecture(obj,val)
            blkname=class(obj);
            blkname=blkname(8:end);
            validatestring(val,{'Streaming Radix 2 (this choice will be removed -see release notes).',...
            'Streaming Radix 2^2',...
            'Burst Radix 2'},blkname,'Architecture');
            if strcmpi(val,'Streaming Radix 2 (this choice will be removed -see release notes).')
                coder.internal.error('dsphdl:FFT:Radix2DeprecationWarning');
            end
            obj.Architecture=val;
        end
        function set.ComplexMultiplication(obj,val)
            blkname=class(obj);
            blkname=blkname(8:end);
            validatestring(val,{'Use 3 multipliers and 5 adders',...
            'Use 4 multipliers and 2 adders'},blkname,'ComplexMultiplication');

            obj.ComplexMultiplication=val;
        end

    end

    methods(Access=protected)
        function validateInputsImpl(obj,varargin)







            coder.extrinsic('dsphdl.private.AbstractFFT.isFeatureOn','gcb');
            blkname=class(obj);
            blkname=blkname(8:end);
            validDataType={'numeric','embedded.fi'};
            validDimension={'vector','column'};

            validateattributes(varargin{1},validDataType,validDimension,blkname,'data');
            if obj.isInMATLABSystemBlock
                blkName=coder.const(gcb);
            else
                blkName=class(obj);
            end
            if isa(varargin{1},'embedded.fi')
                din=varargin{1};
                wordLength=din.WordLength;
                if wordLength<obj.MinWordLength||wordLength>obj.MaxWordLength
                    coder.internal.error('dsphdl:FFT:EmbeddedFi',blkName);
                end
            end

            obj.pInputVectorSize=length(varargin{1});
            if strcmpi(obj.Architecture,'Streaming Radix 2^2')&&obj.pInputVectorSize>1
                if mod(log2(obj.pInputVectorSize),2)~=floor(mod(log2(obj.pInputVectorSize),2))
                    coder.internal.error('dsphdl:FFT:InputVectSizePow2',blkName);
                end
                if obj.pInputVectorSize>obj.MaxInputVectorSize
                    if~coder.const(dsphdl.private.AbstractFFT.isFeatureOn('ExtendedFFTInputSize'))
                        coder.internal.error('dsphdl:FFT:InputVectSizeMax',blkName);
                    end
                end
                if obj.pInputVectorSize>obj.FFTLength
                    coder.internal.error('dsphdl:FFT:InputVectSize',blkName);
                end
            elseif obj.pInputVectorSize>1
                coder.internal.error('dsphdl:FFT:ScalarArchitecture',blkName);
            end

            validateBoolean(obj,varargin{:});

        end

        function flag=isInputComplexityMutableImpl(~,~)

            flag=true;
        end

        function validateBoolean(obj,varargin)
            validDimension={'scalar'};
            if isempty(coder.target)||~eml_ambiguous_types
                blkname=class(obj);
                blkname=blkname(8:end);
                if obj.ValidInputPort&&obj.ResetInputPort
                    validateattributes(varargin{2},{'logical'},validDimension,blkname,'valid');
                    validateattributes(varargin{3},{'logical'},validDimension,blkname,'reset');
                elseif obj.ValidInputPort
                    validateattributes(varargin{2},{'logical'},validDimension,blkname,'valid');
                elseif obj.ResetInputPort
                    validateattributes(varargin{2},{'logical'},validDimension,blkname,'reset');
                end
            end

        end

        function resetImpl(obj)
            obj.pInBufferIndex=1;
            obj.pInBuffer_re(:)=0;
            obj.pInBuffer_im(:)=0;
            obj.pInBuffer_valid(:)=0;
            obj.pLatencyCnt=1;
            obj.pInitLatencyCnt=true;
            obj.pOutBuffer_valid(:)=0;
            obj.pOutBuffer_cmplx(:)=complex(0);
            obj.pWrOutBuffer_index=1;
            obj.pRdOutBuffer_index=1;
            obj.pWrOutBuffer_roll=false;
            obj.pRdOutBuffer_roll=false;
            obj.pEvenSample=true;
            obj.pHoldTime=0;
            obj.pHoldSample=1;
            obj.pStartOutputPort=[true;false(obj.pFFTLength/obj.pInputVectorSize-1,1)];
            obj.pEndOutputPort=[false;true;false(obj.pFFTLength/obj.pInputVectorSize-2,1)];
            obj.pOverflowStage(:)=0;
            obj.pOverflowFlag=true;
            obj.pSimTime=1;
            obj.pSOF=0;
            obj.pCurSOF=0;
            obj.pSOFFifo=zeros(1024,1);
            obj.pWrFifoAddr=1;
            obj.pRdFifoAddr=1;
            obj.pLastData=obj.pInitialValue;
            obj.pState=0;
            obj.pSampleCnt=0;
            obj.pOutCnt=0;
            obj.pWrEnb=false;
            if obj.pInitialize
                obj.pRdyReg=true;
                obj.pInitialize=false;
            else
                obj.pRdyReg=false;
            end

        end

        function flag=getExecutionSemanticsImpl(obj)
            if obj.ResetInputPort
                flag={'Classic','SynchronousWithResetPort'};
            else
                flag={'Classic','Synchronous'};
            end

        end

        function setupImpl(obj,A,varargin)

            if~isfloat(A)
                obj.pFimath=fimath('RoundingMethod','Floor','OverflowAction','Wrap');
                obj.pUserFimath=fimath('RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction);
            end

            dLen=size(A,1);
            obj.pInputLen=dLen;
            obj.pFFTLength=double(obj.FFTLength);
            obj.pInitialize=true;
            obj.pInputVectorSize=length(A);
            frameTransferTime=ceil(double(obj.FFTLength)/obj.pInputVectorSize);
            noOfFrames=ceil(getLatency(obj,obj.FFTLength,obj.pInputVectorSize)/frameTransferTime);
            inBufferSize=2*noOfFrames*double(obj.FFTLength);


            if size(A,1)==obj.pFFTLength
                obj.pRemoveFFTLatency=obj.RemoveFFTLatency;
            else
                obj.pRemoveFFTLatency=false;
            end

            obj.pOutputDataFirst=scheduleOutput(obj);

            if obj.pRemoveFFTLatency
                obj.pFFTLatency=0;
            else
                obj.pFFTLatency=obj.waitCycle4dVld(obj.pFFTLength);
            end

            obj.pNormalize=obj.Normalize;
            if obj.pNormalize
                obj.pBitGrowthVector=zeros(log2f(obj,obj.pFFTLength),1);
            else
                obj.pBitGrowthVector=ones(log2f(obj,obj.pFFTLength),1);
            end
            obj.pOverflowFlag=true;
            obj.pOverflowStage=zeros(log2f(obj,obj.pFFTLength),1);
            obj.pResetStart=false;
            obj.pInBufferSize=inBufferSize;
            obj.pOutBufferSize=2*inBufferSize;
            pInBuffer_re_tmp=zeros(inBufferSize,1,'like',real(A));
            pInBuffer_im_tmp=zeros(inBufferSize,1,'like',real(A));
            obj.pInBuffer_valid=zeros(inBufferSize,1);
            pOutBuffer_cmplx_tmp=complex(zeros(obj.pOutBufferSize,1,'like',real(A)));
            obj.pOutBuffer_valid=zeros(obj.pOutBufferSize,1);
            totalBitGrowth=sum(obj.pBitGrowthVector);
            if~isfloat(A)
                if isa(A,'embedded.fi')
                    if issigned(A)
                        obj.pInBuffer_re=fi(pInBuffer_re_tmp,1,A.WordLength+totalBitGrowth,A.FractionLength,obj.pFimath);
                        obj.pInBuffer_im=fi(pInBuffer_im_tmp,1,A.WordLength+totalBitGrowth,A.FractionLength,obj.pFimath);
                        obj.pOutBuffer_cmplx=fi(pOutBuffer_cmplx_tmp,1,A.WordLength+totalBitGrowth,A.FractionLength,obj.pFimath);
                        obj.pLastData=complex(fi(zeros(dLen,1),1,A.WordLength+totalBitGrowth,A.FractionLength,obj.pFimath));
                    else
                        obj.pInBuffer_re=fi(pInBuffer_re_tmp,1,A.WordLength+totalBitGrowth+1,A.FractionLength,obj.pFimath);
                        obj.pInBuffer_im=fi(pInBuffer_im_tmp,1,A.WordLength+totalBitGrowth+1,A.FractionLength,obj.pFimath);
                        obj.pOutBuffer_cmplx=fi(pOutBuffer_cmplx_tmp,1,A.WordLength+totalBitGrowth+1,A.FractionLength,obj.pFimath);
                        obj.pLastData=complex(fi(zeros(dLen,1),1,A.WordLength+totalBitGrowth+1,A.FractionLength,obj.pFimath));
                    end
                elseif isinteger(A)&&strncmpi(class(A),'uint',4)
                    n=numerictype(class(A));
                    obj.pInBuffer_re=fi(pInBuffer_re_tmp,1,n.WordLength+1+totalBitGrowth,0,obj.pFimath);
                    obj.pInBuffer_im=fi(pInBuffer_im_tmp,1,n.WordLength+1+totalBitGrowth,0,obj.pFimath);
                    obj.pOutBuffer_cmplx=fi(pOutBuffer_cmplx_tmp,1,n.WordLength+1+totalBitGrowth,0,obj.pFimath);
                    obj.pLastData=complex(fi(zeros(dLen,1),1,n.WordLength+1+totalBitGrowth,0,obj.pFimath),fi(0,1,n.WordLength+1+totalBitGrowth,0,obj.pFimath));
                elseif totalBitGrowth==0
                    obj.pInBuffer_re=zeros(inBufferSize,1,'like',real(A));
                    obj.pInBuffer_im=zeros(inBufferSize,1,'like',real(A));
                    obj.pOutBuffer_cmplx=complex(zeros(obj.pOutBufferSize,1,'like',real(A)));
                    obj.pLastData=complex(zeros(dLen,1,'like',real(A)));
                elseif isinteger(A)&&strncmpi(class(A),'int',3)
                    n=numerictype(class(A));
                    obj.pInBuffer_re=fi(pInBuffer_re_tmp,1,n.WordLength+totalBitGrowth,0,obj.pFimath);
                    obj.pInBuffer_im=fi(pInBuffer_im_tmp,1,n.WordLength+totalBitGrowth,0,obj.pFimath);
                    obj.pOutBuffer_cmplx=fi(pOutBuffer_cmplx_tmp,1,n.WordLength+totalBitGrowth,0,obj.pFimath);
                    obj.pLastData=complex(fi(zeros(dLen,1),1,n.WordLength+totalBitGrowth,0,obj.pFimath),fi(0,1,n.WordLength+totalBitGrowth,0,obj.pFimath));
                end
            else
                obj.pInBuffer_re=zeros(inBufferSize,1,'like',real(A));
                obj.pInBuffer_im=zeros(inBufferSize,1,'like',real(A));
                obj.pOutBuffer_cmplx=complex(zeros(obj.pOutBufferSize,1,'like',real(A)));
                obj.pLastData=complex(zeros(dLen,1,'like',real(A)));
            end

            obj.pInitialValue=complex(zeros(dLen,1,'like',obj.pLastData));

            obj.pBitReversedOutput=obj.BitReversedOutput;
            obj.pBitReversedInput=obj.BitReversedInput;

            [obj.pBitReverseTable_H,obj.pBitReverseTable_F]=createBitReversTable(obj);

            obj.pStartOutputPort=[true;false(obj.pFFTLength/obj.pInputVectorSize-1,1)];
            obj.pEndOutputPort=[false;true;false(obj.pFFTLength/obj.pInputVectorSize-2,1)];
            obj.pEvenSample=true;
            obj.pSimTime=1;
            obj.pSOF=0;
            obj.pCurSOF=0;
            obj.pWrFifoAddr=1;
            obj.pRdFifoAddr=1;
            obj.pState=0;
            obj.pSampleCnt=0;
            obj.pOutCnt=0;
            obj.pWrEnb=false;
            obj.pRdyReg=true;
        end
    end




    methods(Static,Hidden)
        function twiddleTable=getTwiddleTable(stage,data_wordLength)
            if ischar(data_wordLength)
                twiddleTable=exp(-1i*2*pi*(0:2^(stage-1)-1)/2^stage);
            else
                twdl_wordLength=data_wordLength;
                twdl_fractionLength=data_wordLength-2;
                noOfTwiddles=((0:2^(stage-1)-1)/2^stage);
                twiddleTable=fi(exp(-1i*2*pi*noOfTwiddles),1,twdl_wordLength,twdl_fractionLength,'RoundingMethod','Convergent','OverflowAction','Wrap');



            end
        end
    end



    methods(Access=protected)
        function varargout=outputImpl(obj,varargin)
            if pra.rangeAnalysisViaRtw
                pra.stub_fcn('always');
            end



            dataIn=varargin{1};
            vldIn=varargin{2};
            expectedOutputLen=length(dataIn);
            resetIn=false(expectedOutputLen,1);





            outputDataFirst=obj.pOutputDataFirst;


            earlyCall=true;
            updateStates=false;

            [dataOut,startOut,endOut,validOut]=obj.read_outBuffer(expectedOutputLen,resetIn,outputDataFirst,earlyCall,updateStates);
            varargout{1}=dataOut;
            if strcmpi(obj.Architecture,'Burst Radix 2')
                readyOut=outputReady(obj);
                if obj.StartOutputPort&&obj.EndOutputPort
                    varargout{2}=startOut;
                    varargout{3}=endOut;
                    varargout{4}=validOut;
                    varargout{5}=readyOut;
                elseif obj.StartOutputPort
                    varargout{2}=startOut;
                    varargout{3}=validOut;
                    varargout{4}=readyOut;
                elseif obj.EndOutputPort
                    varargout{2}=endOut;
                    varargout{3}=validOut;
                    varargout{4}=readyOut;
                else
                    varargout{2}=validOut;
                    varargout{3}=readyOut;
                end
            else
                if obj.StartOutputPort&&obj.EndOutputPort
                    varargout{2}=startOut;
                    varargout{3}=endOut;
                    varargout{4}=validOut;
                elseif obj.StartOutputPort
                    varargout{2}=startOut;
                    varargout{3}=validOut;
                elseif obj.EndOutputPort
                    varargout{2}=endOut;
                    varargout{3}=validOut;
                else
                    varargout{2}=validOut;
                end
            end




            if~outputDataFirst

                updateStates=true;
                obj.read_outBuffer(expectedOutputLen,resetIn,outputDataFirst,earlyCall,updateStates);



                [dataOut,startOut,endOut,validOut]=obj.updateState(varargin{:});


                varargout{1}=dataOut;
                if obj.StartOutputPort&&obj.EndOutputPort
                    varargout{2}=startOut;
                    varargout{3}=endOut;
                    varargout{4}=validOut;
                elseif obj.StartOutputPort
                    varargout{2}=startOut;
                    varargout{3}=validOut;
                elseif obj.EndOutputPort
                    varargout{2}=endOut;
                    varargout{3}=validOut;
                else
                    varargout{2}=validOut;
                end
            end
            if pra.rangeAnalysisViaRtw
                pra.condition(dsphdl.private.AbstractFFT.outputRR(obj,varargout{1},varargin{1}));
            end
        end

        function updateImpl(obj,varargin)



            if~coder.target('hdl')
                expectedOutputLen=length(varargin{1});
                resetIn=false(expectedOutputLen,1);





                outputDataFirst=obj.pOutputDataFirst;

                if outputDataFirst

                    updateStates=true;
                    earlyCall=true;
                    obj.read_outBuffer(expectedOutputLen,resetIn,outputDataFirst,earlyCall,updateStates);
                    obj.updateState(varargin{:});
                end
            end
        end

        function[dataOut,startOut,endOut,validOut]=updateState(obj,varargin)



            outputDataFirst=obj.pOutputDataFirst;
            earlyCall=true;


            inputPorts=obj.StartInputPort*4+obj.ValidInputPort*2+obj.ResetInputPort;
            inData=varargin{1};
            switch inputPorts
            case 7
                startIn=repmat(varargin{2},length(inData),1);
                validIn=repmat(varargin{3},length(inData),1);
                resetIn=repmat(varargin{4},length(inData),1);
            case 6
                startIn=repmat(varargin{2},length(inData),1);
                validIn=repmat(varargin{3},length(inData),1);
                resetIn=false(length(inData),1);%#ok<*PREALL>
            case 5
                startIn=repmat(varargin{2},length(inData),1);
                validIn=true(length(inData),1);
                resetIn=repmat(varargin{3},length(inData),1);
            case 4
                startIn=repmat(varargin{2},length(inData),1);
                validIn=true(length(inData),1);
                resetIn=false(length(inData),1);
            case 3
                startIn=false(length(inData),1);
                validIn=repmat(varargin{2},length(inData),1);
                resetIn=repmat(varargin{3},length(inData),1);
            case 2
                startIn=false(length(inData),1);
                validIn=repmat(varargin{2},length(inData),1);
                resetIn=false(length(inData),1);
            case 1
                startIn=false(length(inData),1);
                validIn=true(length(inData),1);
                resetIn=repmat(varargin{2},length(inData),1);
            case 0
                startIn=false(length(inData),1);
                validIn=true(length(inData),1);
                resetIn=false(length(inData),1);
            end




            if obj.pResetStart
                obj.pResetStart(:)=0;
            end
            loop=1;

            if resetIn(loop)==1
                obj.pResetStart(:)=1;
            end

            if obj.pResetStart
                dataInOutMem=0;
            else
                dataInOutMem=availableData(obj);
            end
            resetIfTrue(obj,resetIn,loop,dataInOutMem,earlyCall);


            registerOutputSOF(obj,inData,validIn,resetIn);

            updateReady(obj,validIn,resetIn);

            validData=validIn&~resetFrame(obj,resetIn)&isExCycle(obj);
            inSample=inData(validData==1);
            if~isreal(varargin{1})&&isreal(inSample)
                inSample=complex(inSample);
            end

            if~isempty(inSample)

                if isreal(inSample)
                    obj.pInBuffer_re(obj.pInBufferIndex:obj.pInBufferIndex+length(inSample)-1)=inSample;
                    obj.pInBuffer_im(obj.pInBufferIndex:obj.pInBufferIndex+length(inSample)-1)=zeros(length(inSample),1,'like',inSample);
                else
                    obj.pInBuffer_re(obj.pInBufferIndex:obj.pInBufferIndex+length(inSample)-1)=real(inSample);
                    obj.pInBuffer_im(obj.pInBufferIndex:obj.pInBufferIndex+length(inSample)-1)=imag(inSample);
                end

                obj.pInBufferIndex=obj.pInBufferIndex+length(inSample);



                if obj.pInBufferIndex-1>=obj.pFFTLength
                    if strcmpi(obj.Architecture,'Burst Radix 2')&&obj.FFTLength>=8
                        [pOutBuffer_re,pOutBuffer_im]=obj.Radix2FFT(obj.pInBuffer_re(1:obj.pFFTLength),obj.pInBuffer_im(1:obj.pFFTLength));
                    else
                        [pOutBuffer_re,pOutBuffer_im]=obj.Radix22FFT(obj.pInBuffer_re(1:obj.pFFTLength),obj.pInBuffer_im(1:obj.pFFTLength));
                    end
                    obj.write_outBuffer(complex(pOutBuffer_re,pOutBuffer_im));

                    obj.pInBufferIndex=obj.pInBufferIndex-obj.pFFTLength;
                    obj.pInBuffer_re=[obj.pInBuffer_re(obj.pFFTLength+1:end);zeros(obj.pFFTLength,1)];
                    obj.pInBuffer_im=[obj.pInBuffer_im(obj.pFFTLength+1:end);zeros(obj.pFFTLength,1)];
                end
            end



            if~outputDataFirst
                earlyCall=false;
                updateStates=true;
                expectedOutputLen=length(inData);
                [dataOut,startOut,endOut,validOut]=obj.read_outBuffer(expectedOutputLen,resetIn,outputDataFirst,earlyCall,updateStates);
                varargout{1}=dataOut;
                if obj.StartOutputPort&&obj.EndOutputPort
                    varargout{2}=startOut;
                    varargout{3}=endOut;
                    varargout{4}=validOut;
                elseif obj.StartOutputPort
                    varargout{2}=startOut;
                    varargout{3}=validOut;
                elseif obj.EndOutputPort
                    varargout{2}=endOut;
                    varargout{3}=validOut;
                else
                    varargout{2}=validOut;
                end
            end


            updateSimTime(obj);
        end
    end



    methods(Access=protected)

        function updateSimTime(obj)
            obj.pSimTime=obj.pSimTime+1;
        end

        function registerOutputSOF(obj,inData,validIn,resetIn)
            resetOut=resetFrame(obj,resetIn);
            validData=validIn&(~resetOut);
            vldSamples=length(inData(validData));

            if obj.pInBufferIndex+vldSamples-1>=obj.pFFTLength
                if~strcmpi(obj.Architecture,'Streaming Radix 2^2')||obj.FFTLength<8
                    index=spFind(obj,validIn,'==',1);
                    sampleNeeded=obj.pFFTLength-obj.pInBufferIndex+1;
                    if sampleNeeded>0&&~isempty(index)
                        EOFTime=obj.pSimTime+index(sampleNeeded);
                    else
                        EOFTime=obj.pSimTime;
                    end
                    if~obj.pRemoveFFTLatency
                        txSOF=EOFTime+obj.getLatency-obj.pFFTLength;
                    else
                        txSOF=EOFTime-obj.pFFTLength;
                    end
                else
                    EOFTime=obj.pSimTime;
                    if~obj.pRemoveFFTLatency
                        txSOF=EOFTime+obj.getLatency-obj.pFFTLength/vldSamples+1;
                    else
                        txSOF=EOFTime;
                    end
                end
                pushFIFO(obj,txSOF);
            end
        end
        function pushFIFO(obj,data)
            curAddr=obj.pWrFifoAddr;
            obj.pSOFFifo(curAddr)=data;
            if curAddr==1024
                curAddr=1;
            else
                curAddr=curAddr+1;
            end
            obj.pWrFifoAddr=curAddr;
        end
        function data=pullFIFO(obj,updateStates)
            curAddr=obj.pRdFifoAddr;
            data=obj.pSOFFifo(curAddr);
            if data>0
                if curAddr==1024
                    curAddr=1;
                else
                    curAddr=curAddr+1;
                end
                if updateStates
                    obj.pRdFifoAddr=curAddr;
                end
            end
        end

        function write_outBuffer(obj,data)
            for loop=1:length(data)
                obj.pOutBuffer_cmplx(obj.pWrOutBuffer_index)=data(loop);
                if obj.pWrOutBuffer_index<obj.pOutBufferSize
                    obj.pWrOutBuffer_index=obj.pWrOutBuffer_index+1;
                else
                    obj.pWrOutBuffer_index=1;
                    obj.pWrOutBuffer_roll=~obj.pWrOutBuffer_roll;
                end

            end
        end

        function[data,startOut,endOut,dataValid]=read_outBuffer(obj,dataLength,resetIn,outputData,earlyCall,updateStates)
            data=complex(zeros(dataLength,1,'like',real(obj.pOutBuffer_cmplx)));
            startOut=false;
            endOut=false;
            dataValid=false;
            sampleValid=false(dataLength,1);
            sampleIndex=zeros(dataLength,1);


            obj_pCurSOF=obj.pCurSOF;

            if obj.pResetStart
                dataInOutMem=0;
            else
                dataInOutMem=availableData(obj);
            end
            if outputData
                if~earlyCall

                    dataInOutMem=resetIfTrue(obj,resetIn,1,dataInOutMem,earlyCall);
                end
                if dataInOutMem>0
                    if obj_pCurSOF==0
                        obj_pCurSOF=pullFIFO(obj,updateStates);
                    elseif obj.pSimTime>=obj_pCurSOF+obj.pFFTLength/dataLength
                        obj_pCurSOF=pullFIFO(obj,updateStates);
                    end
                    if obj_pCurSOF<=obj.pSimTime&&obj.pSimTime<=ceil(obj_pCurSOF+obj.pFFTLength/dataLength-1)
                        data=rdMem(obj,dataLength,updateStates);
                        dataValid=true;
                        startOut=obj.pStartOutputPort(1);
                        if obj.pInputVectorSize==obj.pFFTLength
                            endOut=obj.pStartOutputPort(1);
                        else
                            endOut=obj.pEndOutputPort(1);
                        end
                        dataInOutMem=dataInOutMem-dataValid;
                        if updateStates
                            obj.pLastData=data;
                            obj.pStartOutputPort=[obj.pStartOutputPort(end);obj.pStartOutputPort(1:end-1)];
                            obj.pEndOutputPort=[obj.pEndOutputPort(end);obj.pEndOutputPort(1:end-1)];
                        end
                    else
                        dataValid=false;
                        data(:)=obj.pLastData;
                        startOut=false;
                        endOut=false;
                    end
                else
                    dataValid=false;
                    data(:)=obj.pLastData;
                    startOut=false;
                    endOut=false;
                end
            end

            if updateStates
                obj.pCurSOF=obj_pCurSOF;
            end
        end
        function status=isExCycle(obj)
            status=obj.pWrEnb;
        end
        function updateReady(obj,validIn,resetIn)
            IDLE=0;
            LOAD=1;
            SAVE=2;
            WAIT=3;
            UNLOAD=4;
            if strcmpi(obj.Architecture,'Burst Radix 2')&&obj.FFTLength>=8
                vldIn=validIn(1);
                startOut=obj.pStartOutputPort(2);
                if~resetIn
                    switch obj.pState
                    case IDLE
                        obj.pState=IDLE;
                        obj.pRdyReg=true;

                        obj.pOutCnt=0;
                        obj.pWrEnb=false;
                        if vldIn&&~resetIn
                            obj.pWrEnb=true;
                            obj.pSampleCnt=obj.pSampleCnt+1;
                            obj.pState=LOAD;
                        end
                    case LOAD
                        obj.pState=LOAD;
                        if vldIn
                            if obj.pSampleCnt==obj.pFFTLength-1
                                obj.pRdyReg=false;
                                obj.pWrEnb=true;
                                obj.pSampleCnt=0;
                                obj.pState=SAVE;
                            else
                                obj.pSampleCnt=obj.pSampleCnt+1;
                                obj.pWrEnb=true;
                                obj.pRdyReg=true;
                            end
                        end
                    case SAVE
                        obj.pState=WAIT;
                        obj.pSampleCnt=0;
                        obj.pWrEnb=false;
                        if vldIn
                            obj.pWrEnb=true;
                            obj.pSampleCnt=obj.pSampleCnt+1;
                        end
                    case WAIT
                        obj.pState=WAIT;
                        obj.pWrEnb=false;
                        if obj.pBitReversedOutput
                            if startOut
                                obj.pOutCnt=obj.pOutCnt+1;
                                obj.pState=UNLOAD;
                            end
                        else
                            if startOut


                                obj.pOutCnt=obj.pOutCnt+1;
                                obj.pState=UNLOAD;
                            end
                        end
                    case UNLOAD
                        if obj.pBitReversedInput
                            if obj.pBitReversedOutput
                                if obj.pOutCnt==obj.pFFTLength-3
                                    obj.pOutCnt=0;
                                    obj.pRdyReg=true;
                                    obj.pState=IDLE;
                                else
                                    obj.pOutCnt=obj.pOutCnt+1;
                                end
                            else
                                if obj.pOutCnt==obj.pFFTLength-4
                                    obj.pOutCnt=0;
                                    obj.pRdyReg=true;
                                    obj.pState=IDLE;
                                else
                                    obj.pOutCnt=obj.pOutCnt+1;
                                end
                            end
                        else
                            if obj.pBitReversedOutput
                                if obj.pOutCnt==obj.pFFTLength/2-2
                                    obj.pOutCnt=0;
                                    obj.pRdyReg=true;
                                    obj.pState=IDLE;
                                else
                                    obj.pOutCnt=obj.pOutCnt+1;
                                end
                            else
                                if obj.pOutCnt==obj.pFFTLength/2-3
                                    obj.pOutCnt=0;
                                    obj.pRdyReg=true;
                                    obj.pState=IDLE;
                                else
                                    obj.pOutCnt=obj.pOutCnt+1;
                                end
                            end
                        end

                    otherwise
                        obj.pState=IDLE;
                        obj.pRdyReg=true;
                        obj.pSampleCnt=0;
                        obj.pOutCnt=0;
                        obj.pWrEnb=false;
                    end
                else
                    obj.pState=IDLE;
                    obj.pRdyReg=false;
                    obj.pSampleCnt=0;
                    obj.pOutCnt=0;
                    obj.pWrEnb=false;
                end
            elseif strcmpi(obj.Architecture,'Burst Radix 2')
                obj.pOutCnt=0;
                obj.pState=IDLE;
                obj.pRdyReg=~resetIn;
                obj.pSampleCnt=0;
                obj.pWrEnb=true;
            else
                obj.pOutCnt=0;
                obj.pState=IDLE;

                obj.pSampleCnt=0;
                obj.pWrEnb=true;
            end
        end
        function ready=outputReady(obj)
            ready=obj.pRdyReg;
        end
        function data=rdMem(obj,Len,updateStates)
            if nargin==1
                Len=1;
            end
            data=zeros(Len,1,'like',obj.pOutBuffer_cmplx);

            obj_pRdOutBuffer_index=obj.pRdOutBuffer_index;
            obj_pRdOutBuffer_roll=obj.pRdOutBuffer_roll;

            for loop=1:Len
                data(loop)=obj.pOutBuffer_cmplx(obj_pRdOutBuffer_index);
                if obj_pRdOutBuffer_index==obj.pOutBufferSize
                    obj_pRdOutBuffer_index=1;
                    obj_pRdOutBuffer_roll=~obj_pRdOutBuffer_roll;
                else
                    obj_pRdOutBuffer_index=obj_pRdOutBuffer_index+1;
                end
            end

            if updateStates
                obj.pRdOutBuffer_index=obj_pRdOutBuffer_index;
                obj.pRdOutBuffer_roll=obj_pRdOutBuffer_roll;
            end

        end
        function sampleIndex=getIndexVector(obj,stage)
            N=obj.pFFTLength;
            assert(1<=stage);
            assert(stage<=N/2);
            sampleIndex=zeros(1,N/2);
            coder.varsize('sampleIndex',[1,N/2]);
            if stage==1
                sampleIndex=[0:2:N/(2^stage)-2,1:2:N/(2^stage)-1];
                return;
            elseif stage==log2f(obj,N)
                sampleIndex=(0:1:N/(2)-1);
            else
                BaseSampleIndex=[0:2:N/(2^stage)-2,1:2:N/(2^stage)-1];
                sampleIndex=BaseSampleIndex;
                for i=1:2^(stage-1)-1
                    sampleIndex=[sampleIndex,(BaseSampleIndex+i*(N/2^(stage-1)))];%#ok<AGROW>
                end
            end
        end
        function dataInOutMem=resetIfTrue(obj,resetIn,loop,curDataInOutMem,earlyCall)

            dataInOutMem=curDataInOutMem;
            inBufferIndex=obj.pInBufferIndex;
            inBufferReal=obj.pInBuffer_re;
            inBufferImag=obj.pInBuffer_im;
            inBufferValid=obj.pInBuffer_valid;
            if obj.pResetStart
                resetImpl(obj);
                dataInOutMem=0;


                if~earlyCall

                    obj.pInBufferIndex=inBufferIndex;
                    obj.pInBuffer_re=inBufferReal;
                    obj.pInBuffer_im=inBufferImag;
                    obj.pInBuffer_valid=inBufferValid;
                end
            end
...
...
...
...
...
...
...
...
        end
        function resetOut=resetFrame(obj,resetIn)





            resetOut=zeros(length(resetIn),1);
            resetIndex=zeros(length(resetIn),1);
            resetIndex=spFind(obj,resetIn,'==',1);
            resetOut=resetIn;
            if~isempty(resetIndex)
                lastIndex=length(resetIndex);
                if resetIndex(1)>obj.getLatency(obj.pFFTLength)-obj.pInBufferIndex
                    firstIndex=obj.pFFTLength-obj.pInBufferIndex+2;
                else
                    firstIndex=1;
                end
                for loop=firstIndex:resetIndex(lastIndex)
                    resetOut(loop)=true;
                end
            end
        end
        function outputDataFirst=scheduleOutput(obj)






















            if~obj.pRemoveFFTLatency
                outputDataFirst=true;
            else
                outputDataFirst=false;
            end
        end
        function dataLength=availableData(obj)
            if obj.pRdOutBuffer_roll==obj.pWrOutBuffer_roll
                dataLength=obj.pWrOutBuffer_index-obj.pRdOutBuffer_index;
            else
                dataLength=obj.pOutBufferSize-obj.pRdOutBuffer_index+obj.pWrOutBuffer_index;
            end

        end

    end


    methods(Access=protected)



        function[dout_re,dout_im]=Radix2FFT(obj,dataIn_re,dataIn_im)








            NumberOfStages=log2f(obj,obj.pFFTLength);

            if obj.pBitReversedInput
                dataIn_re=bitrevorder(dataIn_re);
                dataIn_im=bitrevorder(dataIn_im);
            end

            if obj.InverseFFT
                dataIn_tmp=zeros(obj.pFFTLength,1,'like',dataIn_re);
                dataIn_tmp=dataIn_re;
                dataIn_re=dataIn_im;
                dataIn_im=dataIn_tmp;
            end

            data_sign=1;
            if obj.pNormalize
                totalBitGrowth=0;
            else
                totalBitGrowth=sum(obj.pBitGrowthVector);
            end
            if~isfloat(dataIn_re)
                if isinteger(dataIn_re)
                    c=class(dataIn_re);
                    n=numerictype(c);
                    data_wordLength=n.WordLength+totalBitGrowth;
                    data_fractionLength=0;
                    if strncmpi(c,'uint',4)
                        data_wordLength=data_wordLength+1;
                    end
                else
                    if issigned(dataIn_re)
                        data_wordLength=dataIn_re.WordLength;
                        data_fractionLength=dataIn_re.FractionLength;
                    else
                        data_wordLength=dataIn_re.WordLength+1;
                        data_fractionLength=dataIn_re.FractionLength;
                    end
                end
                din_re=fi(dataIn_re,data_sign,data_wordLength,data_fractionLength,obj.pFimath);
                din_im=fi(dataIn_im,data_sign,data_wordLength,data_fractionLength,obj.pFimath);
            else
                din_re=dataIn_re;
                din_im=dataIn_im;
                data_wordLength='double';
                data_fractionLength='double';
            end

            dout_re_stage=zeros(obj.pFFTLength,1,'like',din_re);
            dout_im_stage=zeros(obj.pFFTLength,1,'like',din_re);


            if~isfloat(dataIn_re)
                twdl_wordLength=data_wordLength;
            end

            for stage=coder.unroll(1:NumberOfStages)

                if isfloat(din_re)
                    twiddleTable=complex(zeros(2^(stage-1),1,'like',din_re)');
                    twiddleTable=dsphdl.private.AbstractFFT.getTwiddleTable(stage,'double');
                else

                    twiddleTable_tmp=complex(fi(zeros(2^(stage-1),1)',1,twdl_wordLength,twdl_wordLength-2,'RoundingMethod','Floor','OverflowAction','Wrap'));%#ok<*NASGU>

                    twiddleTable_tmp(:)=dsphdl.private.AbstractFFT.getTwiddleTable(stage,twdl_wordLength);
                    twiddleTable=twiddleTable_tmp;

                end

                outIndex=1;
                twdlIndex=0;
                N=obj.pFFTLength;
                sampleIndex=zeros(1,N/2);
                sampleIndex=obj.getIndexVector(stage);
                len=length(sampleIndex);

                for loop=1:len
                    inIndex=sampleIndex(loop);
                    [wr,wi]=obj.getTwiddleFactor(twiddleTable,twdlIndex,stage);

                    if stage==NumberOfStages
                        [X,U,Y,V]=obj.butterfly(din_re(inIndex+1),din_im(inIndex+1),din_re(inIndex+(obj.pFFTLength/2)+1),din_im(inIndex+(obj.pFFTLength/2)+1),wr,wi,stage);
                    else
                        [X,U,Y,V]=obj.butterfly(din_re(inIndex+1),din_im(inIndex+1),din_re(inIndex+obj.pFFTLength/(2^stage)+1),din_im(inIndex+obj.pFFTLength/(2^stage)+1),wr,wi,stage);
                    end
                    if isfloat(din_re)
                        dout_re_stage(outIndex)=X;
                        dout_re_stage(outIndex+1)=Y;
                        dout_im_stage(outIndex)=U;
                        dout_im_stage(outIndex+1)=V;
                    elseif strcmpi(obj.OutputDataType,'Same as input')
                        if obj.pNormalize
                            if strcmpi(obj.RoundingMethod,'Floor')
                                X_scaled=bitsra(X,1);
                                Y_scaled=bitsra(Y,1);
                                U_scaled=bitsra(U,1);
                                V_scaled=bitsra(V,1);
                            else
                                X_tmp=fi(X,X.Signed,X.WordLength,X.FractionLength-1,obj.pUserFimath);
                                Y_tmp=fi(Y,Y.Signed,Y.WordLength,Y.FractionLength-1,obj.pUserFimath);
                                U_tmp=fi(U,U.Signed,U.WordLength,U.FractionLength-1,obj.pUserFimath);
                                V_tmp=fi(V,V.Signed,V.WordLength,V.FractionLength-1,obj.pUserFimath);
                                X_scaled=bitsra(X_tmp,1);
                                Y_scaled=bitsra(Y_tmp,1);
                                U_scaled=bitsra(U_tmp,1);
                                V_scaled=bitsra(V_tmp,1);
                            end
                        else
                            X_scaled=X;
                            Y_scaled=Y;
                            U_scaled=U;
                            V_scaled=V;
                        end

                        logFFTOverflow(obj,X_scaled,Y_scaled,U_scaled,V_scaled,data_sign,data_wordLength,data_fractionLength,stage);

                        X_cast=fi(X_scaled,data_sign,data_wordLength,data_fractionLength,obj.pUserFimath);
                        Y_cast=fi(Y_scaled,data_sign,data_wordLength,data_fractionLength,obj.pUserFimath);
                        U_cast=fi(U_scaled,data_sign,data_wordLength,data_fractionLength,obj.pUserFimath);
                        V_cast=fi(V_scaled,data_sign,data_wordLength,data_fractionLength,obj.pUserFimath);

                        dout_re_stage(outIndex)=fi(X_cast,data_sign,data_wordLength,data_fractionLength,obj.pFimath);
                        dout_re_stage(outIndex+1)=fi(Y_cast,data_sign,data_wordLength,data_fractionLength,obj.pFimath);
                        dout_im_stage(outIndex)=fi(U_cast,data_sign,data_wordLength,data_fractionLength,obj.pFimath);
                        dout_im_stage(outIndex+1)=fi(V_cast,data_sign,data_wordLength,data_fractionLength,obj.pFimath);
                    else

                    end
                    outIndex=outIndex+2;
                    twdlIndex=twdlIndex+1;
                end
                if isfloat(din_re)
                    din_re=dout_re_stage;
                    din_im=dout_im_stage;
                else
                    din_re=fi(dout_re_stage,data_sign,data_wordLength,data_fractionLength,obj.pFimath);
                    din_im=fi(dout_im_stage,data_sign,data_wordLength,data_fractionLength,obj.pFimath);
                end

            end


            warnIfOverflow(obj);


            if isfloat(din_re)
                scaleFactor=obj.pNormalize*(obj.pFFTLength-1)+1;
                if obj.InverseFFT
                    dout_re_scaled=din_im/scaleFactor;
                    dout_im_scaled=din_re/scaleFactor;
                else
                    dout_re_scaled=din_re/scaleFactor;
                    dout_im_scaled=din_im/scaleFactor;
                end
            else


                dout_re_scaled=fi(din_re,1,data_wordLength,data_fractionLength,obj.pFimath);
                dout_im_scaled=fi(din_im,1,data_wordLength,data_fractionLength,obj.pFimath);
                if obj.InverseFFT
                    dout_tmp=zeros(obj.pFFTLength,1,'like',dout_re_scaled);
                    dout_tmp=dout_re_scaled;
                    dout_re_scaled=dout_im_scaled;
                    dout_im_scaled=dout_tmp;
                end
            end


            if isfloat(din_re)
                dout_re_stageL=dout_re_scaled;
                dout_im_stageL=dout_im_scaled;
            else
                dout_re_stageL=fi(dout_re_scaled,data_sign,data_wordLength,data_fractionLength,obj.pFimath);
                dout_im_stageL=fi(dout_im_scaled,data_sign,data_wordLength,data_fractionLength,obj.pFimath);
            end




            dout_re=zeros(obj.pFFTLength,1,'like',dout_re_stageL);
            dout_im=zeros(obj.pFFTLength,1,'like',dout_im_stageL);



            if~obj.pBitReversedOutput
                for in_index=0:obj.pFFTLength-1
                    out_index=obj.bitReverse(in_index,obj.pBitReverseTable_F,2*obj.pFFTLength,NumberOfStages+1);
                    dout_re(out_index+1)=dout_re_stageL(in_index+1);
                    dout_im(out_index+1)=dout_im_stageL(in_index+1);
                end
            else
                dout_re=dout_re_stageL;
                dout_im=dout_im_stageL;
            end

        end



        function[dout_re,dout_im]=Radix22FFT(obj,dataIn_re,dataIn_im)


            NumberOfStages=log2(obj.pFFTLength);

            bitRevOrderOutput=obj.pBitReversedOutput;

            if obj.pBitReversedInput
                dataIn_re=bitrevorder(dataIn_re);
                dataIn_im=bitrevorder(dataIn_im);
            end

            if obj.InverseFFT
                dataIn_tmp=zeros(obj.pFFTLength,1,'like',dataIn_re);
                dataIn_tmp=dataIn_re;
                dataIn_re=dataIn_im;
                dataIn_im=dataIn_tmp;
            end


            data_sign=1;
            if obj.pNormalize
                totalBitGrowth=0;
            else
                totalBitGrowth=sum(obj.pBitGrowthVector);
            end
            if~isfloat(dataIn_re)
                if isinteger(dataIn_re)
                    c=class(dataIn_re);
                    n=numerictype(c);
                    data_wordLength=n.WordLength+totalBitGrowth;
                    data_fractionLength=0;
                    if strncmpi(c,'uint',4)
                        data_wordLength=data_wordLength+1;
                    end
                else
                    if issigned(dataIn_re)
                        data_wordLength=dataIn_re.WordLength;
                        data_fractionLength=dataIn_re.FractionLength;
                    else
                        data_wordLength=dataIn_re.WordLength+1;
                        data_fractionLength=dataIn_re.FractionLength;
                    end
                end
                din_re=fi(dataIn_re,data_sign,data_wordLength,data_fractionLength,obj.pFimath);
                din_im=fi(dataIn_im,data_sign,data_wordLength,data_fractionLength,obj.pFimath);
            else
                din_re=dataIn_re;
                din_im=dataIn_im;
            end

            din_cmplx=complex(din_re,din_im);

            if isfloat(din_cmplx)
                twdlTable=exp(-1i*2*pi*(0:2^(NumberOfStages)-1)/2^NumberOfStages);
            else
                twdl_WordLength=data_wordLength-totalBitGrowth;
                twdl_FractionLength=twdl_WordLength-2;
                twdlTable=fi(exp(-1i*2*pi*(0:2^(NumberOfStages)-1)/2^NumberOfStages).',1,twdl_WordLength,twdl_FractionLength,'RoundingMethod','Convergent','OverflowAction','Wrap');


                twdlTable=fi(twdlTable,1,obj.pFimath);
            end

            twdlIndex=ones(length(din_cmplx),1);
            processLen=length(din_cmplx)/2;


            if isfloat(din_cmplx)
                btf1_out=complex(zeros(length(din_cmplx),1,'like',din_re));
                btf2_out=complex(zeros(length(din_cmplx),1,'like',din_re));
                btf1_in=cast(0,'like',din_cmplx);
                btf2_in=cast(0,'like',din_cmplx);
            else
                btf1_out=complex(fi(zeros(length(din_cmplx),1),1,data_wordLength+1,data_fractionLength,obj.pFimath));
                btf2_out=complex(fi(zeros(length(din_cmplx),1),1,data_wordLength+1,data_fractionLength,obj.pFimath));
                btf1_tmp=complex(fi(zeros(length(din_cmplx),1),1,data_wordLength+1,data_fractionLength-1,obj.pUserFimath));
                btf2_tmp=complex(fi(zeros(length(din_cmplx),1),1,data_wordLength+1,data_fractionLength-1,obj.pUserFimath));
                btf1_in=complex(fi(0,1,data_wordLength,data_fractionLength,obj.pUserFimath));
                btf2_in=complex(fi(0,1,data_wordLength,data_fractionLength,obj.pUserFimath));
            end

            out1_scaled=complex(zeros(length(din_cmplx),1,'like',btf1_out));
            out2_scaled=complex(zeros(length(din_cmplx),1,'like',btf2_out));
            out1=complex(zeros(length(din_cmplx),1,'like',din_re));
            out2=complex(zeros(length(din_cmplx),1,'like',din_re));

            for stage=coder.unroll(1:floor(NumberOfStages/2))


                index=(0:2*processLen:length(din_cmplx)-1);
                for loop1=(index)
                    for loop2=1:processLen
                        loop=loop1+loop2;
                        twdlIdx_1=twdlIndex(loop);
                        twdlIdx_2=twdlIndex(processLen+loop);
                        if isfloat(din_cmplx)
                            btf1_in(:)=din_cmplx(loop)*twdlTable(twdlIdx_1);
                            btf2_in(:)=din_cmplx(processLen+loop)*twdlTable(twdlIdx_2);
                        else
                            btf1_in(:)=din_cmplx(loop)*twdlTable(twdlIdx_1);
                            btf2_in(:)=din_cmplx(processLen+loop)*twdlTable(twdlIdx_2);
                        end
                        btf1_out(loop)=btf1_in+btf2_in;
                        btf1_out(processLen+loop)=btf1_in-btf2_in;
                    end
                end


                if isfloat(din_cmplx)
                    if obj.pNormalize
                        out1_scaled=cast(btf1_out/2,'like',btf1_out);
                    else
                        out1_scaled=btf1_out;
                    end
                else
                    if obj.pNormalize
                        if strcmpi(obj.RoundingMethod,'Floor')
                            out1_scaled=bitsra(btf1_out,1);
                        else
                            btf1_tmp(:)=btf1_out;
                            out1_scaled=bitsra(btf1_tmp,1);
                        end
                    else
                        out1_scaled=btf1_out;
                    end
                end

                out1(:)=out1_scaled;





                processLen=processLen/2;

                index=(0:2*processLen:length(din_cmplx)-1);
                if isfloat(din_re)
                    for loop1=(index)
                        if any(loop1==(2*processLen:4*processLen:length(din_cmplx)))
                            coef=complex(0,-1);
                        else
                            coef=complex(1,0);
                        end
                        for loop2=1:processLen
                            loop=loop1+loop2;
                            btf2_out(loop)=out1(loop)+(coef)*out1(processLen+loop);
                            btf2_out(loop+processLen)=out1(loop)-(coef)*out1(processLen+loop);
                        end
                    end
                else
                    for loop1=(index)
                        if any(loop1==(2*processLen:4*processLen:length(din_cmplx)))
                            for loop2=1:processLen
                                loop=loop1+loop2;
                                out1xJ=complex(imag(out1(processLen+loop)),real(out1(processLen+loop)));
                                btf2_out(loop)=out1(loop)+out1xJ;
                                btf2_out(loop+processLen)=out1(loop)-out1xJ;
                                out2_im_tmp=imag(btf2_out(loop));
                                btf2_out(loop)=complex(real(btf2_out(loop)),imag(btf2_out(loop+processLen)));
                                btf2_out(loop+processLen)=complex(real(btf2_out(loop+processLen)),out2_im_tmp);
                            end
                        else
                            for loop2=1:processLen
                                loop=loop1+loop2;
                                btf2_out(loop)=out1(loop)+out1(processLen+loop);
                                btf2_out(loop+processLen)=out1(loop)-out1(processLen+loop);
                            end
                        end

                    end
                end

                if isfloat(din_cmplx)
                    if obj.pNormalize
                        out2_scaled=cast(btf2_out/2,'like',btf2_out);
                    else
                        out2_scaled=btf2_out;
                    end
                else
                    if obj.pNormalize
                        if strcmpi(obj.RoundingMethod,'Floor')
                            out2_scaled=bitsra(btf2_out,1);
                        else
                            btf2_tmp(:)=btf2_out;
                            out2_scaled=bitsra(btf2_tmp,1);
                        end
                    else
                        out2_scaled=btf2_out;
                    end
                end

                out2(:)=out2_scaled;




                addrIndex=bitrevorder(0:length(din_cmplx)/processLen-1);
                indexSize=processLen+max((0:processLen:(length(din_cmplx)/4^(stage-1))-1));
                twdlIndex_tmp=zeros(indexSize,1);
                ii=1;
                for loop1=((0:processLen:(length(din_cmplx)/4^(stage-1))-1))
                    for loop2=1:processLen
                        loop=loop1+loop2;
                        twdlIndex_tmp(loop)=1+(loop2-1)*addrIndex(ii);
                    end
                    ii=ii+1;
                end
                twdlIndex=repmat(twdlIndex_tmp,4^(stage-1),1);
                processLen=processLen/2;
                if isfloat(out2)
                    din_cmplx(:)=out2;
                else
                    din_cmplx(:)=out2;
                end
            end

            if rem(NumberOfStages,2)
                if isfloat(din_cmplx)
                    btf3_out=complex(zeros(length(din_cmplx),1,'like',din_re));
                else
                    btf3_out=complex(fi(zeros(length(din_cmplx),1),1,data_wordLength+1,data_fractionLength,obj.pFimath));
                    btf3_tmp=complex(fi(zeros(length(din_cmplx),1),1,data_wordLength+1,data_fractionLength-1,obj.pUserFimath));
                end
                out3_scaled=complex(zeros(length(din_cmplx),1,'like',btf3_out));
                out3=complex(zeros(length(din_cmplx),1,'like',din_re));

                index=(0:2:length(din_cmplx)-1);
                for loop1=(index)
                    for loop2=1:processLen
                        loop=loop1+loop2;
                        twdlIdx_1=twdlIndex(loop);
                        twdlIdx_2=twdlIndex(processLen+loop);
                        if isfloat(din_cmplx)
                            btf1_in(:)=din_cmplx(loop)*twdlTable(twdlIdx_1);
                            btf2_in(:)=din_cmplx(processLen+loop)*twdlTable(twdlIdx_2);
                        else
                            btf1_in(:)=din_cmplx(loop)*twdlTable(twdlIdx_1);
                            btf2_in(:)=din_cmplx(processLen+loop)*twdlTable(twdlIdx_2);
                        end
                        btf3_out(loop)=btf1_in+btf2_in;
                        btf3_out(processLen+loop)=btf1_in-btf2_in;
                    end
                end



                if isfloat(din_cmplx)
                    if obj.pNormalize
                        out3_scaled=cast(btf3_out/2,'like',btf3_out);
                    else
                        out3_scaled=btf3_out;
                    end
                else
                    if obj.pNormalize
                        if strcmpi(obj.RoundingMethod,'Floor')
                            out3_scaled=bitsra(btf3_out,1);
                        else
                            btf3_tmp(:)=btf3_out;
                            out3_scaled=bitsra(btf3_tmp,1);
                        end
                    else
                        out3_scaled=btf3_out;
                    end
                end


                out3(:)=out3_scaled;

                if~bitRevOrderOutput
                    dout_re=real(bitrevorder(out3));
                    dout_im=imag(bitrevorder(out3));
                else
                    dout_re=real(out3);
                    dout_im=imag(out3);
                end
            else
                if~bitRevOrderOutput
                    dout_re=real(bitrevorder(out2));
                    dout_im=imag(bitrevorder(out2));
                else
                    dout_re=real(out2);
                    dout_im=imag(out2);
                end
            end
            if obj.InverseFFT
                dout_tmp=zeros(obj.pFFTLength,1,'like',dout_re);
                dout_tmp=dout_re;
                dout_re=dout_im;
                dout_im=dout_tmp;
            end

        end



        function[X,U,Y,V]=butterfly(obj,x,u,y,v,wr,wi,~)%#ok<*INUSL>



            if isfloat(x)
                wry=wr*y;
                wiv=wi*v;
                wrv=wr*v;
                wiy=wi*y;
                X=x+wry-wiv;
                U=u+wrv+wiy;
                Y=x-wry+wiv;
                V=u-wrv-wiy;
            else
                wr_cast=fi(wr,1,wr.WordLength,wr.FractionLength,obj.pFimath);
                wi_cast=fi(wi,1,wi.WordLength,wi.FractionLength,obj.pFimath);
                y_cast=fi(y,1,y.WordLength,y.FractionLength,obj.pFimath);
                v_cast=fi(v,1,v.WordLength,v.FractionLength,obj.pFimath);














                wry=fi(wr_cast*y_cast,1,wr.WordLength+y.WordLength,wr.FractionLength+y.FractionLength,obj.pFimath);
                wiv=fi(wi_cast*v_cast,1,wi.WordLength+v.WordLength,wi.FractionLength+v.FractionLength,obj.pFimath);
                wrv=fi(wr_cast*v_cast,1,wr.WordLength+v.WordLength,wr.FractionLength+v.FractionLength,obj.pFimath);
                wiy=fi(wi_cast*y_cast,1,wi.WordLength+y.WordLength,wi.FractionLength+y.FractionLength,obj.pFimath);

                cmplx_re=fi(wry-wiv,wry.Signed,wry.WordLength+1,wry.FractionLength,obj.pFimath);
                cmplx_im=fi(wrv+wiy,wry.Signed,wry.WordLength+1,wry.FractionLength,obj.pFimath);

                x_cast=fi(x,cmplx_re.Signed,cmplx_re.WordLength,cmplx_re.FractionLength,obj.pFimath);
                u_cast=fi(u,cmplx_re.Signed,cmplx_re.WordLength,cmplx_re.FractionLength,obj.pFimath);

                X=fi(x_cast+cmplx_re,x_cast.Signed,x_cast.WordLength+1,x_cast.FractionLength,obj.pFimath);
                U=fi(u_cast+cmplx_im,u_cast.Signed,u_cast.WordLength+1,u_cast.FractionLength,obj.pFimath);
                Y=fi(x_cast-cmplx_re,x_cast.Signed,x_cast.WordLength+1,x_cast.FractionLength,obj.pFimath);
                V=fi(u_cast-cmplx_im,u_cast.Signed,u_cast.WordLength+1,u_cast.FractionLength,obj.pFimath);

            end
        end


        function[wr,wi]=getTwiddleFactor(obj,twiddleTable,twiddleIndex,stage)
            if stage==1
                if isfloat(twiddleTable)
                    wr=1;
                    wi=0;
                else
                    wr=fi(1,1,twiddleTable.WordLength,twiddleTable.WordLength-2,obj.pFimath);
                    wi=fi(0,1,twiddleTable.WordLength,twiddleTable.WordLength-2,obj.pFimath);
                end
            else
                twiddleIndex=obj.bitReverse(twiddleIndex,obj.pBitReverseTable_H,obj.pFFTLength,stage);
                twdlValue=twiddleTable(twiddleIndex+1);
                wr=real(twdlValue);
                wi=imag(twdlValue);

            end
        end

        function out=bitReverse(obj,in,bitReverseTable,FFTLength,stage)

            if stage==log2f(obj,FFTLength)
                out=double(bitReverseTable(in+1));
            else
                out=rem(fix(bitReverseTable(in+1)/2),2^(stage-1));
            end

        end
        function[table_h,table_f]=createBitReversTable(obj)
            table_h=bitrevorder(0:obj.pFFTLength/2-1);
            table_f=bitrevorder(0:obj.pFFTLength-1);
        end
    end



    methods(Access=protected)



        function result=spFind(obj,vector,condition,value)
            N=obj.pFFTLength;
            result=zeros(N,1);
            coder.varsize('result',[N,1]);
            index=1;
            switch condition
            case '=='
                for loop=1:length(vector)
                    if vector(loop)==value
                        result(index)=loop;
                        index=index+1;

                    end
                end
            case '<='
                for loop=1:length(vector)
                    if vector(loop)==value
                        result(index)=loop;
                        index=index+1;
                    end
                end
            end
            result=result(result>0);
        end
        function result=spFindFirst(obj,vector,condition,value)
            result=zeros(1,1);
            coder.varsize('result',[1,1]);
            index=1;
            switch condition
            case '=='
                for loop=1:length(vector)
                    if vector(loop)==value
                        result=loop;
                        break;
                    end
                end
            case '<='
                for loop=1:length(vector)
                    if vector(loop)==value
                        result=loop;
                        break;
                    end
                end
            end
        end
    end



    methods(Hidden)
        function logFFTOverflow(obj,X,Y,U,V,data_sign,data_wordLength,data_fractionLength,stage)
            outputType=fi(0,data_sign,data_wordLength,data_fractionLength,'RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction);
            minMaxOutput=range(outputType);
            minValue=min(minMaxOutput);
            maxValue=max(minMaxOutput);
            if X<minValue||X>maxValue||Y<minValue||Y>maxValue||U<minValue||U>maxValue||V<minValue||V>maxValue
                obj.pOverflowStage(stage)=1;
            end
        end
        function result=log2f(obj,data)
            result=log2(double(data));
        end

        function latency=waitCycle4dVld(obj,varargin)

            if nargin==3
                FFTLen=varargin{1};
                inVectSize=varargin{2};
            elseif nargin==2
                inVectSize=obj.pInputVectorSize;
                if isempty(inVectSize)
                    inVectSize=1;
                end
                FFTLen=varargin{1};
            else
                inVectSize=obj.pInputVectorSize;
                if isempty(inVectSize)
                    inVectSize=1;
                end
                FFTLen=obj.pFFTLength;
                if isempty(FFTLen)
                    FFTLen=obj.FFTLength;
                end
            end

            if strcmpi(obj.Architecture,'Streaming Radix 2^2')||obj.FFTLength<8
                latency=rx22Latency(obj,FFTLen,inVectSize)+bitReversalLatency(obj,FFTLen,inVectSize);
            elseif strcmpi(obj.Architecture,'Burst Radix 2')
                latency=rx2MinResLatency(obj,FFTLen);
            else
                latency=rx2Latency(obj,FFTLen)+bitReversalLatency(obj,FFTLen,inVectSize);
            end
        end

        function Latency=rx22Latency(obj,FFTLen,inputSize)

            delayToAllignTwdl=3;
            Rx2Latency=delayToAllignTwdl+13;
            SDF1Latency=6;
            SDF2Latency=5;
            SDNF1Latency=delayToAllignTwdl+6;
            SDNF2Latency=1;


            BITRIVERSEDIN=bitReversedInputCorrection(obj,inputSize,FFTLen);


            [totalSDF1Stage,totalSDF2Stage,totalSDNF1Stage,totalSDNF2Stage]=NoStages(obj,FFTLen,inputSize);

            Latency=0;
            firstBTFLatency=0;
            for loop=1:2:2*totalSDF1Stage
                if loop==1
                    Adjustment=0;
                else
                    Adjustment=5+inputSize-1;
                end
                firstBTFLatency=delayToAllignTwdl+(FFTLen/inputSize)/2^(loop)+SDF1Latency+Adjustment;
                Latency=Latency+firstBTFLatency;
            end

            secondBTFLatency=0;
            for loop=1:2:2*totalSDF2Stage
                secondBTFLatency=(FFTLen/inputSize)/2^(loop+1)+SDF2Latency;
                if secondBTFLatency<9
                    secondBTFLatency=9;
                end
                Latency=Latency+secondBTFLatency;
            end

            for i=1:totalSDNF1Stage
                Latency=Latency+SDNF1Latency;
            end

            for loop=1:totalSDNF2Stage
                Latency=Latency+SDNF2Latency;
            end

            if rem(totalSDF1Stage,(log2(FFTLen)/2))
                if inputSize==1
                    Latency=Latency+Rx2Latency;
                else
                    Latency=Latency+SDNF1Latency+1;
                end
            end

            Latency=Latency-FFTLen/inputSize+latencyAdj(obj,inputSize,FFTLen)+BITRIVERSEDIN+3;

        end

        function Latency=rx2Latency(obj,val)


            butterFlyLatency=6*(log2f(obj,val)-1)+8;

            if val==16
                pipeLineLatency=val/16+1;
            else
                pipeLineLatency=floor(val/16);
            end
            Latency=pipeLineLatency+butterFlyLatency;
        end

        function Latency=rx2MinResLatency(obj,FFTLen)
            stages=log2(FFTLen);
            btfPipeLine=10+1;
            rdwrDelay=6;
            IODelay=stages-1;
            SLCorrection=1;

            if FFTLen<=8&&~obj.BitReversedOutput
                BitNaturalOutputDelay=4;
            else
                BitNaturalOutputDelay=0;
            end

            if obj.BitReversedInput
                BitNaturalInputDelay=-2;
            else
                BitNaturalInputDelay=0;
            end
            Latency=FFTLen+(stages-1)*(FFTLen/2)+stages*(btfPipeLine+rdwrDelay)+IODelay+BitNaturalOutputDelay+BitNaturalInputDelay+SLCorrection;
        end

        function latency=bitReversedInputCorrection(obj,inputSize,FFTLen)
            if obj.BitReversedInput
                if inputSize==1||(FFTLen==inputSize)
                    latency=0;
                elseif inputSize==2&&FFTLen==4
                    latency=-1;
                elseif(inputSize==128&&FFTLen==256)||(inputSize==32&&FFTLen==64)||(inputSize==8&&FFTLen==16)
                    latency=-2;
                else
                    latency=-4;
                end
            else
                if inputSize==2&&FFTLen==4
                    latency=1;
                else
                    latency=0;
                end
            end
        end

        function correction=latencyAdj(obj,inputSize,FFTLen,varargin)
            if inputSize==1
                correction=0;
            elseif inputSize==2
                correction=-(ceil(log2(FFTLen)/2)-2);
            elseif inputSize==4
                if rem(log2(FFTLen),2)
                    correction=1-3*(log2(FFTLen)-3)/2;
                elseif FFTLen==4
                    correction=-8;
                else
                    correction=-9-3*(log2(FFTLen)-4)/2;
                end
            elseif inputSize==8
                if log2(FFTLen)==3
                    correction=2;
                elseif rem(log2(FFTLen),2)
                    correction=8-7*(log2(FFTLen)-3)/2;
                else
                    correction=-8-7*(log2(FFTLen)-4)/2;
                end

            elseif inputSize==16
                if log2(FFTLen)==4
                    correction=-7;
                elseif rem(log2(FFTLen),2)
                    correction=2-15*(log2(FFTLen)-5)/2;
                else
                    correction=-8-15*(log2(FFTLen)-6)/2;
                end
            elseif inputSize==32
                if log2(FFTLen)==5
                    correction=3;
                elseif rem(log2(FFTLen),2)
                    correction=33-31*(log2(FFTLen)-5)/2;
                else
                    correction=-7-31*(log2(FFTLen)-6)/2;
                end
            elseif inputSize==64
                if log2(FFTLen)==6
                    correction=-6;
                elseif rem(log2(FFTLen),2)
                    correction=3-63*(log2(FFTLen)-7)/2;
                else
                    correction=-7-63*(log2(FFTLen)-8)/2;
                end
            elseif inputSize==128
                if log2(FFTLen)==7
                    correction=4;
                elseif rem(log2(FFTLen),2)
                    correction=130-127*(log2(FFTLen)-7)/2;
                else
                    correction=-6-127*(log2(FFTLen)-8)/2;
                end
            elseif inputSize==256
                if log2(FFTLen)==8
                    correction=-5;
                elseif rem(log2(FFTLen),2)
                    correction=4-255*(log2(FFTLen)-9)/2;
                else
                    correction=-6-255*(log2(FFTLen)-10)/2;
                end
            else
                correction=0;

            end
        end

        function latency=bitReversalLatency(obj,FFTLen,inVect)
            if inVect==1
                if FFTLen==4
                    earlyRead=1;
                    earlyReadCycle=-2;
                elseif FFTLen<=32
                    earlyRead=0;
                    earlyReadCycle=0;
                else
                    earlyRead=1;
                    divisor=2^(floor((log2f(obj,FFTLen))/2));
                    earlyReadCycle=FFTLen/divisor;
                end
                latency=(~xor(obj.BitReversedOutput,obj.BitReversedInput))*(FFTLen-1-earlyRead*earlyReadCycle);
            else
                if xor(obj.BitReversedOutput,obj.BitReversedInput)
                    latency=0;
                else
                    if inVect==FFTLen
                        latency=0;
                    else
                        muxPipeline=log2(inVect)+log2(inVect);
                        latency=FFTLen/inVect+muxPipeline+3;
                    end
                end
            end
        end

        function[SDF1,SDF2,SDNF1,SDNF2]=NoStages(obj,FFTLen,DATA_VECSIZE)



            totalR4Stages=floor(log2(FFTLen)/2);
            MEMSize=floor(double(FFTLen)/double(2*DATA_VECSIZE));
            SDF1=0;
            SDF2=0;
            SDNF1=0;
            SDNF2=0;

            for i=1:totalR4Stages
                if MEMSize>0
                    SDF1=SDF1+1;
                else
                    SDNF1=SDNF1+1;
                end
                MEMSize=floor(MEMSize/2);
                if MEMSize>0
                    SDF2=SDF2+1;
                else
                    SDNF2=SDNF2+1;
                end
                MEMSize=floor(MEMSize/2);
            end
        end

        function warnIfOverflow(obj)
            stagesWithWarning=sum(obj.pOverflowStage);

            if stagesWithWarning>0&&obj.pOverflowFlag
                coder.internal.warning('dspshared:system:HDLFFTOverflow');
                obj.pOverflowFlag=false;
            end
        end

        function dispLatency(obj)
            coder.extrinsic('fprintf');
            fprintf('INFO: The FFT latency is %i calls to the step method.\n',int32(obj.getLatency()));
        end
    end
    methods(Static,Hidden)
        function status=isFeatureOn(feature)
            status=strcmpi(hdldspfeature(feature),'on');
        end

        function y=outputRR(obj,y,u)







            isFloat=false;

            if isfi(real(y))
                yType=numerictype(real(y));
            elseif isinteger(y)
                temp=fi(cast([],'like',y));
                yType=numerictype(temp);
            else
                yType=numerictype(class(real(y)));
                isFloat=true;
            end



            mathWordLength=64;


            if isFloat
                mathType=yType;
            else

                mathWordLength=yType.WordLength+1;

                if~obj.pNormalize
                    mathWordLength=mathWordLength+ceil(log2(obj.pFFTLength));
                end








                mathType=numerictype(yType,'WordLength',mathWordLength);
            end




            mathFiMath=fimath('OverflowAction','Wrap',...
            'RoundingMethod','Nearest',...
            'ProductMode','KeepLSB',...
            'ProductWordLength',mathWordLength,...
            'SumMode','KeepLSB',...
            'SumWordLength',mathWordLength);



            castFiMath=fimath('OverflowAction','Saturate',...
            'RoundingMethod','Nearest');


            growthFactor=fi(1,mathType,mathFiMath);
            if~obj.pNormalize
                growthFactor=fi(obj.pFFTLength,mathType,mathFiMath);
            end



            magURealMin=pra.range_query(real(u),'min');
            magURealMax=pra.range_query(real(u),'max');
            magUImagMin=pra.range_query(imag(u),'min');
            magUImagMax=pra.range_query(imag(u),'max');

            magURealMin=fi(magURealMin,mathType,mathFiMath);
            magURealMax=fi(magURealMax,mathType,mathFiMath);
            magUImagMin=fi(magUImagMin,mathType,mathFiMath);
            magUImagMax=fi(magUImagMax,mathType,mathFiMath);

            magURealMin=abs(magURealMin);
            magURealMax=abs(magURealMax);
            magUImagMin=abs(magUImagMin);
            magUImagMax=abs(magUImagMax);

            maxMagnitude=max([magURealMin,magURealMax,magUImagMin,magUImagMax]);


            maxMagnitude=growthFactor*maxMagnitude;


            lowerBound=fi(-maxMagnitude,yType,castFiMath);
            upperBound=fi(maxMagnitude,yType,castFiMath);


            pra.range_relationship(real(y)>=lowerBound);

            pra.range_relationship(real(y)<=upperBound);

            pra.range_relationship(imag(y)>=lowerBound);

            pra.range_relationship(imag(y)<=upperBound);
        end

    end

end

