classdef(StrictDefaults)FIRFilter<matlab.System






























































































































%#codegen
%#ok<*EMCLS>




    properties(Nontunable,Constant,Hidden)
        MaxInputFrameSize=64;
    end
    properties(Nontunable)




        NumeratorSource='Property';



        Numerator=[0.5,0.5];



        NumeratorPrototype=[];




        FilterStructure='Direct form systolic';




        SerializationOption='Minimum number of cycles between valid input samples';



        NumCycles=2;



        NumberOfMultipliers=2;
    end

    properties(Nontunable,Hidden)




        RelatedCoeffOptimization(1,1)logical=true;




        SymmetryOptimization(1,1)logical=true;
    end

    properties(Dependent,Hidden)



        Sharing;

    end
    properties(Dependent,Hidden)


        SharingFactor;
        NumberOfCycles;
    end











    properties(Nontunable)


        ResetInputPort(1,1)logical=false;



        HDLGlobalReset(1,1)logical=false;
    end
    properties(Nontunable,Hidden)

        ValidInPort(1,1)logical=true;



        ReadyPort(1,1)logical=false;

    end

    properties(Nontunable)








        RoundingMethod='Floor';







        OverflowAction='Wrap';





        CoefficientsDataType='Same word length as input';







        OutputDataType='Full precision';

    end

    properties(Constant,Hidden)

        ShowFutureProperties=false;

        NumeratorSourceSet=matlab.system.StringSet({...
        'Property',...
        'Input port (Parallel interface)'});

        FilterStructureSet=matlab.system.StringSet({...
        'Direct form systolic',...
        'Direct form transposed',...
        'Partly serial systolic'});


        SerializationOptionSet=matlab.system.StringSet({...
        'Maximum number of multipliers',...
        'Minimum number of cycles between valid input samples'});




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

        numMults;
        numMuxInputs;
        pSerializationFactor;
        pIsInputComplex;
        vecSize;


        pIsFilterComplex(1,1)logical=false;
        pFilterBankArch(1,1)logical=true;
        pIsSymmetric(1,1)logical=false;
    end

    properties(Access=private)
        W;
        X;
        a;
        p;
        v;
        s;
        Y;
        outputQueue;
        maskCount;
        sharingCount;
        validLastPhase;
        pInputDT;
        pCoeffInputDT;
        pFimath;
        pUserFimath;
        phFIR;
        pInitialLatency=0;
        pReadyState;
        pSavedData;
        pDinReg;
        pDoutReg;
        pDoutReg1;
        pRdyReg;
        pRdyReg1;
        pSavedDataVld;

        pVoutReg;
        resetCount;
        rstREG;
        resetCountEn;
        pSharingConst;
    end
    properties(Nontunable,Access=private)
        pNumeratorPrototype=[];
    end
    properties(Access=private)

        pVldInReg(1,1)logical=false;
        pVldOutReg(1,1)logical=false;
        pVldOutReg1(1,1)logical=false;
        pResetStart(1,1)logical;
        pCoeffDTCheck(1,1)logical=true;
        pTransientPad(1,1)logical=false;
        pInitialize(1,1)logical=true;
    end




    methods(Static,Access=protected)



        function header=getHeaderImpl





            text=sprintf(['Filter real or complex input with an FIR filter optimized for HDL code generation.\n\n',...
'Choose from fully-parallel Direct form systolic or Direct form transposed structures or a Partly serial systolic structure with configurable serialization parameters. '...
            ,'All structures share multipliers in symmetric or antisymmetric filters. Both systolic structures make efficient use of Intel and Xilinx DSP blocks.\n\n'...
            ,'When using programmable coefficients, set Coefficients prototype to a coefficient vector that is representative of the symmetry and zero-value locations of the expected coefficients.'...
            ,'The block uses this prototype to optimize multipliers in the filter implementation. If your coefficients are unknown or not expected to share symmetry or zero-value locations, set Coefficients prototype to [].\n']);
            header=matlab.system.display.Header('dsphdl.FIRFilter',...
            'Title','Discrete FIR Filter',...
            'Text',text,...
            'ShowSourceLink',false);

        end



        function groups=getPropertyGroupsImpl

            algorithmParameters=matlab.system.display.Section(...
            'Title','Filter parameters',...
            'PropertyList',{'NumeratorSource','Numerator','NumeratorPrototype','FilterStructure','SerializationOption','NumCycles','NumberOfMultipliers'});

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



        function isVisible=showSimulateUsingImpl



            isVisible=false;
        end



    end

    methods(Static)

        function helpFixedPoint






            matlab.system.dispFixptHelp('dsphdl.FIRFilter',...
            {'RoundingMethod','OverflowAction',...
            'CoefficientsDataType','OutputDataType'});
        end

    end

    methods



        function obj=FIRFilter(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','DSP_HDL_Toolbox'))
                    error(message('dsphdl:dsphdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','DSP_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:},'Numerator');
        end



        function set.Numerator(obj,value)
            validateattributes(value,...
            {'numeric'},...
            {'finite','nonempty','row'},...
            'FIRFilter','Numerator');
            obj.Numerator=value;
        end
        function set.NumeratorPrototype(obj,value)
            validateattributes(value,...
            {'numeric'},...
            {'finite'},...
            'FIRFilter','NumeratorPrototype');
            obj.NumeratorPrototype=value;
        end

        function set.NumCycles(obj,value)




            validateattributes(value,...
            {'numeric'},...
            {'scalar','positive'},...
            'FIRFilter','NumCycles');
            if~isinf(value)
                validateattributes(value,...
                {'numeric'},...
                {'integer'},...
                'FIRFilter','NumCycles');
            end

            obj.NumCycles=value;
        end
        function set.NumberOfMultipliers(obj,value)
            validateattributes(value,...
            {'numeric'},...
            {'scalar','positive','integer'},...
            'FIRFilter','NumberOfMultipliers');

            obj.NumberOfMultipliers=value;
        end
        function set.SharingFactor(obj,value)
            warning(message('MATLAB:system:throwObsoletePropertyWarningNewName',...
            class(obj),'SharingFactor','NumCycles'));

            validateattributes(value,...
            {'numeric'},...
            {'positive','integer'},...
            'FIRFilter','SharingFactor');
            obj.NumCycles=value;
        end
        function set.FilterStructure(obj,value)
            obj.FilterStructure=value;
        end
        function set.Sharing(obj,value)
            warning(message('MATLAB:system:throwObsoletePropertyWarningNewName',...
            class(obj),'Sharing','FilterStructure'));


            obj.FilterStructure='Direct form systolic';
            if value
                obj.FilterStructure='Partly serial systolic';
            end
        end
        function value=get.SharingFactor(obj)
            value=obj.NumCycles;
        end
        function value=get.Sharing(obj)
            if strcmpi(obj.FilterStructure,'Partly serial systolic')
                value=true;
            else
                value=false;
            end
        end
        function set.NumberOfCycles(obj,value)
            warning(message('MATLAB:system:throwObsoletePropertyWarningNewName',...
            class(obj),'NumberOfCycles','NumCycles'));

            validateattributes(value,...
            {'numeric'},...
            {'scalar','positive'},...
            'FIRFilter','NumberOfCycles');
            if~isinf(value)
                validateattributes(value,...
                {'numeric'},...
                {'integer'},...
                'FIRFilter','NumberOfCycles');
            end
            obj.NumCycles=value;
        end
        function value=get.NumberOfCycles(obj)
            value=obj.NumCycles;
        end
    end

    methods(Access=protected)



        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);


            if obj.isLocked
                s.W=obj.W;
                s.X=obj.X;
                s.a=obj.a;
                s.p=obj.p;
                s.v=obj.v;
                s.s=obj.s;
                s.Y=obj.Y;
                s.outputQueue=obj.outputQueue;
                s.maskCount=obj.maskCount;
                s.sharingCount=obj.sharingCount;
                s.resetCount=obj.resetCount;
                s.resetCountEn=obj.resetCountEn;
                s.validLastPhase=obj.validLastPhase;
                s.pFilterBankArch=obj.pFilterBankArch;
                s.pFimath=obj.pFimath;
                s.pUserFimath=obj.pUserFimath;
                s.phFIR=obj.phFIR;
                s.pInputDT=obj.pInputDT;
                s.pCoeffInputDT=obj.pCoeffInputDT;
                s.pIsFilterComplex=obj.pIsFilterComplex;
                s.pInitialLatency=obj.pInitialLatency;
                s.pIsInputComplex=obj.pIsInputComplex;
                s.pReadyState=obj.pReadyState;
                s.pRdyReg=obj.pRdyReg;
                s.pRdyReg1=obj.pRdyReg1;
                s.pSavedData=obj.pSavedData;
                s.pSavedDataVld=obj.pSavedDataVld;
                s.pDinReg=obj.pDinReg;
                s.pVldInReg=obj.pVldInReg;
                s.pIsSymmetric=obj.pIsSymmetric;
                s.pDoutReg=obj.pDoutReg;
                s.pVoutReg=obj.pVoutReg;
                s.pNumeratorPrototype=obj.pNumeratorPrototype;
                s.vecSize=obj.vecSize;
                s.pTransientPad=obj.pTransientPad;
                s.rstREG=obj.rstREG;
                s.pSerializationFactor=obj.pSerializationFactor;
                s.pInitialize=obj.pInitialize;
            end
        end



        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end



        function hide=isInactivePropertyImpl(obj,prop)

            show=true;

            switch prop
            case 'Numerator'
                show=strcmp(obj.NumeratorSource,'Property');

            case 'NumeratorPrototype'
                show=strcmp(obj.NumeratorSource,'Input port (Parallel interface)');

            case 'CoefficientsDataType'
                show=strcmp(obj.NumeratorSource,'Property');

            case 'Sharing'
                show=false;
            case 'SerializationOption'
                show=strcmp(obj.FilterStructure,'Partly serial systolic');
            case 'NumCycles'
                show=strcmp(obj.SerializationOption,'Minimum number of cycles between valid input samples')&&strcmp(obj.FilterStructure,'Partly serial systolic');
            case 'NumberOfMultipliers'
                show=strcmp(obj.SerializationOption,'Maximum number of multipliers')&&strcmp(obj.FilterStructure,'Partly serial systolic');


























            end

            hide=~show;

        end



        function[portActive,optionActive]=getValidInPortProperty(obj)


            optionActive=(strcmp(obj.InputProcessing,'Elements as channels (sample based)')&&~(strcmpi(obj.FilterStructure,'Partly serial systolic')))||...
            strcmp(obj.InputProcessing,'Columns as channels (frame based)');

            if optionActive
                portActive=obj.ValidInPort;
            else
                portActive=true;
            end

        end




        function icon=getIconImpl(obj)
            isInputComplex=propagatedInputComplexity(obj,1);
            dt1=propagatedInputDataType(obj,1);
            inputDT=getInputDT(obj,dt1);
            inVecSize=propagatedInputSize(obj,1);

            if isempty(dt1)
                icon=sprintf('Discrete FIR Filter\nLatency = --');
            elseif strcmpi(obj.FilterStructure,'Direct form systolic')||strcmpi(obj.FilterStructure,'Partly serial systolic')
                inVecSize=inVecSize(1);
                if strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')
                    isCoeffComplex=propagatedInputComplexity(obj,3);
                    coefficientsDataType=getInputCoeffDT(obj,coder.const(propagatedInputDataType(obj,3)));
                    inputCoefficientLength=propagatedInputSize(obj,3);

                    if~isempty(obj.NumeratorPrototype)
                        coeff=obj.NumeratorPrototype;
                    else
                        if isCoeffComplex
                            coeff=complex(rand(1,inputCoefficientLength(2)));
                        else
                            coeff=rand(1,inputCoefficientLength(2));
                        end
                    end



                    icon=sprintf('Discrete FIR Filter\nLatency = %d',getLatency(obj,coefficientsDataType,coeff,isInputComplex,inVecSize));
                else
                    isCoeffComplex=logical(~isreal(obj.Numerator));%#ok<NASGU>
                    coefficientsDataType=getCoefficientsDT(obj,inputDT);

                    icon=sprintf('Discrete FIR Filter\nLatency = %d',getLatency(obj,numerictype(coefficientsDataType),obj.Numerator,isInputComplex,inVecSize));
                end
            else
                inVecSize=inVecSize(1);
                isCoeffComplex=logical(~isreal(obj.Numerator));%#ok<NASGU>
                if strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')
                    isCoeffComplex=propagatedInputComplexity(obj,3);
                    coefficientsDataType=getInputCoeffDT(obj,coder.const(propagatedInputDataType(obj,3)));
                    inputCoefficientLength=propagatedInputSize(obj,3);
                    if~isempty(obj.NumeratorPrototype)
                        coeff=obj.NumeratorPrototype;
                    else
                        if isCoeffComplex
                            coeff=complex(rand(1,inputCoefficientLength(2)));
                        else
                            coeff=rand(1,inputCoefficientLength(2));
                        end
                    end

                    coeff=cast(coeff,'like',fi(0,coefficientsDataType));

                    icon=sprintf('Discrete FIR Filter\nLatency = %d',getLatency(obj,coefficientsDataType,coeff,isInputComplex,inVecSize));
                else
                    coefficientsDataType=getCoefficientsDT(obj,obj.pInputDT);
                    icon=sprintf('Discrete FIR Filter\nLatency = %d',getLatency(obj,numerictype(coefficientsDataType),obj.Numerator,isInputComplex,inVecSize));
                end
            end

        end



        function num=getNumInputsImpl(obj)

            num=2;
            if strcmp(obj.NumeratorSource,'Input port (Parallel interface)')
                num=num+1;
            end

            if obj.ResetInputPort
                num=num+1;
            end








        end



        function num=getNumOutputsImpl(obj)

            num=2;
            if strcmpi(obj.FilterStructure,'Partly serial systolic')
                num=num+1;
            end

        end



        function varargout=getInputNamesImpl(obj)


            varargout{1}='data';


            varargout=[varargout,'valid'];


            if strcmp(obj.NumeratorSource,'Input port (Parallel interface)')
                varargout=[varargout,'coeff'];




            end

            if obj.ResetInputPort
                varargout=[varargout,'reset'];
            end
        end



        function varargout=getOutputNamesImpl(obj)

            varargout{1}='data';
            varargout{2}='valid';

            if strcmpi(obj.FilterStructure,'Partly serial systolic')
                varargout{3}='ready';
            end

        end



        function varargout=getOutputDataTypeImpl(obj)

            dinType=coder.const(propagatedInputDataType(obj,1));
            inputDT=getInputDT(obj,dinType);
            isInputComplex=coder.const(propagatedInputComplexity(obj,1));
            inputSize=coder.const(max(propagatedInputSize(obj,1)));
            if isempty(inputSize)
                inputSize=1;
            end
            if strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')
                if isempty(obj.NumeratorPrototype)
                    filterLen=coder.const(propagatedInputSize(obj,3));
                else
                    filterLen=length(obj.NumeratorPrototype);
                end
                coefDT=propagatedInputDataType(obj,3);

                if~isempty(filterLen)
                    filterLen=max(filterLen);
                end
            else
                filterLen=length(obj.Numerator);
                coefDT=getCoefficientsDT(obj,inputDT);
            end




            filterProp=getSymmetryFIRS(obj,obj.Numerator,coefDT,obj.NumeratorSource);
            isSymmetric=logical(abs(filterProp.isSymmetric));
            sharing=coder.const(getSerializationFactor(obj,isInputComplex,isSymmetric));
            if strcmpi(obj.FilterStructure,'Partly serial systolic')&&sharing>1
                outputDT=getOutputDTSystolic(obj,dinType);
            else
                outputDT=getOutputDTFilterBank(obj,dinType,numerictype(coefDT),filterLen);
            end

            varargout{1}=outputDT;

            varargout{2}='logical';

            if strcmpi(obj.FilterStructure,'Partly serial systolic')
                varargout{3}='logical';
            end

        end
        function outputDT=getOutputDTFilterBank(obj,dinType,coeffType,filterLen)







            outputDT=obj.OutputDataType;
            symOpt=true;
            if strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')








                numeratorPrototype=obj.pNumeratorPrototype;
                if isfloat(coeffType)
                    coeffType='Same word length as input';
                end

                hFIR=dsphdl.private.AbstractFilterBank('FilterStructure',obj.FilterStructure,...
                'FilterCoefficientSource',obj.NumeratorSource,...
                'CoefficientsDataType',coeffType,...
                'FilterOutputDataType',outputDT,...
                'FilterCoefficients',reshapeFilterCoef(obj,numeratorPrototype,1),...
                'RoundingMethod',obj.RoundingMethod,...
                'OverflowAction',obj.OverflowAction,...
                'ResetInputPort',obj.ResetInputPort,...
                'SymmetryOptimization',symOpt);
            else

                hFIR=dsphdl.private.AbstractFilterBank('FilterStructure',obj.FilterStructure,...
                'FilterCoefficientSource',obj.NumeratorSource,...
                'CoefficientsDataType',coeffType,...
                'FilterOutputDataType',outputDT,...
                'FilterCoefficients',reshapeFilterCoef(obj,obj.Numerator,1),...
                'RoundingMethod',obj.RoundingMethod,...
                'OverflowAction',obj.OverflowAction,...
                'ResetInputPort',obj.ResetInputPort,...
                'SymmetryOptimization',symOpt);
            end

            inputDT=getInputDT(hFIR,dinType);

            if~isempty(inputDT)
                if isnumerictype(inputDT)
                    outputDT=numerictype(getOutputDT(hFIR,inputDT,filterLen));
                else
                    outputDT=inputDT;
                end
            else
                outputDT=[];
            end
        end
        function outputDT=getOutputDTSystolic(obj,dt1)

            if(~isempty(dt1))
                if ischar(dt1)
                    inputDT=eval([dt1,'(0)']);
                else
                    inputDT=fi(0,dt1);
                end

                dataTypes=determineDataTypes(obj,inputDT);

                if isfi(dataTypes.yDT)
                    outputDT=dataTypes.yDT.numerictype();
                else
                    outputDT=class(dataTypes.yDT);
                end
            else
                outputDT=[];
            end
        end



        function varargout=isOutputComplexImpl(obj,varargin)
            if strcmpi(obj.NumeratorSource,'Property')
                varargout{1}=(~isreal(obj.Numerator))||propagatedInputComplexity(obj,1);
            else
                varargout{1}=(~isreal(obj.NumeratorPrototype))||propagatedInputComplexity(obj,1)||propagatedInputComplexity(obj,3);
            end
            varargout{2}=false;
            if strcmpi(obj.FilterStructure,'Partly serial systolic')
                varargout{3}=false;
            end
        end



        function varargout=getOutputSizeImpl(obj)
            varargout{1}=propagatedInputSize(obj,1);
            varargout{2}=1;
            if strcmpi(obj.FilterStructure,'Partly serial systolic')
                varargout{3}=1;
            end
        end



        function varargout=isOutputFixedSizeImpl(obj)
            varargout{1}=true;
            varargout{2}=true;
            if strcmpi(obj.FilterStructure,'Partly serial systolic')
                varargout{3}=true;
            end
        end



        function validatePropertiesImpl(obj)

            if strcmpi(obj.FilterStructure,'Partly serial systolic')&&strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')
                if~obj.isInMATLABSystemBlock
                    blkName=class(obj);
                    blkName=blkName(8:end);
                else
                    blkName=gcb;
                end
                coder.internal.error('dsphdl:FIRFilter:NumeratorSourceNotSupported',blkName);
            end
            if~strcmpi(obj.NumeratorSource,'Property')
                if~isempty(obj.NumeratorPrototype)
                    validateattributes(obj.NumeratorPrototype,...
                    {'single','double','embedded.fi',...
                    'uint8','int8','uint16','int16','uint32','int32'},...
                    {'vector','row'},...
                    'FIRFilter','Coefficients prototype');
                end
            end
        end

        function validateInputsImpl(obj,varargin)
            coder.extrinsic('dsphdlshared.internal.validateCoefDataType','gcb');
            if isempty(coder.target)||~eml_ambiguous_types
                inData=varargin{1};
                if~obj.isInMATLABSystemBlock
                    blkName=class(obj);

                else
                    blkName=coder.const(gcb);
                end
                validateattributes(varargin{1},...
                {'single','double','embedded.fi',...
                'uint8','int8','uint16','int16','uint32','int32','uint64','int64'},...
                {'vector','column'},...
                'FIRFilter','data');

                [frameSize,NoChannel]=size(varargin{1});
                if frameSize>obj.MaxInputFrameSize
                    coder.internal.error('dsphdl:FIRFilter:MaxInputFrameSize',blkName,obj.MaxInputFrameSize);
                end
                validateattributes(varargin{2},{'logical'},...
                {'scalar'},...
                'FIRFilter','valid');

                if strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')&&obj.ResetInputPort
                    validateattributes(varargin{3},...
                    {'single','double','embedded.fi',...
                    'uint8','int8','uint16','int16','uint32','int32'},...
                    {'vector','row'},...
                    'FIRFilter','Coeff');

                    validateattributes(varargin{4},{'logical'},...
                    {'scalar'},...
                    'FIRFilter','reset');
                    crossValidate(obj,varargin{1},varargin{3},blkName);
                elseif strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')
                    validateattributes(varargin{3},...
                    {'single','double','embedded.fi','real'...
                    ,'uint8','int8','uint16','int16','uint32','int32'},...
                    {'vector','row'},...
                    'FIRFilter','Coeff');
                    crossValidate(obj,varargin{1},varargin{3},blkName);
                elseif obj.ResetInputPort
                    validateattributes(varargin{3},{'logical'},...
                    {'scalar'},...
                    'FIRFilter','reset');
                end


                if strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')
                    coefficients=obj.NumeratorPrototype;
                else
                    coefficients=obj.Numerator;
                    inputDT=getInputDT(obj,inData);
                    dsphdlshared.internal.validateCoefDataType(blkName,obj.pCoeffDTCheck,inputDT,obj.Numerator,obj.CoefficientsDataType,true,true,obj.isInMATLABSystemBlock)
                end


                if strcmpi(obj.FilterStructure,'Partly serial systolic')&&strcmpi(obj.SerializationOption,'Maximum number of multipliers')&&~isempty(coefficients)
                    if isreal(inData)
                        if~isreal(coefficients)
                            if obj.NumberOfMultipliers<2
                                coder.internal.error('dsphdl:FIRFilter:NumberOfMultipliersTooSmall',blkName,obj.NumberOfMultipliers);
                            end
                        end
                    else
                        if isreal(coefficients)
                            if obj.NumberOfMultipliers<2
                                coder.internal.error('dsphdl:FIRFilter:NumberOfMultipliersTooSmall',blkName,obj.NumberOfMultipliers);
                            end
                        elseif obj.NumberOfMultipliers<3
                            coder.internal.error('dsphdl:FIRFilter:NumberOfMultipliersTooSmall',blkName,obj.NumberOfMultipliers)
                        end
                    end
                end


                if strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')&&~isempty(obj.NumeratorPrototype)
                    if length(varargin{1})==1
                        symmetryBeforeCast=getSymmetryFIRS(obj,coefficients,double(0),obj.NumeratorSource);
                        isSymmetric=logical(abs(symmetryBeforeCast.isSymmetric));

                        if isSymmetric&&symmetryBeforeCast.Exception(1)==0
                            expectedLen=ceil(length(coefficients)/2);
                            actualLen=length(varargin{3});
                        else
                            expectedLen=length(coefficients);
                            actualLen=length(varargin{3});
                        end
                        if expectedLen~=actualLen
                            if isSymmetric
                                coder.internal.error('dsphdl:FIRFilter:UnexpectedNumberOfInputCoefficients2',blkName,expectedLen,length(coefficients),actualLen);
                            else
                                coder.internal.error('dsphdl:FIRFilter:UnexpectedNumberOfInputCoefficients1',blkName,expectedLen,length(coefficients),actualLen);
                            end
                        end

                        if xor(isreal(coefficients),isreal(varargin{3}))
                            coder.internal.error('dsphdl:FIRFilter:UnexpectedComplexityOfInputCoefficients',blkName);
                        end
                    else
                        expectedLen=length(coefficients);
                        actualLen=length(varargin{3});
                        if expectedLen~=actualLen
                            coder.internal.error('dsphdl:FIRFilter:UnexpectedNumberOfInputCoefficients1',blkName,expectedLen,length(coefficients),actualLen);
                        end






                    end
                end

                if strcmpi(obj.FilterStructure,'Partly serial systolic')&&length(varargin{1})>1
                    coder.internal.error('dsphdl:FIRFilter:ScalarFilterStructure',blkName);
                end
                if strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')
                    if isempty(obj.NumeratorPrototype)
                        coefLen=coder.const(length(varargin{3}));


                        if isreal(varargin{3})
                            obj.pNumeratorPrototype=coder.const((1:1:coefLen)/coefLen);
                        else
                            obj.pNumeratorPrototype=coder.const(complex((1:1:coefLen)/coefLen));
                        end
                    else
                        obj.pNumeratorPrototype=obj.NumeratorPrototype;
                    end
                else
                    obj.pNumeratorPrototype=[];
                end
            end
        end
        function crossValidate(~,data,coef,blkName)
            if xor(isfloat(data),isfloat(coef))||...
                xor(strcmpi(class(data),'double'),strcmpi(class(coef),'double'))||...
                xor(strcmpi(class(data),'single'),strcmpi(class(coef),'single'))
                coder.internal.error('dsphdl:FIRFilter:DataAndCoeffNotTheSameType',blkName);
            end
        end


        function varargout=isInputDirectFeedthroughImpl(~,varargin)
            for ii=1:nargout
                varargout{ii}=false;
            end
        end





        function resetImpl(obj)

            sharing=coder.const(obj.pSerializationFactor);
            if(strcmpi(obj.FilterStructure,'Partly serial systolic'))&&sharing>1
                resetSystolicSharing(obj);
            else
                resetFilterBank(obj);
            end
        end


        function flag=getExecutionSemanticsImpl(obj)
            if obj.ResetInputPort
                flag={'Classic','SynchronousWithResetPort'};
            else
                flag={'Classic','Synchronous'};
            end
        end





        function setupImpl(obj,varargin)
            dataIn=varargin{1};
            obj.pInputDT=coder.const(getInputDT(obj,dataIn));
            obj.pInitialize=true;
            if strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')
                obj.pCoeffInputDT=getInputCoeffDT(obj,varargin{3});
                if isempty(obj.NumeratorPrototype)
                    coefLen=coder.const(length(varargin{3}));


                    if isreal(varargin{3})
                        obj.pNumeratorPrototype=coder.const((1:1:coefLen)/coefLen);
                    else
                        obj.pNumeratorPrototype=coder.const(complex((1:1:coefLen)/coefLen));
                    end
                else
                    obj.pNumeratorPrototype=obj.NumeratorPrototype;
                end
            end

            obj.pIsInputComplex=coder.const(~isreal(dataIn));
            coefDT=coder.const(getCoefficientsDT(obj,obj.pInputDT));

            filterProp=coder.const(getSymmetryFIRS(obj,obj.Numerator,coefDT,obj.NumeratorSource));
            obj.pIsSymmetric=coder.const(logical(abs(filterProp.isSymmetric))&&obj.SymmetryOptimization);
            obj.pSerializationFactor=coder.const(getSerializationFactor(obj,obj.pIsInputComplex,obj.pIsSymmetric));

            if(strcmpi(obj.FilterStructure,'Partly serial systolic'))&&obj.pSerializationFactor>1
                setupSystolicSharing(obj,varargin{:});
            else
                setupFilterBank(obj,varargin{:});
            end
        end





        function updateImpl(obj,varargin)
            if~coder.target('hdl')
                sharing=coder.const(obj.pSerializationFactor);
                if strcmpi(obj.FilterStructure,'Partly serial systolic')&&sharing>1
                    updateSystolicSharing(obj,varargin{:});
                else
                    updateFilterBank(obj,varargin{:});
                end
            end
        end




        function setupFilterBank(obj,varargin)

            coder.extrinsic('dsphdl.private.AbstractHDLPolyphaseFilterBank.getFeature','dsphdl.private.AbstractHDLPolyphaseFilterBank.setFeature')
            if~isfloat(varargin{1})
                obj.pFimath=fimath('RoundingMethod','Floor','OverflowAction','Wrap');
                obj.pUserFimath=fimath('RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction);
            end
            obj.pRdyReg=true;
            inData=varargin{1};
            obj.vecSize=length(inData);

            if strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')
                if isfloat(obj.pCoeffInputDT)
                    coefficientsDataType='Same word length as input';
                else
                    coefficientsDataType=obj.pCoeffInputDT;
                end
                if~isempty(obj.NumeratorPrototype)
                    numerator=obj.NumeratorPrototype;
                    numeratorLen=length(numerator);
                    if obj.vecSize==1
                        SymmetryOptimization=true;
                    else
                        SymmetryOptimization=false;
                    end
                else
                    coeff=varargin{3};
                    numeratorLen=length(coeff);
                    numerator=obj.pNumeratorPrototype;
                    SymmetryOptimization=false;

                end

                if obj.vecSize==1
                    outputDT=obj.OutputDataType;
                    roundMethod=obj.RoundingMethod;
                    overflowAction=obj.OverflowAction;
                    reshapeCoeff=numerator;
                else
                    reshapeCoeff=coder.const(reshapeFilterCoef(obj,numerator,obj.vecSize));
                    reshapeCoeff=coder.const([reshapeCoeff(end,:);reshapeCoeff(1:end-1,:)]);
                    outputDT='Full precision';
                    roundMethod='Floor';
                    overflowAction='Wrap';
                end
                hFIR=cell(1,obj.vecSize);
                for loop=coder.unroll(1:obj.vecSize)
                    hFIR{loop}=dsphdl.private.AbstractFilterBank('FilterStructure',obj.FilterStructure,...
                    'FilterCoefficientSource',obj.NumeratorSource,...
                    'CoefficientsDataType',coefficientsDataType,...
                    'FilterOutputDataType',outputDT,...
                    'InputCoefficientLength',numeratorLen,...
                    'FilterCoefficients',reshapeCoeff,...
                    'RoundingMethod',roundMethod,...
                    'OverflowAction',overflowAction,...
                    'ResetInputPort',obj.ResetInputPort,...
                    'SymmetryOptimization',SymmetryOptimization);
                    hFIR{loop}.isInMATLABSystemBlock=obj.isInMATLABSystemBlock;



                    hFIR{loop}.setCoeffDTCheck(false);
                end
                if isempty(numerator)
                    obj.pInitialLatency=getLatency(obj,obj.pInputDT,cast(rand(1,numeratorLen),'like',coeff),~isreal(inData),obj.vecSize);
                else
                    obj.pInitialLatency=getLatency(obj,obj.pInputDT,numerator,~isreal(inData),obj.vecSize);
                end
                if((~isreal(inData)||~isreal(numerator)))
                    obj.pIsFilterComplex=true;
                else
                    obj.pIsFilterComplex=false;
                end
            else
                numerator=obj.Numerator;
                numeratorLen=length(numerator);
                coefficientsDataType=obj.CoefficientsDataType;
                reshapeCoeff=reshapeFilterCoef(obj,numerator,obj.vecSize);
                reshapeCoeff=[reshapeCoeff(end,:);reshapeCoeff(1:end-1,:)];
                if obj.vecSize==1
                    outputDT=obj.OutputDataType;
                    roundMethod=obj.RoundingMethod;
                    overflowAction=obj.OverflowAction;
                    symOpt=true;
                else
                    outputDT='Full precision';
                    roundMethod='Floor';
                    overflowAction='Wrap';
                    symOpt=false;
                end
                hFIR=cell(1,obj.vecSize);
                for loop=coder.unroll(1:obj.vecSize)
                    hFIR{loop}=dsphdl.private.AbstractFilterBank('FilterStructure',obj.FilterStructure,...
                    'FilterCoefficientSource',obj.NumeratorSource,...
                    'CoefficientsDataType',coefficientsDataType,...
                    'FilterOutputDataType',outputDT,...
                    'InputCoefficientLength',numeratorLen,...
                    'FilterCoefficients',reshapeCoeff,...
                    'RoundingMethod',roundMethod,...
                    'OverflowAction',overflowAction,...
                    'ResetInputPort',obj.ResetInputPort,...
                    'SymmetryOptimization',symOpt);
                    hFIR{loop}.isInMATLABSystemBlock=obj.isInMATLABSystemBlock;




                    hFIR{loop}.setCoeffDTCheck(false);
                end
                obj.pInitialLatency=getLatency(obj,obj.pInputDT,numerator,~isreal(inData),obj.vecSize);
                if((~isreal(inData)||~isreal(obj.Numerator)))
                    obj.pIsFilterComplex=true;
                else
                    obj.pIsFilterComplex=false;
                end
            end
            obj.phFIR=hFIR;
            obj.pResetStart=false;
            if isreal(inData)
                if isfloat(inData)
                    obj.pDinReg=cast(zeros(obj.vecSize,1),'like',inData);
                else
                    obj.pDinReg=cast(zeros(obj.vecSize,1),'like',fi(0,obj.pInputDT));
                end
            else
                if isfloat(inData)
                    obj.pDinReg=complex(cast(zeros(obj.vecSize,1),'like',inData));
                else
                    obj.pDinReg=complex(cast(zeros(obj.vecSize,1),'like',fi(0,obj.pInputDT)));
                end
            end






            if obj.vecSize>1
                if isfloat(inData)

                    if obj.pIsFilterComplex
                        obj.pDoutReg=complex(cast(zeros(obj.vecSize,ceil(log2(obj.vecSize))+1),'like',inData));
                    else
                        obj.pDoutReg=cast(zeros(obj.vecSize,ceil(log2(obj.vecSize))+1),'like',inData);
                    end
                else
                    if isfi(inData)
                        inDataType=numerictype(inData);
                    else
                        inDataType=numerictype(class(inData));
                    end
                    outDT=fi(0,getOutputDTFilterBank(obj,inDataType,coefficientsDataType,numeratorLen));
                    if obj.pIsFilterComplex
                        obj.pDoutReg=complex(fi(zeros(obj.vecSize,ceil(log2(obj.vecSize))+1),...
                        outDT.Signed,outDT.WordLength,outDT.FractionLength,...
                        'OverflowAction',obj.OverflowAction,'RoundingMethod',obj.RoundingMethod));
                    else
                        obj.pDoutReg=fi(zeros(obj.vecSize,ceil(log2(obj.vecSize))+1),...
                        outDT.Signed,outDT.WordLength,outDT.FractionLength,...
                        'OverflowAction',obj.OverflowAction,'RoundingMethod',obj.RoundingMethod);
                    end
                end
                obj.pVoutReg=false(1,ceil(log2(obj.vecSize))+1);
            else
                if isfloat(inData)
                    if obj.pIsFilterComplex
                        obj.pDoutReg=complex(cast(zeros(1,1),'like',inData));
                    else
                        obj.pDoutReg=cast(zeros(1,1),'like',inData);
                    end
                else
                    if isfi(inData)
                        inDataType=numerictype(inData);
                    else
                        inDataType=numerictype(class(inData));
                    end
                    outDT=fi(0,getOutputDTFilterBank(obj,inDataType,coefficientsDataType,numeratorLen));
                    if obj.pIsFilterComplex
                        obj.pDoutReg=complex(cast(zeros(1,1),'like',outDT));
                    else
                        obj.pDoutReg=cast(zeros(1,1),'like',outDT);
                    end
                end
                obj.pVoutReg=false(1,1);
            end

            if~coder.target('hdl')
                dataIn=varargin{1};
                validIn=varargin{2};
                if isfloat(dataIn)
                    dataIn_cast=dataIn;
                else
                    dataIn_cast=fi(dataIn,obj.pInputDT);
                end
                for loop=1:obj.vecSize
                    if strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')
                        if obj.vecSize==1
                            coeffIn=varargin{3};
                        else
                            reshapeCoeff=reshapeFilterCoef(obj,varargin{3},obj.vecSize);
                            coeffIn=[reshapeCoeff(end,:);reshapeCoeff(1:end-1,:)];
                        end
                        if obj.ResetInputPort
                            rst=varargin{4};
                            setup(obj.phFIR{loop},dataIn_cast,validIn,coeffIn,rst);
                        else
                            setup(obj.phFIR{loop},dataIn_cast,validIn,coeffIn);
                        end
                    else
                        if obj.ResetInputPort
                            rst=varargin{3};
                            setup(obj.phFIR{loop},dataIn_cast,validIn,rst);
                        else
                            setup(obj.phFIR{loop},dataIn_cast,validIn);
                        end

                    end
                end
            end
        end

        function updateFilterBank(obj,varargin)
            if~coder.target('hdl')
                dataIn=varargin{1};
                validIn=varargin{2};
                if obj.ResetInputPort
                    if strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')
                        coeff=varargin{3};
                        resetIn=varargin{4};
                    else
                        coeff=[];
                        resetIn=varargin{3};
                    end
                else
                    if strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')
                        coeff=varargin{3};
                        resetIn=false;
                    else
                        coeff=[];
                        resetIn=false;
                    end
                end
                obj.pRdyReg=~resetIn;

                if isfloat(dataIn)
                    dataIn_cast=dataIn;
                else
                    dataIn_cast=fi(dataIn,obj.pInputDT);
                end

                if obj.pResetStart
                    obj.pResetStart=false;
                end
                if resetIn
                    obj.pResetStart=true;
                    validIn=false;
                    dataIn_cast(:)=0;
                end

                resetIfTrue(obj);

                if length(dataIn_cast)==1
                    updateFilterBankS(obj,dataIn_cast,coeff,validIn,resetIn);
                else
                    updateFilterBankV(obj,dataIn_cast,coeff,validIn,resetIn);
                end


            end
        end
        function updateFilterBankS(obj,dataIn,coeff,validIn,resetIn)
            loop=1;
            if strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')
                if obj.ResetInputPort
                    update(obj.phFIR{loop},dataIn,validIn,coeff,resetIn);
                else
                    update(obj.phFIR{loop},dataIn,validIn,coeff);
                end
            else
                if obj.ResetInputPort
                    update(obj.phFIR{loop},dataIn,validIn,resetIn);
                else
                    update(obj.phFIR{loop},dataIn,validIn);
                end
            end
        end
        function updateFilterBankV(obj,dataIn,coeff,validIn,resetIn)
            if strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')
                reshapeCoeff=reshapeFilterCoef(obj,coeff,obj.vecSize);
                coeffV=[reshapeCoeff(end,:);reshapeCoeff(1:end-1,:)];
                for loop=coder.unroll(1:obj.vecSize)
                    dIn=getDinVec(obj,dataIn,loop,resetIn);
                    if obj.ResetInputPort
                        [dout,vldOut]=step(obj.phFIR{loop},dIn,validIn,coeffV,resetIn);
                    else
                        [dout,vldOut]=step(obj.phFIR{loop},dIn,validIn,coeffV);
                    end
                    if vldOut
                        sumout=cast(sum(dout(:)),'like',obj.pDoutReg);
                    else
                        sumout=cast(0,'like',obj.pDoutReg);
                    end
                    obj.pDoutReg(loop,:)=[obj.pDoutReg(loop,2:end),sumout];
                end
            else
                for loop=coder.unroll(1:obj.vecSize)
                    dIn=getDinVec(obj,dataIn,loop,resetIn);
                    if obj.ResetInputPort
                        [dout,vldOut]=step(obj.phFIR{loop},dIn,validIn,resetIn);
                    else
                        [dout,vldOut]=step(obj.phFIR{loop},dIn,validIn);
                    end
                    if vldOut
                        sumout=cast(sum(dout(:)),'like',obj.pDoutReg);
                    else
                        sumout=cast(0,'like',obj.pDoutReg);
                    end
                    obj.pDoutReg(loop,:)=[obj.pDoutReg(loop,2:end),sumout];
                end
            end
            obj.pVoutReg=[obj.pVoutReg(2:end),vldOut];
            if validIn
                obj.pDinReg=dataIn;
            end
        end
        function dIn=getDinVec(obj,dataIn,loop,resetIn)
            if resetIn
                dIn=dataIn;
            else
                if loop==1
                    dIn=[dataIn(1);obj.pDinReg(2:end)];
                else
                    dIn=[dataIn(loop);obj.pDinReg(2+loop-1:end);dataIn(1:loop-1)];
                end
            end
        end

        function resetFilterBank(obj)
            if~coder.target('hdl')
                obj.pResetStart=false;
                obj.pDinReg(:)=0;
                obj.pDoutReg(:)=0;
                obj.pVoutReg(:)=false;
                if obj.pInitialize
                    obj.pRdyReg=true;
                    obj.pInitialize=false;
                else
                    obj.pRdyReg=false;
                end
                for loop=1:obj.vecSize
                    reset(obj.phFIR{loop});
                end
            end
        end





        function setupSystolicSharing(obj,varargin)

            dataIn=varargin{1};

            dataInDT=cast(0,'like',dataIn);


            dataTypes=coder.const(obj.determineDataTypes(dataInDT));
            xDT=dataTypes.xDT;
            wDT=dataTypes.wDT;
            yDT=dataTypes.yDT;


            obj.pResetStart=false;
            obj.pReadyState=0;
            obj.pRdyReg=true;
            obj.pRdyReg1=true;
            obj.pVldInReg=false;
            obj.pVldOutReg=false;
            obj.pVldOutReg1=false;
            obj.pDinReg=cast(0,'like',dataIn);
            obj.pDoutReg=cast(0,'like',yDT);
            obj.pDoutReg1=cast(0,'like',yDT);

            if isreal(dataIn)
                obj.pSavedData=cast(0,'like',dataIn);
            else
                obj.pSavedData=cast(complex(0),'like',dataIn);
            end

            obj.pSavedDataVld=false;
            numTaps=length(obj.Numerator);



            if obj.pIsSymmetric
                fullySerial=(ceil(numTaps/2)<=obj.pSerializationFactor);
                if fullySerial
                    obj.numMults=1;
                    obj.numMuxInputs=ceil(numTaps/2);
                elseif mod(numTaps,2)
                    numMultsTmp=ceil((numTaps-1)/(2*obj.pSerializationFactor));
                    obj.numMuxInputs=ceil((numTaps-1)/(2*numMultsTmp));
                    obj.numMults=numMultsTmp+1;
                else
                    obj.numMults=ceil(numTaps/(2*obj.pSerializationFactor));
                    obj.numMuxInputs=ceil(numTaps/(2*obj.numMults));
                end
            else
                fullySerial=(numTaps<=obj.pSerializationFactor);
                if fullySerial
                    obj.numMults=1;
                    obj.numMuxInputs=numTaps;
                else
                    obj.numMults=ceil(numTaps/obj.pSerializationFactor);
                    obj.numMuxInputs=ceil(numTaps/obj.numMults);
                end
            end

            obj.sharingCount=0;
            obj.resetCount=0;
            obj.resetCountEn=false;
            obj.X=zeros(length(obj.Numerator),1,'like',xDT);
            obj.W=cast(obj.Numerator,'like',wDT);
            obj.validLastPhase=false;

            if fullySerial
                fullySerialCorr=1;
            else
                fullySerialCorr=-1;
            end
            obj.pIsFilterComplex=~isreal(dataIn)&&~isreal(obj.Numerator);
            validPipeLength=coder.const(6+obj.numMults+double(obj.pIsSymmetric)-fullySerialCorr);


            obj.v=false(validPipeLength,1);






            maxQueueLength=ceil(validPipeLength/obj.pSerializationFactor);

            if~coder.target('hdl')
                obj.outputQueue=dsphdlshared.Queue(maxQueueLength,yDT);
            end


            obj.Y=yDT;
            obj.pTransientPad=false;
            obj.rstREG=0;

            if obj.pSerializationFactor==2
                obj.pSharingConst=4;
            else
                obj.pSharingConst=obj.pSerializationFactor;
            end
        end



        function updateSystolicSharing(obj,varargin)

            obj.resetCountEn=true;

            dataIn=varargin{1};
            validIn=varargin{2};
            if obj.ResetInputPort
                if strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')
                    coef=varargin{3};
                    resetIn=varargin{4};
                else
                    coef=obj.W;
                    resetIn=varargin{3};
                end
            else
                if strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')
                    coef=varargin{3};
                    resetIn=false;
                else
                    coef=obj.W;
                    resetIn=false;
                end
            end

            if obj.pResetStart
                obj.pResetStart=false;
            end
            if resetIn
                obj.pResetStart=true;
                validIn=false;
                dataIn(:)=0;
            end




            if(obj.rstREG==obj.resetCount)

                if((obj.resetCount<=obj.pSerializationFactor+ceil(length(obj.Numerator)/obj.pSerializationFactor))&&(obj.resetCount>0))&&~obj.pTransientPad
                    obj.pTransientPad=true;
                    obj.resetCount=0;

                elseif(obj.resetCount>0)&&~obj.pTransientPad
                    obj.resetCount=0;
                    obj.rstREG=0;

                elseif obj.pTransientPad&&(obj.resetCount<(length(obj.Numerator)+obj.pSharingConst)+2)&&obj.validLastPhase
                    obj.resetCount=obj.resetCount+1;
                else
                    if obj.pTransientPad&&obj.resetCount>=length(obj.Numerator)+obj.pSharingConst+2
                        obj.resetCount=0;
                        obj.pTransientPad=false;
                    end
                end
            end
            obj.rstREG=obj.resetCount;

            resetIfTrue(obj);

            if(obj.resetCount>=obj.pSerializationFactor+ceil(length(obj.Numerator)/obj.pSerializationFactor))&&~obj.pTransientPad
                obj.X(1:end)=0;
            end



            [dIn,dInVld]=updateReady(obj,validIn,dataIn,resetIn);



            coeffTemplate=obj.getCoefficientsDT(obj.pInputDT);
            if~any(cast(obj.Numerator,'like',coeffTemplate))
                obj.pRdyReg1=~resetIn;
                obj.pVldInReg=validIn;
                obj.pDinReg=dataIn;
                obj.pVldOutReg1=validIn;
                obj.pDoutReg1(:)=0;
                obj.pRdyReg=~resetIn;
                obj.pVldOutReg=validIn;
                obj.pDoutReg(:)=0;
            else
                obj.pRdyReg1=obj.pRdyReg;
                obj.pVldInReg=validIn;
                obj.pDinReg=dataIn;
                obj.pVldOutReg1=obj.pVldOutReg;
                obj.pDoutReg1=obj.pDoutReg;
                obj.pVldOutReg=obj.v(end);
                obj.pDoutReg=obj.Y(end);
            end

            if obj.numMuxInputs<=1
                obj.validLastPhase=(obj.sharingCount==(obj.numMuxInputs));
            end

            obj.v=[obj.validLastPhase;obj.v(1:end-1)];

            if obj.v(end)

                if~coder.target('hdl')
                    obj.Y=obj.outputQueue.pop();
                end
            end



            if obj.validLastPhase

                y=cast(coef*obj.X,'like',obj.Y);

                if~coder.target('hdl')
                    obj.outputQueue.push(y);
                end
            end
            if obj.numMuxInputs>1
                obj.validLastPhase=(obj.sharingCount==(obj.numMuxInputs-1));
            end


            if dInVld&&(obj.sharingCount==0)
                obj.X(:)=[dIn;obj.X(1:end-1)];
            end




            if dInVld||(obj.sharingCount>0)
                if obj.sharingCount==(obj.pSerializationFactor-1)
                    obj.sharingCount=0;
                else
                    obj.sharingCount=obj.sharingCount+1;
                end
            end

        end



        function resetSystolicSharing(obj)

            if~coder.target('hdl')
                obj.outputQueue.clear();
            end

            obj.v(:)=false;
            obj.Y(:)=0;
            obj.validLastPhase(:)=0;
            obj.sharingCount(:)=0;

            if obj.pInitialize
                obj.pRdyReg=true;
                obj.pInitialize=false;
            else
                obj.pRdyReg=false;
            end
            obj.pVldInReg=false;
            obj.pDinReg(:)=0;
            obj.pVldOutReg=false;
            obj.pVoutReg(:)=false;
            obj.pVldOutReg1=false;
            obj.pDoutReg(:)=0;
            obj.pDoutReg1(:)=0;
            obj.pReadyState(:)=0;
            obj.pSavedData(:)=0;
            obj.pSavedDataVld=false;

            if obj.resetCountEn
                obj.resetCount=obj.resetCount+1;
            end

            obj.resetCountEn=true;

        end




        function varargout=outputImpl(obj,varargin)
            sharing=coder.const(obj.pSerializationFactor);
            if strcmpi(obj.FilterStructure,'Partly serial systolic')&&sharing>1
                [data,dvld,ready]=outputSystolic(obj,varargin{:});
                varargout{1}=data;
                varargout{2}=dvld;
                varargout{3}=ready;
            else
                [data,dvld]=outputFilterBank(obj,varargin{:});
                varargout{1}=data;
                varargout{2}=dvld;
                if(strcmpi(obj.FilterStructure,'Partly serial systolic'))
                    varargout{3}=obj.pRdyReg;
                end
            end
        end

        function varargout=outputFilterBank(obj,varargin)
            dataIn=varargin{1};
            validIn=varargin{2};
            if isfloat(dataIn)
                dataIn_cast=dataIn;
            else
                dataIn_cast=fi(dataIn,obj.pInputDT);
            end
            coeffTemplate=obj.getCoefficientsDT(obj.pInputDT);
            if obj.vecSize==1||~any(cast(obj.Numerator,'like',coeffTemplate))
                if strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')
                    coeff=varargin{3};

                    if obj.ResetInputPort
                        [data,dvld]=output(obj.phFIR{1},dataIn_cast,validIn,coeff,varargin{4});
                    else
                        [data,dvld]=output(obj.phFIR{1},dataIn_cast,validIn,coeff);
                    end
                    varargout{1}=data;
                    varargout{2}=dvld;
                else

                    if obj.ResetInputPort
                        [data,dvld]=output(obj.phFIR{1},dataIn_cast,validIn,varargin{3});
                    else
                        [data,dvld]=output(obj.phFIR{1},dataIn_cast,validIn);
                    end
                    varargout{1}=data;
                    varargout{2}=dvld;
                end
            else
                varargout{1}=obj.pDoutReg(:,1);
                varargout{2}=obj.pVoutReg(1);
            end
        end

        function varargout=outputSystolic(obj,varargin)

            [dataOut,valid,ready]=getOutput(obj);
            if valid&&(~obj.pTransientPad)
                varargout{1}=dataOut;
            else
                varargout{1}=cast(0,'like',dataOut);
            end
            varargout{2}=valid;
            varargout{3}=ready;

        end
        function[dIn,dInVld]=updateReady(obj,validIn,dataIn,resetIn)
            IDLE=0;
            LOAD=1;
            SAVE=2;
            WAIT=3;
            UNLOAD=4;



            if strcmpi(obj.FilterStructure,'Partly serial systolic')
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
                    obj.pRdyReg=false;
                    obj.pSavedData(:)=0;
                    obj.pSavedDataVld=false;
                end
            else
                dIn=cast(0,'like',dataIn);
                dInVld=false;
                obj.pReadyState=IDLE;
                obj.pRdyReg=false;
                obj.pSavedData(:)=0;
                obj.pSavedDataVld=false;

            end
        end
        function[data,valid,ready]=getOutput(obj)

            coeffTemplate=obj.getCoefficientsDT(obj.pInputDT);

            if obj.pIsFilterComplex||~any(cast(obj.Numerator,'like',coeffTemplate))
                data=obj.pDoutReg1;
                valid=obj.pVldOutReg1;
                ready=obj.pRdyReg;
            else
                data=obj.Y(end);
                valid=obj.v(end);
                ready=obj.pRdyReg;

            end
        end


        function dataTypes=determineDataTypes(obj,dataInDT)

            coder.extrinsic('dsphdl.FIRFilter.getPrecision');



            wDTInit=cast(0,'like',obj.Numerator);
            if isreal(dataInDT)&&isreal(wDTInit)

                accDTInit=0;
                yDTInit=0;
            else

                accDTInit=complex(0,0);
                yDTInit=complex(0,0);
            end

            if isa(dataInDT,'single')||isa(dataInDT,'double')||isdouble(numerictype(dataInDT))||issingle(numerictype(dataInDT))


                xDT=dataInDT;
                wDT=cast(wDTInit,'like',dataInDT);
                yDT=cast(yDTInit,'like',dataInDT);
                accDT=cast(accDTInit,'like',dataInDT);

            elseif isinteger(dataInDT)||(isa(dataInDT,'embedded.fi')&&isfixed(dataInDT))



                [inputWL,inputFL,inputS]=dsphdlshared.hdlgetwordsizefromdata(dataInDT);

                if inputS
                    dataInNT=numerictype(inputS,inputWL,inputFL);
                else
                    dataInNT=numerictype(1,inputWL+1,inputFL);
                end

                if isnumerictype(obj.CoefficientsDataType)

                    if strcmpi(obj.CoefficientsDataType.Signedness,'Unsigned')
                        coeffsNumerictypeI=numerictype(1,obj.CoefficientsDataType.WordLength+1,obj.CoefficientsDataType.FractionLength);
                    else
                        coeffsNumerictypeI=obj.CoefficientsDataType;
                    end

                else
                    coeffsNumerictypeI=numerictype(1,inputWL);
                end


                if strcmpi(coeffsNumerictypeI.Signedness,'Unsigned')
                    coeffsNumerictype=numerictype(1,inputWL+1);
                else
                    coeffsNumerictype=coeffsNumerictypeI;
                end

                quantizedCoeffs=fi(obj.Numerator,coeffsNumerictype);

                [accNT,yNT]=coder.const(@dsphdl.FIRFilter.getPrecision,...
                quantizedCoeffs,dataInNT,obj.OutputDataType);

                xDT=fi(dataInDT,inputS,inputWL,inputFL);
                wDT=fi(wDTInit,quantizedCoeffs.numerictype);
                accDT=fi(accDTInit,accNT);


                yFimath=fimath(...
                'OverflowAction',obj.OverflowAction,...
                'RoundingMethod',obj.RoundingMethod);

                yDT=fi(yDTInit,yNT,yFimath);

            else






            end

            dataTypes=struct(...
            'xDT',xDT,...
            'wDT',wDT,...
            'accDT',accDT,...
            'yDT',yDT);

        end


        function updateSimTime(obj)
            obj.pSimTime=obj.pSimTime+1;
        end
        function resetIfTrue(obj)
            if obj.pResetStart
                if(strcmpi(obj.FilterStructure,'Partly serial systolic'))&&obj.pSerializationFactor>1
                    resetSystolicSharing(obj);
                elseif obj.pFilterBankArch
                    resetFilterBank(obj);
                end
            end
        end
    end


    methods(Static,Hidden)



        function[accNT,yNT]=getPrecision(W,xNT,outputDataType)













            [accLimits,yLimits]=dsp.internal.FIRFilterPrecision(W,xNT);

            accNT=accLimits.numerictype;

            if isnumerictype(outputDataType)

                yNT=outputDataType;
            else

                switch outputDataType
                case 'Full precision'
                    yNT=accLimits.numerictype;
                case 'Same word length as input'
                    yNT=yLimits.numerictype;
                end
            end

        end

    end
    methods(Hidden)
        function sharing=getSerializationFactor(obj,isInputComplex,isSymmetric)

            if isempty(isInputComplex)
                isInputComplex=false;
            end
            numTaps=length(obj.Numerator);

            if strcmpi(obj.SerializationOption,'Minimum number of cycles between valid input samples')
                if isinf(obj.NumCycles)||obj.NumCycles>=numTaps
                    sharing=length(obj.Numerator);
                else
                    sharing=obj.NumCycles;
                end
            else
                oddSymm=mod(numTaps,2);
                if isSymmetric
                    numTaps=ceil(numTaps/2);
                end
                if~isInputComplex&&isreal(obj.Numerator)
                    oddSymSharingFactor=obj.NumberOfMultipliers-oddSymm;
                    sharing=ceil(numTaps/(oddSymSharingFactor));
                elseif xor(~isInputComplex,isreal(obj.Numerator))
                    oddSymSharingFactor=obj.NumberOfMultipliers-2*oddSymm;
                    sharing=ceil(numTaps/(floor(oddSymSharingFactor/2)));
                else
                    oddSymSharingFactor=obj.NumberOfMultipliers-3*oddSymm;
                    sharing=ceil(numTaps/(floor(oddSymSharingFactor/3)));
                end
                if isinf(sharing)||sharing>=numTaps
                    sharing=length(obj.Numerator);
                end
            end

        end
        function coefTable=reshapeFilterCoef(obj,FilterCoefficients,NumFrequencyBands)%#ok<INUSL>
            numOfCoef=length(FilterCoefficients);
            zeroPadLen=NumFrequencyBands-mod(numOfCoef,NumFrequencyBands);
            if zeroPadLen==NumFrequencyBands
                coef_zeroPad=FilterCoefficients;
            elseif isnumeric(FilterCoefficients)
                coef_zeroPad=[FilterCoefficients(:);zeros(zeroPadLen,1,'like',FilterCoefficients)];
            else
                coef_zeroPad=[FilterCoefficients(:);zeros(zeroPadLen,1)];
            end

            NumTaps=length(coef_zeroPad)/NumFrequencyBands;
            coef_reshape=reshape(coef_zeroPad,NumFrequencyBands,NumTaps);
            coefTable=cast(flipud(coef_reshape),'like',coef_reshape);

        end
        function DT=getInputCoeffDT(obj,data)%#ok<INUSL>
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
                    DT=numerictype('double');
                end
            else
                DT=numerictype('double');
            end
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
                DT=numerictype('double');
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
                        coefficientsDT=fi(obj.Numerator,signedness,wordLength,'OverflowAction','Saturate','RoundingMethod','Nearest');
                    else
                        fractionLength=CoefficientsDT.FractionLength;
                        coefficientsDT=fi(0,signedness,wordLength,fractionLength,'OverflowAction','Saturate','RoundingMethod','Nearest');
                    end
                else
                    coefficientsDT=[];


                end
            elseif isnumerictype(inputDT)
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

                else
                    coef=fi(obj.Numerator,1,inputDT.WordLength);
                    wordLength=coef.WordLength;
                    fractionLength=coef.FractionLength;
                    coefficientsDT=fi(0,1,wordLength,fractionLength,'OverflowAction','Saturate','RoundingMethod','Nearest');
                end


            elseif ischar(inputDT)
                if strcmpi(inputDT,'single')
                    coefficientsDT=single(0);
                else
                    coefficientsDT=double(0);
                end
            else
                if isa(inputDT,'single')
                    coefficientsDT=single(0);
                else
                    coefficientsDT=double(0);
                end
            end
        end
        function filterSymmetry=getSymmetryFIRS(obj,coefficient,coefficientDT,coefficientSource)
            exception1=strcmpi(obj.FilterStructure,'Partly serial systolic')&&strcmpi(obj.SerializationOption,'Minimum number of cycles between valid input samples')&&obj.NumCycles>1;
            exception2=strcmpi(obj.FilterStructure,'Partly serial systolic')&&strcmpi(obj.SerializationOption,'Maximum number of multipliers');
            filterSymmetry.isSymmetric=0;
            if strcmpi(coefficientSource,'Input port (Parallel interface)')

                coeffDT=double(0);
            elseif isnumerictype(coefficientDT)
                coeffDT=fi(0,coefficientDT);
            else
                coeffDT=coefficientDT;
            end
            coeff=cast(coefficient,'like',coeffDT);
            filterSymmetry.SymmetryFromTo=[1,length(coeff)];
            if strcmpi(coefficientSource,'Input port (Parallel interface)')&&isempty(coeff)
                filterSymmetry.isSymmetric=0;
                filterSymmetry.SymmetryFromTo=[1,obj.InputCoefficientLength];
                filterSymmetry.Exception=zeros(obj.InputCoefficientLength,1);
            else
                filterSymmetry.Exception=zeros(length(coeff),1);
                if mod(length(coeff),2)

                    c=[coeff(1:floor(length(coeff)/2)),0,coeff(ceil(length(coeff)/2)+1:length(coeff))];
                else
                    c=coeff;
                end
                b=fliplr(c);
                if length(c)>1
                    if~any(c-b)
                        filterSymmetry.isSymmetric=1;
                    elseif~any(c+b)
                        filterSymmetry.isSymmetric=-1;
                    else
                        filterSymmetry.isSymmetric=0;
                    end
                end
            end


            if~(exception1||exception2)
                if(strcmpi(coefficientSource,'Input port (Parallel interface)')&&~isempty(coeff))||strcmpi(coefficientSource,'Property')
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
        end
        function setCoeffDTCheck(obj,value)

            obj.pCoeffDTCheck=value;
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

    methods(Access=public)
        function latency=getLatency(obj,varargin)
            if nargin==5
                coeffDT=varargin{1};
                Coeff=varargin{2};
                isInputComplex=varargin{3};
                inVecSize=varargin{4};
            elseif nargin==4
                coeffDT=varargin{1};
                Coeff=varargin{2};
                isInputComplex=varargin{3};
                inVecSize=1;
            elseif nargin==3
                coeffDT=varargin{1};
                Coeff=varargin{2};
                isInputComplex=false;
                inVecSize=1;
            elseif nargin==2
                coeffDT=varargin{1};
                if strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')
                    Coeff=obj.NumeratorPrototype;
                else
                    Coeff=obj.Numerator;
                end
                isInputComplex=false;
                inVecSize=1;
            else
                if strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')
                    coeffDT=numerictype('double');
                    Coeff=obj.NumeratorPrototype;
                else
                    if~isnumerictype(obj.CoefficientsDataType)
                        coeffDT=numerictype('double');
                    else
                        coeffDT=obj.CoefficientsDataType;
                    end
                    Coeff=obj.Numerator;
                end
                isInputComplex=false;
                inVecSize=1;
            end

            if isempty(Coeff)
                if strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')
                    if~isempty(obj.NumeratorPrototype)
                        Coeff=obj.NumeratorPrototype;
                    else
                        coder.internal.error('dsphdl:FIRFilter:EmptyFilterCoefficient','dsphdl.FIRFilter');
                    end
                else
                    Coeff=obj.Numerator;
                end
            end
            if isempty(coeffDT)
                if strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')
                    coeffDT=numerictype('double');
                else
                    if~isnumerictype(obj.CoefficientsDataType)
                        coeffDT=numerictype('double');
                    else
                        coeffDT=obj.CoefficientsDataType;
                    end
                end
            end
            if isempty(isInputComplex)
                isInputComplex=false;
            elseif~islogical(isInputComplex)
                coder.internal.error('dsphdl:FIRFilter:InputComplexityNotBoolean','dsphdl.FIRFilter')
            end

            filterProp=getSymmetryFIRS(obj,Coeff,coeffDT,obj.NumeratorSource);
            isSymmetric=logical(abs(filterProp.isSymmetric))&&obj.SymmetryOptimization;
            sharing=getSerializationFactor(obj,isInputComplex,isSymmetric);

            if strcmpi(obj.FilterStructure,'Partly serial systolic')&&sharing>1
                latency=getLatencySystolicSharing(obj,coeffDT,isSymmetric,sharing,isInputComplex);
            else
                latency=getLatencyFilterBank(obj,coeffDT,Coeff,isInputComplex,inVecSize);
            end
        end

    end
    methods(Access=protected)
        function latency=getLatencyFilterBank(obj,CoeffDT,Coeff,isInputComplex,inputVecSize)
            if strcmpi(obj.NumeratorSource,'Input port (Parallel interface)')
                numerator=Coeff;
                if~isfloat(CoeffDT)
                    coefficientsDataType=CoeffDT;
                else
                    coefficientsDataType='Same word length as input';
                end
                inputCoefficientLength=length(numerator);
                hFIR=dsphdl.private.AbstractFilterBank('FilterStructure',obj.FilterStructure,...
                'FilterCoefficientSource',obj.NumeratorSource,...
                'InputCoefficientLength',inputCoefficientLength(1),...
                'CoefficientsDataType',coefficientsDataType,...
                'FilterOutputDataType',obj.OutputDataType,...
                'FilterCoefficients',reshapeFilterCoef(obj,numerator,inputVecSize),...
                'RoundingMethod',obj.RoundingMethod,...
                'OverflowAction',obj.OverflowAction,...
                'ResetInputPort',obj.ResetInputPort);
            else
                numerator=Coeff;
                coefficientsDataType=obj.CoefficientsDataType;
                hFIR=dsphdl.private.AbstractFilterBank('FilterStructure',obj.FilterStructure,...
                'FilterCoefficientSource',obj.NumeratorSource,...
                'CoefficientsDataType',coefficientsDataType,...
                'FilterOutputDataType',obj.OutputDataType,...
                'FilterCoefficients',reshapeFilterCoef(obj,numerator,inputVecSize),...
                'RoundingMethod',obj.RoundingMethod,...
                'OverflowAction',obj.OverflowAction,...
                'ResetInputPort',obj.ResetInputPort);
            end
            NoSubFiler=inputVecSize;

            if inputVecSize>1
                finalDTReg=1;
            else
                finalDTReg=0;
            end

            if~ischar(coefficientsDataType)
                if~any(fi(numerator,coefficientsDataType))
                    latency=1;
                else
                    latency=getLatency(hFIR,CoeffDT,reshapeFilterCoef(obj,numerator,inputVecSize),NoSubFiler,inputVecSize,isInputComplex)+ceil(log2(inputVecSize))+finalDTReg;
                end
            else
                if~any(numerator)
                    latency=1;
                else
                    latency=getLatency(hFIR,CoeffDT,reshapeFilterCoef(obj,numerator,inputVecSize),NoSubFiler,inputVecSize,isInputComplex)+ceil(log2(inputVecSize))+finalDTReg;
                end
            end

        end
        function latency=getLatencySystolicSharing(obj,inputDT,isSymmetric,sharing,isInputComplex)

            if~(isnumerictype(inputDT)||isfloat(inputDT))&&~isnumerictype(obj.CoefficientsDataType)
                coder.internal.error('dsphdl:FIRFilter:getLatencyCallWithoutInputDataType','dsphdl.FIRFilter');
            end
            nmux=double(0);
            nmult=double(0);
            fullySerial=false;

            numTaps=length(obj.Numerator);

            [nmux,nmult,fullySerial]=getNmuxNmult(obj,numTaps,isSymmetric,sharing);
            if fullySerial
                fullySerialCorr=1;
            else
                fullySerialCorr=-1;
            end
            cmplxCmplxFilter=isInputComplex&&(~isreal(obj.Numerator));



            coeffTemplate=obj.getCoefficientsDT(inputDT);
            if~any(cast(obj.Numerator,'like',coeffTemplate))
                latency=1;
            else
                latency=6+nmult+double(isSymmetric)-fullySerialCorr+nmux+2*double(cmplxCmplxFilter);
            end
        end




    end
    methods(Hidden)
        function[nmuxinput,nmult,fullySerial]=getNmuxNmult(obj,numTaps,isSymmetric,serializationFactor)


            if isSymmetric
                fullySerial=(ceil(numTaps/2)<=serializationFactor);
                if fullySerial
                    nmult=1;
                    nmuxinput=ceil(numTaps/2);
                elseif mod(numTaps,2)
                    numMultsTmp=ceil((numTaps-1)/(2*serializationFactor));
                    nmuxinput=ceil((numTaps-1)/(2*numMultsTmp));
                    nmult=numMultsTmp+1;
                else
                    nmult=ceil(numTaps/(2*serializationFactor));
                    nmuxinput=ceil(numTaps/(2*nmult));
                end
            else
                fullySerial=(numTaps<=serializationFactor);
                if fullySerial
                    nmult=1;
                    nmuxinput=numTaps;
                else
                    nmult=ceil(numTaps/serializationFactor);
                    nmuxinput=ceil(numTaps/nmult);
                end
            end

        end
    end
end




























































































































































































































































