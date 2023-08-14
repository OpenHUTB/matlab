classdef(StrictDefaults)FIRInterpolator<matlab.System
















































































































%#codegen
%#ok<*EMCLS>




    properties(Nontunable,Constant,Hidden)


        MaxInputVectorSize=64;

        MinWordLength=2;

        MaxWordLength=128;

    end

    properties(Nontunable)


        InterpolationFactor=2;




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
        pInputVectorSize;
        pFimath;
        pUserFimath;
        pInterpolationFactor;
        pOutBuffer_size;
        pInputDT;
        pInputSize;
        pNumCycles;
        pSerializationFactor;
        pSharingCountReached;

        pIsFilterComplex(1,1)logical=false;
        pInterleaving;
    end
    properties(Access=private)

        pSimTime=1;
        pDlyLine;
        pDlyLineVld;
        pOutputReg;
        pVldOut;
        pRdyOut;
        pState;
        pDout;
        pDvld;
        pFilterArray;
        pFilterOrder;
        pFilterValidREG;
        pDelayBalanceREG;
        pFIRDelay;
        pFilterOutput;
        pValidOutput;
        pFIRMaxDelay;
        pSharingCounter;
        pSharingMUX;
        pOutputSharing;
        pReadyOutput;
        pSharingMUXConst;
        pSharingCountConst;
        pValidDelayBalance;
        sharingCount;
        pReadyState;
        pRdyReg;
        pSavedData;
        pSavedDataVld;
        resetCount;
        resetCountEn;
        rstREG;
        pTransientPad(1,1)logical=false;
        validLastPhase;
        pSubLength;


        pResetStart(1,1)logical;
        pCoeffDTCheck(1,1)logical=true;
        pInitialize(1,1)logical=true;



    end



    methods(Static)
        function helpFixedPoint
            matlab.system.dispFixptHelp('dsphdl.FIRInterpolator',...
            {'RoundingMethod','OverflowAction',...
            'CoefficientsDataType','OutputDataType'});
        end

    end
    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={...
'InterpolationFactor'...
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
            if~isnumerictype(obj.CoefficientsDataType)
                coeffDT=numerictype('double');
            else
                coeffDT=obj.CoefficientsDataType;
            end
            numerator=coder.const(reshapeFilterCoef(obj,obj.Numerator,obj.InterpolationFactor));

            FilterArray=cell(obj.InterpolationFactor,1);

            for ii=1:1:obj.InterpolationFactor

                FilterArray{ii}=dsphdl.FIRFilter('Numerator',numerator(ii,:),...
                'FilterStructure',obj.FilterStructure,...
                'RoundingMethod',obj.RoundingMethod,...
                'OverflowAction',obj.OverflowAction,...
                'CoefficientsDataType',obj.CoefficientsDataType,...
                'ResetInputPort',obj.ResetInputPort,...
                'HDLGlobalReset',obj.HDLGlobalReset,...
                'OutputDataType',obj.OutputDataType);

                FilterArray{ii}.setCoeffDTCheck(false);

            end

            latencies=zeros(obj.InterpolationFactor,1);
            for ii=1:1:obj.InterpolationFactor
                latencies(ii)=getLatency(FilterArray{ii},coeffDT,...
                FilterArray{ii}.Numerator,isInputComplex,inputVectorSize);
            end
            latency=max(latencies)+1;

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

            text=sprintf(['FIR Interpolator Filter real or complex input for HDL code generation.\n\n',...
            'Choose from Direct form systolic or Direct form transposed structures.\n',...
'All filter structure shares multipliers in symmetric or antisymmetric filters if possible.\n'...
            ,'Systolic structures make efficient use of Intel and Xilinx DSP blocks.\n']);
            header=matlab.system.display.Header('dsphdl.FIRInterpolator',...
            'Title','FIR Interpolator',...
            'Text',text,...
            'ShowSourceLink',false);

        end



        function groups=getPropertyGroupsImpl

            algorithmParameters=matlab.system.display.Section(...
            'Title','Filter parameters',...
            'PropertyList',{'Numerator','FilterStructure','InterpolationFactor','NumCycles'});

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
            num=3;

        end

        function varargout=getOutputNamesImpl(obj)

            varargout=cell(1,getNumOutputs(obj));
            outputPortInd=1;
            varargout{outputPortInd}='data';

            outputPortInd=outputPortInd+1;
            varargout{outputPortInd}='valid';

            outputPortInd=outputPortInd+1;
            varargout{outputPortInd}='ready';

        end

        function[DT,VAR]=getInputDT(obj,data)
            if isnumerictype(data)
                DT=data;
                VAR=fi(0,DT);
            elseif isa(data,'embedded.fi')
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

        end

        function varargout=getOutputDataTypeImpl(obj)
            dt1=propagatedInputDataType(obj,1);

            inputDT=getInputDT(obj,dt1);
            if isempty(dt1)
                varargout{1}=[];
            elseif~isempty(inputDT)
                if isempty(coder.target)||~eml_ambiguous_types
                    [outputDT]=getOutputDT(obj,inputDT);
                    varargout{1}=outputDT;
                end
            else
                varargout{1}=[];
            end

            varargout{2}='logical';
            varargout{3}='logical';
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

            if inputSize(1)>1||obj.NumCycles==1
                varargout{1}=[inputSize(1)*obj.InterpolationFactor,1];


            else
                if obj.NumCycles>=obj.InterpolationFactor&&strcmpi(obj.FilterStructure,'Direct form systolic')
                    varargout{1}=1;
                else
                    if strcmpi(obj.FilterStructure,'Direct form systolic')
                        varargout{1}=[ceil(obj.InterpolationFactor/obj.NumCycles),1];

                        if ceil(obj.InterpolationFactor/obj.NumCycles)~=floor(obj.InterpolationFactor/obj.NumCycles)
                            coder.internal.error('dsphdl:FIRInterp:EvenPartlySerial');
                        end
                    else
                        varargout{1}=[obj.InterpolationFactor,1];
                    end
                end

            end

            if inputSize(1)*obj.InterpolationFactor>64
                coder.internal.error('dsphdl:FIRInterp:OutputVectSizeMax');
            end

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
                s.pInputVectorSize=obj.pInputVectorSize;
                s.pFimath=obj.pFimath;
                s.pUserFimath=obj.pUserFimath;
                s.pInterpolationFactor=obj.pInterpolationFactor;
                s.pDlyLine=obj.pDlyLine;
                s.pState=obj.pState;
                s.pDout=obj.pDout;
                s.pDlyLineVld=obj.pDlyLineVld;
                s.pOutputReg=obj.pOutputReg;
                s.pVldOut=obj.pVldOut;
                s.pRdyOut=obj.pRdyOut;
                s.pDvld=obj.pDvld;
                s.pOutBuffer_size=obj.pOutBuffer_size;
                s.pSimTime=obj.pSimTime;
                s.pInputDT=obj.pInputDT;
                s.pIsFilterComplex=obj.pIsFilterComplex;
                s.pFilterArray=obj.pFilterArray;
                s.pFilterOrder=obj.pFilterOrder;
                s.pFilterValidREG=obj.pFilterValidREG;
                s.pDelayBalanceREG=obj.pDelayBalanceREG;
                s.pFIRDelay=obj.pFIRDelay;
                s.pFilterOutput=obj.pFilterOutput;
                s.pValidOutput=obj.pValidOutput;
                s.pReadyOutput=obj.pReadyOutput;
                s.pFIRMaxDelay=obj.pFIRMaxDelay;
                s.pValidDelayBalance=obj.pValidDelayBalance;
                s.pNumCycles=obj.pNumCycles;
                s.sharingCount=obj.sharingCount;
                s.pReadyState=obj.pReadyState;
                s.pSavedData=obj.pSavedData;
                s.pSavedDataVld=obj.pSavedDataVld;
                s.pSerializationFactor=obj.pSerializationFactor;
                s.pSharingCountReached=obj.pSharingCountReached;
                s.pInterleaving=obj.pInterleaving;
                s.validLastPhase=obj.validLastPhase;
                s.resetCount=obj.resetCount;
                s.resetCountEn=obj.resetCountEn;
                s.rstREG=obj.rstREG;
                s.pTransientPad=obj.pTransientPad;
                s.pSubLength=obj.pSubLength;
                s.pInitialize=obj.pInitialize;
                s.pSharingMUX=obj.pSharingMUX;
                s.pSharingCounter=obj.pSharingCounter;
                s.pSharingMUXConst=obj.pSharingMUXConst;
                s.pSharingCountConst=obj.pSharingCountConst;
                s.pOutputSharing=obj.pOutputSharing;
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
            inputDT=getInputDT(obj,dt1);
            inputSize=getInputVectorSize(obj);
            interpStr=sprintf('x[n/%i]\n',obj.InterpolationFactor);
            if isempty(dt1)
                icon=sprintf('%sFIR Interpolator\nLatency = --',interpStr);
            elseif strcmpi(obj.FilterStructure,'Direct form systolic')||strcmpi(obj.FilterStructure,'Partly serial systolic')
                coeffDT=getCoefficientsDT(obj,inputDT);

                icon=sprintf('%sFIR Interpolator\nLatency = %d',interpStr,getLatency(obj,numerictype(coeffDT),isInputComplex,inputSize));

            else
                coeffDT=getCoefficientsDT(obj,inputDT);

                icon=sprintf('%sFIR Interpolator\nLatency = %d',interpStr,getLatency(obj,numerictype(coeffDT),isInputComplex,inputSize));

            end
        end
        function inputVectorSize=getInputVectorSize(obj)
            inputVectorSize=obj.pInputVectorSize;
        end

    end

    methods

        function obj=FIRInterpolator(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','DSP_HDL_Toolbox'))
                    error(message('dsphdl:dsphdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','DSP_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:},'InterpolationFactor','Numerator','NumCycles');
        end




        function set.FilterStructure(obj,value)
            obj.FilterStructure=value;
        end

        function set.InterpolationFactor(obj,value)
            validateattributes(value,{'double'},{'real','integer','scalar','finite','>=',2},'FIRInterpolator','InterpolationFactor');
            obj.InterpolationFactor=value;
        end

        function set.Numerator(obj,value)
            validateattributes(value,...
            {'numeric'},...
            {'finite','nonempty','row'},...
            'FIRInterpolator','Numerator');
            obj.Numerator=value;
        end

        function set.NumCycles(obj,value)




            validateattributes(value,...
            {'numeric'},...
            {'scalar','positive'},...
            'FIRInterpolator','NumCycles');
            if~isinf(value)
                validateattributes(value,...
                {'numeric'},...
                {'integer'},...
                'FIRInterpolator','NumCycles');
            end
            obj.NumCycles=value;
        end

        function set.RoundingMethod(obj,val)
            validatestring(val,{'Ceiling','Convergent','Floor',...
            'Nearest','Round','Zero'},'FIRInterpolator','Rounding mode');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            validatestring(val,{'Wrap','Saturate'},'FIRInterpolator','Overflow Action');
            obj.OverflowAction=val;
        end
    end



    methods(Access=protected)
        function validatePropertiesImpl(obj)

            if~coder.target('hdl')
                InterpFactor=obj.InterpolationFactor;
                validateattributes(InterpFactor,{'double'},{'real','integer','scalar','finite','>=',2},'FIRInterpolator','InterpolationFactor');



            end
        end
        function validateInputsImpl(obj,varargin)










            coder.extrinsic('dsphdlshared.internal.validateCoefDataType','gcb');
            coder.extrinsic('gcb');
            inData=varargin{1};
            if~coder.target('hdl')
                validDataType={'double','single','uint8','uint16','uint32','int8','int16','int32','int64','embedded.fi'};
                validDimension={'vector','column'};

                validateattributes(inData,validDataType,validDimension,'FIRInterpolator','data');


                obj.pInputVectorSize=length(inData);
                if obj.pInputVectorSize>64
                    coder.internal.error('dsphdl:FIRInterp:InputVectSizeMax',coder.const(gcb));
                end


                validateBoolean(obj,varargin{:});
            end



            if obj.NumCycles>1&&length(varargin{1})>1
                coder.internal.error('dsphdl:FIRInterp:FramePartlySerial');
            end

            coeffDTCheck=getCoeffDTCheck(obj);
            if~obj.isInMATLABSystemBlock
                blkName=class(obj);
            else
                blkName=coder.const(gcb);
            end

            inputDT=getInputDT(obj,inData);
            dsphdlshared.internal.validateCoefDataType(blkName,coeffDTCheck,inputDT,obj.Numerator,obj.CoefficientsDataType,true,true,obj.isInMATLABSystemBlock)

        end

        function flag=isInputComplexityMutableImpl(~,~)

            flag=true;
        end

        function validateBoolean(obj,varargin)
            validDimension={'scalar'};
            if isempty(coder.target)||~eml_ambiguous_types

                validateattributes(varargin{2},{'logical'},validDimension,'FIRInterpolator','valid');
                if obj.ResetInputPort
                    validateattributes(varargin{3},{'logical'},validDimension,'FIRInterpolator','reset');
                end
            end

        end

        function resetImpl(obj)
            if~coder.target('hdl')
                obj.pDlyLineVld(:)=false;
                obj.pDlyLine(:)=0;
                obj.pOutputReg(:,:)=0;
                obj.pVldOut(:)=false;
                obj.pRdyOut(:)=true;
                obj.pSimTime=1;
                obj.pState(:)=0;
                obj.pDout(:)=0;
                obj.pDvld=false;
                obj.pResetStart=false;
                obj.pDelayBalanceREG(:,:,:)=0;
                obj.pFilterOutput(:,1)=0;
                obj.pValidOutput(:,1)=false;
                obj.pReadyOutput(:,1)=false;
                obj.pValidDelayBalance(:)=false;
                obj.pSharingCounter(:)=0;
                obj.pSharingMUX(:)=0;
                obj.pOutputSharing(:)=false;
                obj.sharingCount(:)=0;
                if obj.pInitialize
                    obj.pRdyReg=true;
                    obj.pInitialize=false;
                else
                    obj.pRdyReg=false;
                end
                obj.pReadyState(:)=0;
                obj.pSavedData(:)=0;
                obj.pSavedDataVld=false;

                if obj.resetCountEn
                    obj.resetCount=obj.resetCount+1;
                end

                obj.resetCountEn=true;


                for ii=1:1:obj.InterpolationFactor
                    reset(obj.pFilterArray{ii});
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
            coder.extrinsic('dsp.internal.FIRFilterPrecision');
            [DT,~]=getInputDT(obj,A);
            obj.pInputDT=coder.const(DT);
            obj.pInitialize=true;
            numerator=coder.const(reshapeFilterCoef(obj,obj.Numerator,obj.InterpolationFactor));


            numMults=ceil(numel(numerator)/obj.NumCycles);
            numMuxInputs=ceil((numel(numerator)/obj.InterpolationFactor)/numMults);
            subLength=size(numerator,2);
            obj.pSubLength=subLength;
            tableSubSize=ceil(subLength/numMults);
            obj.pInterleaving=(obj.NumCycles>obj.InterpolationFactor)&&(numMults<obj.InterpolationFactor)&&tableSubSize>=2;


            if strcmpi(obj.FilterStructure,'Direct form systolic')
                if obj.pInterleaving
                    if isinf(obj.NumCycles)
                        obj.pNumCycles=ceil((numel(obj.Numerator)/obj.InterpolationFactor))*obj.InterpolationFactor;
                    else
                        obj.pNumCycles=numMuxInputs*obj.InterpolationFactor;
                    end
                else
                    obj.pNumCycles=obj.NumCycles;
                end

            else
                obj.pNumCycles=1;

            end

            if isreal(A)
                obj.pSavedData=cast(0,'like',A);
            else
                obj.pSavedData=cast(complex(0),'like',A);

            end

            obj.pSavedDataVld=false;

            if~coder.target('hdl')

                [outputDT]=getOutputDT(obj,obj.pInputDT);
                obj.pOutputDT=outputDT;


                if~isfloat(A)
                    obj.pFimath=fimath('RoundingMethod','Floor','OverflowAction','Wrap');
                    obj.pUserFimath=fimath('RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction);
                end

                obj.pInputVectorSize=coder.const(size(A,1));
                obj.pOutBuffer_size=coder.const(obj.pInputVectorSize*(ceil(obj.InterpolationFactor/obj.pNumCycles)));

                if obj.pOutBuffer_size>64
                    coder.internal.error('dsphdl:FIRInterp:OutputVectSizeMax');
                end


                obj.sharingCount=0;




                obj.pInputVectorSize=length(A);
                obj.pInterpolationFactor=double(obj.InterpolationFactor);
                obj.pRoundingMethod=obj.RoundingMethod;
                obj.pOverflowAction=obj.OverflowAction;
                obj.pFilterCoefficientDT=obj.CoefficientsDataType;
                obj.pIsFilterComplex=~isreal(A)&&isCoeffComplex(obj);
                obj.pFilterOrder=coder.const(ceil(size(numerator,1)));




                FilterArray=cell(obj.InterpolationFactor,1);
                FilterArrayPartlySerial=cell(obj.InterpolationFactor,1);
                CoefficientDT=getCoefficientsDT(obj,obj.pInputDT);


                if obj.pInterleaving
                    for ii=1:1:obj.InterpolationFactor

                        FilterArrayPartlySerial{ii}=dsphdl.FIRFilter('Numerator',numerator(ii,:),...
                        'FilterStructure','Partly serial systolic',...
                        'NumCycles',obj.pNumCycles,...
                        'RoundingMethod',obj.RoundingMethod,...
                        'OverflowAction',obj.OverflowAction,...
                        'CoefficientsDataType',numerictype(CoefficientDT),...
                        'ResetInputPort',obj.ResetInputPort,...
                        'HDLGlobalReset',obj.HDLGlobalReset,...
                        'OutputDataType',obj.OutputDataType);

                        FilterArrayPartlySerial{ii}.setCoeffDTCheck(false);
                        FilterArrayPartlySerial{ii}.SymmetryOptimization=false;


                        if obj.ResetInputPort
                            setup(FilterArrayPartlySerial{ii},A,true,false);
                        else
                            setup(FilterArrayPartlySerial{ii},A,true);
                        end
                    end

                elseif obj.pNumCycles>1
                    for ii=1:1:obj.InterpolationFactor

                        FilterArrayPartlySerial{ii}=dsphdl.FIRFilter('Numerator',numerator(ii,:),...
                        'FilterStructure','Partly serial systolic',...
                        'NumCycles',obj.pNumCycles,...
                        'RoundingMethod',obj.RoundingMethod,...
                        'OverflowAction',obj.OverflowAction,...
                        'CoefficientsDataType',obj.CoefficientsDataType,...
                        'ResetInputPort',obj.ResetInputPort,...
                        'HDLGlobalReset',obj.HDLGlobalReset,...
                        'OutputDataType',obj.OutputDataType);

                        FilterArrayPartlySerial{ii}.setCoeffDTCheck(false);


                        if obj.ResetInputPort
                            setup(FilterArrayPartlySerial{ii},A,true,false);
                        else
                            setup(FilterArrayPartlySerial{ii},A,true);
                        end
                    end
                else
                    for ii=1:1:obj.InterpolationFactor

                        FilterArray{ii}=dsphdl.FIRFilter('Numerator',numerator(ii,:),...
                        'FilterStructure',obj.FilterStructure,...
                        'RoundingMethod',obj.RoundingMethod,...
                        'OverflowAction',obj.OverflowAction,...
                        'CoefficientsDataType',obj.CoefficientsDataType,...
                        'ResetInputPort',obj.ResetInputPort,...
                        'HDLGlobalReset',obj.HDLGlobalReset,...
                        'OutputDataType',obj.OutputDataType);

                        FilterArray{ii}.setCoeffDTCheck(false);

                        if obj.ResetInputPort
                            setup(FilterArray{ii},A,true,false);
                        else
                            setup(FilterArray{ii},A,true);
                        end
                    end
                end


                if obj.pNumCycles>1
                    obj.pFilterArray=FilterArrayPartlySerial;

                else
                    obj.pFilterArray=FilterArray;
                end



                if isa(A,'double')
                    firOutputTH=0;
                elseif isa(A,'single')
                    firOutputTH=single(0);
                else

                    [fullPrecision,~]=coder.const(@dsp.internal.FIRFilterPrecision,...
                    cast(obj.Numerator,'like',CoefficientDT),obj.pInputDT);

                    firOutputTH=fi(fullPrecision,'RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction);
                end


                latency=zeros(1,obj.InterpolationFactor);

                if~isnumerictype(obj.CoefficientsDataType)
                    coeffDT=numerictype('double');
                else
                    coeffDT=obj.CoefficientsDataType;
                end

                for ii=1:1:obj.InterpolationFactor

                    latency(ii)=getLatency(obj.pFilterArray{ii},coeffDT,...
                    obj.pFilterArray{ii}.Numerator,obj.pIsFilterComplex,obj.pInputVectorSize);



                end


                MinFIRLatency=min(latency);
                MaxFIRLatency=max(latency)+1;
                delayB=MaxFIRLatency-MinFIRLatency;

                if delayB==1
                    delayB=2;
                elseif obj.pNumCycles>1

                end


                obj.pFIRDelay=zeros(1,obj.InterpolationFactor);

                for ii=1:1:obj.InterpolationFactor
                    obj.pFIRDelay(ii)=MaxFIRLatency-latency(ii);
                end


                [~,ind]=max(latency(1:obj.InterpolationFactor));
                obj.pFIRMaxDelay=ind;



                outDT=fi(0,outputDT,'RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction);




                if~isreal(A)||~isreal(obj.Numerator)
                    if~coder.target('hdl')
                        obj.pDelayBalanceREG=complex(zeros(delayB,obj.InterpolationFactor,obj.pInputVectorSize,'like',firOutputTH));
                        obj.pFilterOutput=complex(zeros(obj.InterpolationFactor,obj.pInputVectorSize,'like',firOutputTH));
                        obj.pOutputReg=cast(complex(zeros(obj.pOutBuffer_size,1)),'like',outDT);

                    else
                        obj.pDelayBalanceREG=complex(zeros(2,obj.InterpolationFactor,obj.pInputVectorSize,'like',firOutputTH));
                        obj.pFilterOutput=complex(zeros(obj.InterpolationFactor,obj.pInputVectorSize,'like',firOutputTH));
                        obj.pOutputReg=cast(complex(zeros(obj.pOutBuffer_size,1)),'like',outDT);
                    end
                else
                    if~coder.target('hdl')
                        obj.pDelayBalanceREG=zeros(delayB,obj.InterpolationFactor,obj.pInputVectorSize,'like',firOutputTH);
                        obj.pFilterOutput=zeros(obj.InterpolationFactor,obj.pInputVectorSize,'like',firOutputTH);
                        obj.pOutputReg=cast((zeros(obj.pOutBuffer_size,1)),'like',outDT);

                    else
                        obj.pDelayBalanceREG=zeros(2,obj.InterpolationFactor,obj.pInputVectorSize,'like',firOutputTH);
                        obj.pFilterOutput=zeros(obj.InterpolationFactor,obj.pInputVectorSize,'like',firOutputTH);
                        obj.pOutputReg=cast((zeros(obj.pOutBuffer_size,1)),'like',outDT);

                    end
                end

                obj.pVldOut=false;
                obj.pRdyOut=false;
                obj.pValidOutput=false(obj.InterpolationFactor,1);
                obj.pReadyOutput=false(obj.InterpolationFactor,1);

                if obj.pNumCycles>obj.InterpolationFactor
                    obj.pSharingCounter=fi(0,0,ceil(log2(obj.pNumCycles/obj.InterpolationFactor)),0,hdlfimath);
                else
                    obj.pSharingCounter=fi(0,0,1,0,hdlfimath);
                end

                obj.pSharingMUX=fi(0,0,ceil(log2(obj.InterpolationFactor)),0,hdlfimath);
                obj.pOutputSharing=false;

                if obj.pNumCycles<obj.InterpolationFactor&&obj.pNumCycles>1
                    obj.pSharingMUXConst=coder.const((ceil(obj.InterpolationFactor/obj.pNumCycles)));
                else
                    obj.pSharingMUXConst=obj.InterpolationFactor;
                end

                if obj.pNumCycles<obj.InterpolationFactor
                    obj.pSharingCountConst=obj.pNumCycles;
                else
                    obj.pSharingCountConst=obj.InterpolationFactor;
                end

                obj.pValidDelayBalance=zeros(delayB,obj.InterpolationFactor);
            else
                if isempty(coder.target)||~eml_ambiguous_types
                    [DT,~]=getInputDT(obj,A);


                    InputVectorSize=length(A);
                    obj.pOutBuffer_size=coder.const(InputVectorSize*(ceil(obj.InterpolationFactor/obj.pNumCycles)));
                    CoefficientDT=getCoefficientsDT(obj,DT);

                    [fullPrecision,~]=coder.const(@dsp.internal.FIRFilterPrecision,...
                    cast(obj.Numerator,'like',CoefficientDT),DT);

                    if isnumerictype(obj.OutputDataType)
                        outputDT=numerictype(obj.OutputDataType);
                    elseif strcmpi(obj.OutputDataType,'Full precision')
                        outputDT=numerictype(fullPrecision);
                    else
                        wordLength=inputPrecision.WordLength;
                        fractionLength=fullPrecision.FractionLength-(fullPrecision.WordLength-inputPrecision.WordLength);
                        signed=fullPrecision.SignednessBool;
                        outputDT=numerictype(signed,wordLength,fractionLength);

                    end
                    a=fi(0,outputDT,'RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction);
                    if~isreal(A)||~isreal(obj.Numerator)
                        obj.pOutputReg=cast(complex(zeros(obj.pOutBuffer_size,1)),'like',a);
                    else
                        obj.pOutputReg=cast((zeros(obj.pOutBuffer_size,1)),'like',a);
                    end
                    obj.pVldOut=false;
                    obj.pRdyOut=false;
                end
            end
            obj.pSerializationFactor=coder.const(obj.pNumCycles);
            obj.pRdyReg=true;
            obj.pReadyState=0;
            if~coder.target('hdl')

                if obj.pInterleaving
                    numMults=ceil(numel(numerator)/obj.pNumCycles);
                    obj.pSharingCountReached=ceil(size(numerator,2)/numMults);
                else
                    obj.pSharingCountReached=floor(obj.pNumCycles/obj.InterpolationFactor);
                end
            else
                obj.pSharingCountReached=floor(obj.pNumCycles/obj.InterpolationFactor);
            end
            obj.validLastPhase=false;
            obj.resetCount=0;
            obj.resetCountEn=false;
            obj.rstREG=0;
            obj.pTransientPad=false;

        end

        function[dIn,dInVld]=updateReady(obj,validIn,dataIn,resetIn)
            IDLE=0;
            LOAD=1;
            SAVE=2;
            WAIT=3;
            UNLOAD=4;



            vldIn=validIn(1);
            sharingCnt=obj.sharingCount;
            serializationFactor=obj.pSerializationFactor;
            if serializationFactor==2
                finalValue=0;
            else
                finalValue=serializationFactor-1;
            end
            if~resetIn
                switch obj.pReadyState
                case IDLE
                    dIn=dataIn;
                    dInVld=validIn;
                    obj.pReadyState=IDLE;
                    obj.pRdyReg=true;
                    obj.pSavedData(:)=0;
                    obj.pSavedDataVld=false;
                    if vldIn
                        obj.pReadyState=LOAD;
                        obj.pRdyReg=false;
                    end
                case LOAD
                    dIn=cast(0,'like',dataIn);
                    dInVld=false;
                    obj.pReadyState=WAIT;
                    if serializationFactor>2
                        if vldIn
                            obj.pReadyState=SAVE;
                            obj.pSavedData(:)=dataIn;
                            obj.pSavedDataVld=validIn;
                        end
                    else
                        if vldIn
                            obj.pReadyState=UNLOAD;
                            obj.pSavedData(:)=dataIn;
                            obj.pSavedDataVld=validIn;
                        else
                            obj.pRdyReg=true;
                            obj.pReadyState=IDLE;
                            dIn=dataIn;
                            dInVld=validIn;
                        end
                    end
                case SAVE
                    dIn=cast(0,'like',dataIn);
                    dInVld=false;
                    obj.pReadyState=SAVE;
                    if sharingCnt==finalValue
                        obj.pReadyState=UNLOAD;
                    end
                    obj.pRdyReg=false;

                case WAIT
                    dIn=cast(0,'like',dataIn);
                    dInVld=false;


                    if sharingCnt==finalValue||serializationFactor==2
                        obj.pRdyReg=true;
                        obj.pReadyState=IDLE;

                    end
                case UNLOAD

                    obj.pReadyState=WAIT;

                    dIn=obj.pSavedData;
                    dInVld=obj.pSavedDataVld;
                    obj.pSavedData(:)=dataIn;
                    obj.pSavedDataVld=vldIn;
                otherwise
                    dIn=cast(0,'like',dataIn);
                    dInVld=false;
                    obj.pReadyState=IDLE;
                    obj.pRdyReg=true;
                    obj.pSavedData(:)=0;
                    obj.pSavedDataVld=false;
                end
            else
                dIn=cast(0,'like',dataIn);
                dInVld=false;
                obj.pReadyState=IDLE;
                obj.pRdyReg=true;
                obj.pSavedData(:)=0;
                obj.pSavedDataVld=false;
            end

        end




    end




    methods(Hidden)

        function setCoeffDTCheck(obj,value)

            obj.pCoeffDTCheck=value;
        end

        function value=getCoeffDTCheck(obj)

            value=obj.pCoeffDTCheck;
        end
    end



    methods(Access=protected)
        function varargout=outputImpl(obj,varargin)
            if~coder.target('hdl')
                if obj.pVldOut&&~obj.pTransientPad
                    varargout{1}=obj.pOutputReg;
                else
                    varargout{1}=cast(zeros(ceil(obj.InterpolationFactor/obj.pNumCycles)*obj.pInputVectorSize,1),'like',obj.pOutputReg);
                end

                varargout{2}=obj.pVldOut;
                if obj.pNumCycles==1
                    varargout{3}=obj.pRdyReg;
                    obj.pRdyReg=true;
                else
                    ReadyOutput=false(obj.InterpolationFactor,1);
                    for ii=1:1:obj.InterpolationFactor
                        [~,~,ReadyOutput(ii)]=outputImpl(obj.pFilterArray{ii},varargin{1},varargin{2});
                    end

                    if obj.pInterleaving
                        varargout{3}=obj.pRdyReg;
                    else
                        varargout{3}=ReadyOutput(obj.pFIRMaxDelay);
                    end
                end
            else
                varargout{1}=obj.pOutputReg;
                varargout{2}=false;
                varargout{3}=false;
            end
        end

        function updateImpl(obj,varargin)

            if~coder.target('hdl')
                if nargin==4
                    resetIn=varargin{3};
                else
                    resetIn=false;
                end
                if isscalar(varargin{1})
                    if obj.pInterleaving
                        [dIn,dInVld]=updateReady(obj,varargin{2},varargin{1},resetIn);
                    end
                end

                if resetIn
                    obj.pResetStart=true;
                end

                if obj.pNumCycles==1
                    if obj.ResetInputPort
                        for ii=1:1:obj.InterpolationFactor
                            [obj.pFilterOutput(ii,:),obj.pValidOutput(ii)]=step(obj.pFilterArray{ii},varargin{1},varargin{2},varargin{3});
                        end
                    else
                        for ii=1:1:obj.InterpolationFactor
                            [obj.pFilterOutput(ii,:),obj.pValidOutput(ii)]=step(obj.pFilterArray{ii},varargin{1},varargin{2});
                        end
                    end
                elseif obj.pInterleaving

                    if obj.ResetInputPort
                        for ii=1:1:obj.InterpolationFactor
                            [obj.pFilterOutput(ii,:),obj.pValidOutput(ii),obj.pReadyOutput(ii)]=step(obj.pFilterArray{ii},dIn,dInVld,varargin{3});
                        end
                    else
                        for ii=1:1:obj.InterpolationFactor
                            [obj.pFilterOutput(ii,:),obj.pValidOutput(ii),obj.pReadyOutput(ii)]=step(obj.pFilterArray{ii},dIn,dInVld);
                        end
                    end
                else
                    if obj.ResetInputPort
                        for ii=1:1:obj.InterpolationFactor
                            [obj.pFilterOutput(ii,:),obj.pValidOutput(ii),obj.pReadyOutput(ii)]=step(obj.pFilterArray{ii},varargin{1},varargin{2},varargin{3});
                        end
                    else
                        for ii=1:1:obj.InterpolationFactor
                            [obj.pFilterOutput(ii,:),obj.pValidOutput(ii),obj.pReadyOutput(ii)]=step(obj.pFilterArray{ii},varargin{1},varargin{2});
                        end
                    end
                end


                if obj.pNumCycles==1
                    for ii=1:1:obj.InterpolationFactor
                        if obj.pValidOutput(ii)
                            obj.pDelayBalanceREG(end-1:-1:1,ii,:)=obj.pDelayBalanceREG(end:-1:2,ii,:);
                            obj.pDelayBalanceREG(obj.pFIRDelay(ii),ii,:)=obj.pFilterOutput(ii,:);
                        end
                    end
                else
                    for ii=1:1:obj.InterpolationFactor
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

                if obj.pNumCycles==1
                    for ii=1:1:obj.pInputVectorSize
                        for jj=1:1:obj.pInterpolationFactor
                            obj.pOutputReg(((ii-1)*obj.pInterpolationFactor)+jj,1)=obj.pDelayBalanceREG(1,jj,ii);
                        end
                    end
                    if obj.pValidOutput(obj.pFIRMaxDelay)
                        obj.pVldOut=true;
                    else
                        obj.pVldOut=false;
                    end

                else

                    if obj.pValidOutput(obj.pFIRMaxDelay)
                        obj.pOutputSharing=true;
                        obj.pVldOut=true;
                    elseif obj.pSharingCounter==0&&obj.pSharingMUX==0
                        obj.pOutputSharing=false;
                    end

                    obj.pVldOut=(obj.pSharingCounter==0&&obj.pOutputSharing)||obj.pValidOutput(obj.pFIRMaxDelay);

                    if obj.pNumCycles>=obj.InterpolationFactor
                        obj.pOutputReg(:)=obj.pDelayBalanceREG(1,double(obj.pSharingMUX)+1,1);
                    else
                        obj.pOutputReg(:)=obj.pDelayBalanceREG(1,((double(obj.pSharingMUX))*obj.pSharingMUXConst)+1:(double(obj.pSharingMUX)+1)*obj.pSharingMUXConst,1);
                    end

                    if obj.pSharingCounter==0&&obj.pOutputSharing
                        obj.pSharingMUX(:)=obj.pSharingMUX+1;

                        if double(obj.pSharingMUX)>=obj.pSharingCountConst
                            obj.pSharingMUX(:)=0;
                        end

                    end

                    if obj.pOutputSharing
                        obj.pSharingCounter(:)=obj.pSharingCounter+1;

                        if obj.pSharingCounter>=obj.pSharingCountReached
                            obj.pSharingCounter(:)=0;
                        end

                    end
                    obj.pRdyOut=obj.pReadyOutput(obj.pFIRMaxDelay);
                end



                if obj.pInterleaving

                    if(obj.rstREG==obj.resetCount)

                        if((obj.resetCount<=(obj.pSubLength*2))&&(obj.resetCount>0))&&~obj.pTransientPad
                            obj.pTransientPad=true;
                            obj.resetCount=0;

                        elseif(obj.resetCount>0)&&~obj.pTransientPad
                            obj.resetCount=0;
                            obj.rstREG=0;

                        elseif obj.pTransientPad&&(obj.resetCount<(obj.pSubLength*2)+5)&&obj.validLastPhase
                            obj.resetCount=obj.resetCount+1;
                        else
                            if obj.pTransientPad&&obj.resetCount>=(obj.pSubLength*2)+5
                                obj.resetCount=0;
                                obj.pTransientPad=false;
                            end
                        end
                    end
                    obj.rstREG=obj.resetCount;

                    obj.validLastPhase=(obj.sharingCount==(obj.pSerializationFactor-1));

                end



                if varargin{2}||(obj.sharingCount>0)
                    if obj.sharingCount==(obj.pSerializationFactor-1)
                        obj.sharingCount=0;
                    else
                        obj.sharingCount=obj.sharingCount+1;
                    end
                end


                resetIfTrue(obj);
                if obj.pNumCycles==1
                    obj.pRdyOut=true;
                end
            end
        end


        function resetIfTrue(obj)
            if obj.pResetStart
                resetImpl(obj);
            end
        end
    end





    methods(Access=protected)

        function[outputDT]=getOutputDT(obj,inputDT)
            coder.extrinsic('dsp.internal.FIRFilterPrecision');

            if strcmpi(inputDT.DataTypeMode,'Double')
                A=zeros(propagatedInputSize(obj,1));
            elseif strcmpi(inputDT.DataTypeMode,'Single')
                A=single(zeros(propagatedInputSize(obj,1)));
            else
                A=fi(zeros(propagatedInputSize(obj,1)),inputDT);
            end

            if isa(A,'double')
                outputDT=numerictype('double');
            elseif isa(A,'single')
                outputDT=numerictype('single');
            else
                CoefficientDT=getCoefficientsDT(obj,inputDT);

                [fullPrecision,inputPrecision]=coder.const(@dsp.internal.FIRFilterPrecision,...
                cast(obj.Numerator,'like',CoefficientDT),inputDT);
                if isnumerictype(obj.OutputDataType)
                    outputDT=numerictype(obj.OutputDataType);
                elseif strcmpi(obj.OutputDataType,'Full precision')
                    outputDT=numerictype(fullPrecision);
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

                if isnumerictype(CoefficientsDT)
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
                    coef=fi(obj.Numerator,0,inputDT.WordLength);
                    wordLength=coef.WordLength;
                    fractionLength=coef.FractionLength;
                    coefficientsDT=fi(0,0,wordLength,fractionLength,'OverflowAction','Saturate','RoundingMethod','Nearest');
                end
            else
                if isa(inputDT,'single')
                    coefficientsDT=single(0);
                else
                    coefficientsDT=double(0);
                end
            end
        end
        function coefTable=reshapeFilterCoef(~,Numerator,InterpolationFactor)

            numOfCoef=length(Numerator);
            zeroPadLen=InterpolationFactor-mod(numOfCoef,InterpolationFactor);
            if zeroPadLen==InterpolationFactor
                coef_zeroPad=Numerator;
            else
                coef_zeroPad=[Numerator(:);zeros(zeroPadLen,1,'like',Numerator)];
            end

            NumTaps=length(coef_zeroPad)/InterpolationFactor;
            coef_reshape=reshape(coef_zeroPad,InterpolationFactor,NumTaps);
            coefTable=(coef_reshape);

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

