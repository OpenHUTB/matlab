classdef(StrictDefaults)FIRDecimator<matlab.System




























































































%#codegen
%#ok<*EMCLS>




    properties(Nontunable,Constant,Hidden)


        MaxInputVectorSize=64;

        MinWordLength=2;

        MaxWordLength=128;

    end

    properties(Nontunable)


        DecimationFactor=2;




        Numerator=fir1(35,0.4);




        FilterStructure='Direct form systolic';



        NumCycles=1;

    end


    properties(Nontunable)






        RoundingMethod='Floor';






        OverflowAction='Wrap';





        CoefficientsDataType='Same word length as input';







        OutputDataType='Full precision';




        ResetInputPort(1,1)logical=false;




        HDLGlobalReset(1,1)logical=false;
    end




    properties(Nontunable,Hidden)



        NumeratorSource='Property';
    end
    properties(Constant,Hidden)


        FilterStructureSet=matlab.system.StringSet({...
        'Direct form systolic',...
        'Direct form transposed'});

        RoundingMethodSet=matlab.system.internal.RoundingMethodSet({...
        'Ceiling',...
        'Convergent',...
        'Floor',...
        'Nearest',...
        'Round',...
        'Zero'});

        OverflowActionSet=matlab.system.internal.OverflowActionSet;

        CoefficientsDataTypeSet=matlab.system.internal.DataTypeSet(...
        {...
        'Same word length as input',...
        matlab.system.internal.CustomDataType(...
        'Signedness',{'Signed','Unsigned'},...
        'Scaling',{'BinaryPoint','Unspecified'})...
        },...
        'ValuePropertyName','Numerator',...
        'HasDesignMinimum',false,...
        'HasDesignMaximum',false);

        OutputDataTypeSet=matlab.system.internal.DataTypeSet({...
        'Full precision',...
        'Same word length as input',...
        matlab.system.internal.CustomDataType('Signedness',{'Signed','Unsigned'})},...
        'HasDesignMinimum',false,...
        'HasDesignMaximum',false);
    end

    properties(Nontunable,Access=private)

        pRoundingMethod;
        pOverflowAction;
        pFilterCoefficientDT;
        pFilterOutDT;
        pOutputDT;
        pFullPrecisionOutDT;
        pInputVectorSize;
        pFimath;
        pUserFimath;
        pDecimationFactor;
        phFIR;
        pOutBuffer_size;
        phFIRf;

        phFIRp;
        pOneTapFilter;
        pDelayBalanceVector;


        pIsFilterComplex(1,1)logical=false;
        pUsePartlySerial(1,1)logical=false;
        pIsLthBand(1,1)logical;
        pSingleFIRFilter(1,1)logical=false;

    end
    properties(Access=private)

        pSimTime=1;
        pDlyLine;
        pDlyLineVld;
        pOutputReg;
        pVldOut;
        pAccReg;
        pState;
        pDout;
        pDvld;
        pDout1;
        pDvld1;
        pSampleCnt;
        pNumCycleCnt;
        pInputDT;
        pInputDly;
        pInputCnt;
        pLatencyBalanceReg;
        pValidIdx;
        pState2;
        pRdyCycleCnt;
        pRdyReg;
        pNumCycles;


        pResetStart(1,1)logical;
        pLatencyBalance(1,1)logical=false;
        pCoeffDTCheck(1,1)logical=true;
        pInputDlyVld(1,1)logical=false;
    end



    methods(Static)
        function helpFixedPoint
            matlab.system.dispFixptHelp('dsphdl.FIRDecimator',...
            {'RoundingMethod','OverflowAction',...
            'CoefficientsDataType','OutputDataType'});
        end

    end
    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={...
'DecimationFactor'...
            ,'Numerator'...
            ,'FilterStructure',...
            'NumCycles',...
            'RoundingMethod',...
            'OverflowAction',...
            'CoefficientsDataType',...
            'OutputDataType',...
'ResetInputPort'...
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
            if~coder.target('hdl')
                if nargin==4
                    coeffDT=varargin{1};
                    isInputComplex=varargin{2};
                    inputVectorSize=round(varargin{3});
                elseif nargin==3
                    coeffDT=varargin{1};
                    isInputComplex=varargin{2};
                    inputVectorSize=1;
                elseif nargin==2
                    coeffDT=varargin{1};
                    isInputComplex=false;
                    inputVectorSize=1;
                else
                    if~isnumerictype(obj.CoefficientsDataType)
                        coeffDT=numerictype('double');
                    else
                        coeffDT=obj.CoefficientsDataType;
                    end
                    isInputComplex=false;
                    inputVectorSize=1;
                end

                if isempty(coeffDT)
                    if~isnumerictype(obj.CoefficientsDataType)
                        coeffDT=numerictype('double');
                    else
                        coeffDT=obj.CoefficientsDataType;
                    end
                end

                if isempty(isInputComplex)
                    isInputComplex=false;
                end

                if isCoeffComplex(obj)
                    numerator=obj.Numerator;
                else
                    numerator=real(obj.Numerator);
                end

                decimFactor=double(obj.DecimationFactor);
                reshape_coeff=reshapeFilterCoef(obj,numerator,decimFactor);

                [LthBand,~]=dsphdl.FIRDecimator.isLthBandFilter(reshape_coeff,decimFactor);
                usePartlySerial=isPartlySerial(obj,inputVectorSize,LthBand,reshape_coeff);
                if inputVectorSize>decimFactor

                    accLatency=obj.getAccPipelineLen(inputVectorSize,decimFactor,coeffDT,usePartlySerial);

                    fcell=getFrameFIRFilters(obj,numerator);
                    [~,firfilterBankLatency]=getFrameFIRLatencyIdx(obj,fcell,...
                    coeffDT,isInputComplex,inputVectorSize,decimFactor);
                    latency=accLatency+firfilterBankLatency;
                else

                    if usePartlySerial

                        if isinf(obj.NumCycles)||obj.NumCycles>=length(numerator)
                            fcell=getPartlySerialFIRFilters(obj,numerator,true);
                            [firfilterBankLatency,~]=getPartlySerialLatency(obj,fcell,...
                            coeffDT,isInputComplex);
                            latency=(firfilterBankLatency-1)*obj.DecimationFactor;
                        else
                            accLatency=obj.getAccPipelineLen(inputVectorSize,decimFactor,coeffDT,usePartlySerial);

                            fcell=getPartlySerialFIRFilters(obj,numerator,false);
                            [firfilterBankLatency,~]=getPartlySerialLatency(obj,fcell,...
                            coeffDT,isInputComplex);
                            latency=accLatency+firfilterBankLatency+obj.NumCycles*(decimFactor-1);
                        end
                    else
                        accInputVectorSize=inputVectorSize;

                        if accInputVectorSize==1
                            accPipeline=decimFactor/accInputVectorSize+1;
                        else
                            if decimFactor==accInputVectorSize
                                accPipeline=decimFactor/accInputVectorSize+ceil(log2(accInputVectorSize));
                            else
                                accPipeline=decimFactor/accInputVectorSize+ceil(log2(accInputVectorSize))+2;
                            end
                        end



                        latency=getLatencyFilterBank(obj,coeffDT,numerator,decimFactor,inputVectorSize,isInputComplex)+...
                        accPipeline;
                    end
                end
            else
                latency=0;
            end



        end

    end


    methods(Static,Access=protected)
        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end

        function hide=isInactivePropertyImpl(obj,prop)

            show=true;
            switch prop
            case 'NumCycles'
                show=strcmp(obj.FilterStructure,'Direct form systolic');
            end
            hide=~show;
        end

        function header=getHeaderImpl

            text=sprintf(['FIR Decimator Filter real or complex input for HDL code generation.\n\n',...
            'Choose from Direct form systolic or Direct form transposed structures.\n',...
'All filter structure shares multipliers in symmetric or antisymmetric filters if possible.\n'...
            ,'Systolic structures make efficient use of Intel and Xilinx DSP blocks.\n']);
            header=matlab.system.display.Header('dsphdl.FIRDecimator',...
            'Title','FIR Decimator',...
            'Text',text,...
            'ShowSourceLink',false);

        end



        function groups=getPropertyGroupsImpl

            algorithmParameters=matlab.system.display.Section(...
            'Title','Filter parameters',...
            'PropertyList',{'Numerator','FilterStructure','DecimationFactor','NumCycles'});

            mainGroup=matlab.system.display.SectionGroup(mfilename('class'),...
            'TitleSource','Auto',...
            'Sections',algorithmParameters);

            rstPort=matlab.system.display.Section(...
            'Title','Initialize data path registers',...
            'PropertyList',{'ResetInputPort','HDLGlobalReset'});

            ctrlGroup=matlab.system.display.SectionGroup(...
            'Title','Control Ports',...
            'Sections',rstPort);

            dtGroup=matlab.system.display.internal.DataTypesGroup(mfilename('class'));

            groups=[mainGroup,dtGroup,ctrlGroup];
        end

    end
    methods(Static,Hidden)
        function[status,OneTabSubfilter]=isLthBandFilter(reshape_coeff,decimFactor)
            status=false;
            OneTabSubfilter=false(decimFactor,1);

            [numRow,~]=size(reshape_coeff);
            for loop=1:numRow
                oneTab=sum((reshape_coeff(loop,:)~=0));
                if oneTab==1
                    OneTabSubfilter(loop)=true;
                end
            end
            if sum(OneTabSubfilter)==1
                status=true;
            end
        end
    end

    methods(Access=protected)
        function num=getNumInputsImpl(obj)
            num=2;
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
            inputPortInd=inputPortInd+1;

            if obj.ResetInputPort
                varargout{inputPortInd}='reset';
            end
        end
        function num=getNumOutputsImpl(obj)
            num=2;

        end

        function varargout=getOutputNamesImpl(obj)

            varargout=cell(1,getNumOutputs(obj));
            outputPortInd=1;
            varargout{outputPortInd}='data';

            outputPortInd=outputPortInd+1;
            varargout{outputPortInd}='valid';
        end

        function[DT,VAR]=getInputDT(obj,data)

            if~isempty(data)

                if isnumerictype(data)
                    DT=data;
                    VAR=fi(0,DT);
                elseif isa(data,'embedded.fi')||isa(data,'Simulink.NumericType')||isa(data,'embedded.numerictype')
                    DT=numerictype(data);
                    VAR=fi(0,DT);
                elseif isinteger(data)
                    DT=numerictype(class(data));
                    VAR=fi(0,DT);
                elseif ischar(data)
                    DT=numerictype(data);
                    VAR=fi(0,DT);
                else
                    DT=numerictype(class(data));
                    VAR=cast(0,'like',data);
                end

            else
                DT=data;
            end
        end

        function varargout=getOutputDataTypeImpl(obj)
            dt1=propagatedInputDataType(obj,1);

            inputDT=getInputDT(obj,dt1);
            if isempty(dt1)
                varargout{1}=[];
            elseif~isempty(inputDT)
                [outputDT,~]=getOutputDT(obj,inputDT);
                varargout{1}=outputDT;
            else
                varargout{1}=[];
            end
            varargout{2}='logical';
        end

        function varargout=isOutputComplexImpl(obj)
            inputCmplx=propagatedInputComplexity(obj,1);

            if inputCmplx||isCoeffComplex(obj)
                varargout{1}=true;
            else
                varargout{1}=false;
            end
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

            inputSize=propagatedInputSize(obj,1);

            varargout{1}=ceil(inputSize(1)/obj.DecimationFactor);

            for ii=2:getNumOutputs(obj)
                varargout{ii}=1;
            end
        end

        function varargout=isInputDirectFeedthroughImpl(obj,varargin)



            for ii=1:nargout
                varargout{ii}=false;
            end
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.pRoundingMethod=obj.pRoundingMethod;
                s.pOverflowAction=obj.pOverflowAction;
                s.pFilterCoefficientDT=obj.pFilterCoefficientDT;
                s.pOutputDT=obj.pOutputDT;
                s.pFullPrecisionOutDT=obj.pFullPrecisionOutDT;
                s.pInputVectorSize=obj.pInputVectorSize;
                s.pFimath=obj.pFimath;
                s.pUserFimath=obj.pUserFimath;
                s.pDecimationFactor=obj.pDecimationFactor;
                s.pDlyLine=obj.pDlyLine;
                s.pAccReg=obj.pAccReg;
                s.pState=obj.pState;
                s.pDlyLineVld=obj.pDlyLineVld;
                s.pOutputReg=obj.pOutputReg;
                s.pVldOut=obj.pVldOut;
                s.pDout=obj.pDout;
                s.pDvld=obj.pDvld;
                s.pDout1=obj.pDout1;
                s.pDvld1=obj.pDvld1;
                s.phFIR=obj.phFIR;
                s.phFIRf=obj.phFIRf;
                s.phFIRp=obj.phFIRp;
                s.pOutBuffer_size=obj.pOutBuffer_size;
                s.pSimTime=obj.pSimTime;
                s.pInputDT=obj.pInputDT;
                s.pSampleCnt=obj.pSampleCnt;
                s.pIsFilterComplex=obj.pIsFilterComplex;
                s.pValidIdx=obj.pValidIdx;
                s.pInputDly=obj.pInputDly;
                s.pInputCnt=obj.pInputCnt;
                s.pLatencyBalance=obj.pLatencyBalance;
                s.pLatencyBalanceReg=obj.pLatencyBalanceReg;
                s.pOneTapFilter=obj.pOneTapFilter;
                s.pIsLthBand=obj.pIsLthBand;
                s.pUsePartlySerial=obj.pUsePartlySerial;
                s.pInputDlyVld=obj.pInputDlyVld;
                s.pDelayBalanceVector=obj.pDelayBalanceVector;
                s.pSingleFIRFilter=obj.pSingleFIRFilter;
                s.pNumCycleCnt=obj.pNumCycleCnt;
                s.pState2=obj.pState2;
                s.pRdyCycleCnt=obj.pRdyCycleCnt;
                s.pRdyReg=obj.pRdyReg;
                s.pNumCycles=obj.pNumCycles;
            end

        end



        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            removedProperty={};
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
            isInputComplex=propagatedInputComplexity(obj,1);
            dt1=propagatedInputDataType(obj,1);

            inputSize=getInputVectorSize(obj);
            decimStr=sprintf('x[%in]\n',obj.DecimationFactor);
            if isempty(dt1)
                icon=sprintf('%sFIR Decimator\nLatency = --',decimStr);
            elseif strcmpi(obj.FilterStructure,'Direct form systolic')||strcmpi(obj.FilterStructure,'Partly serial systolic')
                inputDT=getInputDT(obj,numerictype(dt1));
                coeffDT=getCoefficientsDT(obj,inputDT);
                icon=sprintf('%sFIR Decimator\nLatency = %d',decimStr,getLatency(obj,numerictype(coeffDT),isInputComplex,inputSize));
            else
                inputDT=getInputDT(obj,numerictype(dt1));
                coeffDT=getCoefficientsDT(obj,inputDT);
                icon=sprintf('%sFIR Decimator\nLatency = %d',decimStr,getLatency(obj,numerictype(coeffDT),isInputComplex,inputSize));
            end
        end
        function inputVectorSize=getInputVectorSize(obj)
            inputVectorSize=obj.pInputVectorSize;
        end

    end

    methods

        function obj=FIRDecimator(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','DSP_HDL_Toolbox'))
                    error(message('dsphdl:dsphdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','DSP_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:},'DecimationFactor','Numerator');
        end




        function set.FilterStructure(obj,value)
            obj.FilterStructure=value;
        end
        function set.Numerator(obj,value)
            validateattributes(value,...
            {'numeric'},...
            {'finite','nonempty','row'},...
            'FIRDecimator','Numerator');
            obj.Numerator=value;
        end
        function set.RoundingMethod(obj,val)
            validatestring(val,{'Ceiling','Convergent','Floor',...
            'Nearest','Round','Zero'},'FIRDecimator','Rounding mode');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            validatestring(val,{'Wrap','Saturate'},'FIRDecimator','Overflow Action');
            obj.OverflowAction=val;
        end
        function set.DecimationFactor(obj,value)
            validateattributes(value,{'double'},{'real','integer','scalar','finite','>=',2},'FIRDecimator','DecimationFactor');
            obj.DecimationFactor=value;
        end
        function set.NumCycles(obj,value)




            validateattributes(value,...
            {'numeric'},...
            {'scalar','positive'},...
            'FIRDecimator','NumCycles');
            if~isinf(value)
                validateattributes(value,...
                {'numeric'},...
                {'integer'},...
                'FIRDecimator','NumCycles');
            end
            obj.NumCycles=value;
        end
    end



    methods(Access=protected)
        function validatePropertiesImpl(obj)

            if~coder.target('hdl')
                decimFactor=obj.DecimationFactor;
                validateattributes(decimFactor,{'double'},{'real','integer','scalar','finite','>=',2},'FIRDecimator','DecimationFactor');
                numCycels=obj.NumCycles;




                validateattributes(numCycels,...
                {'numeric'},...
                {'scalar','positive'},...
                'FIRDecimator','NumCycles');
                if~isinf(numCycels)
                    validateattributes(numCycels,...
                    {'numeric'},...
                    {'integer'},...
                    'FIRDecimator','NumCycles');
                end
            end
        end
        function validateInputsImpl(obj,varargin)
            coder.extrinsic('dsphdlshared.internal.validateCoefDataType','gcb');








            if isempty(coder.target)||~eml_ambiguous_types
                inData=varargin{1};

                coeffDTCheck=getCoeffDTCheck(obj);
                if~obj.isInMATLABSystemBlock
                    blkName=class(obj);
                else
                    blkName=gcb;
                end



                if~coder.target('hdl')
                    validDataType={'numeric','embedded.fi','embedded.numerictype','Simulink.NumericType'};
                    validDimension={'vector','column'};
                    validateattributes(inData,validDataType,validDimension,'FIRDecimator','data');


                    obj.pInputVectorSize=length(inData);
                    if obj.pInputVectorSize>64
                        coder.internal.error('dsphdl:FIRDecim:InputVectSizeMax',blkName);
                    end
                    if obj.pInputVectorSize>obj.DecimationFactor&&...
                        mod(obj.pInputVectorSize,obj.DecimationFactor)~=0


                        coder.internal.error('dsphdl:FIRDecim:InputVectSizeMax',blkName);
                    end
                    if mod(obj.DecimationFactor,obj.pInputVectorSize)~=0&&...
                        mod(obj.pInputVectorSize,obj.DecimationFactor)~=0
                        coder.internal.error('dsphdl:FIRDecim:InputVectSizeMax',blkName);
                    end
                    if obj.pInputVectorSize>1&&(obj.NumCycles>1||isinf(obj.NumCycles))
                        coder.internal.error('dsphdl:FIRDecim:InvalidNumCycles4FrameInput',blkName);
                    end

                    validateBoolean(obj,varargin{:});
                end









                inputDT=getInputDT(obj,inData);
                dsphdlshared.internal.validateCoefDataType(blkName,coeffDTCheck,inputDT,obj.Numerator,obj.CoefficientsDataType,true,true,obj.isInMATLABSystemBlock);
            end
        end


        function flag=isInputComplexityMutableImpl(~,~)

            flag=true;
        end

        function validateBoolean(obj,varargin)
            validDimension={'scalar'};
            if isempty(coder.target)||~eml_ambiguous_types

                validateattributes(varargin{2},{'logical'},validDimension,'FIRDecimator','valid');
                if obj.ResetInputPort
                    validateattributes(varargin{3},{'logical'},validDimension,'FIRDecimator','reset');
                end
            end

        end

        function resetImpl(obj)
            if~coder.target('hdl')
                obj.pDlyLineVld(:)=false;
                obj.pDlyLine(:)=0;
                obj.pOutputReg(:)=0;
                obj.pVldOut(:)=false;
                obj.pAccReg(:)=0;
                obj.pSimTime=1;
                obj.pState(:)=0;
                obj.pDout(:)=0;
                obj.pDvld=false;
                obj.pDout1(:)=0;
                obj.pDvld1=false;
                obj.pResetStart=false;
                obj.pSampleCnt=0;
                obj.pInputDly(:)=0;
                obj.pInputCnt(:)=0;
                obj.pInputDlyVld=false;
                obj.pNumCycleCnt=0;
                obj.pState2=0;
                obj.pRdyCycleCnt=0;
                obj.pRdyReg=true;



                if~isempty(obj.phFIR)
                    reset(obj.phFIR);
                end
                if~isempty(obj.phFIRf)
                    for ii=1:1:length(obj.phFIRf)
                        reset(obj.phFIRf{ii});
                    end
                end
                if~isempty(obj.phFIRp)

                    for ii=1:1:length(obj.phFIRp)
                        reset(obj.phFIRp{ii});
                    end
                end
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
            coder.extrinsic('dsphdl.FIRDecimator.isLthBandFilter')


            if~isfloat(A)
                obj.pFimath=fimath('RoundingMethod','Floor','OverflowAction','Wrap');
                obj.pUserFimath=fimath('RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction);
            end
            [inputDT,~]=getInputDT(obj,A);
            obj.pInputDT=coder.const(inputDT);

            obj.pInputVectorSize=length(A);
            obj.pDecimationFactor=double(obj.DecimationFactor);
            obj.pRoundingMethod=obj.RoundingMethod;
            obj.pOverflowAction=obj.OverflowAction;
            obj.pFilterCoefficientDT=obj.CoefficientsDataType;
            obj.pIsFilterComplex=~isreal(A)&&isCoeffComplex(obj);
            if isinf(obj.NumCycles)||obj.NumCycles>=length(obj.Numerator)
                obj.pNumCycles=length(obj.Numerator);
            else
                obj.pNumCycles=obj.NumCycles;
            end


            if isCoeffComplex(obj)
                numerator=obj.Numerator;
            else
                numerator=real(obj.Numerator);
            end


            decimFactor=obj.pDecimationFactor;
            coeffTemplate=coder.const(getCoefficientsDT(obj,inputDT));
            obj.pInputDly=cast(zeros(obj.pDecimationFactor,1),'like',A);
            obj.pInputCnt=0;
            obj.pInputDlyVld=false;
            reshape_coeff=coder.const(reshapeFilterCoef(obj,numerator,decimFactor));
            isFilterComplex=~isreal(A)||~isreal(obj.Numerator);
            [isLthBand_tmp,oneTapFilter_tmp]=dsphdl.FIRDecimator.isLthBandFilter(reshape_coeff,decimFactor);
            isLthBand=coder.const(isLthBand_tmp);
            oneTapFilter=coder.const(oneTapFilter_tmp);
            obj.pOneTapFilter=oneTapFilter;
            obj.pIsLthBand=isLthBand;

            obj.pUsePartlySerial=coder.const(isPartlySerial(obj,obj.pInputVectorSize,obj.pIsLthBand,reshape_coeff));
            [obj.pOutputDT,fullPrecisionOutDT]=getOutputDT(obj,obj.pInputDT);
            obj.pFullPrecisionOutDT=fullPrecisionOutDT;
            obj.pSingleFIRFilter=(isinf(obj.NumCycles)||obj.NumCycles>=length(numerator))&&obj.pInputVectorSize==1;
            obj.pNumCycleCnt=0;
            if obj.pInputVectorSize<=obj.DecimationFactor
                if obj.pUsePartlySerial
                    fcell=getPartlySerialFIRFilters(obj,numerator,obj.pSingleFIRFilter,obj.pInputDT);
                    obj.phFIRp=fcell;

                    if~isnumerictype(fcell{1}.CoefficientsDataType)
                        coeffDT=fi(0,numerictype('double'));
                    else
                        coeffDT=fcell{1}.CoefficientsDataType;
                    end

                    isInputComplex=~isreal(A);
                    if~coder.target('hdl')
                        [~,delayBalanceVector_tmp]=getPartlySerialLatency(obj,fcell,coeffDT,isInputComplex);
                    else
                        delayBalanceVector_tmp=0;
                    end
                    delayBalanceVector=delayBalanceVector_tmp;
                    obj.pDelayBalanceVector=delayBalanceVector;
                    obj.pLatencyBalance=nnz(delayBalanceVector);




                    nonZeroCoeffV=getNonZeroCoeffFilter(obj,fcell,coeffDT);

                    if obj.pSingleFIRFilter
                        obj.pState=0;
                        obj.pSampleCnt=0;
                    else
                        numDelays=0;
                        for ii=1:decimFactor
                            if delayBalanceVector(ii)>0
                                numDelays=delayBalanceVector(ii);
                                break;
                            end
                        end

                        vldIdx=1;


                        for ii=1:decimFactor
                            if delayBalanceVector(ii)==0&&nonZeroCoeffV(ii)==true
                                vldIdx=ii;
                            end
                        end
                        if~coder.target('hdl')
                            if isFilterComplex
                                obj.pLatencyBalanceReg=complex(zeros(numDelays,1,'like',fi(0,fullPrecisionOutDT)));
                            else
                                obj.pLatencyBalanceReg=zeros(numDelays,1,'like',fi(0,fullPrecisionOutDT));
                            end
                        end
                        obj.pValidIdx=vldIdx;
                    end
                else
                    hFIR=dsphdl.private.AbstractFilterBank('FilterStructure',obj.FilterStructure,...
                    'FilterCoefficientSource','Property',...
                    'CoefficientsDataType',obj.CoefficientsDataType,...
                    'FilterOutputDataType','Full precision',...
                    'FilterCoefficients',reshapeFilterCoef(obj,numerator,decimFactor),...
                    'RoundingMethod',obj.RoundingMethod,...
                    'OverflowAction',obj.OverflowAction,...
                    'ResetInputPort',obj.ResetInputPort,...
                    'SymmetryOptimization',false);
                    obj.phFIR=hFIR;
                end




            else





                fcell=getFrameFIRFilters(obj,numerator,obj.pInputDT);
                obj.phFIRf=fcell;


                if~isnumerictype(fcell{1}.CoefficientsDataType)
                    coeffDT=fi(0,numerictype('double'));
                else
                    coeffDT=fcell{1}.CoefficientsDataType;
                end
                isInputComplex=~isreal(A);
                inputVectorSize=length(A);
                nonzerocoeffIdx=coder.const(getFrameFIRLatencyIdx(obj,fcell,...
                coeffDT,isInputComplex,inputVectorSize,decimFactor));
                obj.pValidIdx=nonzerocoeffIdx;
                [obj.pOutputDT,fullPrecisionOutDT]=getOutputDT(obj,obj.pInputDT);
                obj.pFullPrecisionOutDT=fullPrecisionOutDT;
            end


            if~coder.target('hdl')
                pipeLineLen=getAccPipelineLen(obj,obj.pInputVectorSize,decimFactor,numerictype(coeffTemplate),obj.pUsePartlySerial);
            else
                pipeLineLen=1;
            end
            partlySerialDelay=1;

            isOutputCmplx=~isreal(A)||isCoeffComplex(obj);


            if obj.DecimationFactor>=obj.pInputVectorSize
                outFrameSize=1;
            else
                outFrameSize=ceil(obj.pInputVectorSize/obj.DecimationFactor);
            end

            if isOutputCmplx
                obj.pAccReg=repmat(complex(fi(0,fullPrecisionOutDT,'RoundingMethod','Floor','OverflowAction','Wrap'),...
                fi(0,fullPrecisionOutDT,'RoundingMethod','Floor','OverflowAction','Wrap')),outFrameSize,1);
                if obj.pDecimationFactor<=obj.pInputVectorSize||obj.pUsePartlySerial
                    if obj.pUsePartlySerial
                        obj.pDlyLine=complex(fi(zeros(pipeLineLen+partlySerialDelay,1),obj.pOutputDT,'RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction),...
                        fi(zeros(pipeLineLen+partlySerialDelay,1),obj.pOutputDT,'RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction));
                    else
                        obj.pDlyLine=complex(fi(zeros(pipeLineLen*outFrameSize,1),obj.pOutputDT,'RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction),...
                        fi(zeros(pipeLineLen*outFrameSize,1),obj.pOutputDT,'RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction));
                    end
                else
                    obj.pDlyLine=complex(fi(zeros(pipeLineLen,1),fullPrecisionOutDT,'RoundingMethod','Floor','OverflowAction','Wrap'),...
                    fi(zeros(pipeLineLen,1),fullPrecisionOutDT,'RoundingMethod','Floor','OverflowAction','Wrap'));
                end
                obj.pOutputReg=repmat(complex(fi(0,obj.pOutputDT,'RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction),...
                fi(0,obj.pOutputDT,'RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction)),outFrameSize,1);
                obj.pDout=repmat(complex(fi(0,obj.pOutputDT,'RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction),...
                fi(0,obj.pOutputDT,'RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction)),outFrameSize,1);
                obj.pDout1=repmat(complex(fi(0,obj.pOutputDT,'RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction),...
                fi(0,obj.pOutputDT,'RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction)),outFrameSize,1);
            else
                obj.pAccReg=fi(0,fullPrecisionOutDT,'RoundingMethod','Floor','OverflowAction','Wrap');
                if obj.pDecimationFactor<=obj.pInputVectorSize||obj.pUsePartlySerial
                    if obj.pUsePartlySerial
                        obj.pDlyLine=fi(zeros(pipeLineLen+partlySerialDelay,1),obj.pOutputDT,'RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction);
                    else
                        obj.pDlyLine=fi(zeros(pipeLineLen*outFrameSize,1),obj.pOutputDT,'RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction);
                    end
                else
                    obj.pDlyLine=fi(zeros(pipeLineLen,1),fullPrecisionOutDT,'RoundingMethod','Floor','OverflowAction','Wrap');
                end
                obj.pOutputReg=repmat(fi(0,obj.pOutputDT,'RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction),outFrameSize,1);
                obj.pDout=repmat(fi(0,obj.pOutputDT,'RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction),outFrameSize,1);
                obj.pDout1=repmat(fi(0,obj.pOutputDT,'RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction),outFrameSize,1);
            end
            if obj.pUsePartlySerial
                obj.pDlyLineVld=false(pipeLineLen+partlySerialDelay,1);
            else
                obj.pDlyLineVld=false(pipeLineLen,1);
            end

            obj.pVldOut=false;
            obj.pDvld=false;
            obj.pDvld1=false;
            obj.pResetStart=false;
            obj.pSampleCnt=0;
            obj.pState=0;
            obj.pState2=0;
            obj.pRdyCycleCnt=0;
            obj.pRdyReg=true;
            obj.pSimTime=1;

        end

    end




    methods(Static,Hidden)

    end



    methods(Access=protected)
        function varargout=outputImpl(obj,varargin)

            varargout{1}=obj.pOutputReg;
            varargout{2}=obj.pVldOut;

        end

        function updateImpl(obj,varargin)
            if~coder.target('hdl')
                dataIn=varargin{1};
                validIn=varargin{2};
                if nargin==4
                    resetIn=varargin{3};
                else
                    resetIn=false;
                end
                dataIn_cast=fi(dataIn,obj.pInputDT);
                if obj.pResetStart
                    obj.pResetStart=false;
                end
                if resetIn
                    obj.pResetStart=true;
                    validIn=false;
                    dataIn_cast(:)=0;
                end

                resetIfTrue(obj);
                decimFactor=obj.pDecimationFactor;

                if obj.pInputVectorSize<=obj.pDecimationFactor
                    if obj.pUsePartlySerial
                        if obj.pSingleFIRFilter
                            if obj.pNumCycles>1
                                dropEarlyData(obj,validIn);
                                vldIn=obj.pInputDlyVld;
                            else
                                vldIn=validIn;
                            end
                            if obj.ResetInputPort
                                [filterOut,filterVldout]=...
                                step(obj.phFIRp{1},dataIn_cast,vldIn,resetIn);%#ok<*EMVDF>
                            else
                                [filterOut,filterVldout]=...
                                step(obj.phFIRp{1},dataIn_cast,vldIn);
                            end
                        else
                            fullPrecisionOutDT=obj.pFullPrecisionOutDT;
                            if isreal(obj.pDlyLine(1))
                                filterOutVal=fi(0,fullPrecisionOutDT);
                            else
                                filterOutVal=fi(complex(0),fullPrecisionOutDT);
                            end
                            firOut=zeros(decimFactor,1,'like',filterOutVal);
                            filterOut=zeros(decimFactor,1,'like',filterOutVal);
                            firVldout=false(decimFactor,1);
                            for ii=1:decimFactor


                                dIn=obj.pInputDly(ii);
                                if obj.ResetInputPort
                                    [firOut(ii),firVldout(ii)]=...
                                    step(obj.phFIRp{ii},dIn,obj.pInputDlyVld,resetIn);%#ok<*EMVDF>
                                else
                                    [firOut(ii),firVldout(ii)]=...
                                    step(obj.phFIRp{ii},dIn,obj.pInputDlyVld);
                                end
                            end
                            if obj.pLatencyBalance
                                for ii=1:decimFactor
                                    if obj.pDelayBalanceVector(ii)==0
                                        filterOut(ii)=firOut(ii);
                                    else
                                        filterOut(ii)=obj.pLatencyBalanceReg(end);
                                        if obj.pDelayBalanceVector(ii)==1
                                            obj.pLatencyBalanceReg(1)=firOut(ii);
                                        else
                                            obj.pLatencyBalanceReg(2:end)=obj.pLatencyBalanceReg(1:end-1);
                                            obj.pLatencyBalanceReg(1)=firOut(ii);
                                        end
                                    end
                                end
                            else
                                filterOut=firOut;
                            end

                            filterVldout=firVldout(obj.pValidIdx);
                            inputDlyLine(obj,validIn,dataIn_cast,decimFactor);
                        end
                    else

                        if obj.pNumCycles>1
                            dropEarlyData(obj,validIn);
                            vldIn=obj.pInputDlyVld;
                        else
                            vldIn=validIn;
                        end
                        if obj.ResetInputPort
                            [filterOut,filterVldout]=step(obj.phFIR,dataIn_cast,vldIn,resetIn);
                        else
                            [filterOut,filterVldout]=step(obj.phFIR,dataIn_cast,vldIn);
                        end
                    end
                else


                    frameSize=obj.pInputVectorSize/decimFactor;


                    fullPrecisionOutDT=obj.pFullPrecisionOutDT;
                    if isreal(obj.pDlyLine(1))
                        filterOutType=fi(0,fullPrecisionOutDT);
                    else
                        filterOutType=fi(complex(0),fullPrecisionOutDT);
                    end
                    filterOut=zeros(obj.pInputVectorSize,1,...
                    'like',filterOutType);
                    firVldout=false(decimFactor,1);
                    for ii=1:decimFactor


                        dIn=dataIn_cast(ii:decimFactor:end);
                        if obj.ResetInputPort
                            [firOut,firVldout(ii)]=...
                            step(obj.phFIRf{ii},dIn,validIn,resetIn);
                        else
                            [firOut,firVldout(ii)]=...
                            step(obj.phFIRf{ii},dIn,validIn);
                        end
                        for jj=1:frameSize
                            filterOut(((jj-1)*decimFactor)+ii)=firOut(jj);
                        end
                    end
                    filterVldout=firVldout(obj.pValidIdx);
                end

                if obj.pDecimationFactor<=obj.pInputVectorSize||obj.pUsePartlySerial

                    if obj.pUsePartlySerial
                        if obj.pSingleFIRFilter
                            [dOut,vOut]=downSample(obj,filterOut,filterVldout);
                            if obj.pNumCycles==1
                                obj.pOutputReg(:)=dOut;
                                obj.pVldOut=vOut;
                            else
                                obj.pOutputReg(:)=obj.pDout;
                                obj.pVldOut=obj.pDvld;
                                if vOut
                                    obj.pDout(:)=dOut;
                                else
                                    obj.pDout(:)=0;
                                end
                                obj.pDvld=vOut;
                            end
                        else


                            [dOut,vOut]=SumOfElem(obj,filterOut,filterVldout);
                            obj.pOutputReg(:)=obj.pDout;
                            obj.pVldOut=obj.pDvld;
                            if vOut
                                obj.pDout(:)=dOut;
                            else
                                obj.pDout(:)=0;
                            end
                            obj.pDvld=vOut;
                        end
                    else
                        [dOut,vOut]=SumOfElem(obj,filterOut,filterVldout);
                        obj.pOutputReg(:)=dOut;
                        obj.pVldOut=vOut;
                    end
                elseif obj.pInputVectorSize==1
                    [dOut,vOut]=integ(obj,filterOut,filterVldout);
                    if obj.DecimationFactor>=length(obj.Numerator)&&(obj.pNumCycles)>1
                        obj.pOutputReg(:)=obj.pDout1;
                        obj.pVldOut=obj.pDvld1;
                        obj.pDout1(:)=obj.pDout;
                        obj.pDvld1=obj.pDvld;
                        if vOut
                            obj.pDout(:)=dOut;
                        else
                            obj.pDout(:)=0;
                        end
                        obj.pDvld=vOut;
                    else
                        obj.pOutputReg(:)=obj.pDout;
                        obj.pVldOut=obj.pDvld;
                        if vOut
                            obj.pDout(:)=dOut;
                        else
                            obj.pDout(:)=0;
                        end
                        obj.pDvld=vOut;
                    end
                else
                    [dSOut,vSOut]=SumOfElem(obj,filterOut,filterVldout);
                    [dOut,vOut]=integ(obj,dSOut,vSOut);
                    obj.pOutputReg(:)=obj.pDout;
                    obj.pVldOut=obj.pDvld;
                    if vOut
                        obj.pDout(:)=dOut;
                    else
                        obj.pDout(:)=0;
                    end
                    obj.pDvld=vOut;
                end

                updateSimTime(obj);
            end
        end
        function inputDlyLine(obj,validIn,dataIn_cast,delayLen)

            if validIn&&obj.pRdyReg
                obj.pInputDly(1:end-1)=obj.pInputDly(2:end);
                obj.pInputDly(end)=dataIn_cast;
            end
            switch obj.pState
            case 0
                obj.pState=0;
                obj.pInputCnt(:)=0;
                obj.pInputDlyVld=false;
                if validIn&&obj.pRdyReg
                    obj.pState=1;
                    obj.pInputCnt(:)=1;
                end

            case 1
                obj.pState=1;
                obj.pInputDlyVld=false;
                if validIn&&obj.pRdyReg
                    if obj.pInputCnt(:)==delayLen-1
                        obj.pInputDlyVld=true;
                        obj.pInputCnt(:)=0;
                        obj.pState=0;
                    else
                        obj.pInputCnt(:)=obj.pInputCnt(:)+1;
                    end
                end
            otherwise
                obj.pState=0;
                obj.pInputCnt(:)=0;
                obj.pInputDlyVld=false;
            end
            switch obj.pState2
            case 0
                obj.pState2=0;
                obj.pRdyCycleCnt(:)=0;
                obj.pRdyReg=true;
                if validIn&&obj.pNumCycles>1
                    obj.pRdyCycleCnt(:)=obj.pRdyCycleCnt+1;
                    obj.pRdyReg=false;
                    obj.pState2=1;
                end
            case 1
                obj.pState2=1;
                obj.pRdyReg=false;
                if obj.pRdyCycleCnt(:)<obj.pNumCycles-1
                    obj.pRdyCycleCnt(:)=obj.pRdyCycleCnt+1;
                else
                    obj.pRdyCycleCnt(:)=0;
                    obj.pRdyReg=true;
                    obj.pState2=0;
                end

            otherwise
                obj.pState2=0;
                obj.pRdyCycleCnt(:)=0;
                obj.pRdyReg=true;
            end
        end
        function dropEarlyData(obj,validIn)
            switch obj.pState2
            case 0
                obj.pState2=0;
                obj.pRdyCycleCnt(:)=0;
                obj.pInputDlyVld=false;
                obj.pRdyReg=true;
                if validIn&&obj.pNumCycles>1
                    obj.pRdyCycleCnt(:)=obj.pRdyCycleCnt+1;
                    obj.pInputDlyVld=true;
                    obj.pRdyReg=false;
                    obj.pState2=1;
                end
            case 1
                obj.pState2=1;
                obj.pRdyReg=false;
                obj.pInputDlyVld=false;
                if obj.pRdyCycleCnt(:)<obj.pNumCycles-1
                    obj.pRdyCycleCnt(:)=obj.pRdyCycleCnt+1;
                else
                    obj.pRdyCycleCnt(:)=0;
                    obj.pRdyReg=true;
                    obj.pState2=0;
                end

            otherwise
                obj.pState2=0;
                obj.pRdyCycleCnt(:)=0;
                obj.pRdyReg=true;
                obj.pInputDlyVld=false;
            end
        end
        function[dOut,vOut]=SumOfElem(obj,filterIn,filterVldIn)
            decimFactor=obj.pDecimationFactor;
            inVectorSize=obj.pInputVectorSize;
            if decimFactor>=inVectorSize
                if filterVldIn
                    obj.pDlyLine(:)=[obj.pDlyLine(2:end);cast(sum(filterIn),'like',obj.pDlyLine)];
                    obj.pDlyLineVld(:)=[obj.pDlyLineVld(2:end);filterVldIn];
                else
                    obj.pDlyLine(:)=[obj.pDlyLine(2:end);cast(0,'like',obj.pDlyLine)];
                    obj.pDlyLineVld(:)=[obj.pDlyLineVld(2:end);false];
                end
                dOut=obj.pDlyLine(1);
                vOut=obj.pDlyLineVld(1);
            else
                outFrameSize=inVectorSize/decimFactor;
                filterInSamp=filterIn(1:decimFactor);



                for ii=1:outFrameSize
                    if filterVldIn
                        filterInSamp(:)=filterIn((decimFactor*(ii-1))+1:decimFactor*ii);
                        if isreal(filterInSamp)
                            filterval=0;
                        else
                            filterval=complex(0);
                        end
                        if isfloat(filterInSamp)
                            filterIn_sum=cast(filterval,'like',filterInSamp);
                        else
                            nt=numerictype(filterInSamp);
                            wl=nt.WordLength+ceil(log2(length(filterInSamp)));
                            filterIn_sum=fi(filterval,nt.SignednessBool,wl,nt.FractionLength);
                        end
                        filterIn_sum(:)=sum(filterInSamp);
                        filterIn_sum_cast=cast(filterIn_sum,'like',obj.pDlyLine);

                        obj.pDlyLine(:)=[obj.pDlyLine(2:end);filterIn_sum_cast];
                    else
                        obj.pDlyLine(:)=[obj.pDlyLine(2:end);cast(0,'like',obj.pDlyLine)];
                    end
                end

                if isscalar(obj.pDlyLineVld)
                    obj.pDlyLineVld=filterVldIn;
                else
                    obj.pDlyLineVld(:)=[obj.pDlyLineVld(2:end);filterVldIn];
                end





                dOut=obj.pDlyLine(1:outFrameSize);
                vOut=obj.pDlyLineVld(1);
                assert(islogical(vOut));
            end
        end

        function[dOut,vOut]=integ(obj,filterIn,filterVldIn)
            dOut=cast(0,'like',obj.pAccReg);
            vOut=false;
            if filterVldIn
                if obj.pSampleCnt==0
                    obj.pAccReg(:)=sum(filterIn);
                    obj.pSampleCnt=obj.pSampleCnt+obj.pInputVectorSize;


                else
                    obj.pAccReg(:)=cast(sum(filterIn),'like',obj.pAccReg(:))+obj.pAccReg(:);
                    if obj.pSampleCnt==obj.pDecimationFactor-obj.pInputVectorSize
                        obj.pSampleCnt=0;
                        dOut=obj.pAccReg;
                        vOut=true;
                    else
                        obj.pSampleCnt=obj.pSampleCnt+obj.pInputVectorSize;


                    end
                end
            end
        end
        function[dOut,vOut]=downSample(obj,filterOut,filterVldOut)
            dOut=cast(0,'like',filterOut);
            switch obj.pState
            case 0
                obj.pState=0;
                dOut(:)=0;
                vOut=false;
                obj.pSampleCnt=0;
                if filterVldOut
                    obj.pState=1;


                    obj.pSampleCnt=1;
                end
            case 1
                obj.pState=1;
                dOut(:)=0;
                vOut=false;
                if filterVldOut
                    if obj.pSampleCnt==obj.pDecimationFactor-1
                        obj.pSampleCnt=0;
                        dOut=filterOut;
                        vOut=filterVldOut;
                    else
                        obj.pSampleCnt=obj.pSampleCnt+1;
                    end
                end
            otherwise
                obj.pState=0;
                dOut(:)=0;
                vOut=false;
                obj.pSampleCnt=0;
            end

        end
        function resetIfTrue(obj)
            if obj.pResetStart
                resetImpl(obj);
            end
        end
    end





    methods(Access=protected)
        function latency=getLatencyFilterBank(obj,CoeffDT,Coeff,decimFactor,inputVectorSize,isInputComplex)
            if~(isnumerictype(CoeffDT)||isfloat(CoeffDT)||strcmpi(CoeffDT,'double')||strcmpi(CoeffDT,'single'))&&...
                ~isnumerictype(obj.CoefficientsDataType)
                coder.internal.error('dsphdl:FIRFilter:getLatencyCallWithoutInputDataType','dsphdl.FIRFilter');
            end
            if~isfloat(CoeffDT)
                coefficientsDataType=CoeffDT;
            else
                coefficientsDataType='Same word length as input';
            end
            hFIR=dsphdl.private.AbstractFilterBank('FilterStructure',obj.FilterStructure,...
            'FilterCoefficientSource',obj.NumeratorSource,...
            'CoefficientsDataType',coefficientsDataType,...
            'FilterOutputDataType',obj.OutputDataType,...
            'FilterCoefficients',reshapeFilterCoef(obj,Coeff,decimFactor),...
            'RoundingMethod',obj.RoundingMethod,...
            'OverflowAction',obj.OverflowAction,...
            'ResetInputPort',obj.ResetInputPort);
            latency=getLatency(hFIR,CoeffDT,reshapeFilterCoef(obj,Coeff,decimFactor),decimFactor,inputVectorSize,isInputComplex);
        end
        function[outputDT,fullPrecisionOutDT]=getOutputDT(obj,inputDT)
            coder.extrinsic('dsp.internal.FIRFilterPrecision');

            if isdouble(inputDT)
                outputDT=numerictype('double');
                fullPrecisionOutDT=numerictype('double');
            elseif issingle(inputDT)
                outputDT=numerictype('single');
                fullPrecisionOutDT=numerictype('single');
            else
                CoefficientDT=getCoefficientsDT(obj,inputDT);
                [fullPrecision,inputPrecision]=coder.const(@dsp.internal.FIRFilterPrecision,...
                cast(obj.Numerator,'like',CoefficientDT),inputDT);
                fullPrecisionOutDT=numerictype(fullPrecision.Signed,fullPrecision.WordLength,fullPrecision.FractionLength);
                if isnumerictype(obj.OutputDataType)
                    outputDT=obj.OutputDataType;
                elseif strcmpi(obj.OutputDataType,'Full precision')
                    outputDT=fullPrecisionOutDT;
                else
                    wordLength=inputPrecision.WordLength;
                    fractionLength=fullPrecision.FractionLength-(fullPrecision.WordLength-inputPrecision.WordLength);
                    signed=fullPrecision.SignednessBool;
                    outputDT=numerictype(signed,wordLength,fractionLength);

                end
            end
        end
        function status=isCoeffComplex(obj)
            if~isreal(obj.Numerator)&&any(imag(obj.Numerator))
                status=true;
            else
                status=false;
            end
        end

    end



    methods(Hidden)
        function coefficientsDT=getCoefficientsDT(obj,varargin)
            inputDT=varargin{end};

            if isnumerictype(inputDT)
                CoefficientsDT=obj.CoefficientsDataType;
                if isfloat(inputDT)
                    coefficientsDT=fi(0,inputDT);
                elseif isnumerictype(CoefficientsDT)
                    wordLength=CoefficientsDT.WordLength;
                    signedness=CoefficientsDT.SignednessBool;
                    if CoefficientsDT.isscalingunspecified
                        DT=fi(obj.Numerator,signedness,wordLength,'OverflowAction','Saturate','RoundingMethod','Nearest');
                        coefficientsDT=fi(0,DT.Signed,DT.WordLength,DT.FractionLength,'OverflowAction','Saturate','RoundingMethod','Nearest');
                    else
                        fractionLength=CoefficientsDT.FractionLength;
                        coefficientsDT=fi(0,signedness,wordLength,fractionLength,'OverflowAction','Saturate','RoundingMethod','Nearest');
                    end

                elseif any(obj.Numerator(:)<0)
                    coef=fi(obj.Numerator,1,inputDT.WordLength);
                    wordLength=coef.WordLength;
                    fractionLength=coef.FractionLength;
                    coefficientsDT=fi(0,1,wordLength,fractionLength,'OverflowAction','Saturate','RoundingMethod','Nearest');
                else
                    coef=fi(obj.Numerator,1,inputDT.WordLength);
                    wordLength=coef.WordLength;
                    fractionLength=coef.FractionLength;
                    coefficientsDT=fi(0,1,wordLength,fractionLength,'OverflowAction','Saturate','RoundingMethod','Nearest');
                end
            else
                if isa(inputDT,'single')
                    coefficientsDT=single(0);
                else
                    coefficientsDT=double(0);
                end
            end
        end
        function coefTable=reshapeFilterCoef(obj,Numerator,DecimationFactor)%#ok<INUSL> %, dataIn)

            numOfCoef=length(Numerator);
            zeroPadLen=DecimationFactor-mod(numOfCoef,DecimationFactor);
            if zeroPadLen==DecimationFactor
                coef_zeroPad=Numerator;
            else
                coef_zeroPad=[Numerator(:);zeros(zeroPadLen,1,'like',Numerator)];
            end

            NumTaps=length(coef_zeroPad)/DecimationFactor;
            coef_reshape=reshape(coef_zeroPad,DecimationFactor,NumTaps);
            coefTable=flipud(coef_reshape);

        end

        function fcell=getFrameFIRFilters(obj,numerator,inputDT)



            decimFactor=double(obj.DecimationFactor);

            filtercoefs=coder.const(reshapeFilterCoef(obj,numerator,decimFactor));





            if nargin==3
                if isfloat(inputDT)
                    coeffDT='Same word length as input';
                else
                    coeffDT=numerictype(getCoefficientsDT(obj,inputDT));
                end
            else
                coeffDT=obj.CoefficientsDataType;
            end
            numfilters=decimFactor;


            fcell=cell(numfilters,1);
            for ii=1:1:numfilters
                fcell{ii}=dsphdl.FIRFilter('FilterStructure',obj.FilterStructure,...
                'NumeratorSource','Property',...
                'CoefficientsDataType',coeffDT,...
                'OutputDataType','Full precision',...
                'Numerator',filtercoefs(ii,:),...
                'RoundingMethod',obj.RoundingMethod,...
                'OverflowAction',obj.OverflowAction,...
                'ResetInputPort',obj.ResetInputPort);

                fcell{ii}.setCoeffDTCheck(false);
            end
        end

        function fcell=getPartlySerialFIRFilters(obj,numerator,singlePartlySerial,inputDT)



            decimFactor=double(obj.DecimationFactor);







            if nargin==4
                if isfloat(inputDT)
                    coeffDT='Same word length as input';
                else
                    coeffDT=numerictype(getCoefficientsDT(obj,inputDT));
                end
            else
                coeffDT=obj.CoefficientsDataType;
            end

            if singlePartlySerial
                numfilters=1;
                fcell=cell(numfilters,1);
                filtercoefs=numerator;
                if isinf(obj.NumCycles)
                    numCycles=double(length(numerator));
                else
                    numCycles=double(obj.NumCycles);
                end
            else
                numfilters=decimFactor;


                fcell=cell(numfilters,1);
                filtercoefs=coder.const(reshapeFilterCoef(obj,numerator,decimFactor));
                numCycles=double(obj.NumCycles*decimFactor);
            end

            for ii=1:1:numfilters
                fcell{ii}=dsphdl.FIRFilter('FilterStructure','Partly serial systolic',...
                'NumeratorSource','Property',...
                'CoefficientsDataType',coeffDT,...
                'OutputDataType','Full precision',...
                'Numerator',filtercoefs(ii,:),...
                'RoundingMethod',obj.RoundingMethod,...
                'OverflowAction',obj.OverflowAction,...
                'ResetInputPort',obj.ResetInputPort,...
                'NumCycles',numCycles);

                fcell{ii}.setCoeffDTCheck(false);
            end
        end

        function pipeLineLen=getAccPipelineLen(obj,inputVectorSize,decimFactor,coeffDT,isPartlySerial)



            if inputVectorSize>1
                if decimFactor==inputVectorSize


                    pipeLineLen=ceil(log2(inputVectorSize))+1;
                elseif inputVectorSize>decimFactor


                    coeffs=obj.Numerator;
                    nonzeroPhase=true(decimFactor,1);
                    for ii=1:decimFactor


                        coeffs_thisPhase=fi(coeffs(ii:decimFactor:end),coeffDT);
                        if all(coeffs_thisPhase==0)
                            nonzeroPhase(ii)=false;
                        end
                    end
                    numNonzeroPhases=sum(nonzeroPhase,'double');
                    pipeLineLen=ceil(log2(numNonzeroPhases))+1;
                else
                    pipeLineLen=ceil(log2(inputVectorSize))+2;
                end
            elseif isPartlySerial
                coeffs=obj.Numerator;
                nonzeroPhase=true(decimFactor,1);
                for ii=1:decimFactor


                    coeffs_thisPhase=fi(coeffs(ii:decimFactor:end),coeffDT);
                    if all(coeffs_thisPhase==0)
                        nonzeroPhase(ii)=false;
                    end
                end
                numNonzeroPhases=sum(nonzeroPhase,'double');
                pipeLineLen=ceil(log2(numNonzeroPhases));
            else
                pipeLineLen=ceil(log2(decimFactor));
            end
        end

        function[nonzerocoeffIdx,firfilterBankLatency]=getFrameFIRLatencyIdx(obj,fcell,...
            coeffDT,isInputComplex,inputVectorSize,decimFactor)%#ok<INUSL>




            filterLatency=zeros(decimFactor,1);
            nonzerocoeffIdx=0;
            for ii=1:decimFactor
                filterLatency(ii)=getLatency(fcell{ii},coeffDT,fcell{ii}.Numerator,...
                isInputComplex,ceil(inputVectorSize/decimFactor));
                if any(fi(fcell{ii}.Numerator,numerictype(coeffDT))~=0)
                    nonzerocoeffIdx=ii;
                end
            end

            isLatencySame=(filterLatency==filterLatency(nonzerocoeffIdx));
            for ii=1:decimFactor
                if~isLatencySame(ii)&&any(fi(fcell{ii}.Numerator,numerictype(coeffDT))~=0)


                    coder.internal.error('dsphdl:FIRDecim:commutatorPhaseLatencyMismatch');
                end
            end
            firfilterBankLatency=filterLatency(nonzerocoeffIdx);
        end

        function[latency,latencyBalanceVector]=getPartlySerialLatency(obj,fcell,...
            coeffDT,isInputComplex)%#ok<INUSL>


            filterLatency=zeros(length(fcell),1);
            for ii=1:length(fcell)
                filterLatency(ii)=getLatency(fcell{ii},coeffDT,fcell{ii}.Numerator,...
                isInputComplex,1);
            end
            latency=max(filterLatency);



            filterLatency(filterLatency<=1)=latency;




            latencyBalanceVector=zeros(length(filterLatency),1);
            for ii=1:length(filterLatency)
                latencyBalanceVector(ii)=latency-filterLatency(ii);
            end
        end
        function nonzerocoeffIdx=getNonZeroCoeffIdx(obj,fcell,...
            coeffDT,decimFactor)%#ok<INUSL>

            nonzerocoeffIdx=1;
            for ii=1:decimFactor
                if any(fi(fcell{ii}.Numerator,numerictype(coeffDT))~=0)
                    nonzerocoeffIdx=ii;
                end
            end
        end
        function nonZeroCoeffV=getNonZeroCoeffFilter(obj,fcell,...
            coeffDT)%#ok<INUSL>

            nonZeroCoeffV=false(length(fcell),1);
            for ii=1:length(fcell)
                if any(fi(fcell{ii}.Numerator,numerictype(coeffDT)))
                    nonZeroCoeffV(ii)=true;
                end
            end
        end
        function status=isPartlySerial(obj,inputVectSize,LthBand,reshape_coeff)
            status=false;
            [~,col]=size(reshape_coeff);

            if(inputVectSize==1&&strcmpi(obj.FilterStructure,'Direct form systolic'))&&((obj.NumCycles>1)||(LthBand))&&col>1
                status=true;
            end
        end
        function setCoeffDTCheck(obj,value)

            obj.pCoeffDTCheck=value;
        end
        function value=getCoeffDTCheck(obj)

            value=obj.pCoeffDTCheck;
        end
    end
    methods(Access=protected)

        function updateSimTime(obj)
            obj.pSimTime=obj.pSimTime+1;
        end

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end
    end

end

