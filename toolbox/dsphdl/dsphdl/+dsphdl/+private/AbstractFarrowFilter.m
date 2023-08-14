classdef(Hidden,StrictDefaults)AbstractFarrowFilter<matlab.System





























































































%#codegen

    properties(Nontunable)



        Mode='Property';
    end



    properties(Nontunable)


        RateChange=147/160;
    end


    properties(Nontunable)


        Numerator=[-1/6,1/2,-1/3,0;1/2,-1,-1/2,1;-1/2,1/2,1,0;1/6,0,-1/6,0];
    end



    properties(Nontunable)



        FilterStructure='Direct form systolic';





        NumCycles=1;



        ResetInputPort(1,1)logical=false;



        HDLGlobalReset(1,1)logical=false;










        RoundingMethod='Floor';







        OverflowAction='Wrap';





        CoefficientsDataType='Same word length as input';















        FractionalDelayDataType=numerictype(0,18,15);







        MultiplicandDataType='Full precision';







        OutputDataType='Full precision';




    end


    properties(Hidden,Transient)
        ModeSet=matlab.system.StringSet({...
        'Property',...
        'Input port'});

    end


    properties(Constant,Hidden)

        ShowFutureProperties=false;


        FilterStructureSet=matlab.system.StringSet({...
        'Direct form systolic',...
        'Direct form transposed',...
        'Partly serial systolic'});





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
        'HasDesignMinimum',true,...
        'HasDesignMaximum',true);

        OutputDataTypeSet=matlab.system.internal.DataTypeSet({...
        'Full precision',...
        'Same as first input',...
        matlab.system.internal.CustomDataType('Signedness',{'Signed','Unsigned'})},...
        'HasDesignMinimum',true,...
        'HasDesignMaximum',true);










        FractionalDelayDataTypeSet=matlab.system.internal.DataTypeSet({...
        matlab.system.internal.CustomDataType(...
        'Signedness',{'Signed','Unsigned'},...
        'Scaling',{'BinaryPoint','Unspecified'})});

        MultiplicandDataTypeSet=matlab.system.internal.DataTypeSet({...
        'Full precision',...
        matlab.system.internal.CustomDataType(...
        'Signedness',{'Signed','Unsigned'},...
        'Scaling',{'BinaryPoint','Unspecified'})});

    end





    properties(Access=private)
        FIRFilter1;
        FIRFilter2;
        FIRFilter3;
        FIRFilter4;
        pFilterOrder;
        pInputDT;
        pFilterOutputHold;
        pFilterOutput;
        pSampleCount;
        pFracDelayAccum;
        pFracDelayOut;
        pReadyREG;
