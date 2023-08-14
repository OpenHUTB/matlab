classdef(Hidden,StrictDefaults)AbstractChannelizer<matlab.System




%#codegen
%#ok<*EMCLS>




    properties(Nontunable,Constant,Hidden)




        BitGrowthVector=numerictype([],1,0);


        MaxInputVectorSize=64;

        MinWordLength=2;

        MaxWordLength=128;

    end

    properties(Nontunable,Hidden)






        BitReversedOutput(1,1)logical=false;




        BitReversedInput(1,1)logical=false;





        RemoveFFTLatency(1,1)logical=false;
    end


    properties(Nontunable)



        FilterStructure='Direct form transposed';




        ComplexMultiplication='Use 4 multipliers and 2 adders';




        NumFrequencyBands=8;



        FilterCoefficients=[-0.0329,0.1218,0.3183,0.4829,0.5469,0.4829,0.3183,0.1218,-0.0329];




        RoundingMethod='Floor';



        OverflowAction='Wrap';




        CoefficientsDataType='Same word length as input';




        FilterOutputDataType='Same word length as input';



        OutputSize='Same as number of frequency bands';








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
    end





    properties(Constant,Hidden)
        FilterStructureSet=matlab.system.StringSet({...
        'Direct form systolic',...
        'Direct form transposed'});

        RoundingMethodSet=matlab.system.internal.RoundingMethodSet({'Ceiling','Convergent','Floor','Nearest','Round','Zero'});
        OverflowActionSet=matlab.system.internal.OverflowActionSet;
        FilterOutputDataTypeSet=matlab.system.internal.DataTypeSet(...
        {'Same word length as input',...
        'Full precision',...
        matlab.system.internal.CustomDataType('Signedness',{'Signed','Unsigned'})},...
        'HasDesignMinimum',false,...
        'HasDesignMaximum',false);
        CoefficientsDataTypeSet=matlab.system.internal.DataTypeSet(...
        {'Same word length as input',...
        matlab.system.internal.CustomDataType('Signedness',{'Signed','Unsigned'},...
        'Scaling',{'Unspecified','BinaryPoint'})},...
        'ValuePropertyName','FilterCoefficients',...
        'HasDesignMinimum',false,...
        'HasDesignMaximum',false);
        ComplexMultiplicationSet=matlab.system.StringSet({'Use 3 multipliers and 5 adders',...
        'Use 4 multipliers and 2 adders'});
        OutputSizeSet=matlab.system.StringSet({'Same as input size',...
        'Same as number of frequency bands'});
    end

    properties(Nontunable,Access=private)

        pComplexMultiplication;
        pNumberOfFrequencyBand;
        pRoundingMethod;
        pOverflowAction;
        pFilterCoefficientDT;
        pFilterOutputDTString;
        pFilterOutputDT;
        pFilterOutDT;
        pOutputSize;
        pOutputDT;
        pInputVectorSize;
        pBitGrowthVector;
        pNormalize;
        pFimath;
        pUserFimath;
        pNumFrequencyBands;
        pInputDT;
        phFFT;
        phFIR;


        pOutBuffer_size;
        pIsInputComplex;


        pBitReversedOutput(1,1)logical;
        pBitReversedInput(1,1)logical;

    end
    properties(Access=private)

        pWrOutBuffer_index;
        pRdOutBuffer_index;
        pOutBuffer;
        pLastData;
        pSimTime=1;
        pOutput;


        pWrOutBuffer_roll(1,1)logical;
        pRdOutBuffer_roll(1,1)logical;
        pDRdy(1,1)logical;
        pResetStart(1,1)logical;
    end



    methods(Static)
        function helpFixedPoint


        end

    end
    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={...
'FilterStructure'...
            ,'NumberOfFrequencyBands'...
            ,'FilterCoefficients'...
            ,'ComplexMultiplication'...
            ,'OutputSize',...
'Normalize'...
            ,'RoundingMethod',...
            'OveflowAction',...
            'CoefficientsDataType',...
            'FilterOutputDataType',...
'ResetInputPort'...
            ,'StartOutputPort'...
            ,'EndOutputPort'...
            };

        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'RoundingMethod','OverflowAction','CoefficientsDataType','FilterOutputDataType',...
            };
        end
    end




    methods(Access=public)
        function latency=getLatency(obj,varargin)






            if nargin==4
                numFreqBands=varargin{1};
                inVectSize=varargin{2};
                isInputComplex=varargin{3};
            elseif nargin==3
                numFreqBands=varargin{1};
                inVectSize=varargin{2};
                if isempty(obj.pIsInputComplex)
                    isInputComplex=false;
                else
                    isInputComplex=obj.pIsInputComplex;
                end
            elseif nargin==2
                numFreqBands=varargin{1};
                if isempty(obj.pInputVectorSize)
                    inVectSize=1;
                else
                    inVectSize=obj.pInputVectorSize;
                end
                if isempty(obj.pIsInputComplex)
                    isInputComplex=false;
                else
                    isInputComplex=obj.pIsInputComplex;
                end
            else
                numFreqBands=obj.NumFrequencyBands;
                if isempty(obj.pInputVectorSize)
                    inVectSize=1;
                else
                    inVectSize=obj.pInputVectorSize;
                end
                if isempty(obj.pIsInputComplex)
                    isInputComplex=false;
                else
                    isInputComplex=obj.pIsInputComplex;
                end
            end
            coeff=obj.FilterCoefficients;
            correction=double(and(isInputComplex,~isreal(coeff)));
            if strcmpi(obj.OutputSize,'Same as number of frequency bands')&&inVectSize==numFreqBands
                correction=2+1*double(and(isInputComplex,~isreal(coeff)));
            end
            latency=waitCycle4dVld(obj,numFreqBands,inVectSize)+correction;
        end

    end


    methods(Static,Access=protected)
        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end
        function groups=getPropertyGroupsImpl

            algorithmParameters=matlab.system.display.Section(...
            'Title','Filter parameters',...
            'PropertyList',{'FilterCoefficients','FilterStructure'});
            FFTParameters=matlab.system.display.Section(...
            'Title','FFT parameters',...
            'PropertyList',{'NumFrequencyBands','ComplexMultiplication','Normalize'});
            OutputSizeParameter=matlab.system.display.Section(...
            'Title','Output size parameter',...
            'PropertyList',{'OutputSize'});

            filter=matlab.system.display.SectionGroup(...
            'TitleSource','Auto',...
            'Sections',[algorithmParameters,FFTParameters,OutputSizeParameter]);

            className=mfilename('class');
            dataTypesGroup=matlab.system.display.internal.DataTypesGroup(className);
            dataTypesGroup.PropertyList{3}=...
            matlab.system.display.internal.DataTypeProperty('CoefficientsDataType',...
            'Description','Coefficients');
            dataTypesGroup.PropertyList{4}=...
            matlab.system.display.internal.DataTypeProperty('FilterOutputDataType',...
            'Description','Filter output');

            controlInSection=matlab.system.display.Section(...
            'Title','Input Control Ports',...
            'PropertyList',{'ResetInputPort'});

            controlOutSection=matlab.system.display.Section(...
            'Title','Output Control Ports',...
            'PropertyList',{'StartOutputPort','EndOutputPort'});

            control=matlab.system.display.SectionGroup(...
            'Title','Control Ports',...
            'Sections',[controlInSection,controlOutSection]);

            groups=[filter,dataTypesGroup,control];
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
            if obj.StartOutputPort
                num=num+1;
            end
            if obj.EndOutputPort
                num=num+1;
            end

        end

        function varargout=getOutputNamesImpl(obj)

            varargout=cell(1,getNumOutputs(obj));
            outputPortInd=1;
            varargout{outputPortInd}='data';
            outputPortInd=outputPortInd+1;

            if obj.StartOutputPort
                varargout{outputPortInd}='start';
                outputPortInd=outputPortInd+1;
            end

            if obj.EndOutputPort
                varargout{outputPortInd}='end';
                outputPortInd=outputPortInd+1;
            end

            if obj.ValidOutputPort
                varargout{outputPortInd}='valid';
            end
        end

        function[DT,VAR]=getInputDT(obj,data)%#ok<INUSL> 
            if isnumerictype(data)
                DT=data;
                VAR=fi(0,DT);
            elseif isa(data,'embedded.fi')
                DT=numerictype(data);
                VAR=fi(0,DT);
            elseif isa(data,'uint8')
                DT=numerictype(0,8,0);
                VAR=fi(0,DT);
            elseif isa(data,'uint16')
                DT=numerictype(0,16,0);
                VAR=fi(0,DT);
            elseif isa(data,'uint32')
                DT=numerictype(0,32,0);
                VAR=fi(0,DT);



            elseif isa(data,'int8')
                DT=numerictype(1,8,0);
                VAR=fi(0,DT);
            elseif isa(data,'int16')
                DT=numerictype(1,16,0);
                VAR=fi(0,DT);
            elseif isa(data,'int32')
                DT=numerictype(1,32,0);
                VAR=fi(0,DT);
            elseif isa(data,'int64')
                DT=numerictype(1,64,0);
                VAR=fi(0,DT);
            elseif ischar(data)
                if strcmpi(data,'uint8')
                    DT=numerictype(0,8,0);
                    VAR=fi(0,DT);
                elseif strcmpi(data,'uint16')
                    DT=numerictype(0,16,0);
                    VAR=fi(0,DT);
                elseif strcmpi(data,'uint32')
                    DT=numerictype(0,32,0);
                    VAR=fi(0,DT);



                elseif strcmpi(data,'int8')
                    DT=numerictype(1,8,0);
                    VAR=fi(0,DT);
                elseif strcmpi(data,'int16')
                    DT=numerictype(1,16,0);
                    VAR=fi(0,DT);
                elseif strcmpi(data,'int32')
                    DT=numerictype(1,32,0);
                    VAR=fi(0,DT);
                elseif strcmpi(data,'int64')
                    DT=numerictype(1,64,0);
                    VAR=fi(0,DT);
                else
                    DT=data;
                    VAR=cast(0,'like',real(data));
                end
            else
                DT=data;
                VAR=cast(0,'like',real(data));
            end
        end

        function varargout=getOutputDataTypeImpl(obj)
            coder.extrinsic('dsphdl.private.AbstractChannelizer.getFeature','dsphdl.private.AbstractChannelizer.setFeature');
            inputDT=propagatedInputDataType(obj,1);
            if(~isempty(inputDT))
                inputDT=getInputDT(obj,inputDT);
                if~coder.target('hdl')

                    [oldFFTLength,oldFFTInputSize]=dsphdl.private.AbstractChannelizer.getFeature('FFT');
                    [ChannelizserLen,ChannelizerSize]=dsphdl.private.AbstractChannelizer.getFeature('Channelizer');
                    dsphdl.private.AbstractChannelizer.setFeature('FFT',ChannelizserLen,ChannelizerSize);
                    hFFT=dsphdl.FFT('Normalize',obj.Normalize,...
                    'FFTLength',obj.NumFrequencyBands);
                    hFIR=dsphdl.private.AbstractFilterBank('FilterStructure',obj.FilterStructure,...
                    'CoefficientsDataType',obj.CoefficientsDataType,...
                    'FilterOutputDataType',obj.FilterOutputDataType,...
                    'FilterCoefficients',reshapeFilterCoef(obj,obj.FilterCoefficients,obj.NumFrequencyBands),...
                    'OverflowAction',obj.OverflowAction,...
                    'ResetInputPort',obj.ResetInputPort);

                    filterOutputDT=getOutputDT(hFIR,inputDT);
                    fftOutputDT=getOutputDT(hFFT,filterOutputDT);

                    if isfloat(fftOutputDT)
                        if isa(fftOutputDT,'single')
                            varargout{1}=numerictype('single');
                        else
                            varargout{1}=numerictype('double');
                        end
                    else
                        varargout{1}=fftOutputDT;
                    end
                    for ii=2:getNumOutputs(obj)
                        varargout{ii}=numerictype('boolean');
                    end
                    release(hFIR);
                    release(hFFT);



                    dsphdl.private.AbstractChannelizer.setFeature('FFT',oldFFTLength,oldFFTInputSize);
                else
                    varargout{1}=inputDT;
                    for ii=2:getNumOutputs(obj)
                        varargout{ii}=numerictype('boolean');
                    end
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
            if strcmpi(obj.OutputSize,'Same as input size')
                varargout{1}=propagatedInputSize(obj,1);
            else
                varargout{1}=[1,obj.NumFrequencyBands];
            end
            for ii=2:getNumOutputs(obj)
                varargout{ii}=1;
            end
        end

        function varargout=isInputDirectFeedthroughImpl(obj,varargin)%#ok<INUSD> 



            for ii=1:nargout
                varargout{ii}=false;
            end
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.pComplexMultiplication=obj.pComplexMultiplication;
                s.pNumberOfFrequencyBand=obj.pNumFrequencyBands;
                s.pRoundingMethod=obj.pRoundingMethod;
                s.pOverflowAction=obj.pOverflowAction;
                s.pFilterCoefficientDT=obj.pFilterCoefficientDT;
                s.pFilterOutputDTString=obj.pFilterOutputDTString;
                s.pFilterOutputDT=obj.pFilterOutputDT;
                s.pOutputSize=obj.pOutputSize;
                s.pOutputDT=obj.pOutputDT;
                s.pInputVectorSize=obj.pInputVectorSize;
                s.pBitGrowthVector=obj.pBitGrowthVector;
                s.pNormalize=obj.pNormalize;
                s.pFimath=obj.pFimath;
                s.pUserFimath=obj.pUserFimath;
                s.pNumFrequencyBands=obj.pNumFrequencyBands;
                s.pOutput=obj.pOutput;
                s.phFFT=obj.phFFT;
                s.phFIR=obj.phFIR;
                s.pBitReversedOutput=obj.pBitReversedOutput;
                s.pBitReversedInput=obj.pBitReversedInput;
                s.pWrOutBuffer_index=obj.pWrOutBuffer_index;
                s.pRdOutBuffer_index=obj.pRdOutBuffer_index;
                s.pOutBuffer_size=obj.pOutBuffer_size;
                s.pOutBuffer=obj.pOutBuffer;
                s.pSimTime=obj.pSimTime;
                s.pWrOutBuffer_roll=obj.pWrOutBuffer_roll;
                s.pRdOutBuffer_roll=obj.pRdOutBuffer_roll;
                s.pDRdy=obj.pDRdy;
                s.pInputDT=obj.pInputDT;





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
            inputSize=getInputVectorSize(obj);
            isInputComplex=propagatedInputComplexity(obj,1);
            if isempty(inputSize)
                icon=sprintf('Channelizer\nLatency = --');
            else
                icon=sprintf('Channelizer\nLatency = %d',getLatency(obj,obj.NumFrequencyBands,inputSize,isInputComplex));
            end
        end
        function inputVectorSize=getInputVectorSize(obj)
            inputVectorSize=obj.pInputVectorSize;
        end

    end

    methods

        function obj=AbstractChannelizer(varargin)

            if coder.target('MATLAB')
                if~(builtin('license','checkout','DSP_HDL_Toolbox'))
                    error(message('dsphdl:dsphdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','DSP_HDL_Toolbox');
            end

            if~coder.target('hdl')
                coder.allowpcode('plain');
                setProperties(obj,nargin,varargin{:});
            end
        end




        function set.ComplexMultiplication(obj,val)
            validatestring(val,{'Use 3 multipliers and 5 adders',...
            'Use 4 multipliers and 2 adders'},'Channelizer','ComplexMultiplication');
            obj.ComplexMultiplication=val;
        end
        function set.NumFrequencyBands(obj,val)
            coder.extrinsic('dsphdl.private.AbstractChannelizer.isFeatureOn');
            validateattributes(val,{'double'},{'scalar','positive','integer'},'Channelizer','NumFrequencyBands');
            if floor(log2f(obj,val))~=log2f(obj,val)
                coder.internal.error('dspshared:system:lenFFTNotPowTwo');
            else
                if coder.const(dsphdl.private.AbstractChannelizer.isFeatureOn('ExtendedChannelizerFrequencyBand'))
                    validateattributes(val,{'numeric'},{'real','integer','scalar','finite','>=',2^2},'Channelizer','NumFrequencyBands');
                else
                    validateattributes(val,{'numeric'},{'real','integer','scalar','finite','>=',2^2,'<=',2^16},'Channelizer','NumFrequencyBands');
                end
            end
            obj.NumFrequencyBands=val;
        end

        function set.FilterCoefficients(obj,value)
            validateattributes(value,...
            {'numeric'},...
            {'finite','nonempty','row'},...
            'Channelizer','FilterCoefficients');

            obj.FilterCoefficients=value;
        end





        function set.RoundingMethod(obj,val)
            validatestring(val,{'Ceiling','Convergent','Floor',...
            'Nearest','Round','Zero'},'Channelizer','Rounding mode');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            validatestring(val,{'Wrap','Saturate'},'Channelizer','Overflow Action');
            obj.OverflowAction=val;
        end
        function set.OutputSize(obj,val)
            validatestring(val,{'Same as input size',...
            'Same as number of frequency bands'},'Channelizer','OutputSize');
            obj.OutputSize=val;
        end


    end



    methods(Access=protected)

        function validatePropertiesImpl(obj)
            coder.extrinsic('dsphdl.private.AbstractChannelizer.isFeatureOn');

            if~coder.target('hdl')
                coeffDT=obj.CoefficientsDataType;
                coeff=obj.FilterCoefficients;

                if isnumerictype(coeffDT)
                    post_cast=double(cast(coeff,'like',fi(0,coeffDT)));
                else
                    post_cast=double(coeff);
                end

                if all(post_cast==0)||...
                    (all(real(post_cast)==0)&&all(imag(post_cast)==0))
                    coder.internal.error('dsphdl:Channelizer:AllZeroCoeffs');
                end
            end
            if~coder.target('hdl')
                FFTLen=obj.NumFrequencyBands;
                validateattributes(FFTLen,{'double'},{'scalar','positive','integer'},'Channelizer','NumFrequencyBands');
                if floor(log2f(obj,FFTLen))~=log2f(obj,FFTLen)
                    error(message('dspshared:system:lenFFTNotPowTwo'));
                else
                    if coder.const(dsphdl.private.AbstractChannelizer.isFeatureOn('ExtendedChannelizerFrequencyBand'))
                        validateattributes(FFTLen,{'double'},{'real','integer','scalar','finite','>=',2^2},'Channelizer','NumFrequencyBands');
                    else
                        validateattributes(FFTLen,{'double'},{'real','integer','scalar','finite','>=',2^2,'<=',2^16},'Channelizer','NumFrequencyBands');
                    end
                end



                hFIR=dsphdl.private.AbstractFilterBank('FilterStructure',obj.FilterStructure,...
                'FilterCoefficientSource','Property',...
                'CoefficientsDataType',obj.CoefficientsDataType,...
                'FilterOutputDataType',obj.FilterOutputDataType,...
                'FilterCoefficients',reshapeFilterCoef(obj,obj.FilterCoefficients,obj.NumFrequencyBands),...
                'RoundingMethod',obj.RoundingMethod,...
                'OverflowAction',obj.OverflowAction,...
                'ResetInputPort',obj.ResetInputPort);
                validateCoefDataType(hFIR,obj.isInMATLABSystemBlock);
            end
        end

        function validateInputsImpl(obj,varargin)










            coder.extrinsic('dsphdl.private.AbstractChannelizer.isFeatureOn','gcb');
            if isempty(coder.target)||~eml_ambiguous_types

                if~obj.isInMATLABSystemBlock
                    blkName=class(obj);
                else
                    blkName=coder.const(gcb);
                end
                validDataType={'double','single','uint8','uint16','uint32','int8','int16','int32','int64','embedded.fi'};
                validDimension={'vector','column'};

                validateattributes(varargin{1},validDataType,validDimension,'Channelizer','data');

                if isa(varargin{1},'embedded.fi')
                    din=varargin{1};
                    wordLength=din.WordLength;
                    if wordLength<obj.MinWordLength||wordLength>obj.MaxWordLength
                        coder.internal.error('dsphdl:FFT:EmbeddedFi',blkName);
                    end
                end

                obj.pInputVectorSize=length(varargin{1});
                if obj.pInputVectorSize>1
                    if mod(log2(obj.pInputVectorSize),2)~=floor(mod(log2(obj.pInputVectorSize),2))
                        coder.internal.error('dsphdl:FFT:InputVectSizePow2',blkName);
                    end
                    if obj.pInputVectorSize>obj.MaxInputVectorSize
                        if~coder.const(dsphdl.private.AbstractChannelizer.isFeatureOn('ExtendedChannelizerInputSize'))
                            coder.internal.error('dsphdl:FFT:InputVectSizeMax',blkName);
                        end
                    end
                    if obj.pInputVectorSize>obj.NumFrequencyBands
                        coder.internal.error('dsphdl:FFT:InputVectSize',blkName);
                    end
                end

                validateBoolean(obj,varargin{:});
            end

        end


        function flag=isInputComplexityMutableImpl(~,~)

            flag=true;
        end

        function validateBoolean(obj,varargin)
            validDimension={'scalar'};
            if isempty(coder.target)||~eml_ambiguous_types

                validateattributes(varargin{2},{'logical'},validDimension,'Channelizer','valid');
                if obj.ResetInputPort
                    validateattributes(varargin{3},{'logical'},validDimension,'Channelizer','reset');
                end
            end

        end

        function resetImpl(obj)
            if~coder.target('hdl')
                obj.pWrOutBuffer_index=1;
                obj.pRdOutBuffer_index=1;

                obj.pOutBuffer(:)=complex(0);
                obj.pWrOutBuffer_roll=false;
                obj.pRdOutBuffer_roll=false;
                obj.pDRdy=false;
                obj.pOutput(:)=complex(0);
                obj.pSimTime=1;
                obj.pResetStart=false;
                reset(obj.phFFT);
                reset(obj.phFIR);




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

            coder.extrinsic('dsphdl.private.AbstractChannelizer.getFeature','dsphdl.private.AbstractChannelizer.setFeature');

            if~isfloat(A)
                obj.pFimath=fimath('RoundingMethod','Floor','OverflowAction','Wrap');
                obj.pUserFimath=fimath('RoundingMethod',obj.RoundingMethod,'OverflowAction',obj.OverflowAction);
            end
            [inputDT,DTV]=getInputDT(obj,A);
            obj.pInputDT=cast(0,'like',DTV);
            obj.pDRdy=false;
            obj.pIsInputComplex=~isreal(A);
            obj.pInputVectorSize=length(A);
            obj.pNumFrequencyBands=double(obj.NumFrequencyBands);
            obj.pComplexMultiplication=obj.ComplexMultiplication;
            obj.pRoundingMethod=obj.RoundingMethod;
            obj.pOverflowAction=obj.OverflowAction;
            obj.pFilterCoefficientDT=obj.CoefficientsDataType;
            obj.pFilterOutputDTString=obj.FilterOutputDataType;
            if strcmpi(obj.OutputSize,'Same as input size')
                obj.pOutputSize=obj.pInputVectorSize;
            else
                obj.pOutputSize=obj.pNumFrequencyBands;
            end
            obj.pNormalize=obj.Normalize;

            if obj.pNormalize
                obj.pBitGrowthVector=zeros(log2f(obj,obj.NumFrequencyBands),1);
            else
                obj.pBitGrowthVector=ones(log2f(obj,obj.NumFrequencyBands),1);
            end


            hFIR=dsphdl.private.AbstractFilterBank('FilterStructure',obj.FilterStructure,...
            'FilterCoefficientSource','Property',...
            'CoefficientsDataType',obj.CoefficientsDataType,...
            'FilterOutputDataType',obj.FilterOutputDataType,...
            'FilterCoefficients',reshapeFilterCoef(obj,obj.FilterCoefficients,obj.pNumFrequencyBands),...
            'RoundingMethod',obj.RoundingMethod,...
            'OverflowAction',obj.OverflowAction,...
            'ResetInputPort',obj.ResetInputPort);
            obj.phFIR=hFIR;



            obj.pBitReversedInput=obj.BitReversedInput;
            if strcmpi(obj.OutputSize,'Same as input size')
                obj.pBitReversedOutput=obj.BitReversedOutput;
            else
                if obj.pInputVectorSize==obj.pNumFrequencyBands
                    obj.pBitReversedOutput=obj.BitReversedOutput;
                else
                    obj.pBitReversedOutput=true;
                end
            end


            [oldFFTLength,oldFFTInputSize]=dsphdl.private.AbstractChannelizer.getFeature('FFT');
            [ChannelizserLen,ChannelizerSize]=dsphdl.private.AbstractChannelizer.getFeature('Channelizer');
            dsphdl.private.AbstractChannelizer.setFeature('FFT',ChannelizserLen,ChannelizerSize);
            hFFT=dsphdl.FFT(...
            'FFTLength',obj.pNumFrequencyBands,...
            'ComplexMultiplication',obj.pComplexMultiplication,...
            'RoundingMethod',obj.pRoundingMethod,...
            'Normalize',obj.pNormalize,...
            'ResetInputPort',obj.ResetInputPort,...
            'StartOutputPort',obj.StartOutputPort,...
            'EndOutputPort',obj.EndOutputPort,...
            'BitReversedInput',obj.pBitReversedInput,...
            'BitReversedOutput',obj.pBitReversedOutput);

            obj.pFilterOutputDT=getOutputDT(hFIR,inputDT);
            obj.pOutputDT=getOutputDT(hFFT,obj.pFilterOutputDT);

            obj.pWrOutBuffer_index=1;
            obj.pRdOutBuffer_index=1;
            obj.pWrOutBuffer_roll=false;
            obj.pRdOutBuffer_roll=false;
            obj.pOutBuffer_size=4*obj.pOutputSize;
            if isfloat(obj.pOutputDT)
                obj.pOutBuffer=complex(zeros(obj.pOutBuffer_size,1,'like',obj.pOutputDT));
                obj.pOutput=complex(zeros(1,obj.pOutputSize,'like',obj.pOutputDT));
            else
                dType=fi(0,obj.pOutputDT,'RoundingMethod',obj.RoundingMethod,'OverflowAction','Wrap');
                obj.pOutBuffer=complex(zeros(obj.pOutBuffer_size,1,'like',dType));
                obj.pOutput=complex(zeros(1,obj.pOutputSize,'like',dType));
            end

            obj.phFFT=hFFT;
            obj.pResetStart=false;
            obj.pSimTime=1;


            dsphdl.private.AbstractChannelizer.setFeature('FFT',oldFFTLength,oldFFTInputSize);


        end
    end




    methods(Static,Hidden)

    end



    methods(Access=protected)
        function varargout=outputImpl(obj,varargin)









            dataIn=varargin{1};

            filterVldOut=false;
            if isreal(dataIn)&&isreal(obj.FilterCoefficients)
                filterOut=zeros(length(dataIn),1,'like',obj.pFilterOutputDT);
            else
                filterOut=complex(zeros(length(dataIn),1,'like',obj.pFilterOutputDT));
            end

            if obj.StartOutputPort&&obj.EndOutputPort
                if obj.ResetInputPort
                    [FFTDataOut,FFTStartOut,FFTEndOut,FFTVldOut]=output(obj.phFFT,filterOut,filterVldOut,varargin{3});
                else
                    [FFTDataOut,FFTStartOut,FFTEndOut,FFTVldOut]=output(obj.phFFT,filterOut,filterVldOut);
                end
            elseif obj.StartOutputPort
                if obj.ResetInputPort
                    [FFTDataOut,FFTStartOut,FFTVldOut]=output(obj.phFFT,filterOut,filterVldOut,varargin{3});
                else
                    [FFTDataOut,FFTStartOut,FFTVldOut]=output(obj.phFFT,filterOut,filterVldOut);
                end
            elseif obj.EndOutputPort
                if obj.ResetInputPort
                    [FFTDataOut,FFTEndOut,FFTVldOut]=output(obj.phFFT,filterOut,filterVldOut,varargin{3});
                else
                    [FFTDataOut,FFTEndOut,FFTVldOut]=output(obj.phFFT,filterOut,filterVldOut);
                end
            else
                if obj.ResetInputPort
                    [FFTDataOut,FFTVldOut]=output(obj.phFFT,filterOut,filterVldOut,varargin{3});
                else
                    [FFTDataOut,FFTVldOut]=output(obj.phFFT,filterOut,filterVldOut);
                end
            end
            if strcmpi(obj.OutputSize,'Same as number of frequency bands')
                [dataOut,dVldOut]=read_outBuffer(obj,FFTDataOut);
                varargout{1}=dataOut;
                if obj.StartOutputPort&&obj.EndOutputPort
                    varargout{2}=dVldOut;
                    varargout{3}=dVldOut;
                    varargout{4}=dVldOut;
                elseif obj.StartOutputPort||obj.EndOutputPort
                    varargout{2}=dVldOut;
                    varargout{3}=dVldOut;



                else
                    varargout{2}=dVldOut;
                end
                write_outBuffer(obj,FFTDataOut,FFTVldOut);
            else
                varargout{1}=FFTDataOut;
                if obj.StartOutputPort&&obj.EndOutputPort
                    varargout{2}=FFTStartOut;
                    varargout{3}=FFTEndOut;
                    varargout{4}=FFTVldOut;
                elseif obj.StartOutputPort
                    varargout{2}=FFTStartOut;
                    varargout{3}=FFTVldOut;
                elseif obj.EndOutputPort
                    varargout{2}=FFTEndOut;
                    varargout{3}=FFTVldOut;
                else
                    varargout{2}=FFTVldOut;
                end
            end

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
                dataIn_cast=cast(dataIn,'like',obj.pInputDT);

                if obj.pResetStart
                    obj.pResetStart=false;
                end
                if resetIn
                    obj.pResetStart=true;
                    validIn=false;
                    if isreal(dataIn)
                        dataIn_cast(:)=cast(zeros(length(dataIn),1),'like',obj.pInputDT);
                    else
                        dataIn_cast(:)=cast(complex(zeros(length(dataIn),1)),'like',obj.pInputDT);
                    end
                end

                resetIfTrue(obj);

















                if obj.ResetInputPort
                    [filterOut,filterVldout]=step(obj.phFIR,dataIn_cast,validIn,varargin{3});
                else
                    [filterOut,filterVldout]=step(obj.phFIR,dataIn_cast,validIn);
                end
                if obj.ResetInputPort
                    update(obj.phFFT,filterOut,filterVldout,varargin{3});
                else
                    update(obj.phFFT,filterOut,filterVldout);
                end


                updateSimTime(obj);
            end
        end
        function resetIfTrue(obj)
            if obj.pResetStart
                resetImpl(obj);
            end
        end
    end









    methods(Hidden)
        function coefTable=reshapeFilterCoef(obj,FilterCoefficients,NumFrequencyBands)%#ok<INUSL> %, dataIn)

            numOfCoef=length(FilterCoefficients);
            zeroPadLen=NumFrequencyBands-mod(numOfCoef,NumFrequencyBands);
            if zeroPadLen==NumFrequencyBands
                coef_zeroPad=FilterCoefficients;
            else

                coef_zeroPad=[FilterCoefficients(:);zeros(zeroPadLen,1,'like',FilterCoefficients)];


            end

            NumTaps=length(coef_zeroPad)/NumFrequencyBands;
            coef_reshape=reshape(coef_zeroPad,NumFrequencyBands,NumTaps);
            coefTable=flipud(coef_reshape);

        end
        function result=log2f(obj,data)%#ok<INUSL> 
            result=log2(double(data));
        end


        function latency=waitCycle4dVld(obj,numFreqBands,inVectSize)
            coder.extrinsic('dsphdl.private.AbstractChannelizer.getFeature','dsphdl.private.AbstractChannelizer.setFeature');
            latency=0;
            if~coder.target('hdl')

                [oldFFTLength,oldFFTInputSize]=dsphdl.private.AbstractChannelizer.getFeature('FFT');
                [ChannelizserLen,ChannelizerSize]=dsphdl.private.AbstractChannelizer.getFeature('Channelizer');
                dsphdl.private.AbstractChannelizer.setFeature('FFT',ChannelizserLen,ChannelizerSize);

                if strcmpi(obj.OutputSize,'Same as input size')
                    OutputOrder=false;
                else
                    if inVectSize==numFreqBands
                        OutputOrder=false;
                    else
                        OutputOrder=true;
                    end
                end
                if~isnumerictype(obj.CoefficientsDataType)
                    coeffFIRDT=numerictype('double');
                else
                    coeffFIRDT=obj.CoefficientsDataType;
                end
                fft=dsphdl.FFT('BitReversedOutput',OutputOrder);


                filtcoeff=reshapeFilterCoef(obj,obj.FilterCoefficients,numFreqBands);
                fir=dsphdl.private.AbstractFilterBank('FilterStructure',obj.FilterStructure,'FilterCoefficients',filtcoeff);
                fft_Latency=getLatency(fft,numFreqBands,inVectSize);
                filter_Latency=getLatency(fir,coeffFIRDT,filtcoeff,...
                numFreqBands,inVectSize,false);

                if strcmpi(obj.OutputSize,'Same as input size')||inVectSize==numFreqBands
                    outputLatency=0;


                else
                    outputLatency=numFreqBands/inVectSize+1;
                end
                latency=fft_Latency+filter_Latency+outputLatency;
                release(fir);
                release(fft);



                dsphdl.private.AbstractChannelizer.setFeature('FFT',oldFFTLength,oldFFTInputSize);


            end
        end
    end
    methods(Access=protected)
        function write_outBuffer(obj,data,vldIn)
            if vldIn
                for loop=coder.unroll(1:length(data))
                    obj.pOutBuffer(obj.pWrOutBuffer_index)=data(loop);
                    if obj.pWrOutBuffer_index<obj.pOutBuffer_size
                        obj.pWrOutBuffer_index=obj.pWrOutBuffer_index+1;
                    else
                        obj.pWrOutBuffer_index=1;
                        obj.pWrOutBuffer_roll=~obj.pWrOutBuffer_roll;
                    end
                end
            end
        end

        function[data,dataVld]=read_outBuffer(obj,dataIn)
            if isfloat(dataIn)
                if isa(dataIn,'single')
                    zeroData=complex(single(zeros(1,obj.pOutputSize)));
                else
                    zeroData=complex(zeros(1,obj.pOutputSize));
                end
            else
                zeroData=complex(zeros(1,obj.pOutputSize,'like',obj.pOutput));
            end

            if obj.pDRdy
                obj.pDRdy=false;
                dataVld=true;
                if obj.pNumFrequencyBands==obj.pInputVectorSize
                    data=obj.pOutput(1:length(obj.pOutput));
                else
                    data=obj.pOutput(bitrevorder(1:length(obj.pOutput)));
                end
            else
                dataVld=false;
                data=zeroData;
            end

            dLen=availableData(obj);
            latency=waitCycle4dVld(obj,obj.pNumFrequencyBands,obj.pInputVectorSize)-1;
            if dLen>=obj.pOutputSize&&obj.pSimTime>=latency
                for loop=coder.unroll(1:length(data))
                    obj.pOutput(1,loop)=obj.pOutBuffer(obj.pRdOutBuffer_index);
                    if obj.pRdOutBuffer_index<obj.pOutBuffer_size
                        obj.pRdOutBuffer_index=obj.pRdOutBuffer_index+1;
                    else
                        obj.pRdOutBuffer_index=1;
                        obj.pRdOutBuffer_roll=~obj.pRdOutBuffer_roll;
                    end
                end
                obj.pDRdy=true;
            else
                obj.pDRdy=false;
            end
        end

        function updateSimTime(obj)
            obj.pSimTime=obj.pSimTime+1;
        end

        function dataLength=availableData(obj)
            if obj.pRdOutBuffer_roll==obj.pWrOutBuffer_roll
                dataLength=obj.pWrOutBuffer_index-obj.pRdOutBuffer_index;
            else
                dataLength=obj.pOutBuffer_size-obj.pRdOutBuffer_index+obj.pWrOutBuffer_index;
            end

        end
    end

    methods(Static,Hidden)
        function status=isFeatureOn(feature)
            status=strcmpi(hdldspfeature(feature),'on');
        end
        function[Length,InputSize]=getFeature(block)
            if strcmpi(block,'FFT')
                Length=hdldspfeature('ExtendedFFTLength');
                InputSize=hdldspfeature('ExtendedFFTInputSize');
            else
                Length=hdldspfeature('ExtendedChannelizerFrequencyBand');
                InputSize=hdldspfeature('ExtendedChannelizerInputSize');
            end
        end

        function setFeature(block,Length,InputSize)
            if strcmpi(block,'FFT')
                hdldspfeature('ExtendedFFTLength',Length);
                hdldspfeature('ExtendedFFTInputSize',InputSize);
            else
                hdldspfeature('ExtendedChannelizerFrequencyBand',Length);
                hdldspfeature('ExtendedChannelizerInputSize',InputSize);
            end
        end
    end

end


