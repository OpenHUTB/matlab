classdef(StrictDefaults)OFDMModulator<matlab.System





%#codegen






    properties(Nontunable)

        OFDMParametersSource='Property';


        FFTLength=64;


        MaxFFTLength=64;


        CPLength=16;


        numLgSc=6;


        numRgSc=5;


        RoundingMethod='Floor';


        WindowLength=4;


        MaxWindowLength=8;




        InsertDCNull(1,1)logical=true;


        ResetInputPort(1,1)logical=false;


        Normalize(1,1)logical=true;


        Windowing(1,1)logical=false;
    end

    properties(Constant,Hidden)
        OFDMParametersSourceSet=matlab.system.StringSet({'Property','Input Port'});
        RoundingMethodSet=matlab.system.StringSet({'Ceiling','Convergent','Floor','Nearest','Round','Zero'});
    end

    properties(Nontunable,Access=private)
        vecLen;
        vecLenFi;
        numSymbs;
        pInputVectorSize;
    end

    properties(Access=private)

        dataIn;
        validIn;


        dataOut;
        validOut;
        readyOut;


        resetSignal;



        symbolFormationObj;
        samplesRepetitionObj;
        IFFTObj;
        HDLFFTShiftModObj;
        CPAdditionObj;
        DownSamplerModObj;
        WindowingObj;

        dataInReg;
        validInReg;
dataOutReady
validOutReady
        insertDC;
        FFTLengthReg;
        CPLengthReg;
        numLgScReg;
        numRgScReg;
        FFTLenOutReady;
        CPLenOutReady;
        numLgScOutReady;
        numRgScOutReady;
        guardSum;
        DCGuardSum;
        maxFFTPlusCP;
        resetReg;
        numDataSc;
        readyHigh;
        readyLow;
        readyLast;
        validInHighCount;
        readyLowCount;
        readyLowMinusVecLen;
        readyFlag;
        validInHighFlag;
        readyLowFlag;
        readyState;
        triggerReady;
        delayedReady;
        sampleInputs;
        sampling;
        validInAndvalidInHighFlag;
        validInHighAndReadyLowFlag;
        validHighFlagLowAndReadyLowFlagLow;
        validHighFlagHighAndReadyLowFlagLow;
        validHighFlagHighAndReadyLowFlagLowHigh;


        vInFFTDelayBal;
        fftInFFTDelayBal;
        cpInFFTDelayBal;
        startFFTDelayBal;
        countReg;
        FFTReg;
        cpReg;
        index;
        FFTRegDelay;
        cpRegDelay;
        index1;
        vecLenReg;

