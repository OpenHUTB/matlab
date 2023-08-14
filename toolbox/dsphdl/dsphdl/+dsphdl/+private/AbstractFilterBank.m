classdef(Hidden,StrictDefaults)AbstractFilterBank<matlab.System




%#codegen
%#ok<*EMCLS>




    properties(Nontunable,Constant,Hidden)
        InputPipeline=1;
        MultiplierPipelineRegister=1;
        SystolicRegister=1;
        AdderPipelineRegister=1;


        ExtraPipelineRegister=4;

        MaxInputVectorSize=64;

        MaxOutputVectorSize=64;

        MinWordLength=2;

        MaxWordLength=128;
    end

    properties(Nontunable)






        NumFilterBanks=1;



        FilterStructure='Direct form transposed';




        ComplexMultiplication='Use 4 multipliers and 2 adders';




        FilterCoefficients=[0.26,0.25;0.27,0.25];









        FilterCoefficientSource='Property';

        InputCoefficientLength=1;








        RoundingMethod='Floor';



        OverflowAction='Wrap';




        CoefficientsDataType='Same word length as input';




        FilterOutputDataType='Same word length as input';


        SymmetryOptimization=true;








        ResetInputPort(1,1)logical=false;
    end
    properties(Nontunable,Hidden)


        ValidInputPort(1,1)logical=true;
    end

    properties(Nontunable,Constant)

        ValidOutputPort(1,1)logical=true;
    end





    properties(Constant,Hidden)

        FilterCoefficientSourceSet=matlab.system.StringSet({'Property','Input port (Parallel interface)'});
        RoundingMethodSet=matlab.system.internal.RoundingMethodSet({'Ceiling','Convergent','Floor','Nearest','Round','Zero'});
        OverflowActionSet=matlab.system.internal.OverflowActionSet;
        FilterOutputDataTypeSet=matlab.system.internal.DataTypeSet(...
        {'Same word length as input',...
        'Full precision',...
        matlab.system.internal.CustomDataType('Signedness',{'Signed','Unsigned'},'Scaling',{'Unspecified','BinaryPoint'})});
        CoefficientsDataTypeSet=matlab.system.internal.DataTypeSet(...
        {'Same word length as input',...
        matlab.system.internal.CustomDataType('Signedness',{'Signed','Unsigned'},'Scaling',{'Unspecified','BinaryPoint'})});
        ComplexMultiplicationSet=matlab.system.StringSet({'Use 3 multipliers and 5 adders',...
        'Use 4 multipliers and 2 adders'});
    end

    properties(Nontunable,Access=private)

        pFilterStructure;
        pNumFilterBanks;

        pComplexMultiplication;
        pFilterCoefficients;
        pFilterCoefficientsPlus;
        pFilterCoefficientsMinus;
        pFilterCoefficientsImag;
        pRoundingMethod;
        pOverflowAction;
        pCoefficientsDataType;
        pFilterOutputDataType;
        pInputVectorSize;
        pFiMath;
        pUserFiMath;
        pOutputSize;
        pInitialLatency=0;
        pOutputBufferSize;
        pFilterSymmetry;
        pCoefMask;
    end
    properties(Access=private)
        pWrOutBuffer_roll(1,1)logical;
        pRdOutBuffer_roll(1,1)logical;
        pResetStart(1,1)logical;
        pOutputVld(1,1)logical;
        pDinVldReg1(1,1)logical;
        pDinVldReg2(1,1)logical;

        pDataOutVld(1,1)logical=false;
        pCoeffDTCheck(1,1)logical=true;

        pWrOutBuffer_index;
        pRdOutBuffer_index;
        pSimTime;
        pOutputBuffer;
        pFilterBankIndex=1;
        pVldInPipeline=[];
        pDelayLine;
        pDelayLineP;
        pDelayLineM;
        pDelayLineI;
        pAccReg;
        pAccRegP;
        pAccRegM;
        pAccRegI;
        pInvalidSampleCnt;
        pDataOut;
    end

    properties(Nontunable,Access=private)
        pCmplxCmplxFIR(1,1)logical=false;
        pRealRealFIR(1,1)logical=true;
    end



    methods(Static)
        function helpFixedPoint

        end

    end
    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={...
'NumFilterBanks'...
            ,'FilterCoefficients'...
            ,'ComplexMultiplication'...
            ,'ResetInputPort'...
            ,'StartOutputPort'...
            ,'EndOutputPort'...
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
            if nargin==6
                coefDT=varargin{1};
                coeff=varargin{2};
                numSubFil=varargin{3};
                inVecSize=varargin{4};
                isInputComplex=varargin{5};
            elseif nargin==5
                coefDT=varargin{1};
                coeff=varargin{2};
                numSubFil=varargin{3};
                inVecSize=varargin{4};
                isInputComplex=false;
            elseif nargin==4
                coefDT=varargin{1};
                coeff=varargin{2};
                numSubFil=varargin{3};
                inVecSize=1;
                isInputComplex=false;
            elseif nargin==3
                coefDT=varargin{1};
                coeff=varargin{2};
                numSubFil=1;
                inVecSize=1;
                isInputComplex=false;
            elseif nargin==2
                coefDT=varargin{1};
                coeff=obj.FilterCoefficient;
                numSubFil=1;
                inVecSize=1;
                isInputComplex=false;
            else
                coefDT=[];
                CoefficientsDT=obj.CoefficientsDataType;

                if~isnumerictype(CoefficientsDT)
                    coder.internal.error('dsphdl:FIRFilter:getLatencyCallWithoutInputDataType','dsphdl.FIRFilter');
                end
            end




            assert(inVecSize<=numSubFil);

            FOLDINGFACTOR=numSubFil/inVecSize;

            if strcmpi(obj.FilterStructure,'Direct form systolic')||strcmpi(obj.FilterStructure,'Partly serial systolic')


                if strcmpi(obj.FilterCoefficientSource,'Input port (Parallel interface)')
                    if isempty(obj.FilterCoefficients)
                        numberOfTaps=obj.InputCoefficientLength;
                        numberOfRows=1;
                    else
                        [numberOfRows,numberOfTaps]=size(coeff);
                    end
                else
                    [numberOfRows,numberOfTaps]=size(coeff);
                end
                if FOLDINGFACTOR==1||numberOfTaps==1
                    FOLDINGDELAY=0;
                else
                    FOLDINGDELAY=(numberOfTaps-1)*(FOLDINGFACTOR-1);
                end
                if numberOfTaps==1
                    tapLatency=numberOfTaps*obj.AdderPipelineRegister+obj.InputPipeline+obj.MultiplierPipelineRegister;
                else
                    filterSymmetry=obj.getSymmetryFIRS(coeff,coefDT,obj.FilterCoefficientSource);
                    if numberOfRows>1
                        filterSymmetry.isSymmetric=0;
                    end
                    if filterSymmetry.isSymmetric~=0&&~any(filterSymmetry.Exception(2:end))
                        numberOfTaps=floor((filterSymmetry.SymmetryFromTo(2)-filterSymmetry.SymmetryFromTo(1)+1)/2);
                        if mod(length(coeff),2)
                            oddSymmetryCorection=1;
                        else
                            oddSymmetryCorection=0;
                        end
                        if filterSymmetry.Exception(1)==1&&oddSymmetryCorection==0
                            extraTap=1;
                        else
                            extraTap=0;
                        end
                        tapLatency=(numberOfTaps+oddSymmetryCorection+extraTap)*obj.AdderPipelineRegister+obj.InputPipeline+obj.SystolicRegister+obj.MultiplierPipelineRegister;
                    else
                        tapLatency=numberOfTaps*obj.AdderPipelineRegister+obj.InputPipeline+obj.MultiplierPipelineRegister+FOLDINGDELAY;
                    end

                end
            else
                tapLatency=obj.InputPipeline+obj.MultiplierPipelineRegister+obj.AdderPipelineRegister-1;
            end


            latency=tapLatency+obj.ExtraPipelineRegister+double(and(isInputComplex,~isreal(coeff)));

        end
        function inputVectorSize=getInputVectorSize(obj)
            inputVectorSize=obj.pInputVectorSize;
        end
        function validateCoefDataType(obj,isMATLABSystemBlock)
            coder.extrinsic('gcb','get_param','bdroot');

            if isnumerictype(obj.CoefficientsDataType)&&obj.pCoeffDTCheck
                coefDT=obj.CoefficientsDataType;

                if~coefDT.isscalingunspecified
                    if any(obj.FilterCoefficients(:)<0)
                        expectedCast=fi(obj.FilterCoefficients,1,coefDT.WordLength);
                        expectedFRL=expectedCast.FractionLength;
                    else
                        expectedCast=fi(obj.FilterCoefficients,0,coefDT.WordLength);
                        expectedFRL=expectedCast.FractionLength;
                    end
                end
                if~isMATLABSystemBlock

                    if any(obj.FilterCoefficients(:)<0)&&~coefDT.SignednessBool
                        coder.internal.warning('dsphdl:FIRFilter:UnexpectedCoefficientsDataType','dsphdl.FIRFilter');
                    end
                    if~coefDT.isscalingunspecified
                        if coefDT.FractionLength<expectedFRL
                            coder.internal.warning('dsphdl:FIRFilter:UnsufficientCoefficientsFractionalLength','dsphdl.FIRFilter')
                        end
                    end
                else
                    blkName=coder.const(gcb);
                    paramValue=coder.const(get_param(bdroot(blkName),'FixptConstPrecisionLossMsg'));
                    if strcmpi(paramValue,'error')

                        if any(obj.FilterCoefficients(:)<0)&&~coefDT.SignednessBool
                            coder.internal.error('dsphdl:FIRFilter:UnexpectedCoefficientsDataType',blkName);
                        end
                        if~coefDT.isscalingunspecified
                            if coefDT.FractionLength<expectedFRL
                                coder.internal.error('dsphdl:FIRFilter:UnsufficientCoefficientsFractionalLength',blkName);
                            end
                        end
                    elseif strcmpi(paramValue,'warning')

                        if any(obj.FilterCoefficients(:)<0)&&~coefDT.SignednessBool
                            coder.internal.warning('dsphdl:FIRFilter:UnexpectedCoefficientsDataType',blkName);
                        end
                        if~coefDT.isscalingunspecified
                            if coefDT.FractionLength<expectedFRL
                                coder.internal.warning('dsphdl:FIRFilter:UnsufficientCoefficientsFractionalLength',blkName);
                            end
                        end
                    end
                end
            end
        end
        function DT=getInputDT(~,data)
            if isnumerictype(data)
                DT=data;
            elseif isa(data,'embedded.fi')
                DT=numerictype(data);
            elseif isinteger(data)
                DT=numerictype(class(data));
            elseif ischar(data)
                if strncmpi(data,'uint',4)||strncmpi(data,'int',3)
                    DT=numerictype(data);
                else
                    DT=data;
                end
            else
                DT=data;
            end
        end
        function outputDT=getOutputDT(obj,inputDT,varargin)
            coder.extrinsic('dsp.internal.FIRFilterPrecision');
            if strcmpi(obj.FilterCoefficientSource,'Input port (Parallel interface)')
                if isnumerictype(inputDT)
                    FilterOutputDT=obj.FilterOutputDataType;
                    CoefficientDT=getCoefficientsDT(obj,inputDT);
                    if isempty(obj.FilterCoefficients)
                        filterLength=varargin{1};
                    else
                        filterLength=length(obj.FilterCoefficients);
                    end
                    if~isempty(filterLength)
                        inputPrecision.WordLength=inputDT.WordLength;
                        inputPrecision.FractionLength=inputDT.FractionLength;
                        inputPrecision.SignednessBool=inputDT.SignednessBool||CoefficientDT.SignednessBool;
                        fullPrecision.WordLength=inputDT.WordLength+CoefficientDT.WordLength+ceil(log2(filterLength));
                        fullPrecision.FractionLength=inputDT.FractionLength+CoefficientDT.FractionLength;
                        fullPrecision.SignednessBool=inputDT.SignednessBool||CoefficientDT.SignednessBool;
                        if isnumerictype(FilterOutputDT)
                            wordLength=FilterOutputDT.WordLength;
                            fractionLength=FilterOutputDT.FractionLength;
                            signed=FilterOutputDT.SignednessBool;
                        elseif strcmpi(FilterOutputDT,'Full precision')
                            wordLength=fullPrecision.WordLength;
                            fractionLength=fullPrecision.FractionLength;
                            signed=fullPrecision.SignednessBool;
                        elseif strcmpi(FilterOutputDT,'Same word length as input')
                            wordLength=inputPrecision.WordLength;
                            fractionLength=fullPrecision.FractionLength-(fullPrecision.WordLength-inputPrecision.WordLength);
                            signed=inputPrecision.SignednessBool;
                        end
                        outputDT=fi(0,signed,wordLength,fractionLength,'RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction);
                    else
                        outputDT=double(0);
                    end
                elseif ischar(inputDT)
                    if strcmpi(inputDT,'single')
                        outputDT=single(0);
                    else
                        outputDT=double(0);
                    end
                elseif isa(inputDT,'single')
                    outputDT=single(0);
                else
                    outputDT=double(0);
                end
            elseif ischar(inputDT)
                if strcmpi(inputDT,'single')
                    outputDT=single(0);
                else
                    outputDT=double(0);
                end
            elseif isa(inputDT,'single')
                outputDT=single(0);
            elseif isa(inputDT,'double')
                outputDT=double(0);
            elseif isdouble(inputDT)
                outputDT=double(0);
            elseif issingle(inputDT)
                outputDT=single(0);
            elseif isnumerictype(inputDT)
                FilterOutputDT=obj.FilterOutputDataType;
                CoefficientDT=getCoefficientsDT(obj,inputDT);
                [fullPrecision,inputPrecision]=coder.const(@dsp.internal.FIRFilterPrecision,...
                cast(obj.FilterCoefficients,'like',CoefficientDT),inputDT);





                if isnumerictype(FilterOutputDT)
                    wordLength=FilterOutputDT.WordLength;
                    fractionLength=FilterOutputDT.FractionLength;
                    signed=FilterOutputDT.SignednessBool;
                elseif strcmpi(FilterOutputDT,'Full precision')
                    wordLength=fullPrecision.WordLength;
                    fractionLength=fullPrecision.FractionLength;
                    signed=fullPrecision.SignednessBool;
                elseif strcmpi(FilterOutputDT,'Same word length as input')
                    wordLength=inputPrecision.WordLength;
                    fractionLength=inputPrecision.FractionLength;
                    signed=inputPrecision.SignednessBool;
                end
                outputDT=fi(0,signed,wordLength,fractionLength,'RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction);
            else
                outputDT=double(0);
            end
        end
        function coefficientsDT=getCoefficientsDT(obj,varargin)
            if nargin>1
                inputDT=varargin{end};
            else
                inputDT=[];
            end
            if isempty(inputDT)

                CoefficientsDT=obj.CoefficientsDataType;
                if isnumerictype(CoefficientsDT)
                    wordLength=CoefficientsDT.WordLength;
                    signedness=CoefficientsDT.SignednessBool;
                    if CoefficientsDT.isscalingunspecified
                        coefficientsDT=fi(obj.FilterCoefficients,signedness,wordLength,'OverflowAction','Saturate','RoundingMethod','Nearest');
                    else
                        fractionLength=CoefficientsDT.FractionLength;
                        coefficientsDT=fi(0,signedness,wordLength,fractionLength,'OverflowAction','Saturate','RoundingMethod','Nearest');
                    end
                else
                    coefficientsDT=[];


                end
            elseif ischar(inputDT)
                if strcmpi(inputDT,'single')
                    coefficientsDT=single(0);
                else
                    coefficientsDT=double(0);
                end
            elseif isa(inputDT,'double')
                coefficientsDT=double(0);
            elseif isa(inputDT,'single')
                coefficientsDT=single(0);
            elseif isdouble(inputDT)
                coefficientsDT=double(0);
            elseif issingle(inputDT)
                coefficientsDT=single(0);
            elseif isnumerictype(inputDT)
                CoefficientsDT=obj.CoefficientsDataType;

                if isnumerictype(CoefficientsDT)
                    wordLength=CoefficientsDT.WordLength;
                    signedness=CoefficientsDT.SignednessBool;
                    if CoefficientsDT.isscalingunspecified
                        DT=fi(obj.FilterCoefficients,signedness,wordLength,'OverflowAction','Saturate','RoundingMethod','Nearest');
                        coefficientsDT=fi(0,DT.Signed,DT.WordLength,DT.FractionLength,'OverflowAction','Saturate','RoundingMethod','Nearest');
                    else
                        fractionLength=CoefficientsDT.FractionLength;
                        coefficientsDT=fi(0,signedness,wordLength,fractionLength,'OverflowAction','Saturate','RoundingMethod','Nearest');
                    end

                else
                    coef=fi(obj.FilterCoefficients,1,inputDT.WordLength);
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
    end


    methods(Static,Access=protected)






        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end
        function groups=getPropertyGroupsImpl

            FilterSection=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'FilterCoefficientSource','NumFilterBanks','FilterCoefficients','ComplexMultiplication'});

            filter=matlab.system.display.SectionGroup(...
            'TitleSource','Auto',...
            'Sections',FilterSection);

            className=mfilename('class');
            dataTypesGroup=matlab.system.display.internal.DataTypesGroup(className);
            dataTypesGroup.PropertyList{3}=...
            matlab.system.display.internal.DataTypeProperty('CoefficientsDataType',...
            'Description','Coefficient data type');
            dataTypesGroup.PropertyList{4}=...
            matlab.system.display.internal.DataTypeProperty('FilterOutputDataType',...
            'Description','Filter output data type');

            controlInSection=matlab.system.display.Section(...
            'Title','Input Control Ports',...
            'PropertyList',{'ResetInputPort'});

            control=matlab.system.display.SectionGroup(...
            'Title','Control Ports',...
            'Sections',controlInSection);

            groups=[filter,dataTypesGroup,control];
        end
    end
    methods(Access=protected)
        function num=getNumInputsImpl(obj)
            num=2;
            if strcmp(obj.FilterCoefficientSource,'Input port (Parallel interface)')
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

            if strcmp(obj.FilterCoefficientSource,'Input port (Parallel interface)')
                inputPortInd=inputPortInd+1;
                varargout{inputPortInd}='coeffVec';
            end

            if obj.ResetInputPort
                inputPortInd=inputPortInd+1;
                varargout{inputPortInd}='reset';
            end

        end
        function num=getNumOutputsImpl(~)
            num=2;

        end

        function varargout=getOutputNamesImpl(obj)

            varargout=cell(1,getNumOutputs(obj));
            outputPortInd=1;
            varargout{outputPortInd}='data';
            outputPortInd=outputPortInd+1;
            varargout{outputPortInd}='valid';
        end

        function varargout=getOutputDataTypeImpl(obj)
            inputDT=propagatedInputDataType(obj,1);
            if strcmpi(obj.FilterCoefficientSource,'Input port (Parallel interface)')&&isempty(obj.FilterCoefficients)
                ds3=propagatedInputSize(obj,3);
            else
                ds3=length(obj.FilterCoefficients);
            end
            if~isempty(inputDT)
                if isnumerictype(inputDT)
                    varargout{1}=numerictype(getOutputDT(obj,inputDT,ds3));
                else
                    varargout{1}=inputDT;
                end
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
            propagatedInputComplexity(obj,1)
            if propagatedInputComplexity(obj,1)||~isreal(obj.FilterCoefficients)
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

            varargout{1}=propagatedInputSize(obj,1);

            for ii=2:getNumOutputs(obj)
                varargout{ii}=1;
            end
        end

        function varargout=isInputDirectFeedthroughImpl(~,varargin)

            for ii=1:nargout
                varargout{ii}=false;
            end

        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.pFilterStructure=obj.pFilterStructure;
                s.pNumFilterBanks=obj.pNumFilterBanks;
                s.pComplexMultiplication=obj.pComplexMultiplication;
                s.pFilterCoefficients=obj.pFilterCoefficients;
                s.pFilterCoefficientsPlus=obj.pFilterCoefficientsPlus;
                s.pFilterCoefficientsMinus=obj.pFilterCoefficientsMinus;
                s.pFilterCoefficientsImag=obj.pFilterCoefficientsImag;
                s.pRoundingMethod=obj.pRoundingMethod;
                s.pOverflowAction=obj.pOverflowAction;
                s.pCoefficientsDataType=obj.pCoefficientsDataType;
                s.pFilterOutputDataType=obj.pFilterOutputDataType;
                s.pInputVectorSize=obj.pInputVectorSize;
                s.pFiMath=obj.pFiMath;
                s.pUserFiMath=obj.pUserFiMath;
                s.pOutputBufferSize=obj.pOutputBufferSize;
                s.pInitialLatency=obj.pInitialLatency;
                s.pWrOutBuffer_roll=obj.pWrOutBuffer_roll;
                s.pRdOutBuffer_roll=obj.pRdOutBuffer_roll;
                s.pResetStart=obj.pResetStart;
                s.pOutputVld=obj.pOutputVld;
                s.pDinVldReg1=obj.pDinVldReg1;
                s.pDinVldReg2=obj.pDinVldReg2;

                s.pWrOutBuffer_index=obj.pWrOutBuffer_index;
                s.pRdOutBuffer_index=obj.pRdOutBuffer_index;
                s.pSimTime=obj.pSimTime;
                s.pOutputBuffer=obj.pOutputBuffer;
                s.pFilterBankIndex=obj.pFilterBankIndex;
                s.pOutputSize=obj.pOutputSize;
                s.pVldInPipeline=obj.pVldInPipeline;
                s.pDelayLine=obj.pDelayLine;
                s.pDelayLineP=obj.pDelayLineP;
                s.pDelayLineM=obj.pDelayLineM;
                s.pDelayLineI=obj.pDelayLineI;
                s.pAccReg=obj.pAccReg;
                s.pAccRegP=obj.pAccRegP;
                s.pAccRegM=obj.pAccRegM;
                s.pAccRegI=obj.pAccRegI;
                s.pFilterSymmetry=obj.pFilterSymmetry;
                s.pInvalidSampleCnt=obj.pInvalidSampleCnt;
                s.pCmplxCmplxFIR=obj.pCmplxCmplxFIR;
                s.pRealRealFIR=obj.pRealRealFIR;
                s.pCoefMask=obj.pCoefMask;
                s.pCoeffDTCheck=obj.pCoeffDTCheck;
                s.pDataOut=obj.pDataOut;
                s.pDataOutVld=obj.pDataOutVld;
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
        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case 'NumFilterBanks'
                if strcmpi(obj.FilterCoefficientSource,'Property')
                    flag=true;
                end




            end
        end
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end

        function icon=getIconImpl(obj)
            inputSize=getInputVectorSize(obj);
            if isempty(inputSize)
                icon=sprintf('FilterBank\nLatency = --');
            else
                icon=sprintf('FilterBank\nLatency = %d',getLatency(obj));
            end
        end
    end



    methods

        function obj=AbstractFilterBank(varargin)
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



        function set.ComplexMultiplication(obj,val)
            validatestring(val,{'Use 3 multipliers and 5 adders',...
            'Use 4 multipliers and 2 adders'},'AbstractFilterBank','ComplexMultiplication');
            obj.ComplexMultiplication=val;
        end

        function set.RoundingMethod(obj,val)
            validatestring(val,{'Ceiling','Convergent','Floor',...
            'Nearest','Round','Zero'},'AbstractFilterBank','Rounding mode');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            validatestring(val,{'Wrap','Saturate'},'AbstractFilterBank','Overflow Action');
            obj.OverflowAction=val;
        end

        function set.FilterCoefficientSource(obj,val)
            validatestring(val,{'Property','Input port (Parallel interface)'},'AbstractFilterBank','FilterCoefficientSource');
            obj.FilterCoefficientSource=val;
        end

    end



    methods(Access=protected)
        function validatePropertiesImpl(obj)



            if~strcmpi(obj.FilterCoefficientSource,'Input port (Parallel interface)')
                coef=obj.FilterCoefficients;
                validateattributes(coef,{'numeric','embedded.fi'},{'2d'},'AbstractFilterBank','FilterCoefficients');
                validateCoefDataType(obj,obj.isInMATLABSystemBlock);
            end

        end
        function validateInputsImpl(obj,varargin)










            validDataType={'double','single','uint8','uint16','uint32','int8','int16','int32','int64','embedded.fi'};
            validDimension={'vector','column'};

            validateattributes(varargin{1},validDataType,validDimension,'AbstractFilterBank','data');

            if isa(varargin{1},'embedded.fi')
                din=varargin{1};
                wordLength=din.WordLength;
                if wordLength<obj.MinWordLength||wordLength>obj.MaxWordLength
                    coder.internal.error('dsphdl:FFT:EmbeddedFi');
                end
            end







            if strcmpi(obj.FilterCoefficientSource,'Input port (Parallel interface)')
                coeff=varargin{3};
                if length(varargin{1})==1
                    validateattributes(coeff,validDataType,{'vector'},'AbstractFilterBank','Coeff');
                else
                    validateattributes(coeff,validDataType,{'2d'},'AbstractFilterBank','Coeff');
                end
                if isa(coeff,'embedded.fi')
                    wordLength=coeff.WordLength;
                    if wordLength<obj.MinWordLength||wordLength>obj.MaxWordLength
                        coder.internal.error('dsphdl:FFT:EmbeddedFi');
                    end
                end
            end

            vldIn=varargin{2};

            if obj.ResetInputPort
                if strcmpi(obj.FilterCoefficientSource,'Input port (Parallel interface)')
                    rst=varargin{4};
                else
                    rst=varargin{3};
                end
            else
                rst='';
            end

            validateBoolean(obj,vldIn,rst);

        end

        function flag=isInputComplexityMutableImpl(~,~)

            flag=true;
        end

        function validateBoolean(obj,vldIn,rst)
            validDimension={'scalar'};
            if isempty(coder.target)||~eml_ambiguous_types

                validateattributes(vldIn,{'logical'},validDimension,'AbstractFilterBank','valid');
                if obj.ResetInputPort
                    validateattributes(rst,{'logical'},validDimension,'AbstractFilterBank','reset');
                end
            end

        end

        function resetImpl(obj)
            obj.pWrOutBuffer_roll=false;
            obj.pRdOutBuffer_roll=false;
            obj.pResetStart=false;
            obj.pOutputVld=false;
            obj.pDinVldReg1=false;
            obj.pDinVldReg2=false;
            obj.pWrOutBuffer_index=1;
            obj.pRdOutBuffer_index=1;
            obj.pSimTime=1;
            obj.pFilterBankIndex=1;
            obj.pOutputBuffer(:)=0;
            obj.pVldInPipeline(:)=0;
            obj.pInvalidSampleCnt(:)=0;
            obj.pDataOut(:)=0;
            obj.pDataOutVld=false;
            for loop=coder.unroll(1:obj.pNumFilterBanks)

                if obj.pCmplxCmplxFIR
                    if strcmpi(obj.FilterStructure,'Direct form systolic')&&strcmpi(obj.FilterCoefficientSource,'Input port (Parallel interface)')
                        obj.pDelayLineP(loop,:)=0;
                        obj.pDelayLineM(loop,:)=0;
                        obj.pDelayLineI(loop,:)=0;
                    end
                    obj.pAccRegP(loop,:)=0;
                    obj.pAccRegM(loop,:)=0;
                    obj.pAccRegI(loop,:)=0;
                else
                    if strcmpi(obj.FilterStructure,'Direct form systolic')&&strcmpi(obj.FilterCoefficientSource,'Input port (Parallel interface)')
                        obj.pDelayLine(loop,:)=0;
                    end
                    obj.pAccReg(loop,:)=0;
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

            if~isfloat(A)
                obj.pFiMath=fimath('RoundingMethod','Floor','OverflowAction','Wrap');
                obj.pUserFiMath=fimath('RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction);
            end
            inputDT=getInputDT(obj,A);

















            filterLen=length(obj.FilterCoefficients);
            filterCoefficients=obj.FilterCoefficients;






            obj.pCoefMask=(filterCoefficients~=0);

            if~isfloat(getCoefficientsDT(obj,inputDT))
                coefType=getCoefficientsDT(obj,inputDT);
                if~coefType.SignednessBool
                    signedType=numerictype(1,coefType.WordLength+1,coefType.FractionLength);
                    obj.pCoefficientsDataType=fi(0,signedType);
                else
                    obj.pCoefficientsDataType=coefType;
                end
            else
                obj.pCoefficientsDataType=getCoefficientsDT(obj,inputDT);
            end
            obj.pFilterSymmetry=obj.getSymmetryFIRS(obj.FilterCoefficients,obj.pCoefficientsDataType,obj.FilterCoefficientSource);

            obj.pFilterCoefficients=cast(obj.FilterCoefficients,'like',obj.pCoefficientsDataType);
            obj.pFilterCoefficientsPlus=real(obj.pFilterCoefficients)+imag(obj.pFilterCoefficients);
            obj.pFilterCoefficientsMinus=real(obj.pFilterCoefficients)-imag(obj.pFilterCoefficients);
            obj.pFilterCoefficientsImag=imag(obj.pFilterCoefficients);


            obj.pFilterOutputDataType=getOutputDT(obj,inputDT,filterLen);
            [obj.pNumFilterBanks,numberOfTaps]=size(filterCoefficients);
            obj.pInputVectorSize=length(A);
            obj.pComplexMultiplication=obj.ComplexMultiplication;
            obj.pRoundingMethod=obj.RoundingMethod;
            obj.pOverflowAction=obj.OverflowAction;
            obj.pCmplxCmplxFIR=~(isreal(obj.FilterCoefficients))&&~(isreal(A));
            obj.pRealRealFIR=isreal(obj.FilterCoefficients)&&isreal(A);
            obj.pInitialLatency=getLatency(obj,obj.pCoefficientsDataType,obj.FilterCoefficients,obj.pNumFilterBanks,obj.pInputVectorSize,~isreal(A))-double(and(~isreal(A),~isreal(filterCoefficients)));
            obj.pOutputBufferSize=8*obj.pInputVectorSize*obj.pInitialLatency;
            obj.pVldInPipeline=zeros(obj.pInitialLatency,1);
            obj.pOutputSize=obj.pInputVectorSize;
            obj.pWrOutBuffer_index=1;
            obj.pRdOutBuffer_index=1;
            obj.pWrOutBuffer_roll=false;
            obj.pRdOutBuffer_roll=false;
            obj.pSimTime=1;
            obj.pResetStart=false;
            obj.pOutputVld=false;
            obj.pDinVldReg1=false;
            obj.pDinVldReg2=false;
            obj.pFilterBankIndex=1;
            if~isreal(A)||~isreal(obj.pFilterCoefficients)
                obj.pOutputBuffer=complex(zeros(obj.pOutputBufferSize,1,'like',obj.pFilterOutputDataType),zeros(obj.pOutputBufferSize,1,'like',obj.pFilterOutputDataType));
                obj.pDataOut=complex(zeros(obj.pInputVectorSize,1,'like',obj.pFilterOutputDataType),zeros(obj.pInputVectorSize,1,'like',obj.pFilterOutputDataType));
            else
                obj.pOutputBuffer=zeros(obj.pOutputBufferSize,1,'like',obj.pFilterOutputDataType);
                obj.pDataOut=zeros(obj.pInputVectorSize,1,'like',obj.pFilterOutputDataType);
            end
            obj.pDataOutVld=false;

            delayLineLn=numberOfTaps;
            accRegLen=numberOfTaps;








            if strcmpi(obj.FilterStructure,'Direct form systolic')&&strcmpi(obj.FilterCoefficientSource,'Input port (Parallel interface)')
                if obj.pFilterSymmetry.isSymmetric~=0
                    delayLineLn=numberOfTaps;
                    accRegLen=ceil(numberOfTaps/2);
                else
                    delayLineLn=2*numberOfTaps;
                    accRegLen=numberOfTaps;
                end
            else
                accRegLen=numberOfTaps;
            end
            if isnumerictype(inputDT)&&(~isfloat(inputDT))
                coefWL=get(obj.pCoefficientsDataType,'WordLength');
                coefFL=get(obj.pCoefficientsDataType,'FractionLength');
                accSign=inputDT.SignednessBool||get(obj.pCoefficientsDataType,'SignednessBool');

                if obj.pFilterSymmetry.isSymmetric~=0
                    accDT=fi(0,accSign,coefWL+inputDT.WordLength+ceil(log2(filterLen))+1,coefFL+inputDT.FractionLength);
                else
                    accDT=fi(0,accSign,coefWL+inputDT.WordLength+ceil(log2(filterLen)),coefFL+inputDT.FractionLength);
                end
                if strcmpi(obj.FilterStructure,'Direct form systolic')&&strcmpi(obj.FilterCoefficientSource,'Input port (Parallel interface)')
                    if obj.pCmplxCmplxFIR
                        obj.pDelayLineP=zeros(obj.pNumFilterBanks,delayLineLn,'like',fi(0,inputDT.Signed,inputDT.WordLength+1,inputDT.FractionLength));
                        obj.pDelayLineM=zeros(obj.pNumFilterBanks,delayLineLn,'like',fi(0,inputDT.Signed,inputDT.WordLength+1,inputDT.FractionLength));
                        obj.pDelayLineI=zeros(obj.pNumFilterBanks,delayLineLn,'like',fi(0,inputDT.Signed,inputDT.WordLength+1,inputDT.FractionLength));
                    elseif isreal(A)
                        obj.pDelayLine=zeros(obj.pNumFilterBanks,delayLineLn,'like',fi(0,inputDT));
                    else
                        obj.pDelayLine=complex(zeros(obj.pNumFilterBanks,delayLineLn,'like',fi(0,inputDT)));
                    end

                    if obj.pRealRealFIR
                        obj.pAccReg=zeros(obj.pNumFilterBanks,accRegLen,'like',accDT);
                    elseif obj.pCmplxCmplxFIR
                        obj.pAccRegP=zeros(obj.pNumFilterBanks,accRegLen,'like',accDT);
                        obj.pAccRegM=zeros(obj.pNumFilterBanks,accRegLen,'like',accDT);
                        obj.pAccRegI=zeros(obj.pNumFilterBanks,accRegLen,'like',accDT);
                    else
                        obj.pAccReg=complex(zeros(obj.pNumFilterBanks,accRegLen,'like',accDT));
                    end
                else
                    if obj.pRealRealFIR
                        obj.pAccReg=zeros(obj.pNumFilterBanks,accRegLen,'like',accDT);
                    elseif obj.pCmplxCmplxFIR
                        obj.pAccRegP=zeros(obj.pNumFilterBanks,accRegLen,'like',accDT);
                        obj.pAccRegM=zeros(obj.pNumFilterBanks,accRegLen,'like',accDT);
                        obj.pAccRegI=zeros(obj.pNumFilterBanks,accRegLen,'like',accDT);
                    else
                        obj.pAccReg=complex(zeros(obj.pNumFilterBanks,accRegLen,'like',accDT));
                    end

                    if obj.pCmplxCmplxFIR
                        obj.pDelayLineP=zeros(obj.pNumFilterBanks,delayLineLn,'like',fi(0,inputDT.Signed,inputDT.WordLength+1,inputDT.FractionLength));
                        obj.pDelayLineM=zeros(obj.pNumFilterBanks,delayLineLn,'like',fi(0,inputDT.Signed,inputDT.WordLength+1,inputDT.FractionLength));
                        obj.pDelayLineI=zeros(obj.pNumFilterBanks,delayLineLn,'like',fi(0,inputDT.Signed,inputDT.WordLength+1,inputDT.FractionLength));
                    elseif isreal(A)
                        obj.pDelayLine=zeros(obj.pNumFilterBanks,delayLineLn,'like',fi(0,inputDT));
                    else
                        obj.pDelayLine=complex(zeros(obj.pNumFilterBanks,delayLineLn,'like',fi(0,inputDT)));
                    end
                end
            else
                if strcmpi(obj.FilterStructure,'Direct form systolic')&&strcmpi(obj.FilterCoefficientSource,'Input port (Parallel interface)')
                    if obj.pCmplxCmplxFIR
                        obj.pDelayLineP=zeros(obj.pNumFilterBanks,delayLineLn,'like',real(A));
                        obj.pDelayLineM=zeros(obj.pNumFilterBanks,delayLineLn,'like',real(A));
                        obj.pDelayLineI=zeros(obj.pNumFilterBanks,delayLineLn,'like',real(A));
                    elseif isreal(A)
                        obj.pDelayLine=zeros(obj.pNumFilterBanks,delayLineLn,'like',A);
                    else
                        obj.pDelayLine=complex(zeros(obj.pNumFilterBanks,delayLineLn,'like',A));
                    end

                    if obj.pRealRealFIR
                        obj.pAccReg=zeros(obj.pNumFilterBanks,accRegLen,'like',A);
                    elseif obj.pCmplxCmplxFIR
                        obj.pAccRegP=zeros(obj.pNumFilterBanks,accRegLen,'like',real(A));
                        obj.pAccRegM=zeros(obj.pNumFilterBanks,accRegLen,'like',real(A));
                        obj.pAccRegI=zeros(obj.pNumFilterBanks,accRegLen,'like',real(A));
                    else
                        obj.pAccReg=complex(zeros(obj.pNumFilterBanks,accRegLen,'like',A));
                    end
                else
                    if obj.pRealRealFIR
                        obj.pAccReg=zeros(obj.pNumFilterBanks,accRegLen,'like',A);
                    elseif obj.pCmplxCmplxFIR
                        obj.pAccRegP=zeros(obj.pNumFilterBanks,accRegLen,'like',real(A));
                        obj.pAccRegM=zeros(obj.pNumFilterBanks,accRegLen,'like',real(A));
                        obj.pAccRegI=zeros(obj.pNumFilterBanks,accRegLen,'like',real(A));
                    else
                        obj.pAccReg=complex(zeros(obj.pNumFilterBanks,accRegLen,'like',A));
                    end

                    if obj.pCmplxCmplxFIR
                        obj.pDelayLineP=zeros(obj.pNumFilterBanks,delayLineLn,'like',real(A));
                        obj.pDelayLineM=zeros(obj.pNumFilterBanks,delayLineLn,'like',real(A));
                        obj.pDelayLineI=zeros(obj.pNumFilterBanks,delayLineLn,'like',real(A));
                    elseif isreal(A)
                        obj.pDelayLine=zeros(obj.pNumFilterBanks,delayLineLn,'like',A);
                    else
                        obj.pDelayLine=complex(zeros(obj.pNumFilterBanks,delayLineLn,'like',A));
                    end
                end
            end
            obj.pInvalidSampleCnt=zeros(obj.pNumFilterBanks,1);

        end
    end




    methods(Static,Hidden)
    end



    methods(Access=protected)
        function varargout=outputImpl(obj,varargin)

            if obj.pCmplxCmplxFIR||all(~any(obj.pFilterCoefficients))
                varargout{1}=obj.pDataOut;
                varargout{2}=obj.pDataOutVld;
            else
                dLen=obj.pOutputSize;
                [dataOut,dataOutVld]=read_outBuffer(obj,dLen);
                varargout{1}=dataOut;
                varargout{2}=dataOutVld;
            end

        end

        function updateImpl(obj,varargin)

            if~coder.target('hdl')
                dLen=obj.pOutputSize;
                if obj.pCmplxCmplxFIR
                    [obj.pDataOut,obj.pDataOutVld]=read_outBuffer(obj,dLen);
                else
                    obj.pDataOut(:)=0;
                    obj.pDataOutVld=false;
                end
                if isDataReady(obj)
                    if obj.pOutputVld
                        for loop=1:dLen
                            if obj.pRdOutBuffer_index<obj.pOutputBufferSize
                                obj.pRdOutBuffer_index=obj.pRdOutBuffer_index+1;
                            else
                                obj.pRdOutBuffer_index=1;
                                obj.pRdOutBuffer_roll=~obj.pRdOutBuffer_roll;
                            end
                        end
                    end
                end


                dataInTmp=varargin{1};
                validIn=varargin{2};

                if obj.ResetInputPort
                    if strcmpi(obj.FilterCoefficientSource,'Input port (Parallel interface)')
                        resetIn=varargin{4};
                    else
                        resetIn=varargin{3};
                    end
                else
                    resetIn=false;
                end
                if obj.pResetStart
                    obj.pResetStart=0;
                end

                if resetIn==1
                    obj.pResetStart=1;
                end
                reset=resetIfTrue(obj);

                if any(obj.pFilterCoefficients(:))
                    delayVldIn(obj,reset,validIn);
                end

                if~isfloat(dataInTmp)
                    dataInType=numerictype(dataInTmp);
                    if~dataInType.SignednessBool
                        signedType=numerictype(1,dataInType.WordLength+1,dataInType.FractionLength);
                        dataIn=fi(dataInTmp,signedType);
                    else
                        dataIn=dataInTmp;
                    end
                else
                    dataIn=dataInTmp;
                end
                if strcmpi(obj.FilterCoefficientSource,'Input port (Parallel interface)')
                    coef=varargin{3};



                    coef_tmp1=coef;



                    isFilterSymmetric=abs(double(obj.pFilterSymmetry.isSymmetric));
                    if isFilterSymmetric




                        if mod(length(obj.FilterCoefficients),2)
                            if obj.FilterCoefficients(1)==obj.FilterCoefficients(end)
                                coef_tmp=[coef_tmp1(1:length(coef_tmp1)-1),coef_tmp1(length(coef_tmp1)),+fliplr(coef_tmp1(1:length(coef_tmp1)-1))];
                            else
                                coef_tmp=[coef_tmp1(1:length(coef_tmp1)-1),coef_tmp1(length(coef_tmp1)),-fliplr(coef_tmp1(1:length(coef_tmp1)-1))];
                            end
                        else
                            if obj.FilterCoefficients(1)==obj.FilterCoefficients(end)
                                coef_tmp=[coef_tmp1(1:length(coef_tmp1)),fliplr(coef_tmp1(1:length(coef_tmp1)))];
                            else
                                coef_tmp=[coef_tmp1(1:length(coef_tmp1)),-fliplr(coef_tmp1(1:length(coef_tmp1)))];
                            end
                        end

                        [numRow,numCol]=size(coef_tmp);
                        coefMask=obj.pCoefMask;
                        coef_tmp2=zeros(numRow,numCol,'like',coef_tmp1);
                        for loop1=1:numRow
                            for loop2=1:numCol
                                if coefMask(loop1,loop2)
                                    coef_tmp2(loop1,loop2)=coef_tmp(loop1,loop2);
                                else
                                    coef_tmp2(loop1,loop2)=0;
                                end
                            end
                        end

                    else
                        [numRow,numCol]=size(coef_tmp1);
                        coefMask=obj.pCoefMask;
                        coef_tmp2=zeros(numRow,numCol,'like',coef_tmp1);
                        if~isempty(obj.FilterCoefficients)
                            for loop1=1:numRow
                                for loop2=1:numCol
                                    if coefMask(loop1,loop2)
                                        coef_tmp2(loop1,loop2)=coef_tmp1(loop1,loop2);
                                    else
                                        coef_tmp2(loop1,loop2)=0;
                                    end
                                end
                            end
                        else
                            coef_tmp2=coef_tmp1;
                        end
                    end
                    filterCoef=coef_tmp2;
                    filterCoefP=cast(real(filterCoef),'like',obj.pCoefficientsDataType)+cast(imag(filterCoef),'like',obj.pCoefficientsDataType);
                    filterCoefM=cast(real(filterCoef),'like',obj.pCoefficientsDataType)-cast(imag(filterCoef),'like',obj.pCoefficientsDataType);
                    filterCoefI=cast(imag(filterCoef),'like',obj.pCoefficientsDataType);
                else
                    filterCoef=obj.pFilterCoefficients;
                    filterCoefP=obj.pFilterCoefficientsPlus;
                    filterCoefM=obj.pFilterCoefficientsMinus;
                    filterCoefI=obj.pFilterCoefficientsImag;
                end

                if all(~any(obj.pFilterCoefficients))

                    obj.pDataOut(:)=0;
                    obj.pDataOutVld=validIn;

                else
                    if~reset&&validIn
                        if strcmpi(obj.FilterCoefficientSource,'Input port (Parallel interface)')
                            if strcmpi(obj.FilterStructure,'Direct form systolic')
                                updateSFIR(obj,dataIn,filterCoef,filterCoefP,filterCoefM,filterCoefI);
                            else
                                updateTFIR(obj,dataIn,filterCoef,filterCoefP,filterCoefM,filterCoefI);
                            end
                        else

                            updateTFIR(obj,dataIn,filterCoef,filterCoefP,filterCoefM,filterCoefI);
                        end
                    end
                    updateSimTime(obj);
                end
            end
        end

        function updateDFIR(obj,dataIn,filterCoef,filterCoefP,filterCoefM,filterCoefI)
            outputType=obj.pFilterOutputDataType;
            isCmplxCmplx=obj.pCmplxCmplxFIR;
            for loop=coder.unroll(1:length(dataIn))
                filterIndex=obj.pFilterBankIndex;
                if isCmplxCmplx
                    obj.pDelayLineP(filterIndex,:)=[real(dataIn(loop)),obj.pDelayLineP(filterIndex,1:end-1)];
                    obj.pDelayLineM(filterIndex,:)=[imag(dataIn(loop)),obj.pDelayLineM(filterIndex,1:end-1)];
                    obj.pDelayLineI(filterIndex,:)=[real(dataIn(loop))+imag(dataIn(loop)),obj.pDelayLineI(filterIndex,1:end-1)];
                elseif isreal(dataIn)
                    obj.pDelayLine(filterIndex,:)=[dataIn(loop),obj.pDelayLine(filterIndex,1:end-1)];
                else
                    obj.pDelayLine(filterIndex,:)=[complex(dataIn(loop)),obj.pDelayLine(filterIndex,1:end-1)];
                end

                if isCmplxCmplx
                    filterOut_P=obj.pDelayLineP(filterIndex,:)*transpose(filterCoefP(filterIndex,:));
                    filterOut_I=obj.pDelayLineI(filterIndex,:)*transpose(filterCoefI(filterIndex,:));
                    filterOut_M=obj.pDelayLineM(filterIndex,:)*transpose(filterCoefM(filterIndex,:));
                    filterOut=complex(filterOut_P-filterOut_I,filterOut_M+filterOut_I);
                else
                    filterOut=obj.pDelayLine(filterIndex,:)*transpose(filterCoef(filterIndex,:));
                end

                if obj.pFilterBankIndex<obj.pNumFilterBanks
                    obj.pFilterBankIndex=obj.pFilterBankIndex+1;
                else
                    obj.pFilterBankIndex=1;
                end

                if isfi(outputType)

                    filterOut_cast=cast(filterOut,'like',outputType);

                    write_outBuffer(obj,filterOut_cast);
                else
                    write_outBuffer(obj,filterOut);
                end
            end
        end
        function updateSFIR(obj,dataIn,filterCoef,filterCoefP,filterCoefM,filterCoefI)
            [~,filterLen]=size(filterCoef);
            isCmplxCmplx=obj.pCmplxCmplxFIR;

            for loop=coder.unroll(1:length(dataIn))
                filterIndex=obj.pFilterBankIndex;
                if isCmplxCmplx
                    obj.pDelayLineP(filterIndex,:)=[real(dataIn(loop)),obj.pDelayLineP(filterIndex,1:end-1)];
                    obj.pDelayLineM(filterIndex,:)=[imag(dataIn(loop)),obj.pDelayLineM(filterIndex,1:end-1)];
                    obj.pDelayLineI(filterIndex,:)=[real(dataIn(loop))+imag(dataIn(loop)),obj.pDelayLineI(filterIndex,1:end-1)];
                elseif isreal(dataIn)
                    obj.pDelayLine(filterIndex,:)=[dataIn(loop),obj.pDelayLine(filterIndex,1:end-1)];
                else
                    obj.pDelayLine(filterIndex,:)=[complex(dataIn(loop)),obj.pDelayLine(filterIndex,1:end-1)];
                end
                if obj.pFilterSymmetry.isSymmetric==0
                    if isCmplxCmplx
                        accP=obj.pDelayLineP(filterIndex,1:2:end).*filterCoefP(filterIndex,:)+obj.pAccRegP(filterIndex,:);
                        accM=obj.pDelayLineM(filterIndex,1:2:end).*filterCoefM(filterIndex,:)+obj.pAccRegM(filterIndex,:);
                        accI=obj.pDelayLineI(filterIndex,1:2:end).*filterCoefI(filterIndex,:)+obj.pAccRegI(filterIndex,:);
                        filterOut=complex(accP(end)-accI(end),accM(end)+accI(end));
                        obj.pAccRegP(filterIndex,:)=[0,accP(1:end-1)];
                        obj.pAccRegM(filterIndex,:)=[0,accM(1:end-1)];
                        obj.pAccRegI(filterIndex,:)=[0,accI(1:end-1)];
                    else
                        acc=obj.pDelayLine(filterIndex,1:2:end).*filterCoef(filterIndex,:)+obj.pAccReg(filterIndex,:);
                        filterOut=acc(end);
                        obj.pAccReg(filterIndex,:)=[0,acc(1:end-1)];
                    end

                elseif obj.pFilterSymmetry.isSymmetric==1
                    if isCmplxCmplx
                        if mod(filterLen,2)
                            preAddP=[(obj.pDelayLineP(filterIndex,1:2:end-1)+obj.pDelayLineP(filterIndex,end)),obj.pDelayLineP(filterIndex,end)];
                            preAddM=[(obj.pDelayLineM(filterIndex,1:2:end-1)+obj.pDelayLineM(filterIndex,end)),obj.pDelayLineM(filterIndex,end)];
                            preAddI=[(obj.pDelayLineI(filterIndex,1:2:end-1)+obj.pDelayLineI(filterIndex,end)),obj.pDelayLineI(filterIndex,end)];
                        else
                            preAddP=(obj.pDelayLineP(filterIndex,1:2:end)+obj.pDelayLineP(filterIndex,end));
                            preAddM=(obj.pDelayLineM(filterIndex,1:2:end)+obj.pDelayLineM(filterIndex,end));
                            preAddI=(obj.pDelayLineI(filterIndex,1:2:end)+obj.pDelayLineI(filterIndex,end));
                        end
                        accP=preAddP.*filterCoefP(filterIndex,1:ceil(filterLen/2))+obj.pAccRegP(filterIndex,:);
                        accM=preAddM.*filterCoefM(filterIndex,1:ceil(filterLen/2))+obj.pAccRegM(filterIndex,:);
                        accI=preAddI.*filterCoefI(filterIndex,1:ceil(filterLen/2))+obj.pAccRegI(filterIndex,:);
                        filterOut=complex(accP(end)-accI(end),accM(end)+accI(end));
                        obj.pAccRegP(filterIndex,:)=[0,accP(1:end-1)];
                        obj.pAccRegM(filterIndex,:)=[0,accM(1:end-1)];
                        obj.pAccRegI(filterIndex,:)=[0,accI(1:end-1)];
                    else
                        if mod(filterLen,2)
                            preAdd=[(obj.pDelayLine(filterIndex,1:2:end-1)+obj.pDelayLine(filterIndex,end)),obj.pDelayLine(filterIndex,end)];
                        else
                            preAdd=(obj.pDelayLine(filterIndex,1:2:end)+obj.pDelayLine(filterIndex,end));
                        end
                        acc=preAdd.*filterCoef(filterIndex,1:ceil(filterLen/2))+obj.pAccReg(filterIndex,:);
                        filterOut=acc(end);
                        obj.pAccReg(filterIndex,:)=[0,acc(1:end-1)];
                    end
                else
                    if isCmplxCmplx
                        if mod(filterLen,2)
                            preAddP=[(obj.pDelayLineP(filterIndex,1:2:end-1)-obj.pDelayLineP(filterIndex,end)),obj.pDelayLineP(filterIndex,end)];
                            preAddM=[(obj.pDelayLineM(filterIndex,1:2:end-1)-obj.pDelayLineM(filterIndex,end)),obj.pDelayLineM(filterIndex,end)];
                            preAddI=[(obj.pDelayLineI(filterIndex,1:2:end-1)-obj.pDelayLineI(filterIndex,end)),obj.pDelayLineI(filterIndex,end)];
                        else
                            preAddP=(obj.pDelayLineP(filterIndex,1:2:end)-obj.pDelayLineP(filterIndex,end));
                            preAddM=(obj.pDelayLineM(filterIndex,1:2:end)-obj.pDelayLineM(filterIndex,end));
                            preAddI=(obj.pDelayLineI(filterIndex,1:2:end)-obj.pDelayLineI(filterIndex,end));
                        end
                        accP=preAddP.*filterCoefP(filterIndex,1:ceil(filterLen/2))+obj.pAccRegP(filterIndex,:);
                        accM=preAddM.*filterCoefM(filterIndex,1:ceil(filterLen/2))+obj.pAccRegM(filterIndex,:);
                        accI=preAddI.*filterCoefI(filterIndex,1:ceil(filterLen/2))+obj.pAccRegI(filterIndex,:);
                        filterOut=complex(accP(end)-accI(end),accM(end)+accI(end));
                        obj.pAccRegP(filterIndex,:)=[0,accP(1:end-1)];
                        obj.pAccRegM(filterIndex,:)=[0,accM(1:end-1)];
                        obj.pAccRegI(filterIndex,:)=[0,accI(1:end-1)];
                    else
                        if mod(filterLen,2)
                            preAdd=[(obj.pDelayLine(filterIndex,1:2:end-1)-obj.pDelayLine(filterIndex,end)),obj.pDelayLine(filterIndex,end)];
                        else
                            preAdd=(obj.pDelayLine(filterIndex,1:2:end)-obj.pDelayLine(filterIndex,end));
                        end
                        acc=preAdd.*filterCoef(filterIndex,1:ceil(filterLen/2))+obj.pAccReg(filterIndex,:);
                        filterOut=acc(end);
                        obj.pAccReg(filterIndex,:)=[0,acc(1:end-1)];
                    end
                end

                if obj.pFilterBankIndex<obj.pNumFilterBanks
                    obj.pFilterBankIndex=obj.pFilterBankIndex+1;
                else
                    obj.pFilterBankIndex=1;
                end
                outputType=obj.pFilterOutputDataType;
                noOfTaps=filterLen;
                if obj.pFilterSymmetry.isSymmetric~=0
                    noOfTaps=noOfTaps/2;
                end
                if obj.pInvalidSampleCnt(filterIndex,1)>=noOfTaps-1
                    if isfi(outputType)
                        filterOut_cast=cast(filterOut,'like',outputType);
                        write_outBuffer(obj,filterOut_cast);
                    else
                        write_outBuffer(obj,filterOut);
                    end
                end
                if obj.pInvalidSampleCnt(filterIndex,1)<noOfTaps
                    obj.pInvalidSampleCnt(filterIndex,1)=obj.pInvalidSampleCnt(filterIndex,1)+1;
                end

            end
        end
        function updateTFIR(obj,dataIn,filterCoef,filterCoefP,filterCoefM,filterCoefI)%#ok<INUSD>
            outputType=obj.pFilterOutputDataType;
            isCmplxCmplx=obj.pCmplxCmplxFIR;
            if isfloat(dataIn)
                dataIn_cast=dataIn;
            else
                dataIn_cast=fi(dataIn,dataIn.Signed,dataIn.WordLength,dataIn.FractionLength,'OverflowAction','Saturate','RoundingMethod','Nearest');
            end
            for loop=coder.unroll(1:length(dataIn_cast))
                filterIndex=obj.pFilterBankIndex;

                if isCmplxCmplx
                    product_P=real(dataIn_cast(loop))*fliplr(filterCoefP(filterIndex,:));
                    product_I=(real(dataIn_cast(loop))+imag(dataIn_cast(loop)))*fliplr(filterCoefI(filterIndex,:));
                    product_M=imag(dataIn_cast(loop))*fliplr(filterCoefM(filterIndex,:));
                    acc_P=product_P+obj.pAccRegP(filterIndex,:);
                    acc_I=product_I+obj.pAccRegI(filterIndex,:);
                    acc_M=product_M+obj.pAccRegM(filterIndex,:);
                    filterOut=complex(acc_P(end)-acc_I(end),acc_M(end)+acc_I(end));
                    obj.pAccRegP(filterIndex,:)=cast([0,acc_P(1:end-1)],'like',obj.pAccRegP);
                    obj.pAccRegI(filterIndex,:)=cast([0,acc_I(1:end-1)],'like',obj.pAccRegI);
                    obj.pAccRegM(filterIndex,:)=cast([0,acc_M(1:end-1)],'like',obj.pAccRegM);
                elseif isreal(dataIn_cast)
                    product=dataIn_cast(loop)*fliplr(filterCoef(filterIndex,:));
                    acc=product+obj.pAccReg(filterIndex,:);
                    filterOut=acc(end);
                    obj.pAccReg(filterIndex,:)=cast([0,acc(1:end-1)],'like',obj.pAccReg);
                else
                    product=complex(dataIn_cast(loop))*fliplr(filterCoef(filterIndex,:));
                    acc=product+obj.pAccReg(filterIndex,:);
                    filterOut=acc(end);
                    obj.pAccReg(filterIndex,:)=cast([0,acc(1:end-1)],'like',obj.pAccReg);
                end

                if obj.pFilterBankIndex<obj.pNumFilterBanks
                    obj.pFilterBankIndex=obj.pFilterBankIndex+1;
                else
                    obj.pFilterBankIndex=1;
                end

                if isfi(outputType)

                    filterOut_cast=cast(filterOut,'like',outputType);

                    write_outBuffer(obj,filterOut_cast);
                else
                    write_outBuffer(obj,filterOut);
                end
            end
        end



        function delayVldIn(obj,reset,validIn)

            obj.pOutputVld=false;
            if reset
                obj.pVldInPipeline(:)=0;
                obj.pOutputVld=false;
                obj.pDinVldReg1=false;
                obj.pDinVldReg2=false;
            else
                if strcmpi(obj.FilterStructure,'Direct form transposed')
                    delayLineLen=obj.pInitialLatency;
                    for loop=delayLineLen:-1:2
                        obj.pVldInPipeline(loop)=obj.pVldInPipeline(loop-1);
                    end
                    obj.pVldInPipeline(1)=validIn;
                    obj.pOutputVld=obj.pVldInPipeline(delayLineLen);
                else
                    delayLineLen=obj.pInitialLatency-1;
                    obj.pOutputVld=obj.pVldInPipeline(delayLineLen-2)&&obj.pDinVldReg2;
                    if obj.pDinVldReg2
                        for loop=delayLineLen-2:-1:2
                            obj.pVldInPipeline(loop)=obj.pVldInPipeline(loop-1);
                        end
                        obj.pVldInPipeline(1)=obj.pDinVldReg2;
                    end
                    obj.pDinVldReg2=obj.pDinVldReg1;
                    obj.pDinVldReg1=validIn;
                end
            end
        end
        function write_outBuffer(obj,data)
            obj.pOutputBuffer(obj.pWrOutBuffer_index)=data;
            if obj.pWrOutBuffer_index<obj.pOutputBufferSize
                obj.pWrOutBuffer_index=obj.pWrOutBuffer_index+1;
            else
                obj.pWrOutBuffer_index=1;
                obj.pWrOutBuffer_roll=~obj.pWrOutBuffer_roll;
            end
        end

        function[dataOut,dataOutVld]=read_outBuffer(obj,dataLength)
            if obj.pRealRealFIR
                dataOut=zeros(dataLength,1,'like',obj.pOutputBuffer);
            else
                dataOut=complex(zeros(dataLength,1,'like',obj.pOutputBuffer));
            end
            dataIndex=obj.pRdOutBuffer_index;
            if isDataReady(obj)
                if obj.pOutputVld
                    dataOutVld=true;
                    for loop=1:dataLength
                        dataOut(loop)=obj.pOutputBuffer(dataIndex);
                        if dataIndex<obj.pOutputBufferSize
                            dataIndex=dataIndex+1;
                        else
                            dataIndex=1;
                        end
                    end
                else
                    dataOutVld=false;
                end
            else
                dataOutVld=false;
            end
        end
        function status=isDataReady(obj)
            if obj.pRdOutBuffer_roll==obj.pWrOutBuffer_roll
                dataLength=obj.pWrOutBuffer_index-obj.pRdOutBuffer_index;
            else
                dataLength=obj.pOutputBufferSize-obj.pRdOutBuffer_index+obj.pWrOutBuffer_index;
            end
            if obj.pResetStart
                status=false;
            elseif dataLength>=obj.pOutputSize
                status=true;
            else
                status=false;
            end

        end
        function updateSimTime(obj)
            obj.pSimTime=obj.pSimTime+1;
        end
        function status=resetIfTrue(obj)
            status=false;
            if obj.pResetStart
                resetImpl(obj);
                status=true;

            end
        end
    end



    methods(Access=public,Hidden)
        function filterSymmetry=getSymmetryFIRS(obj,coefficient,coefficientDT,coefficientSource)
            if strcmpi(coefficientSource,'Input port (Parallel interface)')
                coeffDT=double(0);
            elseif isnumerictype(coefficientDT)
                coeffDT=fi(0,coefficientDT);
            else
                coeffDT=coefficientDT;
            end
            coeff=cast(coefficient,'like',coeffDT);
            filterSymmetry.SymmetryFromTo=[1,length(coeff)];
            if(strcmpi(coefficientSource,'Input port (Parallel interface)')&&isempty(coeff))||~obj.SymmetryOptimization
                filterSymmetry.isSymmetric=0;
                filterSymmetry.SymmetryFromTo=[1,obj.InputCoefficientLength];
                filterSymmetry.Exception=zeros(obj.InputCoefficientLength,1);
            else
                filterSymmetry.isSymmetric=0;
                filterSymmetry.Exception=zeros(length(coeff),1);
                if mod(length(coeff),2)

                    a=[coeff(1:floor(length(coeff)/2)),0,coeff(ceil(length(coeff)/2)+1:length(coeff))];
                else
                    a=coeff;
                end
                b=fliplr(a);
                if length(a)>1
                    if~any(a-b)
                        filterSymmetry.isSymmetric=1;
                    elseif~any(a+b)
                        filterSymmetry.isSymmetric=-1;
                    else
                        filterSymmetry.isSymmetric=0;
                    end
                end
            end


            if((strcmpi(coefficientSource,'Input port (Parallel interface)')&&~isempty(coeff))||strcmpi(coefficientSource,'Property'))&&obj.SymmetryOptimization
                if filterSymmetry.isSymmetric==0
                    filterSymmetry.Exception(1)=1;
                    coeffr=coeff(2:end);
                    if mod(length(coeffr),2)
                        ar=[coeffr(1:floor(length(coeffr)/2)),0,coeffr(ceil(length(coeffr)/2)+1:length(coeffr))];
                    else
                        ar=coeff(2:end);
                    end
                    br=fliplr(ar);
                    if length(ar)>1
                        if~any(ar-br)
                            filterSymmetry.isSymmetric=1;
                        elseif~any(ar+br)
                            filterSymmetry.isSymmetric=-1;
                        else
                            filterSymmetry.isSymmetric=0;
                        end
                    end
                end
            end












































        end
        function filterSymmetry=getSymmetryFIRT(obj,subFilter,blockInfo,OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH,FOLDINGFACTOR)%#ok<INUSL>
            coeffDT=fi(0,blockInfo.COEF_SIGNED,blockInfo.COEF_WORDLENGTH,-blockInfo.COEF_FRACTIONLENGTH);
            coeff=cast(blockInfo.FilterCoefficient,'like',coeffDT);
            channel=size(coeff);
            filterSymmetry=struct([]);

            for i=1:length(coeff)
                filterSymmetry(i).Number=-1;%#ok<*AGROW>
                filterSymmetry(i).Signal=[];
                filterSymmetry(i).Type='DSPFull';
            end
            if FOLDINGFACTOR==0&&channel(1)==1&&obj.SymmetryOptimization
                for i=1:length(coeff)
                    found=false;
                    for j=i+1:length(coeff)
                        if coeff(i)-coeff(j)==0||coeff(i)+coeff(j)==0
                            if filterSymmetry(i).Number<0
                                filterSymmetry(i).Number=j;
                                filterSymmetry(i).Type='DSPMultOut';
                                if~isempty(subFilter)
                                    filterSymmetry(i).Signal=subFilter.addSignal2('Type',pir_fixpt_t(1,OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH),'Name','Symmetry');
                                end

                            end
                            if filterSymmetry(j).Number<0
                                filterSymmetry(j).Number=i;
                                if coeff(i)==coeff(j)
                                    filterSymmetry(j).Type='DSPPostAdd';
                                else
                                    filterSymmetry(j).Type='DSPPostSub';
                                end
                                if~isempty(subFilter)
                                    filterSymmetry(j).Signal=filterSymmetry(i).Signal;
                                end

                            end
                            found=true;
                        end
                    end
                    if~found&&filterSymmetry(i).Number<0
                        filterSymmetry(i).Number=-1;
                        filterSymmetry(i).Signal=[];
                        filterSymmetry(i).Type='DSPFULL';
                    end
                end
            end

        end
    end

    methods(Hidden)
        function setCoeffDTCheck(obj,value)




            obj.pCoeffDTCheck=value;
        end

    end
end


