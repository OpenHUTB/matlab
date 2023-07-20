classdef(StrictDefaults)ChannelSynthesizer<matlab.System






















































































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




        FilterCoefficients=[-0.0329,0.1218,0.3183,0.4829,0.5469,0.4829,0.3183,0.1218,-0.0329];





        RoundingMethod='Floor';




        OverflowAction='Wrap';





        CoefficientsDataType='Same word length as input';







        OutputDataType='Full precision';
    end

    properties(Nontunable,Access=private)

        NumFrequencyBands;
        InputDT;
        phIFFT;
        phFIR;
        nch;
        IFFOutputTDT;
    end
    properties(Access=private)

dataOut
dVldOut
dataOutRst
    end



    properties(Nontunable)


        ResetInputPort(1,1)logical=false;



        Normalize(1,1)logical=true;
    end






    properties(Constant,Hidden)
        FilterStructureSet=matlab.system.StringSet({...
        'Direct form systolic',...
        'Direct form transposed'});

        RoundingMethodSet=matlab.system.internal.RoundingMethodSet({'Ceiling','Convergent','Floor','Nearest','Round','Zero'});
        OverflowActionSet=matlab.system.internal.OverflowActionSet;
        OutputDataTypeSet=matlab.system.internal.DataTypeSet({...
        'Full precision',...
        'Same as input',...
        matlab.system.internal.CustomDataType('Signedness',{'Signed','Unsigned'})},...
        'HasDesignMinimum',false,...
        'HasDesignMaximum',false);
        CoefficientsDataTypeSet=matlab.system.internal.DataTypeSet(...
        {...
        'Same word length as input',...
        matlab.system.internal.CustomDataType(...
        'Signedness',{'Signed','Unsigned'},...
        'Scaling',{'BinaryPoint','Unspecified'})...
        },...
        'ValuePropertyName','FilterCoefficients',...
        'HasDesignMinimum',false,...
        'HasDesignMaximum',false);
        ComplexMultiplicationSet=matlab.system.StringSet({'Use 3 multipliers and 5 adders',...
        'Use 4 multipliers and 2 adders'});
    end



    methods(Hidden)
        function coefTable=reshapeFilterCoef(~,FilterCoefficients,NumFrequencyBands)
            numOfCoef=length(FilterCoefficients);
            zeroPadLen=NumFrequencyBands-mod(numOfCoef,NumFrequencyBands);
            if zeroPadLen==NumFrequencyBands
                coef_zeroPad=FilterCoefficients;
            else
                coef_zeroPad=[FilterCoefficients(:);zeros(zeroPadLen,1,'like',FilterCoefficients)];
            end

            NumTaps=length(coef_zeroPad)/NumFrequencyBands;
            coef_reshape=reshape(coef_zeroPad,NumFrequencyBands,NumTaps);
            coefTable=(coef_reshape);

        end

        function latency=waitCycle4dVld(obj,numFreqBands)
            latency=0;
            if~coder.target('hdl')
                inVectSize=numFreqBands;
                OutputOrder=false;
                if~isnumerictype(obj.CoefficientsDataType)
                    coeffFIRDT=numerictype('double');
                else
                    coeffFIRDT=obj.CoefficientsDataType;
                end
                coeff=reshapeFilterCoef(obj,obj.FilterCoefficients,numFreqBands);
                ifft=dsphdl.IFFT('BitReversedOutput',OutputOrder);
                fir=dsphdl.private.AbstractFilterBank('FilterStructure',obj.FilterStructure,...
                'FilterCoefficients',coeff);

                ifft_Latency=getLatency(ifft,numFreqBands,inVectSize);
                filter_Latency=getLatency(fir,coeffFIRDT,coeff,...
                inVectSize,numFreqBands,true);
                outputLatency=0;
                latency=ifft_Latency+filter_Latency+outputLatency;
                release(fir);
                release(ifft);
            end
        end
    end




    methods(Access=public)
        function latency=getLatency(obj,varargin)



            if nargin==2
                numFreqBands=varargin{1};
            else
                if~isempty(obj.NumFrequencyBands)
                    numFreqBands=obj.NumFrequencyBands;
                else
                    numFreqBands=4;
                end
            end
            latency=waitCycle4dVld(obj,numFreqBands)+1;
            if~obj.isInMATLABSystemBlock&&...
                ~isreal(obj.FilterCoefficients)&&isfloat(obj.InputDT)
                latency=latency-1;
            end

        end
    end



    methods(Access=protected,Static)
        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end

        function groups=getPropertyGroupsImpl

            algorithmParameters=matlab.system.display.Section(...
            'Title','Filter parameters',...
            'PropertyList',{'FilterCoefficients','FilterStructure'});
            iFFTParameters=matlab.system.display.Section(...
            'Title','IFFT parameters',...
            'PropertyList',{'ComplexMultiplication','Normalize'});


            mainGroup=matlab.system.display.SectionGroup(mfilename('class'),...
            'TitleSource','Auto',...
            'Sections',[algorithmParameters,iFFTParameters]);





            rstPort=matlab.system.display.Section(...
            'Title','Initialize data path registers',...
            'PropertyList',{'ResetInputPort'});

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
        function[DT,VAR]=getInputDT(~,data)
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
            elseif isa(data,'uint64')
                DT=numerictype(0,64,0);
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
        function varargout=isInputDirectFeedthroughImpl(~,varargin)
            for ii=1:nargout
                varargout{ii}=false;
            end
        end
        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);
            if obj.isLocked
                s.phIFFT=obj.phIFFT;
                s.phFIR=obj.phFIR;
                s.dataOut=obj.dataOut;
                s.NumFrequencyBands=obj.NumFrequencyBands;
                s.nch=obj.nch;
                s.InputDT=obj.InputDT;
                s.dVldOut=obj.dVldOut;
                s.FilterStructure=obj.FilterStructure;
                s.ComplexMultiplication=obj.ComplexMultiplication;
                s.FilterCoefficients=obj.FilterCoefficients;
                s.RoundingMethod=obj.RoundingMethod;
                s.OverflowAction=obj.OverflowAction;
                s.CoefficientsDataType=obj.CoefficientsDataType;
                s.OutputDataType=obj.OutputDataType;
                s.IFFOutputTDT=obj.IFFOutputTDT;
                s.ResetInputPort=obj.ResetInputPort;
                s.Normalize=obj.Normalize;
                s.dataOutRst=obj.dataOutRst;
            end
        end
        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for i=1:numel(fn)
                obj.(fn{i})=s.(fn{i});
            end
        end
        function varargout=getOutputDataTypeImpl(obj,varargin)
            inputDT=propagatedInputDataType(obj,1);
            if(~isempty(inputDT))
                t=fliplr(propagatedInputSize(obj,1));
                lenOfIfft=t(1);

                inputDT=getInputDT(obj,inputDT);
                if~coder.target('hdl')

                    if isnumerictype(obj.OutputDataType)
                        ouputFIRDT=obj.OutputDataType;
                    elseif strcmpi(obj.OutputDataType,'Same as input')
                        if isnumerictype(inputDT)
                            ouputFIRDT=inputDT;
                        else
                            ouputFIRDT='Full precision';
                        end
                    else
                        ouputFIRDT=obj.OutputDataType;
                    end

                    if isnumerictype(obj.CoefficientsDataType)
                        coeffFIRDT=obj.CoefficientsDataType;
                    else
                        if isnumerictype(inputDT)
                            var=fi(0,inputDT);
                            coefftype=fi(obj.FilterCoefficients,any(obj.FilterCoefficients<0)||...
                            (any(real(obj.FilterCoefficients)<0)||any(imag(obj.FilterCoefficients)<0)),var.WordLength);
                            coeffFIRDT=numerictype(issigned(coefftype),coefftype.WordLength,coefftype.FractionLength);

                        else
                            coeffFIRDT=obj.CoefficientsDataType;
                        end

                    end
                    if~any(lenOfIfft==[4,8,16,32,64])
                        lenOfIfft=4;
                    end

                    hIFFT=dsphdl.IFFT('Normalize',obj.Normalize,...
                    'FFTLength',lenOfIfft);
                    hFIR=dsphdl.private.AbstractFilterBank('FilterStructure',obj.FilterStructure,...
                    'CoefficientsDataType',coeffFIRDT,...
                    'FilterOutputDataType',ouputFIRDT,...
                    'FilterCoefficients',reshapeFilterCoef(obj,obj.FilterCoefficients,lenOfIfft));


                    ifftOutputDT=getOutputDT(hIFFT,inputDT);
                    OutputDT=getOutputDT(hFIR,ifftOutputDT);

                    if isfloat(OutputDT)
                        if isa(OutputDT,'single')
                            varargout{1}=numerictype('single');
                        else
                            varargout{1}=numerictype('double');
                        end
                    else
                        varargout{1}=numerictype(OutputDT);
                    end
                    for ii=2:getNumOutputs(obj)
                        varargout{ii}=numerictype('boolean');
                    end
                    release(hIFFT);
                    release(hFIR);

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


        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end

        function icon=getIconImpl(obj)
            if isempty(obj.nch)
                icon=sprintf('Channel Synthesizer\nLatency = --');
            else
                t=fliplr(propagatedInputSize(obj,1));
                icon=sprintf('Channel Synthesizer\nLatency = %d',getLatency(obj,t(1)));
            end
        end

        function varargout=getOutputSizeImpl(obj)
            varargout{1}=fliplr(propagatedInputSize(obj,1));
            varargout{2}=[1,1];
        end

    end



    methods

        function obj=ChannelSynthesizer(varargin)
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
            'Use 4 multipliers and 2 adders'},'ChannelSynthesizer','ComplexMultiplication');
            obj.ComplexMultiplication=val;
        end

        function set.RoundingMethod(obj,val)
            validatestring(val,{'Ceiling','Convergent','Floor',...
            'Nearest','Round','Zero'},'ChannelSynthesizer','Rounding mode');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            validatestring(val,{'Wrap','Saturate'},'ChannelSynthesizer','Overflow Action');
            obj.OverflowAction=val;
        end

        function set.FilterStructure(obj,value)
            validatestring(value,{'Direct form systolic','Direct form transposed'},...
            'ChannelSynthesizer','Filter Structure');
            obj.FilterStructure=value;
        end

        function set.FilterCoefficients(obj,value)
            validateattributes(value,...
            {'numeric'},...
            {'finite','nonempty','row'},...
            'ChannelSynthesizer','Filter Coefficients');

            obj.FilterCoefficients=value;
        end
    end





    methods(Access=protected)
        function validatePropertiesImpl(obj)


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
                    coder.internal.error('dsphdl:ChannelSynthesizer:AllZeroCoeffs');
                end
            end
        end
        function validateInputsImpl(obj,varargin)








            coder.extrinsic('dsphdl.ChannelSynthesizer.isFeatureOn','gcb');
            if~coder.target('hdl')

                if~obj.isInMATLABSystemBlock
                    blkName=class(obj);
                else
                    blkName=coder.const(gcb);
                end

                validDataType={'double','single','uint8','uint16','uint32','int8','int16','int32','int64','embedded.fi'};
                validDimension={'vector','row'};
                t=fliplr(propagatedInputSize(obj,1));


                validateattributes(varargin{1},validDataType,validDimension,'ChannelSynthesizer','data');

                if isa(varargin{1},'embedded.fi')
                    din=varargin{1};
                    wordLength=din.WordLength;
                    if wordLength<obj.MinWordLength||wordLength>obj.MaxWordLength
                        coder.internal.error('dsphdl:FFT:EmbeddedFi',blkName);
                    end
                end

                inputVectorSize=t(1);

                if~any(inputVectorSize==[4,8,16,32,64])
                    coder.internal.error('dsphdl:ChannelSynthesizer:InputVecSize');
                end

                validateBoolean(obj,varargin{:});
                obj.nch=length(varargin{1});
            end

        end


        function flag=isInputComplexityMutableImpl(~,~)

            flag=true;
        end

        function validateBoolean(obj,varargin)
            validDimension={'scalar'};
            if~coder.target('hdl')

                validateattributes(varargin{2},{'logical'},validDimension,'ChannelSynthesizer','valid');
                if obj.ResetInputPort
                    validateattributes(varargin{3},{'logical'},validDimension,'ChannelSynthesizer','reset');
                end
            end

        end

        function resetImpl(obj)
            if~coder.target('hdl')
                reset(obj.phIFFT);
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

            [inputDT,VAR]=getInputDT(obj,A);
            obj.InputDT=cast(0,'like',VAR);
            obj.NumFrequencyBands=length(A);
            if isnumerictype(obj.OutputDataType)
                ouputFIRDT=obj.OutputDataType;
            elseif strcmpi(obj.OutputDataType,'Same as input')
                if(~isfloat(inputDT))
                    ouputFIRDT=(inputDT);
                else
                    ouputFIRDT='Full precision';
                end
            else
                ouputFIRDT=obj.OutputDataType;
            end

            if isnumerictype(obj.CoefficientsDataType)
                coeffFIRDT=obj.CoefficientsDataType;
            else
                if isnumerictype(inputDT)
                    var=fi(0,inputDT);
                    coefftype=fi(obj.FilterCoefficients,any(obj.FilterCoefficients<0)||...
                    (any(real(obj.FilterCoefficients)<0)||any(imag(obj.FilterCoefficients)<0)),var.WordLength);
                    coeffFIRDT=numerictype(issigned(coefftype),coefftype.WordLength,coefftype.FractionLength);
                else
                    coeffFIRDT=obj.CoefficientsDataType;
                end

            end


            hFIR=dsphdl.private.AbstractFilterBank('FilterStructure',obj.FilterStructure,...
            'FilterCoefficientSource','Property',...
            'CoefficientsDataType',coeffFIRDT,...
            'FilterOutputDataType',ouputFIRDT,...
            'FilterCoefficients',reshapeFilterCoef(obj,obj.FilterCoefficients,length(A)),...
            'RoundingMethod',obj.RoundingMethod,...
            'OverflowAction',obj.OverflowAction,...
            'ResetInputPort',obj.ResetInputPort);
            obj.phFIR=hFIR;
            validateCoefDataType(hFIR,obj.isInMATLABSystemBlock);


            hIFFT=dsphdl.IFFT(...
            'FFTLength',length(A),...
            'ComplexMultiplication',obj.ComplexMultiplication,...
            'RoundingMethod',obj.RoundingMethod,...
            'Normalize',obj.Normalize,...
            'ResetInputPort',obj.ResetInputPort,...
            'StartOutputPort',false,...
            'EndOutputPort',false,...
            'BitReversedInput',obj.BitReversedInput,...
            'BitReversedOutput',obj.BitReversedOutput);


            obj.IFFOutputTDT=getOutputDT(hIFFT,obj.InputDT);
            FilterOutputDT=getOutputDT(hFIR,obj.IFFOutputTDT);

            outputDT=FilterOutputDT;

            obj.phIFFT=hIFFT;
            obj.dataOut=...
            complex(cast(zeros(obj.NumFrequencyBands,1),'like',outputDT));
            obj.dVldOut=false;
            obj.dataOutRst=...
            complex(cast(zeros(obj.NumFrequencyBands,1),'like',outputDT));

        end
    end





    methods(Access=protected)
        function varargout=outputImpl(obj,varargin)
            if obj.ResetInputPort
                if varargin{3}
                    varargout{1}=obj.dataOutRst;
                    varargout{2}=false;
                else
                    varargout{1}=obj.dataOut(:);
                    varargout{2}=obj.dVldOut;
                end
            else
                varargout{1}=obj.dataOut(:);
                varargout{2}=obj.dVldOut(:);
            end
        end

        function updateImpl(obj,varargin)

            if~coder.target('hdl')
                dataIn=varargin{1};
                validIn=varargin{2};
                if obj.ResetInputPort
                    resetIn=varargin{3};
                else
                    resetIn=false;
                end
                dataIn_cast=cast(dataIn(:),'like',obj.InputDT);

                if obj.ResetInputPort
                    [ifftIn,ifftValid]=step(obj.phIFFT,dataIn_cast(:),validIn,resetIn);
                else
                    [ifftIn,ifftValid]=step(obj.phIFFT,dataIn_cast(:),validIn);
                end

                if obj.ResetInputPort
                    [obj.dataOut,obj.dVldOut]=...
                    step(obj.phFIR,ifftIn,ifftValid,resetIn);
                else
                    [obj.dataOut,obj.dVldOut]=...
                    step(obj.phFIR,ifftIn,ifftValid);
                end
            end
        end

    end


    methods(Static,Access=protected)
        function header=getHeaderImpl
            header=matlab.system.display.Header('dsphdl.ChannelSynthesizer',...
            'ShowSourceLink',false,...
            'Title','Channel Synthesizer',...
            'Text',sprintf(['Combine narrowband signals to broadband '...
            ,'signal using polyphase FFT synthesis filter bank '...
            ,'technique.']));
        end
    end

    methods(Static)

        function helpFixedPoint






            matlab.system.dispFixptHelp('dsphdl.ChannelSynthesizer',...
            {'RoundingMethod','OverflowAction',...
            'CoefficientsDataType','OutputDataType'});
        end

    end

    methods(Static,Hidden)
        function status=isFeatureOn(feature)
            status=strcmpi(hdldspfeature(feature),'on');
        end
    end

    methods(Access=protected)
        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end
    end

end