winInFFTDelayBal
winReg
winRegDelay
        winLenOut;
        winLenOutReg;
        winLenZeroFlag;
    end




    methods


        function obj=OFDMModulator(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','LTE_HDL_Toolbox'))
                    error(message('whdl:whdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','LTE_HDL_Toolbox');
            end


            setProperties(obj,nargin,varargin{:});
        end


        function set.FFTLength(obj,val)
            validateattributes(val,{'double','single','embedded.fi','uint32','uint16','uint8'},...
            {'scalar','real','positive','integer'},'OFDMModulator','FFTLength');
            if(isa(val,'embedded.fi'))
                if dsphdlshared.hdlgetwordsizefromdata(val)<4||val.Signed==1||val.FractionLength>0
                    coder.internal.error('whdl:GenOFDMModulator:InvalidFFTWordlength');
                end
            end
            val=double(val);
            if floor(log2(val))~=log2(val)
                coder.internal.error('whdl:GenOFDMModulator:FFTNotPowOfTwo');
            else
                validateattributes(val,{'numeric'},{'integer','scalar','>=',2^3,'<=',2^16},'OFDMModulator','FFTLength');
            end
            obj.FFTLength=val;

        end


        function set.MaxFFTLength(obj,val)
            validateattributes(val,{'double','single','embedded.fi','uint32','uint16','uint8'},...
            {'scalar','real','positive','integer'},'OFDMModulator','MaxFFTLength');
            if(isa(val,'embedded.fi'))
                if dsphdlshared.hdlgetwordsizefromdata(val)<4||val.Signed==1||val.FractionLength>0
                    coder.internal.error('whdl:GenOFDMModulator:InvalidMaxFFTWordlength');
                end
            end
            val=double(val);
            if floor(log2(val))~=log2(val)
                coder.internal.error('whdl:GenOFDMModulator:MaxFFTNotPowTwo');
            else
                validateattributes(val,{'numeric'},{'integer','scalar','>=',2^3,'<=',2^16},'OFDMModulator','MaxFFTLength');
            end
            obj.MaxFFTLength=val;
        end


        function set.numLgSc(obj,val)
            validateattributes(val,{'double','single','embedded.fi','uint32','uint16','uint8'},...
            {'scalar','>=',0,'real','integer'},'OFDMModulator','numLgSc');
            if(isa(val,'embedded.fi'))
                if dsphdlshared.hdlgetwordsizefromdata(val)<2||val.Signed==1||val.FractionLength>0
                    coder.internal.error('whdl:GenOFDMModulator:InvalidLgScWordLength');
                end
            end

            if double(val)>=obj.FFTLength/2
                coder.internal.error('whdl:GenOFDMModulator:numLgScGrtFFTBy2');
            end
            obj.numLgSc=val;
        end

        function set.numRgSc(obj,val)
            validateattributes(val,{'double','single','embedded.fi','uint32','uint16','uint8'},...
            {'scalar','>=',0,'real','integer'},'OFDMModulator','numRgSc');
            if(isa(val,'embedded.fi'))
                if(dsphdlshared.hdlgetwordsizefromdata(val)<2)||val.Signed==1||val.FractionLength>0
                    coder.internal.error('whdl:GenOFDMModulator:InvalidRgScCWordLength');
                end
            end

            if double(val)>=obj.FFTLength/2
                coder.internal.error('whdl:GenOFDMModulator:numRgScGrtFFTBy2');
            end
            obj.numRgSc=val;

        end


        function set.CPLength(obj,val)
            validateattributes(val,{'double','single','embedded.fi','uint32','uint16','uint8'},...
            {'scalar','>=',0,'real','integer'},'OFDMModulator','CPLength');
            if(isa(val,'embedded.fi'))
                if dsphdlshared.hdlgetwordsizefromdata(val)<4||val.Signed==1||val.FractionLength>0
                    coder.internal.error('whdl:GenOFDMModulator:InvalidCPWordLength');
                end
            end
            if double(val)>obj.FFTLength
                coder.internal.error('whdl:GenOFDMModulator:CPGrtFFTErr');
            end
            obj.CPLength=val;
        end


        function set.WindowLength(obj,val)
            if obj.Windowing&&strcmpi(obj.OFDMParametersSource,'Property')
                validateattributes(val,{'double','single','embedded.fi','uint32','uint16','uint8'},...
                {'scalar','>',0,'<=',2^16,'real','positive','integer'},'OFDMModulator','WindowLength');

                if double(val)>double(obj.CPLength)
                    coder.internal.error('whdl:GenOFDMModulator:WindowGrtCPErr');
                end
            end
            obj.WindowLength=val;
        end


        function set.MaxWindowLength(obj,val)
            if obj.Windowing&&strcmpi(obj.OFDMParametersSource,'Input port')
                validateattributes(val,{'double','single','embedded.fi','uint32','uint16','uint8'},...
                {'scalar','>',0,'<=',2^16,'real','positive','integer'},'OFDMModulator','MaxWindowLength');
            end
            obj.MaxWindowLength=val;
        end
    end

    methods(Access=protected)

        function validateInputsImpl(obj,varargin)







            coder.extrinsic('tostringInternalSlName');

            datain=varargin{1};
            if isa(datain,'uint8')||isa(datain,'uint16')||isa(datain,'uint32')||isa(datain,'logical')||(isa(datain,'embedded.fi')&&~datain.Signed)
                coder.internal.error('whdl:GenOFDMModulator:InvalidDatatype');
            end
            validateattributes(datain,{'double','single','embedded.fi','int32','int16','int8'},{'vector','column'},'OFDMModulator','data');

            obj.pInputVectorSize=length(varargin{1});

            if mod(log2(obj.pInputVectorSize),2)~=floor(mod(log2(obj.pInputVectorSize),2))
                coder.internal.error('whdl:GenOFDMModulator:validVectorSize');
            end
            if obj.pInputVectorSize>64
                coder.internal.error('whdl:GenOFDMModulator:validVectorSize');
            end


            if strcmpi(obj.OFDMParametersSource,'Input Port')
                FFTLen=varargin{3};
                CPLen=varargin{4};
                LGuardSc=varargin{5};
                RGuardSc=varargin{6};

                if obj.pInputVectorSize>double(obj.MaxFFTLength)
                    coder.internal.error('whdl:GenOFDMModulator:MaxFFTLessInputVectSize');
                end

                validateattributes(FFTLen,{'double','single','embedded.fi','uint32','uint16','uint8'},...
                {'scalar','>=',0,'real','integer'},'OFDMModulator','FFTLength');
                if(isa(FFTLen,'embedded.fi'))
                    if(dsphdlshared.hdlgetwordsizefromdata(FFTLen)<4||FFTLen.Signed||FFTLen.FractionLength>0)
                        coder.internal.error('whdl:GenOFDMModulator:InvalidFFTWordlength');
                    end
                end


                validateattributes(CPLen,{'double','single','embedded.fi','uint32','uint16','uint8'},...
                {'scalar','>=',0,'real','integer'},'OFDMModulator','CPLength');
                if(isa(CPLen,'embedded.fi'))
                    if(dsphdlshared.hdlgetwordsizefromdata(CPLen)<4||CPLen.Signed||CPLen.FractionLength>0)
                        coder.internal.error('whdl:GenOFDMModulator:InvalidCPWordLength');
                    end
                end


                validateattributes(LGuardSc,{'double','single','embedded.fi','uint32','uint16','uint8'},...
                {'scalar','>=',0,'real','integer'},'OFDMModulator','LeftGuardSubcarriers');
                if(isa(LGuardSc,'embedded.fi'))
                    if(dsphdlshared.hdlgetwordsizefromdata(LGuardSc)<2||LGuardSc.Signed||LGuardSc.FractionLength>0)
                        coder.internal.error('whdl:GenOFDMModulator:InvalidLgScWordLength');
                    end
                end


                validateattributes(RGuardSc,{'double','single','embedded.fi','uint32','uint16','uint8'},...
                {'scalar','>=',0,'real','integer'},'OFDMModulator','RightGuardSubcarriers');
                if(isa(RGuardSc,'embedded.fi'))
                    if(dsphdlshared.hdlgetwordsizefromdata(RGuardSc)<2||RGuardSc.Signed||RGuardSc.FractionLength>0)
                        coder.internal.error('whdl:GenOFDMModulator:InvalidRgScWordLength');
                    end
                end
                if obj.Windowing
                    WinLen=varargin{7};

                    validateattributes(WinLen,{'double','single','embedded.fi','uint32','uint16','uint8'},...
                    {'scalar','>=',0,'real','integer'},'OFDMModulator','WindowLength');
                    if double(WinLen)>double(obj.MaxWindowLength)
                        coder.internal.error('whdl:GenOFDMModulator:WindowGrtMaxWindowErr');
                    end
                    if double(WinLen)>double(CPLen)
                        coder.internal.error('whdl:GenOFDMModulator:WindowGrtCPErr');
                    end
                end
            else

                if obj.pInputVectorSize>double(obj.FFTLength)
                    coder.internal.error('whdl:GenOFDMModulator:FFTLessInputVectSize');
                end

                if obj.InsertDCNull
                    DcStatus=1;
                else
                    DcStatus=0;
                end



                nDataSc=double(obj.FFTLength)-(double(obj.numLgSc)+double(obj.numRgSc)+DcStatus);
                if(obj.pInputVectorSize>=double(nDataSc))&&(obj.pInputVectorSize~=1)
                    coder.internal.error('whdl:GenOFDMModulator:minDataSubcarriers');
                end

            end

            validateBoolean(obj,varargin{:});
        end


        function validateBoolean(obj,varargin)
            validDimension={'scalar'};
            if isempty(coder.target)||~eml_ambiguous_types
                validateattributes(varargin{2},{'logical'},validDimension,'OFDMModulator','valid');
                if obj.Windowing
                    if obj.ResetInputPort
                        if strcmpi(obj.OFDMParametersSource,'Input Port')
                            validateattributes(varargin{8},{'logical'},validDimension,'OFDMModulator','reset');
                        else
                            validateattributes(varargin{3},{'logical'},validDimension,'OFDMModulator','reset');
                        end
                    end
                else
                    if obj.ResetInputPort
                        if strcmpi(obj.OFDMParametersSource,'Input Port')
                            validateattributes(varargin{7},{'logical'},validDimension,'OFDMModulator','reset');
                        else
                            validateattributes(varargin{3},{'logical'},validDimension,'OFDMModulator','reset');
                        end
                    end
                end
            end
        end
    end

    methods(Static,Access=protected)

        function header=getHeaderImpl
            text='Apply OFDM modulation to the input signal.';

            header=matlab.system.display.Header(...
            'Title','OFDM Modulator',...
            'Text',text,...
            'ShowSourceLink',false);
        end


        function groups=getPropertyGroupsImpl

            ofdmParameters=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'OFDMParametersSource','FFTLength','MaxFFTLength','CPLength','numLgSc','numRgSc',...
            'InsertDCNull','Windowing','WindowLength','MaxWindowLength','ResetInputPort'});

            IFFTParam=matlab.system.display.Section(...
            'Title','IFFT Parameters',...
            'PropertyList',{'Normalize','RoundingMethod'});

            mainGroup=matlab.system.display.SectionGroup(mfilename('class'),...
            'Title','Main','Sections',[ofdmParameters,IFFTParam]);

            groups=mainGroup;
        end


        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end
    end

    methods(Access=public)
        function latency=getLatency(obj,varargin)


            fftLen=double(obj.FFTLength);
            numLeftGuardSc=double(obj.numLgSc);
            numRightGuardSc=double(obj.numRgSc);
            if obj.InsertDCNull
                insDCNull=1;
            else
                insDCNull=0;
            end
            if isempty(varargin)
                ipVecSize=obj.pInputVectorSize;
            else
                ipVecSize=varargin{1};
            end

            symbFormLatency=ceil((fftLen-(numLeftGuardSc+numRightGuardSc+insDCNull))/ipVecSize);

            ifftObjLatency=dsp.HDLIFFT('BitReversedOutput',false);

            IFFTLatency=ifftObjLatency.getLatency(obj.FFTLength,ipVecSize);


            cpAdditionLatency=ceil(fftLen/ipVecSize);


            pipeLineDelay=22;

            if obj.Windowing
                pipeLineDelay=pipeLineDelay+10;
            end


            latency=symbFormLatency+IFFTLatency+cpAdditionLatency+pipeLineDelay;
        end
    end

    methods(Access=protected)

        function icon=getIconImpl(obj)
            icon=sprintf('OFDM Modulator');
            if isempty(obj.pInputVectorSize)&&~(strcmpi(obj.OFDMParametersSource,'Input Port'))
                icon=sprintf('OFDM Modulator\nLatency = --');
            elseif(strcmpi(obj.OFDMParametersSource,'Input Port'))
                icon=sprintf('OFDM Modulator');
            else
                icon=sprintf('OFDM Modulator\nLatency = %d',obj.getLatency);
            end
        end


        function num=getNumInputsImpl(obj)
            num=2;
            if(strcmpi(obj.OFDMParametersSource,'Input Port'))
                num=num+4;
                if obj.Windowing
                    num=num+1;
                end
            end
            if(obj.ResetInputPort)
                num=num+1;
            end
        end


        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='data';
            varargout{2}='valid';
            if(strcmpi(obj.OFDMParametersSource,'Input Port'))
                varargout{3}='FFTLen';
                varargout{4}='CPLen';
                varargout{5}='numLgSc';
                varargout{6}='numRgSc';
                if obj.Windowing
                    varargout{7}='winLen';
                    if(obj.ResetInputPort)
                        varargout{8}='reset';
                    end
                else
                    if(obj.ResetInputPort)
                        varargout{7}='reset';
                    end
                end
            else
                if(obj.ResetInputPort)
                    varargout{3}='reset';
                end
            end
        end


        function num=getNumOutputsImpl(~)
            num=3;
        end


        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='data';
            varargout{2}='valid';
            varargout{3}='ready';
        end


        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if strcmpi(obj.OFDMParametersSource,'Input Port')
                props=[props,{'FFTLength','CPLength','numLgSc','numRgSc'}];
                if obj.Windowing
                    props=[props,{'WindowLength'}];
                else
                    props=[props,{'WindowLength','MaxWindowLength'}];
                end
            end
            if strcmpi(obj.OFDMParametersSource,'Property')
                props=[props,{'MaxFFTLength'}];
                if obj.Windowing
                    props=[props,{'MaxWindowLength'}];
                else
                    props=[props,{'WindowLength','MaxWindowLength'}];
                end
            end
            flag=ismember(prop,props);
        end


        function varargout=getOutputDataTypeImpl(obj,varargin)
            inputDT=propagatedInputDataType(obj,1);
            if~isempty(inputDT)
                outputDT=getOutputDT(obj,inputDT);
                varargout{1}=outputDT;
                varargout{2}=numerictype('boolean');
                varargout{3}=numerictype('boolean');
            else
                for ii=1:getNumOutputs(obj)
                    varargout{ii}=[];
                end
            end
        end


        function varargout=isOutputComplexImpl(~)
            varargout{1}=true;
            varargout{2}=false;
            varargout{3}=false;
        end


        function varargout=getOutputSizeImpl(obj)
            varargout{1}=propagatedInputSize(obj,1);
            varargout{2}=1;
            varargout{3}=1;
        end


        function varargout=isOutputFixedSizeImpl(~)
            varargout{1}=true;
            varargout{2}=true;
            varargout{3}=true;
        end


        function flag=getExecutionSemanticsImpl(obj)

            if obj.ResetInputPort
                flag={'Classic','SynchronousWithResetPort'};
            else
                flag={'Classic','Synchronous'};
            end
        end


        function varargout=isInputDirectFeedthroughImpl(obj,varargin)
            varargout{1}=true;
            varargout{2}=true;

            if(strcmpi(obj.OFDMParametersSource,'Input Port'))
                varargout{3}=true;
                varargout{4}=true;
                varargout{5}=true;
                varargout{6}=true;
                if obj.Windowing
                    varargout{7}=true;
                    if obj.ResetInputPort
                        varargout{8}=true;
                    end
                else
                    if obj.ResetInputPort
                        varargout{7}=true;
                    end
                end
            else
                if obj.ResetInputPort
                    varargout{3}=true;
                end
            end
        end


        function setupImpl(obj,varargin)
            A=varargin{1};
            if obj.Normalize
                BitGrowth=0;
            else
                if strcmpi(obj.OFDMParametersSource,'Property')
                    BitGrowth=log2(double(obj.FFTLength));
                else
                    BitGrowth=log2(double(obj.MaxFFTLength));
                end
            end
            obj.vecLen=length(varargin{1});
            VL=log2(obj.vecLen)+1;
            obj.vecLenFi=fi(obj.vecLen,0,VL,0,hdlfimath);
            obj.dataIn=cast(zeros(obj.vecLen,1),'like',varargin{1});
            obj.validIn=false;

            if~isfloat(A)
                if isa(A,'embedded.fi')
                    if issigned(A)
                        obj.dataOut=complex(fi(zeros(obj.vecLen,1),1,A.WordLength+BitGrowth,A.FractionLength));
                    end
                elseif BitGrowth==0
                    obj.dataOut=complex(cast(zeros(obj.vecLen,1),'like',real(A)));
                elseif isa(A,'int8')
                    obj.dataOut=complex(fi(zeros(obj.vecLen,1),1,8+BitGrowth,0));
                elseif isa(A,'int16')
                    obj.dataOut=complex(fi(zeros(obj.vecLen,1),1,16+BitGrowth,0));
                elseif isa(A,'int32')
                    obj.dataOut=complex(fi(zeros(obj.vecLen,1),1,32+BitGrowth,0));
                elseif isa(A,'int64')
                    obj.dataOut=complex(fi(zeros(obj.vecLen,1),1,64+BitGrowth,0));
                end
            else
                obj.dataOut=complex(cast(zeros(obj.vecLen,1),'like',A));
            end
            obj.validOut=false;
            obj.readyOut=true;
            obj.resetSignal=false;


            if strcmpi(obj.OFDMParametersSource,'Property')

                obj.IFFTObj=dsp.HDLIFFT('FFTLength',obj.FFTLength,'Normalize',obj.Normalize,...
                'RoundingMethod',obj.RoundingMethod,'BitReversedOutput',false,'ResetInputPort',obj.ResetInputPort);
                obj.HDLFFTShiftModObj=commhdl.internal.HDLFFTShiftMod('OFDMParametersSource',obj.OFDMParametersSource,'FFTLength',obj.FFTLength,...
                'CPLength',obj.CPLength,'ResetInputPort',obj.ResetInputPort);
                if obj.Windowing
                    obj.symbolFormationObj=commhdl.internal.symbolFormation('OFDMParametersSource',obj.OFDMParametersSource,'FFTLength',obj.FFTLength,...
                    'CPLength',obj.CPLength,'numLgSc',obj.numLgSc,'numRgSc',obj.numRgSc,'InsertDCNull',obj.InsertDCNull,'Windowing',obj.Windowing,'WinLength',obj.WindowLength,'ResetInputPort',obj.ResetInputPort);
                    obj.CPAdditionObj=commhdl.internal.CPAddition('OFDMParametersSource',obj.OFDMParametersSource,'FFTLength',obj.FFTLength,...
                    'CPLength',obj.CPLength,'Windowing',obj.Windowing,'WinLength',obj.WindowLength,'ResetInputPort',obj.ResetInputPort);
                    obj.WindowingObj=commhdl.internal.WindowingSysObj('OFDMParametersSource',obj.OFDMParametersSource,'FFTLength',obj.FFTLength,...
                    'CPLength',obj.CPLength,'WinLength',obj.WindowLength,'ResetInputPort',obj.ResetInputPort);
                else
                    obj.symbolFormationObj=commhdl.internal.symbolFormation('OFDMParametersSource',obj.OFDMParametersSource,'FFTLength',obj.FFTLength,...
                    'CPLength',obj.CPLength,'numLgSc',obj.numLgSc,'numRgSc',obj.numRgSc,'InsertDCNull',obj.InsertDCNull,'ResetInputPort',obj.ResetInputPort);
                    obj.CPAdditionObj=commhdl.internal.CPAddition('OFDMParametersSource',obj.OFDMParametersSource,'FFTLength',obj.FFTLength,...
                    'CPLength',obj.CPLength,'ResetInputPort',obj.ResetInputPort);
                end
            else
                if obj.Windowing
                    obj.symbolFormationObj=commhdl.internal.symbolFormation('OFDMParametersSource',obj.OFDMParametersSource,'MaxFFTLength',obj.MaxFFTLength,'InsertDCNull',obj.InsertDCNull,...
                    'ResetInputPort',obj.ResetInputPort,'Windowing',obj.Windowing,'MaxWinLength',obj.MaxWindowLength);
                    obj.samplesRepetitionObj=commhdl.internal.samplesRepetitionMod('MaxFFTLength',obj.MaxFFTLength,...
                    'ResetInputPort',obj.ResetInputPort,'Windowing',obj.Windowing,'MaxWinLength',obj.MaxWindowLength);
                    obj.IFFTObj=dsp.HDLIFFT('FFTLength',obj.MaxFFTLength,'Normalize',obj.Normalize,...
                    'RoundingMethod',obj.RoundingMethod,'StartOutputPort',true,'BitReversedOutput',false,'ResetInputPort',obj.ResetInputPort);
                    obj.HDLFFTShiftModObj=commhdl.internal.HDLFFTShiftMod('OFDMParametersSource',obj.OFDMParametersSource,'MaxFFTLength',obj.MaxFFTLength,...
                    'ResetInputPort',obj.ResetInputPort,'Windowing',obj.Windowing,'maxWinLength',obj.MaxWindowLength);
                    obj.CPAdditionObj=commhdl.internal.CPAddition('OFDMParametersSource',obj.OFDMParametersSource,'MaxFFTLength',...
                    obj.MaxFFTLength,'Windowing',obj.Windowing,'MaxWinLength',obj.MaxWindowLength,'ResetInputPort',obj.ResetInputPort);
                    obj.DownSamplerModObj=commhdl.internal.DownSamplerMod('MaxFFTLength',obj.MaxFFTLength,'Normalize',obj.Normalize,'resetPort',obj.ResetInputPort,...
                    'Windowing',obj.Windowing,'MaxWinLength',obj.MaxWindowLength);
                    obj.WindowingObj=commhdl.internal.WindowingSysObj('OFDMParametersSource',obj.OFDMParametersSource,'MaxFFTLength',...
                    obj.MaxFFTLength,'MaxWinLength',obj.MaxWindowLength,'ResetInputPort',obj.ResetInputPort);
                else
                    obj.symbolFormationObj=commhdl.internal.symbolFormation('OFDMParametersSource',obj.OFDMParametersSource,'MaxFFTLength',obj.MaxFFTLength,'InsertDCNull',obj.InsertDCNull,...
                    'ResetInputPort',obj.ResetInputPort);
                    obj.samplesRepetitionObj=commhdl.internal.samplesRepetitionMod('MaxFFTLength',obj.MaxFFTLength,...
                    'ResetInputPort',obj.ResetInputPort);
                    obj.IFFTObj=dsp.HDLIFFT('FFTLength',obj.MaxFFTLength,'Normalize',obj.Normalize,...
                    'RoundingMethod',obj.RoundingMethod,'StartOutputPort',true,'BitReversedOutput',false,'ResetInputPort',obj.ResetInputPort);
                    obj.HDLFFTShiftModObj=commhdl.internal.HDLFFTShiftMod('OFDMParametersSource',obj.OFDMParametersSource,'MaxFFTLength',obj.MaxFFTLength,'ResetInputPort',obj.ResetInputPort);
                    obj.CPAdditionObj=commhdl.internal.CPAddition('OFDMParametersSource',obj.OFDMParametersSource,'MaxFFTLength',obj.MaxFFTLength,'ResetInputPort',obj.ResetInputPort);
                    obj.DownSamplerModObj=commhdl.internal.DownSamplerMod('MaxFFTLength',obj.MaxFFTLength,'Normalize',obj.Normalize,'resetPort',obj.ResetInputPort);

                end
            end
            if strcmpi(obj.OFDMParametersSource,'Input Port')
                wordLength=log2(obj.MaxFFTLength)+2;
            else
                wordLength=log2(obj.FFTLength)+2;
            end

            obj.vInFFTDelayBal=false;
            obj.fftInFFTDelayBal=fi(64,0,wordLength,0,hdlfimath);
            obj.cpInFFTDelayBal=fi(16,0,wordLength,0,hdlfimath);
            obj.startFFTDelayBal=false;
            latency=obj.IFFTObj.getLatency(obj.MaxFFTLength,obj.vecLen);
            obj.numSymbs=ceil(latency*obj.vecLen/obj.MaxFFTLength);
            obj.countReg=fi(0,0,wordLength,0,hdlfimath);
            obj.FFTReg=fi(64*ones(obj.numSymbs,1),0,wordLength,0,hdlfimath);
            obj.cpReg=fi(16*ones(obj.numSymbs,1),0,wordLength,0,hdlfimath);
            obj.index=fi(0,0,7,0,hdlfimath);
            obj.FFTRegDelay=fi(64,0,wordLength,0,hdlfimath);
            obj.cpRegDelay=fi(16,0,wordLength,0,hdlfimath);
            obj.index1=fi(0,0,7,0,hdlfimath);
            if obj.Windowing
                obj.winInFFTDelayBal=fi(0,0,wordLength,0,hdlfimath);
                obj.winReg=fi(0*ones(obj.numSymbs,1),0,wordLength,0,hdlfimath);
                obj.winRegDelay=fi(0,0,wordLength,0,hdlfimath);
            end


            obj.insertDC=fi(0,0,wordLength+4,0,hdlfimath);
            obj.FFTLengthReg=fi(64,0,wordLength+4,0,hdlfimath);
            obj.CPLengthReg=fi(16,0,wordLength+4,0,hdlfimath);
            obj.numLgScReg=fi(6,0,wordLength+4,0,hdlfimath);
            obj.numRgScReg=fi(5,0,wordLength+4,0,hdlfimath);
            obj.FFTLenOutReady=fi(64,0,wordLength+4,0,hdlfimath);
            obj.CPLenOutReady=fi(16,0,wordLength+4,0,hdlfimath);
            obj.numLgScOutReady=fi(6,0,wordLength+4,0,hdlfimath);
            obj.numRgScOutReady=fi(5,0,wordLength+4,0,hdlfimath);
            obj.guardSum=fi(0,0,wordLength+4,0,hdlfimath);
            obj.DCGuardSum=fi(0,0,wordLength+4,0,hdlfimath);
            obj.maxFFTPlusCP=fi(64,0,wordLength+VL+3,VL-1,hdlfimath);
            obj.resetReg=false;
            obj.numDataSc=fi(0,0,wordLength+VL+3,VL-1,hdlfimath);
            obj.readyHigh=fi(0,0,wordLength+4,0,hdlfimath);
            obj.readyLast=fi(0,0,wordLength+4,0,hdlfimath);
            obj.readyLow=fi(0,0,wordLength+4,0,hdlfimath);
            obj.readyLowMinusVecLen=fi(0,0,wordLength+4,0,hdlfimath);
            obj.validInHighCount=fi(0,0,wordLength+4,0,hdlfimath);
            obj.readyLowCount=fi(0,0,wordLength+4,0,hdlfimath);

            obj.delayedReady=true;
            obj.validInHighFlag=false;
            obj.readyFlag=false;
            obj.readyLowFlag=false;
            obj.dataInReg=cast(zeros(obj.vecLen,1),'like',varargin{1});
            obj.validInReg=false;
            obj.dataOutReady=cast(zeros(obj.vecLen,1),'like',varargin{1});
            obj.validOutReady=false;
            obj.readyState=fi(0,0,2,0,hdlfimath);
            obj.triggerReady=false;
            obj.sampleInputs=true;
            obj.vecLenReg=fi(obj.vecLen,0,VL,0,hdlfimath);
            obj.validInAndvalidInHighFlag=false;
            obj.validInHighAndReadyLowFlag=false;
            obj.validHighFlagLowAndReadyLowFlagLow=false;
            obj.validHighFlagHighAndReadyLowFlagLow=false;
            obj.validHighFlagHighAndReadyLowFlagLowHigh=false;
            obj.sampling=false;
            if obj.Windowing
                obj.winLenOut=fi(0,0,wordLength,0,hdlfimath);
                obj.winLenOutReg=fi(0,0,wordLength,0,hdlfimath);
                obj.winLenZeroFlag=false;
            end
        end


        function resetImpl(obj)
            obj.dataIn(:)=0;
            obj.validIn=false;
            obj.dataOut(:)=0;
            obj.validOut=false;
            obj.readyOut=true;
            obj.resetSignal=false;



            obj.vInFFTDelayBal=false;
            obj.fftInFFTDelayBal(:)=64;
            obj.cpInFFTDelayBal(:)=16;
            obj.startFFTDelayBal=false;
            obj.countReg(:)=0;
            obj.FFTReg(:)=64;
            obj.cpReg(:)=16;
            obj.index(:)=0;
            obj.FFTRegDelay(:)=64;
            obj.cpRegDelay(:)=16;
            obj.index1(:)=0;
            if obj.Windowing
                obj.winInFFTDelayBal(:)=0;
                obj.winReg(:)=0;
                obj.winRegDelay(:)=0;
            end

            obj.insertDC(:)=0;
            obj.FFTLengthReg(:)=64;
            obj.CPLengthReg(:)=16;
            obj.numLgScReg(:)=6;
            obj.numRgScReg(:)=5;
            obj.FFTLenOutReady(:)=64;
            obj.CPLenOutReady(:)=16;
            obj.numLgScOutReady(:)=6;
            obj.numRgScOutReady(:)=5;
            obj.guardSum(:)=0;
            obj.DCGuardSum(:)=0;
            obj.maxFFTPlusCP(:)=64;
            obj.resetReg=false;
            obj.numDataSc(:)=0;
            obj.readyHigh(:)=0;
            obj.readyLast(:)=0;
            obj.readyLow(:)=0;
            obj.readyLowMinusVecLen(:)=0;
            obj.delayedReady=true;
            obj.validInHighFlag=false;
            obj.readyFlag=false;
            obj.readyLowFlag=false;

            obj.dataInReg(:)=0;
            obj.validInReg=false;
            obj.dataOutReady(:)=0;
            obj.validOutReady=false;
            obj.readyState(:)=0;
            obj.triggerReady=false;
            obj.validInHighCount(:)=0;
            obj.readyLowCount(:)=0;
            obj.sampleInputs=true;
            obj.sampling=false;
            if~obj.ResetInputPort
                reset(obj.symbolFormationObj);
                reset(obj.IFFTObj);
                reset(obj.HDLFFTShiftModObj);
                reset(obj.CPAdditionObj);
                if strcmpi(obj.OFDMParametersSource,'Input Port')
                    reset(obj.samplesRepetitionObj);
                    reset(obj.DownSamplerModObj);
                end
                if obj.Windowing
                    reset(obj.WindowingObj);
                end
            end
            obj.validInAndvalidInHighFlag=false;
            obj.validInHighAndReadyLowFlag=false;
            obj.validHighFlagLowAndReadyLowFlagLow=false;
            obj.validHighFlagHighAndReadyLowFlagLow=false;
            obj.validHighFlagHighAndReadyLowFlagLowHigh=false;
            if obj.Windowing
                obj.winLenOut(:)=0;
                obj.winLenOutReg(:)=0;
                obj.winLenZeroFlag=false;
            end
        end


        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.dataOut;
            varargout{2}=obj.validOut;
            if obj.readyFlag&&varargin{2}
                varargout{3}=false;
                obj.readyFlag=false;
            elseif obj.triggerReady
                varargout{3}=true;
                obj.triggerReady=false;
            else
                varargout{3}=obj.readyOut;
            end
        end


        function updateImpl(obj,varargin)
            obj.dataIn(:)=varargin{1};
            obj.validIn=varargin{2};
            if strcmpi(obj.OFDMParametersSource,'Property')
                if obj.ResetInputPort
                    obj.resetSignal=varargin{3};
                    obj.readyGeneration(obj.dataIn,obj.validIn,obj.resetSignal);
                    [dataOut2,validOut2]=obj.symbolFormationObj(obj.dataOutReady,obj.validOutReady,obj.resetSignal);
                    [dataOut3,validOut3]=obj.IFFTObj(dataOut2,validOut2,obj.resetSignal);
                    [dataOut4,validOut4]=obj.HDLFFTShiftModObj(dataOut3,validOut3,obj.resetSignal);
                    [dataOut5,validOut5]=obj.CPAdditionObj(dataOut4,validOut4,obj.resetSignal);
                    if obj.Windowing
                        [dataOut6,validOut6]=obj.WindowingObj(dataOut5,validOut5,obj.resetSignal);
                        obj.dataOut(:)=dataOut6;
                        obj.validOut=validOut6;
                    else
                        obj.dataOut(:)=dataOut5;
                        obj.validOut=validOut5;
                    end
                    ifResetTrue(obj);
                else
                    obj.readyGeneration(obj.dataIn,obj.validIn);
                    [dataOut2,validOut2]=obj.symbolFormationObj(obj.dataOutReady,obj.validOutReady);
                    [dataOut3,validOut3]=obj.IFFTObj(dataOut2,validOut2);
                    [dataOut4,validOut4]=obj.HDLFFTShiftModObj(dataOut3,validOut3);
                    [dataOut5,validOut5]=obj.CPAdditionObj(dataOut4,validOut4);
                    if obj.Windowing
                        [dataOut6,validOut6]=obj.WindowingObj(dataOut5,validOut5);
                        obj.dataOut(:)=dataOut6;
                        obj.validOut=validOut6;
                    else
                        obj.dataOut(:)=dataOut5;
                        obj.validOut=validOut5;
                    end
                end
            else
                FFTLenSig=varargin{3};
                CPLenSig=varargin{4};
                numLgScSig=varargin{5};
                numRgScSig=varargin{6};

                if obj.validIn
                    if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                        if double(varargin{3})<0
                            coder.internal.error('whdl:GenOFDMModulator:FFTNotPowOfTwo');
                        elseif mod(log2(double(varargin{3})),2)~=floor(mod(log2(double(varargin{3})),2))
                            coder.internal.error('whdl:GenOFDMModulator:FFTNotPowOfTwo');
                        elseif double(varargin{3})>double(obj.MaxFFTLength)
                            coder.internal.error('whdl:GenOFDMModulator:FFTGrtMaxFFT');
                        else
                            validateattributes(double(varargin{3}),{'double'},{'integer','scalar','>=',2^3,'<=',2^16},'OFDMModulator','FFTLength');
                        end
                        if(double(varargin{4})>double(varargin{3}))
                            coder.internal.error('whdl:GenOFDMModulator:CPGrtFFTErr');
                        end
                        validateattributes(double(varargin{4}),{'double'},{'integer','scalar','>=',0},'OFDMModulator','CPLength');
                        if(double(varargin{5})>=double(varargin{3}/2))
                            coder.internal.error('whdl:GenOFDMModulator:numLgScGrtFFTBy2');
                        end
                        validateattributes(double(varargin{5}),{'double'},{'integer','scalar','>=',0},'OFDMModulator','LeftGuardSubcarriers');
                        if(double(varargin{6})>=double(varargin{3}/2))
                            coder.internal.error('whdl:GenOFDMModulator:numRgScGrtFFTBy2');
                        end
                        validateattributes(double(varargin{6}),{'double'},{'integer','scalar','>=',0},'OFDMModulator','RightGuardSubcarriers');

                        if obj.vecLen>FFTLenSig
                            coder.internal.error('whdl:GenOFDMModulator:FFTLessInputVectSize');
                        end
                        grdSum=double(numLgScSig)+double(numRgScSig);
                        if obj.InsertDCNull
                            grdDCSum=grdSum+1;
                        else
                            grdDCSum=grdSum;
                        end
                        numDataScCal=double(FFTLenSig)-grdDCSum;
                        if(obj.vecLen>=double(numDataScCal))&&(obj.vecLen~=1)
                            coder.internal.error('whdl:GenOFDMModulator:minDataSubcarriers');
                        end

                        if obj.Windowing
                            if(double(varargin{7}))>double(obj.MaxWindowLength)
                                coder.internal.error('whdl:GenOFDMModulator:WindowGrtMaxWindowErr');
                            elseif(double(varargin{7})>double(varargin{4}))
                                coder.internal.error('whdl:GenOFDMModulator:WindowGrtCPErr');
                            end
                            validateattributes(double(varargin{7}),{'double'},{'integer','scalar','>=',0},'OFDMModulator','WindowLength');
                        end

                    end
                end

                if obj.ResetInputPort
                    if obj.Windowing
                        winLenSig=varargin{7};
                        obj.resetSignal=varargin{8};
                        obj.readyGeneration(obj.dataIn,obj.validIn,FFTLenSig,CPLenSig,numLgScSig,numRgScSig,winLenSig,obj.resetSignal);
                        [dataOut2,validOut2,FFTLenOut2,CPLenOut2,~,~,winLenOut2]=obj.symbolFormationObj(obj.dataOutReady,obj.validOutReady,...
                        obj.FFTLenOutReady,obj.CPLenOutReady,obj.numLgScOutReady,obj.numRgScOutReady,obj.winLenOut,obj.resetSignal);
                        [dataOut3,validOut3,FFTLenOut3,CPLenOut3,winLenOut3]=obj.samplesRepetitionObj(dataOut2,validOut2,...
                        FFTLenOut2,CPLenOut2,winLenOut2,obj.resetSignal);
                        [dataOut4,startSig,validOut4]=obj.IFFTObj(dataOut3,validOut3,obj.resetSignal);
                        [FFTLenOut4,CPLenOut4,winLenOut4]=obj.IFFTDelayBalance(validOut3,FFTLenOut3,CPLenOut3,startSig,winLenOut3);
                        [dataOut5,validOut5,FFTLenOut5,CPLenOut5,winLenOut5]=obj.DownSamplerModObj(dataOut4,validOut4,...
                        FFTLenOut4,CPLenOut4,winLenOut4,obj.resetSignal);
                        [dataOut6,validOut6,FFTLenOut6,CPLenOut6,winLenOut6]=obj.HDLFFTShiftModObj(dataOut5,validOut5,...
                        FFTLenOut5,CPLenOut5,winLenOut5,obj.resetSignal);
                        [dataOut7,validOut7,FFTLenOut7,CPLenOut7,winLenOut7]=obj.CPAdditionObj(dataOut6,validOut6,...
                        FFTLenOut6,CPLenOut6,winLenOut6,obj.resetSignal);
                        [dataOut8,validOut8]=obj.WindowingObj(dataOut7,validOut7,FFTLenOut7,CPLenOut7,winLenOut7,obj.resetSignal);

                        obj.dataOut(:)=dataOut8;
                        obj.validOut=validOut8;
                        ifResetTrue(obj);
                    else
                        obj.resetSignal=varargin{7};
                        obj.readyGeneration(obj.dataIn,obj.validIn,FFTLenSig,CPLenSig,numLgScSig,numRgScSig,obj.resetSignal);
                        [dataOut2,validOut2,FFTLenOut2,CPLenOut2]=obj.symbolFormationObj(obj.dataOutReady,obj.validOutReady,...
                        obj.FFTLenOutReady,obj.CPLenOutReady,obj.numLgScOutReady,obj.numRgScOutReady,obj.resetSignal);
                        [dataOut3,validOut3,FFTLenOut3,CPLenOut3]=obj.samplesRepetitionObj(dataOut2,validOut2,...
                        FFTLenOut2,CPLenOut2,obj.resetSignal);
                        [dataOut4,startSig,validOut4]=obj.IFFTObj(dataOut3,validOut3,obj.resetSignal);
                        [FFTLenOut4,CPLenOut4]=obj.IFFTDelayBalance(validOut3,FFTLenOut3,CPLenOut3,startSig);
                        [dataOut5,validOut5,FFTLenOut5,CPLenOut5]=obj.DownSamplerModObj(dataOut4,validOut4,...
                        FFTLenOut4,CPLenOut4,obj.resetSignal);
                        [dataOut6,validOut6,FFTLenOut6,CPLenOut6]=obj.HDLFFTShiftModObj(dataOut5,validOut5,...
                        FFTLenOut5,CPLenOut5,obj.resetSignal);
                        [dataOut7,validOut7]=obj.CPAdditionObj(dataOut6,validOut6,...
                        FFTLenOut6,CPLenOut6,obj.resetSignal);
                        obj.dataOut(:)=dataOut7;
                        obj.validOut=validOut7;
                        ifResetTrue(obj);
                    end
                else
                    if obj.Windowing
                        winLenSig=varargin{7};
                        obj.readyGeneration(obj.dataIn,obj.validIn,FFTLenSig,CPLenSig,numLgScSig,numRgScSig,winLenSig);
                        [dataOut2,validOut2,FFTLenOut2,CPLenOut2,~,~,winLenOut2]=obj.symbolFormationObj(obj.dataOutReady,obj.validOutReady,...
                        obj.FFTLenOutReady,obj.CPLenOutReady,obj.numLgScOutReady,obj.numRgScOutReady,obj.winLenOut);
                        [dataOut3,validOut3,FFTLenOut3,CPLenOut3,winLenOut3]=obj.samplesRepetitionObj(dataOut2,validOut2,...
                        FFTLenOut2,CPLenOut2,winLenOut2);
                        [dataOut4,startSig,validOut4]=obj.IFFTObj(dataOut3,validOut3);
                        [FFTLenOut4,CPLenOut4,winLenOut4]=obj.IFFTDelayBalance(validOut3,FFTLenOut3,CPLenOut3,startSig,winLenOut3);
                        [dataOut5,validOut5,FFTLenOut5,CPLenOut5,winLenOut5]=obj.DownSamplerModObj(dataOut4,validOut4,...
                        FFTLenOut4,CPLenOut4,winLenOut4);
                        [dataOut6,validOut6,FFTLenOut6,CPLenOut6,winLenOut6]=obj.HDLFFTShiftModObj(dataOut5,validOut5,...
                        FFTLenOut5,CPLenOut5,winLenOut5);
                        [dataOut7,validOut7,FFTLenOut7,CPLenOut7,winLenOut7]=obj.CPAdditionObj(dataOut6,validOut6,...
                        FFTLenOut6,CPLenOut6,winLenOut6);
                        [dataOut8,validOut8]=obj.WindowingObj(dataOut7,validOut7,...
                        FFTLenOut7,CPLenOut7,winLenOut7);
                        obj.dataOut(:)=dataOut8;
                        obj.validOut=validOut8;
                    else
                        obj.readyGeneration(obj.dataIn,obj.validIn,FFTLenSig,CPLenSig,numLgScSig,numRgScSig);
                        [dataOut2,validOut2,FFTLenOut2,CPLenOut2]=obj.symbolFormationObj(obj.dataOutReady,obj.validOutReady,...
                        obj.FFTLenOutReady,obj.CPLenOutReady,obj.numLgScOutReady,obj.numRgScOutReady);
                        [dataOut3,validOut3,FFTLenOut3,CPLenOut3]=obj.samplesRepetitionObj(dataOut2,validOut2,...
                        FFTLenOut2,CPLenOut2);
                        [dataOut4,startSig,validOut4]=obj.IFFTObj(dataOut3,validOut3);
                        [FFTLenOut4,CPLenOut4]=obj.IFFTDelayBalance(validOut3,FFTLenOut3,CPLenOut3,startSig);
                        [dataOut5,validOut5,FFTLenOut5,CPLenOut5]=obj.DownSamplerModObj(dataOut4,validOut4,...
                        FFTLenOut4,CPLenOut4);
                        [dataOut6,validOut6,FFTLenOut6,CPLenOut6]=obj.HDLFFTShiftModObj(dataOut5,validOut5,...
                        FFTLenOut5,CPLenOut5);
                        [dataOut7,validOut7]=obj.CPAdditionObj(dataOut6,validOut6,...
                        FFTLenOut6,CPLenOut6);
                        obj.dataOut(:)=dataOut7;
                        obj.validOut=validOut7;
                    end
                end
            end

        end


        function ifResetTrue(obj)
            if obj.resetSignal
                resetImpl(obj);
            end
        end


        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end


        function readyGeneration(obj,varargin)
            obj.dataInReg(:)=varargin{1};
            obj.validInReg(:)=obj.delayedReady&&varargin{2};
            obj.insertDC(:)=obj.InsertDCNull;
            obj.sampling=obj.validInReg&&obj.sampleInputs;

            if strcmpi(obj.OFDMParametersSource,'Input Port')
                if obj.sampling
                    obj.FFTLengthReg(:)=varargin{3};
                    obj.CPLengthReg(:)=varargin{4};
                    obj.numLgScReg(:)=varargin{5};
                    obj.numRgScReg(:)=varargin{6};
                    if obj.Windowing
                        obj.winLenOutReg(:)=varargin{7};
                        if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                            if double(varargin{7})==0&&~obj.winLenZeroFlag
                                coder.internal.warning('whdl:GenOFDMModulator:WindowlengthZero');
                                obj.winLenZeroFlag=true;
                            elseif double(varargin{7})==0&&obj.winLenZeroFlag
                                obj.winLenZeroFlag=true;
                            else
                                obj.winLenZeroFlag=false;
                            end
                        end
                    end
                end
                obj.maxFFTPlusCP(:)=obj.MaxFFTLength+obj.CPLengthReg;
            else
                obj.FFTLengthReg(:)=obj.FFTLength;
                obj.CPLengthReg(:)=obj.CPLength;
                obj.numLgScReg(:)=obj.numLgSc;
                obj.numRgScReg(:)=obj.numRgSc;
                obj.maxFFTPlusCP(:)=obj.FFTLengthReg+obj.CPLengthReg;
            end


            obj.guardSum(:)=obj.numLgScReg+obj.numRgScReg;
            obj.DCGuardSum(:)=obj.insertDC+obj.guardSum;
            obj.numDataSc(:)=obj.FFTLengthReg-obj.DCGuardSum;


            obj.readyHigh(:)=ceil(obj.numDataSc/obj.vecLenFi);
            if obj.readyHigh==1
                obj.readyLast(:)=1;
            else
                obj.readyLast(:)=obj.readyHigh-1;
            end

            obj.readyLow(:)=ceil(obj.maxFFTPlusCP/obj.vecLenFi)-obj.readyHigh;
            if obj.readyLow==0
                obj.readyLowMinusVecLen(:)=0;
            else
                obj.readyLowMinusVecLen(:)=obj.readyLow-1;
            end

            obj.validInAndvalidInHighFlag=obj.validInReg&&~obj.validInHighFlag;
            obj.validInHighAndReadyLowFlag=obj.validInHighFlag&&~obj.readyLowFlag;

            if obj.validInAndvalidInHighFlag
                obj.validInHighCount(:)=obj.validInHighCount+1;
            end

            if obj.validInHighAndReadyLowFlag
                obj.readyLowCount(:)=obj.readyLowCount+1;
            end


            if obj.validInHighCount==obj.readyHigh
                obj.validInHighFlag=true;
            end

            if obj.validInHighCount==obj.readyLast
                if obj.readyLow~=0
                    obj.readyFlag=true;
                else
                    obj.readyFlag=false;
                end
            end

            if obj.readyLowCount==obj.readyLow-1
                obj.triggerReady=true;
            end

            if obj.readyLowCount==obj.readyLow
                obj.readyLowFlag=true;
            end

            obj.validHighFlagLowAndReadyLowFlagLow=~obj.validInHighFlag&&~obj.readyLowFlag;
            obj.validHighFlagHighAndReadyLowFlagLow=obj.validInHighFlag&&~obj.readyLowFlag;
            obj.validHighFlagHighAndReadyLowFlagLowHigh=obj.validInHighFlag&&obj.readyLowFlag;

            if obj.validHighFlagLowAndReadyLowFlagLow
                obj.readyOut=true;
            elseif obj.validHighFlagHighAndReadyLowFlagLow
                obj.readyOut=false;
            elseif obj.validHighFlagHighAndReadyLowFlagLowHigh
                obj.validInHighCount(:)=0;
                obj.readyLowCount(:)=0;
                obj.validInHighFlag=false;
                obj.readyLowFlag=false;
                obj.readyOut=true;
            else
                obj.readyOut=true;
            end
            if(obj.validInHighCount==0)
                if(obj.readyLowCount==0)
                    obj.sampleInputs=true;
                end
            end

            obj.delayedReady=obj.readyOut;

            obj.dataOutReady(:)=obj.dataInReg;
            obj.validOutReady=obj.validInReg;
            if strcmpi(obj.OFDMParametersSource,'Input Port')
                obj.FFTLenOutReady(:)=obj.FFTLengthReg;
                obj.CPLenOutReady(:)=obj.CPLengthReg;
                obj.numLgScOutReady(:)=obj.numLgScReg;
                obj.numRgScOutReady(:)=obj.numRgScReg;
                if obj.Windowing
                    obj.winLenOut(:)=obj.winLenOutReg;
                end
            end
        end


        function[fftOut,cpOut,winOut]=IFFTDelayBalance(obj,vIn,fftIn,cpIn,startSigIn,winIn)
            obj.vInFFTDelayBal=vIn;
            obj.fftInFFTDelayBal(:)=fftIn;
            obj.cpInFFTDelayBal(:)=cpIn;
            obj.startFFTDelayBal=startSigIn;
            if obj.Windowing
                obj.winInFFTDelayBal(:)=winIn;
            end

            if obj.vInFFTDelayBal
                if(obj.countReg==0)
                    obj.FFTReg(obj.index+1)=obj.fftInFFTDelayBal;
                    obj.cpReg(obj.index+1)=obj.cpInFFTDelayBal;
                    if obj.Windowing
                        obj.winReg(obj.index+1)=obj.winInFFTDelayBal;
                    end
                    if obj.index==(obj.numSymbs-1)
                        obj.index(:)=0;
                    else
                        obj.index(:)=obj.index+1;
                    end
                end

                if obj.countReg==obj.MaxFFTLength-obj.vecLen
                    obj.countReg(:)=0;
                else
                    obj.countReg(:)=obj.countReg+obj.vecLen;
                end
            end
            if obj.startFFTDelayBal
                fftOut=obj.FFTReg(obj.index1+1);
                cpOut=obj.cpReg(obj.index1+1);
                obj.FFTRegDelay(:)=obj.FFTReg(obj.index1+1);
                obj.cpRegDelay(:)=obj.cpReg(obj.index1+1);
                if obj.Windowing
                    winOut=obj.winReg(obj.index1+1);
                    obj.winRegDelay(:)=obj.winReg(obj.index1+1);
                end
                if obj.index1==obj.numSymbs-1
                    obj.index1(:)=0;
                else
                    obj.index1(:)=obj.index1+1;
                end
            else
                fftOut=obj.FFTRegDelay;
                cpOut=obj.cpRegDelay;
                if obj.Windowing
                    winOut=obj.winRegDelay;
                end
            end
        end


        function outputDT=getOutputDT(obj,inputDT)
            if obj.Normalize
                BitGrowth=0;
            else
                if strcmpi(obj.OFDMParametersSource,'Property')
                    BitGrowth=log2(double(obj.FFTLength));
                else
                    BitGrowth=log2(double(obj.MaxFFTLength));
                end
            end
            if isnumerictype(inputDT)||isfi(inputDT)
                if inputDT.Signed
                    outputDT=numerictype(1,inputDT.WordLength+BitGrowth,inputDT.FractionLength);
                else
                    outputDT=numerictype(1,inputDT.WordLength+BitGrowth+1,inputDT.FractionLength);
                end
            elseif strcmpi(inputDT,'uint8')
                outputDT=numerictype(1,9+BitGrowth,0);
            elseif strcmpi(inputDT,'uint16')
                outputDT=numerictype(1,17+BitGrowth,0);
            elseif strcmpi(inputDT,'uint32')
                outputDT=numerictype(1,33+BitGrowth,0);
            elseif strcmpi(inputDT,'uint64')
                outputDT=numerictype(1,65+BitGrowth,0);
            elseif BitGrowth==0
                if strcmpi(inputDT,'logical')
                    outputDT='double';
                else
                    outputDT=inputDT;
                end
            elseif strcmpi(inputDT,'int8')
                outputDT=numerictype(1,8+BitGrowth,0);
            elseif strcmpi(inputDT,'int16')
                outputDT=numerictype(1,16+BitGrowth,0);
            elseif strcmpi(inputDT,'int32')
                outputDT=numerictype(1,32+BitGrowth,0);
            elseif strcmpi(inputDT,'int64')
                outputDT=numerictype(1,64+BitGrowth,0);
            elseif strcmpi(inputDT,'logical')
                outputDT='double';
            else
                outputDT=inputDT;
            end
        end


        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.dataIn=obj.dataIn;
                s.validIn=obj.validIn;
                s.dataOut=obj.dataOut;
                s.validOut=obj.validOut;
                s.readyOut=obj.readyOut;
                s.resetSignal=obj.resetSignal;
                s.symbolFormationObj=obj.symbolFormationObj;
                s.samplesRepetitionObj=obj.samplesRepetitionObj;
                s.IFFTObj=obj.IFFTObj;
                s.HDLFFTShiftModObj=obj.HDLFFTShiftModObj;
                s.CPAdditionObj=obj.CPAdditionObj;
                s.DownSamplerModObj=obj.DownSamplerModObj;
                s.WindowingObj=obj.WindowingObj;
                s.dataInReg=obj.dataInReg;
                s.validInReg=obj.validInReg;
                s.dataOutReady=obj.dataOutReady;
                s.validOutReady=obj.validOutReady;
                s.insertDC=obj.insertDC;
                s.FFTLengthReg=obj.FFTLengthReg;
                s.CPLengthReg=obj.CPLengthReg;
                s.numLgScReg=obj.numLgScReg;
                s.numRgScReg=obj.numRgScReg;
                s.FFTLenOutReady=obj.FFTLenOutReady;
                s.CPLenOutReady=obj.CPLenOutReady;
                s.numLgScOutReady=obj.numLgScOutReady;
                s.numRgScOutReady=obj.numRgScOutReady;
                s.guardSum=obj.guardSum;
                s.DCGuardSum=obj.DCGuardSum;
                s.maxFFTPlusCP=obj.maxFFTPlusCP;
                s.resetReg=obj.resetReg;
                s.numDataSc=obj.numDataSc;
                s.readyHigh=obj.readyHigh;
                s.readyLow=obj.readyLow;
                s.readyLast=obj.readyLast;
                s.validInHighCount=obj.validInHighCount;
                s.readyLowCount=obj.readyLowCount;
                s.readyLowMinusVecLen=obj.readyLowMinusVecLen;
                s.readyFlag=obj.readyFlag;
                s.validInHighFlag=obj.validInHighFlag;
                s.readyLowFlag=obj.readyLowFlag;
                s.readyState=obj.readyState;
                s.triggerReady=obj.triggerReady;
                s.delayedReady=obj.delayedReady;
                s.sampleInputs=obj.sampleInputs;
                s.sampling=obj.sampling;
                s.validInAndvalidInHighFlag=obj.validInAndvalidInHighFlag;
                s.validInHighAndReadyLowFlag=obj.validInHighAndReadyLowFlag;
                s.validHighFlagLowAndReadyLowFlagLow=obj.validHighFlagLowAndReadyLowFlagLow;
                s.validHighFlagHighAndReadyLowFlagLow=obj.validHighFlagHighAndReadyLowFlagLow;
                s.validHighFlagHighAndReadyLowFlagLowHigh=obj.validHighFlagHighAndReadyLowFlagLowHigh;
                s.vInFFTDelayBal=obj.vInFFTDelayBal;
                s.fftInFFTDelayBal=obj.fftInFFTDelayBal;
                s.cpInFFTDelayBal=obj.cpInFFTDelayBal;
                s.startFFTDelayBal=obj.startFFTDelayBal;
                s.countReg=obj.countReg;
                s.FFTReg=obj.FFTReg;
                s.cpReg=obj.cpReg;
                s.index=obj.index;
                s.FFTRegDelay=obj.FFTRegDelay;
                s.cpRegDelay=obj.cpRegDelay;
                s.index1=obj.index1;
                s.vecLenReg=obj.vecLenReg;
                s.vecLenFi=obj.vecLenFi;
                s.winInFFTDelayBal=obj.winInFFTDelayBal;
                s.winReg=obj.winReg;
                s.winRegDelay=obj.winRegDelay;
                s.winLenOut=obj.winLenOut;
                s.winLenOutReg=obj.winLenOutReg;
                s.winLenZeroFlag=obj.winLenZeroFlag;
                s.vecLen=obj.vecLen;
            end
        end


        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end

        function flag=isInputComplexityMutableImpl(~,~)

            flag=true;
        end

    end
end