pNextSampleREG
        pReadyREGD;
        pValidREG;
        pSumProductCast;
        pOutputCast;
        pOutputDataREG;
        pOutputValidREG;
        pRisingEdgeReady;
        pDataPipeline;
        pValidPipeline;
        pReadyPipeline;
        pFilterValidREG;
        pDelayBalanceREG;
        pFIRDelay;
        pValidOutput;
        pReadyOutput;
        pFIRMaxDelay;
        pvalid;
        pready;
        pFilterArray;
        pRateChangeFi;
        pInputComplex;
        pSampleInAddr;
        pSampleOutAddr;
        pSampleNum;
        pSampleFIFO;
        pNextSample;
        pInterp;
        pNextFracDelay;
        pRateChangeREG;
        pRateChangeREGTwo;
        pPhaseChangeREG;
        pPhaseChange;
        pResetStart;
        pValidDelayBalance;
        pRstREG;
        pInitialize(1,1)logical=true;

    end

    properties(Access=private,Nontunable)
        pNumCycles;

        pIsFilterComplex(1,1)logical=false;
        pInputVectorSize;
    end

    methods
        function obj=AbstractFarrowFilter(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','DSP_HDL_Toolbox'))
                    error(message('dsp:dsphdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','DSP_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:});
        end
    end


    methods(Static,Access=protected)

        function header=getHeaderImpl


            header=matlab.system.display.Header('dsp.HDLFarrowRateConverter',...
            'ShowSourceLink',false,...
            'Title','Farrow Rate Converter');
        end

        function groups=getPropertyGroupsImpl

            algorithmParameters=matlab.system.display.Section(...
            'Title','Filter parameters',...
            'PropertyList',{'Mode','RateChange','Numerator','FilterStructure','NumberOfCycles'});

            mainGroup=matlab.system.display.SectionGroup(mfilename('class'),...
            'TitleSource','Auto',...
            'Sections',algorithmParameters);

            rstPort=matlab.system.display.Section(...
            'Title','Data path register initialization',...
            'PropertyList',{'ResetInputPort','HDLGlobalReset',});

            ctrlGroup=matlab.system.display.SectionGroup(...
            'Title','Control Ports',...
            'Sections',rstPort);

            dtGroup=matlab.system.display.internal.DataTypesGroup(mfilename('class'));

            groups=[mainGroup,dtGroup,ctrlGroup];

        end
    end

    methods(Access=protected)



        function validateInputsImpl(obj,varargin)


            if isempty(coder.target)||~eml_ambiguous_types



            end
        end

        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end

        function setupImpl(obj,varargin)

            if isempty(coder.target)||~eml_ambiguous_types

                dataIn=varargin{1};
                inputDT=getInputDT(obj,dataIn);
                numSize=size(obj.Numerator);
                obj.pFilterOrder=coder.const(numSize(1));
                obj.pInputDT=coder.const(inputDT);
                obj.pInputComplex=coder.const(~isreal(dataIn));

                obj.pFilterArray=cell(size(obj.Numerator,1),1);
                obj.pNumCycles=obj.NumCycles;
                obj.pInputVectorSize=length(dataIn);





                FilterArray=cell(size(obj.Numerator,1),1);
                FilterArrayPartlySerial=cell(size(obj.Numerator,1),1);



                if obj.pNumCycles>1
                    for ii=1:1:size(obj.Numerator,1)

                        FilterArrayPartlySerial{ii}=dsphdl.FIRFilter('Numerator',obj.Numerator(:,ii)',...
                        'FilterStructure','Partly serial systolic',...
                        'NumCycles',obj.pNumCycles,...
                        'RoundingMethod',obj.RoundingMethod,...
                        'OverflowAction',obj.OverflowAction,...
                        'CoefficientsDataType',obj.CoefficientsDataType,...
                        'ResetInputPort',obj.ResetInputPort,...
                        'HDLGlobalReset',obj.HDLGlobalReset,...
                        'OutputDataType','Full precision');

                        FilterArrayPartlySerial{ii}.setCoeffDTCheck(false);

                        if obj.ResetInputPort
                            setup(FilterArrayPartlySerial{ii},dataIn,true,false);
                        else
                            setup(FilterArrayPartlySerial{ii},dataIn,true);
                        end
                    end
                else
                    for ii=1:1:size(obj.Numerator,1)

                        FilterArray{ii}=dsphdl.FIRFilter('Numerator',obj.Numerator(:,ii)',...
                        'FilterStructure',obj.FilterStructure,...
                        'RoundingMethod',obj.RoundingMethod,...
                        'OverflowAction',obj.OverflowAction,...
                        'CoefficientsDataType',obj.CoefficientsDataType,...
                        'ResetInputPort',obj.ResetInputPort,...
                        'HDLGlobalReset',obj.HDLGlobalReset,...
                        'OutputDataType','Full precision');

                        FilterArray{ii}.setCoeffDTCheck(false);

                        if obj.ResetInputPort
                            setup(FilterArray{ii},dataIn,true,false);
                        else
                            setup(FilterArray{ii},dataIn,true);
                        end
                    end
                end

                if obj.pNumCycles>1
                    obj.pFilterArray=FilterArrayPartlySerial;
                else
                    obj.pFilterArray=FilterArray;
                end



                firOutput=cell(size(obj.Numerator,1),1);
                oldMSB=0;oldFraction=0;
                for ii=1:1:size(obj.Numerator,1)
                    if obj.ResetInputPort
                        [firOutput{ii},~]=output(obj.pFilterArray{ii},varargin{1},varargin{2},varargin{end});
                    else
                        [firOutput{ii},~]=output(obj.pFilterArray{ii},varargin{1:2});
                    end
                    if isa(firOutput{ii},'double')||isa(firOutput{ii},'single')
                        MSB=32;
                    else
                        MSB=firOutput{ii}.WordLength-firOutput{ii}.FractionLength;
                    end

                    if isa(firOutput{ii},'double')||isa(firOutput{ii},'single')
                        fraction=0;
                    else
                        fraction=firOutput{ii}.FractionLength;
                    end

                    if MSB>oldMSB
                        oldMSB=MSB;
                    end
                    if fraction>oldFraction
                        oldFraction=fraction;
                    end
                end

                if isa(firOutput{ii},'double')
                    firOutputT=0;
                    firOutputTH=0;
                elseif isa(firOutput{ii},'single')
                    firOutputT=single(0);
                    firOutputTH=single(0);
                else
                    firOutputT=fi(dataIn,firOutput{ii}.Signed,oldMSB+oldFraction,oldFraction,hdlfimath);
                    firOutputTH=fi(dataIn,firOutput{ii}.Signed,oldMSB+oldFraction,oldFraction,...
                    'RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction);
                end
                dataTypes=determineDataTypes(obj,dataIn,firOutputT,obj.pInputComplex);


                fracDelayDT=dataTypes.fracDelayDT;
                multiplicandDT=dataTypes.multiplicandDT;



                obj.pValidOutput=false(size(obj.Numerator,1),1);
                obj.pReadyOutput=true(size(obj.Numerator,1),1);
                obj.pSampleCount=uint8(1);
                obj.pFracDelayAccum=fi(0,0,fracDelayDT.FractionLength+1,fracDelayDT.FractionLength,hdlfimath);
                obj.pFracDelayOut=cast(0,'like',multiplicandDT);
                obj.pRateChangeREG=cast(0,'like',fracDelayDT);
                obj.pRateChangeREGTwo=cast(0,'like',fracDelayDT);
                obj.pPhaseChangeREG=false;
                obj.pPhaseChange=false;
                obj.pReadyREG=false;
                obj.pNextSampleREG=false;
                obj.pReadyREGD=false;
                obj.pValidREG=false;
                obj.pRisingEdgeReady=false;

                if~isreal(dataIn)
                    outDT=complex(dataTypes.outDT);
                    sumProdDT=complex(dataTypes.sumProdDT);
                else
                    outDT=(dataTypes.outDT);
                    sumProdDT=(dataTypes.sumProdDT);
                end
                if~isreal(dataIn)
                    obj.pSumProductCast=zeros(size(obj.Numerator,1),1,'like',sumProdDT);
                    obj.pOutputCast=complex(cast(0,'like',outDT));
                    obj.pFilterOutputHold=complex(zeros(size(obj.Numerator,1),1,'like',firOutputTH));
                    obj.pFilterOutput=complex(zeros(size(obj.Numerator,1),1,'like',firOutputT));
                    obj.pDataPipeline=complex((zeros(((size(obj.Numerator,1)-1)*4)+3,1,'like',outDT)));
                    obj.pValidPipeline=false(((size(obj.Numerator,1)-1)*4)+3,1);
                    obj.pReadyPipeline=false(size(obj.Numerator,1)+1,1);
                    obj.pFilterValidREG=false;
                else
                    obj.pSumProductCast=zeros(size(obj.Numerator,1),1,'like',sumProdDT);
                    obj.pOutputCast=cast(0,'like',outDT);
                    obj.pFilterOutputHold=zeros(size(obj.Numerator,1),1,'like',firOutputTH);
                    obj.pFilterOutput=zeros(size(obj.Numerator,1),1,'like',firOutputT);
                    obj.pDataPipeline=(zeros(((size(obj.Numerator,1)-1)*4)+3,1,'like',outDT));
                    obj.pValidPipeline=false(((size(obj.Numerator,1)-1)*4)+3,1);
                    obj.pReadyPipeline=false(size(obj.Numerator,1)+1,1);
                    obj.pFilterValidREG=false;
                end

                latency=zeros(1,size(obj.Numerator,1));

                if~isnumerictype(obj.CoefficientsDataType)
                    coeffDT=numerictype('double');
                else
                    coeffDT=obj.CoefficientsDataType;
                end

                for ii=1:1:size(obj.Numerator,1)
                    latency(ii)=getLatency(obj.pFilterArray{ii},coeffDT,...
                    obj.pFilterArray{ii}.Numerator,~isreal(dataIn)&&isCoeffComplex(obj)&&~isreal(obj.Numerator)&&any(imag(obj.Numerator)),obj.pInputVectorSize);
                end


                MinFIRLatency=min(latency);
                MaxFIRLatency=max(latency)+1;
                delayB=MaxFIRLatency-MinFIRLatency;

                if delayB==1
                    delayB=2;
                end


                obj.pValidDelayBalance=false(delayB,size(obj.Numerator,1));


                obj.pFIRDelay=zeros(1,size(obj.Numerator,1));

                for ii=1:1:size(obj.Numerator,1)
                    obj.pFIRDelay(ii)=MaxFIRLatency-latency(ii);
                end


                [~,ind]=max(latency(1:obj.pFilterOrder));
                obj.pFIRMaxDelay=ind;
                obj.pvalid=false;
                obj.pready=true;
                obj.pRateChangeFi=fi(obj.RateChange,1,fracDelayDT.WordLength,fracDelayDT.FractionLength);
            end
            if~isreal(dataIn)
                if~coder.target('hdl')
                    obj.pDelayBalanceREG=complex(zeros(delayB,size(obj.Numerator,1),'like',firOutputT));
                    obj.pSampleFIFO=complex(zeros(16,size(obj.Numerator,1),'like',firOutputT));
                else
                    obj.pDelayBalanceREG=complex(zeros(2,size(obj.Numerator,1),'like',firOutputT));
                    obj.pSampleFIFO=complex(zeros(16,size(obj.Numerator,1),'like',firOutputT));
                end
            else
                if~coder.target('hdl')
                    obj.pDelayBalanceREG=zeros(delayB,size(obj.Numerator,1),'like',firOutputT);
                    obj.pSampleFIFO=zeros(16,size(obj.Numerator,1),'like',firOutputT);
                else
                    obj.pDelayBalanceREG=zeros(2,size(obj.Numerator,1),'like',firOutputT);
                    obj.pSampleFIFO=zeros(16,size(obj.Numerator,1),'like',firOutputT);
                end
            end
            obj.pSampleInAddr=fi(0,0,4,0,'OverflowAction','Wrap','RoundingMethod','Floor');
            obj.pSampleOutAddr=fi(0,0,4,0,'OverflowAction','Wrap','RoundingMethod','Floor');
            obj.pSampleNum=fi(0,0,4,0,'OverflowAction','Wrap','RoundingMethod','Floor');
            obj.pNextSample=false;
            obj.pInterp=false;
            obj.pNextFracDelay=fi(0,0,fracDelayDT.FractionLength+1,fracDelayDT.FractionLength,'OverflowAction','Wrap','RoundingMethod','Floor','SumMode','KeepMSB','CastBeforeSum',true);
            obj.pResetStart=false;
            obj.pRstREG=false;
            obj.pInitialize=true;
        end

        function icon=getIconImpl(obj)

            icon=sprintf(['Farrow Rate Converter\nLatency:','12']);

        end


        function resetImpl(obj)

            obj.pFilterOutputHold(:)=0;
            obj.pFilterOutput(:)=0;
            obj.pSampleCount(:)=1;
            obj.pFracDelayAccum(:)=0;
            obj.pNextFracDelay(:)=0;
            obj.pFracDelayOut(:)=0;
            obj.pReadyREG=false;
            obj.pNextSampleREG=false;
            obj.pReadyREGD=false;
            obj.pValidREG=false;
            obj.pSumProductCast(:)=0;
            obj.pOutputCast(:)=0;
            obj.pOutputDataREG(:)=0;
            obj.pOutputValidREG(:)=false;
            obj.pRisingEdgeReady(:)=false;
            obj.pDataPipeline(:)=0;
            obj.pValidPipeline(:)=false;
            obj.pReadyPipeline(:)=false;
            obj.pFilterValidREG(:)=false;
            obj.pDelayBalanceREG(:,:)=0;
            obj.pValidOutput(:)=false;
            obj.pReadyOutput(:)=true;
            obj.pvalid=false;
            obj.pready=true;
            obj.pSampleInAddr(:)=0;
            obj.pSampleOutAddr(:)=0;
            obj.pSampleNum(:)=0;
            obj.pSampleFIFO(:)=0;
            obj.pNextSample=false;
            obj.pInterp=false;
            obj.pResetStart=false;
            obj.pValidDelayBalance(:,:)=false;
            obj.pRstREG=~obj.pInitialize;
            obj.pInitialize=false;

            for ii=1:1:size(obj.Numerator,1)
                reset(obj.pFilterArray{ii});
            end

        end



        function[varargout]=outputImpl(obj,varargin)

            if obj.pValidPipeline(end)
                varargout{1}=obj.pDataPipeline(end);
            else
                varargout{1}=cast(0,'like',obj.pDataPipeline(end));
            end

            varargout{2}=obj.pValidPipeline(end);

            if obj.NumCycles>1
                if obj.ResetInputPort
                    for ii=1:1:size(obj.Numerator,1)
                        [~,~,obj.pReadyOutput(ii)]=output(obj.pFilterArray{ii},varargin{1},varargin{2},varargin{end});
                    end
                else
                    for ii=1:1:size(obj.Numerator,1)
                        [~,~,obj.pReadyOutput(ii)]=output(obj.pFilterArray{ii},varargin{1},varargin{2});
                    end
                end
                varargout{3}=obj.pready&&obj.pReadyOutput(obj.pFIRMaxDelay)&&~obj.pRstREG;
            else
                varargout{3}=(obj.pready&&~obj.pRstREG);
            end
        end



        function updateImpl(obj,varargin)



            obj.pDataPipeline(2:end)=obj.pDataPipeline(1:end-1);
            obj.pValidPipeline(2:end)=obj.pValidPipeline(1:end-1);
            obj.pReadyPipeline(2:end)=obj.pReadyPipeline(1:end-1);

            if strcmpi(obj.Mode,'Input port')
                obj.pRateChangeFi(:)=obj.pRateChangeREGTwo;
                obj.pRateChangeREGTwo(:)=obj.pRateChangeREG;
                obj.pRateChangeREG(:)=varargin{3};

                obj.pPhaseChangeREG=obj.pPhaseChange;
                obj.pPhaseChange=obj.pRateChangeREGTwo~=obj.pRateChangeFi;
            else
                obj.pPhaseChangeREG=false;
                obj.pPhaseChange=false;
            end

            obj.pRstREG=false;

            if obj.ResetInputPort

                if varargin{end}
                    obj.pResetStart=true;
                end
                resetIfTrue(obj);

                [obj.pFracDelayOut(:),obj.pvalid,obj.pready,obj.pFilterOutputHold(:)]=sampleStepController(obj,obj.pValidOutput(obj.pFIRMaxDelay),varargin{end},obj.pDelayBalanceREG(1,:),obj.pPhaseChangeREG);
            else
                [obj.pFracDelayOut(:),obj.pvalid,obj.pready,obj.pFilterOutputHold(:)]=sampleStepController(obj,obj.pValidOutput(obj.pFIRMaxDelay),false,obj.pDelayBalanceREG(1,:),obj.pPhaseChangeREG);
            end



            obj.pSumProductCast(1)=obj.pFilterOutputHold(1);


            for ii=1:1:obj.pFilterOrder-1

                fracDMult=obj.pSumProductCast(ii)*obj.pFracDelayOut;
                fracDAdd=fracDMult+obj.pFilterOutputHold(ii+1);
                if ii==obj.pFilterOrder-1

                    obj.pOutputCast(:)=fracDAdd;
                else

                    obj.pSumProductCast(ii+1)=fracDAdd;
                end

            end
            obj.pDataPipeline(1)=obj.pOutputCast;
            obj.pValidPipeline(1)=obj.pvalid;
            obj.pReadyPipeline(1)=obj.pready;



            if obj.ResetInputPort
                for ii=1:1:size(obj.Numerator,1)
                    if obj.pNumCycles>1
                        [obj.pFilterOutput(ii),obj.pValidOutput(ii),obj.pReadyOutput(ii)]=step(obj.pFilterArray{ii},varargin{1},varargin{2},varargin{end});
                    else
                        [obj.pFilterOutput(ii),obj.pValidOutput(ii)]=step(obj.pFilterArray{ii},varargin{1},varargin{2},varargin{end});

                    end
                end
            else
                for ii=1:1:size(obj.Numerator,1)
                    if obj.pNumCycles>1
                        [obj.pFilterOutput(ii),obj.pValidOutput(ii),obj.pReadyOutput(ii)]=step(obj.pFilterArray{ii},varargin{1},varargin{2});
                    else
                        [obj.pFilterOutput(ii),obj.pValidOutput(ii)]=step(obj.pFilterArray{ii},varargin{1},varargin{2});
                    end
                end
            end


            if obj.pNumCycles==1
                for ii=1:1:obj.pFilterOrder
                    if obj.pValidOutput(ii)
                        obj.pDelayBalanceREG(end-1:-1:1,ii,:)=obj.pDelayBalanceREG(end:-1:2,ii,:);
                        obj.pDelayBalanceREG(obj.pFIRDelay(ii),ii,:)=obj.pFilterOutput(ii,:);
                    end
                end
            else
                for ii=1:1:obj.pFilterOrder
                    if obj.pFIRDelay(ii)>1
                        obj.pDelayBalanceREG(end-1:-1:1,ii,:)=obj.pDelayBalanceREG(end:-1:2,ii,:);
                    end
                    obj.pValidDelayBalance(end-1:-1:1,ii)=obj.pValidDelayBalance(end:-1:2,ii);
                    obj.pValidDelayBalance(obj.pFIRDelay(ii),ii)=obj.pValidOutput(ii);

                    if obj.pValidDelayBalance(1,ii)
                        if obj.pFIRDelay(ii)>1
                            obj.pDelayBalanceREG(1,ii)=obj.pDelayBalanceREG(2,ii);
                        end
                    end

                    if obj.pValidOutput(ii)
                        obj.pDelayBalanceREG(obj.pFIRDelay(ii),ii,:)=obj.pFilterOutput(ii,:);
                    end

                end
            end







            if obj.ResetInputPort&&varargin{end}
                obj.pValidPipeline(1:end)=false;
                obj.pValidOutput(:)=false;
            end

        end

        function num=getNumInputsImpl(obj)

            num=2;

            if strcmpi(obj.Mode,'Input port')
                num=num+1;
            end

            if obj.ResetInputPort
                num=num+1;
            end


        end

        function N=getNumOutputsImpl(obj)

            N=3;

        end

        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,obj.getNumInputs());
            varargout{1}='data';
            varargout{2}='valid';
            num=2;

            if strcmpi(obj.Mode,'Input port')
                num=num+1;
                varargout{num}='rate';
            end

            if strcmpi(obj.Mode,'Fractional delay')
                num=num+1;
                varargout{num}='delay';
            end
            if obj.ResetInputPort
                num=num+1;
                varargout{num}='reset';
            end


        end


        function varargout=getOutputNamesImpl(obj)
            varargout{1}='data';
            varargout{2}='valid';


            varargout{3}='ready';

        end

        function varargout=getOutputSizeImpl(obj)

            varargout=cell(1,nargout);
            for k=1:nargout-1
                varargout{k}=propagatedInputSize(obj,1);


            end
            varargout{end}=1;
        end



        function varargout=getOutputDataTypeImpl(obj)

            dt1=propagatedInputDataType(obj,1);

            if(~isempty(dt1))
                if ischar(dt1)
                    inputDT=eval([dt1,'(0)']);
                else
                    inputDT=fi(0,dt1);
                end
            end

            if isempty(coder.target)||~eml_ambiguous_types
                dataTypes=determineDataTypes(obj,inputDT,firOutput,obj.pInputComplex);
            end

            if isfi(dataTypes.outDT)
                varargout{1}=dataTypes.outDT.numerictype();
            else
                varargout{1}=class(dataTypes.outDT);
            end

            varargout{2}='logical';
            varargout{3}='logical';


        end



        function varargout=isOutputComplexImpl(obj,varargin)

            varargout{1}=propagatedInputComplexity(obj,1);
            varargout{2}=false;
            varargout{3}=false;

        end



        function dataTypes=determineDataTypes(obj,dataInDT,firOutputT,isComplex)

            [dataWL,dataFL,dataS]=dsphdlshared.hdlgetwordsizefromdata(dataInDT);



            outmath=fimath(...
            'OverflowAction',obj.OverflowAction,...
            'RoundingMethod',obj.RoundingMethod);



            if ischar(obj.FractionalDelayDataType)
                fracDT=eval([obj.FractionalDelayDataType,'(0)']);
            else
                fracDT=fi(obj.RateChange,obj.FractionalDelayDataType,hdlfimath);
            end

            [fracDelayWL,fracDelayFL,fracDelayS]=dsphdlshared.hdlgetwordsizefromdata(fracDT);


            if ischar(obj.MultiplicandDataType)
                multDT=fi(1,1,fracDelayWL,fracDelayWL-1,hdlfimath);
            else
                multDT=fi(1,obj.MultiplicandDataType);
            end
            [multiplicandWL,multiplicandFL,multiplicandS]=dsphdlshared.hdlgetwordsizefromdata(multDT);






            if isa(dataInDT,'single')
                multiplicandDT=single(0);
                fracDelayNT=numerictype(1,64);
                if obj.RateChange>=1
                    if obj.RateChange<2
                        fracDelayDT=fi(2,fracDelayNT,hdlfimath);
                    else
                        fracDelayDT=fi(obj.RateChange,fracDelayNT,hdlfimath);
                    end
                else
                    fracDelayDT=fi(1,fracDelayNT,hdlfimath);
                end
            elseif isa(dataInDT,'double')
                multiplicandDT=0;
                fracDelayNT=numerictype(1,64);
                if obj.RateChange>=1
                    if obj.RateChange<2
                        fracDelayDT=fi(2,fracDelayNT,hdlfimath);
                    else
                        fracDelayDT=fi(obj.RateChange,fracDelayNT,hdlfimath);
                    end
                else
                    fracDelayDT=fi(1,fracDelayNT,hdlfimath);
                end
            else
                multiplicandNT=numerictype(multiplicandS,multiplicandWL,multiplicandFL);


                if strcmpi(obj.FractionalDelayDataType.DataTypeMode,'Fixed-point: unspecified scaling')
                    if obj.RateChange>=1

                        if obj.RateChange<2
                            fracDelayDT=fi(2,obj.FractionalDelayDataType,hdlfimath);
                        else
                            fracDelayDT=fi(obj.RateChange,obj.FractionalDelayDataType,hdlfimath);
                        end
                    else
                        fracDelayDT=fi(1,obj.FractionalDelayDataType,hdlfimath);
                    end
                else
                    fracDelayNT=numerictype(fracDelayS,fracDelayWL,fracDelayFL);
                    if obj.RateChange>=1
                        if obj.RateChange<2
                            fracDelayDT=fi(2,fracDelayNT,hdlfimath);
                        else
                            fracDelayDT=fi(obj.RateChange,fracDelayNT,hdlfimath);
                        end
                    else
                        fracDelayDT=fi(1,fracDelayNT,hdlfimath);
                    end

                end

                if isnumerictype(obj.MultiplicandDataType)
                    multiplicandDT=fi(0,multiplicandNT,outmath);
                else
                    multiplicandDT=fi(0,strcmpi(fracDelayDT.Signedness,'Signed'),fracDelayDT.WordLength,fracDelayDT.FractionLength,outmath);

                end

            end

            if isempty(coder.target)||~eml_ambiguous_types

                outDTInit=0;

            end


            if isnumerictype(obj.OutputDataType)

                [outputWL,outputFL,outputS]=dsphdlshared.hdlgetwordsizefromtype(obj.OutputDataType);
                outNT=numerictype(outputS,outputWL,outputFL);
            else

                if~(isa(dataInDT,'single')||isa(dataInDT,'double'))
                    [outputWL,outputFL,outputS]=dsphdlshared.hdlgetwordsizefromdata(dataInDT);
                    outNT=numerictype(outputS,outputWL,outputFL);

                end
            end
            if isa(dataInDT,'single')
                outDT=single((outDTInit));
                sumProdDT=single((outDTInit));
            elseif isa(dataInDT,'double')
                outDT=((outDTInit));
                sumProdDT=((outDTInit));
            else
                outDT=fi(outDTInit,outNT,outmath);
                if outputS==0
                    outputWL=outputWL+1;
                end
                sumProdNT=numerictype(1,outputWL,outputFL);
                sumProdDT=fi(outDTInit,sumProdNT,outmath);
            end
            dataTypes=struct(...
            'sumProdDT',sumProdDT,...
            'fracDelayDT',fracDelayDT,...
            'multiplicandDT',multiplicandDT,...
            'outDT',outDT);

        end

        function DT=getInputDT(obj,data)%#ok<INUSL>
            if isnumerictype(data)
                DT=data;
            elseif isa(data,'embedded.fi')
                DT=numerictype(data);
            elseif isinteger(data)
                DT=numerictype(class(data));
            elseif ischar(data)

                DT=numerictype(data);

            else
                if isa(data,'double')
                    DT=numerictype('double');
                else
                    DT=numerictype('single');
                end
            end
        end




        function varargout=isOutputFixedSizeImpl(obj)
            varargout{1}=true;
            varargout{2}=true;
            varargout{3}=true;

        end


        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.FIRFilter1=obj.FIRFilter1;
                s.FIRFilter2=obj.FIRFilter2;
                s.FIRFilter3=obj.FIRFilter3;
                s.FIRFilter4=obj.FIRFilter4;
                s.pFilterOrder=obj.pFilterOrder;
                s.pInputDT=obj.pInputDT;
                s.pFilterOutputHold=obj.pFilterOutputHold;
                s.pFilterOutput=obj.pFilterOutput;
                s.pSampleCount=obj.pSampleCount;
                s.pFracDelayAccum=obj.pFracDelayAccum;
                s.pNextFracDelay=obj.pNextFracDelay;
                s.pFracDelayOut=obj.pFracDelayOut;
                s.pReadyREG=obj.pReadyREG;
                s.pNextSampleREG=obj.pNextSampleREG;
                s.pReadyREGD=obj.pReadyREGD;
                s.pValidREG=obj.pValidREG;
                s.pSumProductCast=obj.pSumProductCast;
                s.pOutputCast=obj.pOutputCast;
                s.pOutputDataREG=obj.pOutputDataREG;
                s.pOutputValidREG=obj.pOutputValidREG;
                s.pRisingEdgeReady=obj.pRisingEdgeReady;
                s.pDataPipeline=obj.pDataPipeline;
                s.pValidPipeline=obj.pValidPipeline;
                s.pReadyPipeline=obj.pReadyPipeline;
                s.pFilterValidREG=obj.pFilterValidREG;
                s.pDelayBalanceREG=obj.pDelayBalanceREG;
                s.pFIRDelay=obj.pFIRDelay;
                s.pValidOutput=obj.pValidOutput;
                s.pFIRMaxDelay=obj.pFIRMaxDelay;
                s.pvalid=obj.pvalid;
                s.pready=obj.pready;
                s.pFilterArray=obj.pFilterArray;
                s.pRateChangeFi=obj.pRateChangeFi;
                s.pInputComplex=obj.pInputComplex;
                s.pRateChangeREG=obj.pRateChangeREG;
                s.pRateChangeREGTwo=obj.pRateChangeREGTwo;
                s.pPhaseChange=obj.pPhaseChange;
                s.pPhaseChangeREG=obj.pPhaseChangeREG;
                s.pSampleNum=obj.pSampleNum;
                s.pSampleInAddr=obj.pSampleInAddr;
                s.pSampleOutAddr=obj.pSampleOutAddr;
                s.pSampleFIFO=obj.pSampleFIFO;
                s.pNextSample=obj.pNextSample;
                s.pInterp=obj.pInterp;
                s.pNextFracDelay=obj.pNextFracDelay;
                s.pIsFilterComplex=obj.pIsFilterComplex;
                s.pInputVectorSize=obj.pInputVectorSize;
                s.pValidDelayBalance=obj.pValidDelayBalance;
                s.pNumCycles=obj.pNumCycles;
                s.pRstREG=obj.pRstREG;

            end
        end

        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end


        function hide=isInactivePropertyImpl(obj,prop)
            hide=false;
            switch prop
            case 'RateChange'
                if strcmpi(obj.Mode,'Input port')
                    hide=true;
                end
            case 'NumberOfCycles'
                if strcmpi(obj.FilterStructure,'Direct form systolic')||strcmpi(obj.FilterStructure,'Direct form transposed')
                    hide=true;
                end
            end
        end

        function resetIfTrue(obj)
            if obj.pResetStart
                resetImpl(obj);
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




    methods(Static,Access=protected)
        function isVisible=showSimulateUsingImpl

            isVisible=true;
        end
    end

    methods(Access=protected)
        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

        function flag=isInputComplexityMutableImpl(~,~)

            flag=true;
        end
    end



    methods(Access=private)

        function[fracDelay,valid,ready,dataOut]=sampleStepController(obj,validIn,resetIn,dataIn,resetPhase)
%#codegen

            ratewl=obj.pRateChangeFi.WordLength;
            ratefl=obj.pRateChangeFi.FractionLength;
            if ratewl>ratefl
                rateChangeInteger=bitsliceget(obj.pRateChangeFi,ratewl,ratefl+1);
                rateChangeFraction=fi(reinterpretcast(bitsliceget(obj.pRateChangeFi,ratefl,1),numerictype(0,ratefl,ratefl)),0,ratefl+1,ratefl,hdlfimath);
            end
            currentFracAccum=fi(0,0,ratefl+1,ratefl,hdlfimath);


            if bitset(obj.pFracDelayAccum,ratefl+1,0)>fi(0.99999998,0,ratefl,ratefl,hdlfimath)||resetPhase
                currentFracAccum(:)=0;
            else
                currentFracAccum(:)=bitset(obj.pFracDelayAccum,ratefl+1,0);
            end

            fracDelay=fi((fi(1,0,ratefl+1,ratefl)-currentFracAccum),0,ratefl+1,ratefl,hdlfimath);



            readyRST=(~obj.pRisingEdgeReady)&&obj.pFracDelayAccum(:)>fi(0.99999998,0,ratefl,ratefl,hdlfimath)&&obj.pReadyREGD;

            if rateChangeInteger==0
                valid=obj.pReadyREG&&~readyRST;
            else
                valid=obj.pValidREG&&validIn;

            end


            if rateChangeInteger==0
                ready=~obj.pReadyREG&&obj.pSampleNum<=12;
            else
                ready=true;
            end

            obj.pNextFracDelay(:)=fi(currentFracAccum,0,ratefl+1,ratefl,hdlfimath)+fi(rateChangeFraction,0,ratefl+1,ratefl,hdlfimath);
            if obj.pNextFracDelay(:)>fi(0.99999998,0,ratefl+1,ratefl,hdlfimath)
                countCompare=fi(rateChangeInteger+1,0,8,0,hdlfimath);
            else
                countCompare=fi(rateChangeInteger,0,8,0,hdlfimath);
            end

            if validIn&&~(obj.pSampleCount==countCompare)
                obj.pValidREG=false;
            elseif(obj.pSampleCount==countCompare&&validIn)
                obj.pValidREG=true;
            end


            if readyRST
                obj.pReadyREG=false;
            end

            nextSample=readyRST;

            if validIn
                obj.pRisingEdgeReady=false;
            else
                obj.pRisingEdgeReady=(obj.pFracDelayAccum(:)>fi(0.99999998,0,ratefl,ratefl,hdlfimath))&&obj.pReadyREGD;

            end


            if(obj.pSampleCount==countCompare&&validIn&&~(rateChangeInteger==0))||((obj.pReadyREG)&&(rateChangeInteger==0)&&~readyRST)
                obj.pFracDelayAccum(:)=currentFracAccum+rateChangeFraction;
            end


            if obj.pSampleCount==countCompare&&validIn
                obj.pSampleCount(:)=1;
            elseif countCompare>1&&validIn
                obj.pSampleCount(:)=obj.pSampleCount+1;
            end

            interp=rateChangeInteger==0;

            if~interp
                dataOut=dataIn;
            else


                dataOut=obj.pSampleFIFO(obj.pSampleOutAddr+1,:);

                obj.pReadyREGD=obj.pReadyREG;
                if~obj.pReadyREG&&obj.pSampleNum>1
                    obj.pReadyREG=true;

                end

                if validIn
                    obj.pSampleFIFO(obj.pSampleInAddr+1,:)=dataIn;
                    obj.pSampleInAddr(:)=obj.pSampleInAddr+1;
                end

                if xor(validIn,obj.pNextSampleREG)
                    if obj.pNextSampleREG
                        obj.pSampleNum(:)=obj.pSampleNum-1;
                    else
                        obj.pSampleNum(:)=obj.pSampleNum+1;
                    end
                end

                if nextSample
                    obj.pSampleOutAddr(:)=obj.pSampleOutAddr+1;
                end
                obj.pNextSampleREG=nextSample;
            end
            if resetPhase
                obj.pReadyREG=false;

                if obj.pSampleNum(:)>0
                    obj.pNextSampleREG=true;
                end

                obj.pValidREG=false;
                obj.pSampleCount(:)=1;
            end

            if resetIn
                obj.pSampleCount(:)=1;
                obj.pFracDelayAccum(:)=0;
                obj.pReadyREG=false;
                obj.pValidREG=false;
            end
        end
    end






end

