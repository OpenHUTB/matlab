classdef(StrictDefaults)OFDMDemodulator<matlab.System




%#codegen
%#ok<*EMCLS>


    properties(Nontunable)


        OFDMParamsSource='Property';



        FFTLength=64;



        CPLength=16;



        NumLGsC=6;



        NumRGsC=5;



        RoundingMethod='Floor';



        MaxFFTLength=64;



        CPFractionValue=0.55;

    end

    properties(Constant,Hidden)
        OFDMParamsSourceSet=matlab.system.StringSet({...
        'Property','Input port'});

        RoundingMethodSet=matlab.system.StringSet({...
        'Ceiling','Convergent','Floor','Nearest','Round','Zero'});

    end

    properties(Nontunable)


        CPFraction(1,1)logical=false;

        Normalize(1,1)logical=false;

        enableResetInputPort(1,1)logical=false;

        removeDCSubcarriers(1,1)logical=true;

    end

    properties(DiscreteState)

    end



    properties(Access=private)
        dataIn;
        validIn;
        dataOut;
        validOut;
        dataDelay1;
        validDelay1;
        FFTLenDelay1;
        LGDelay1;
        RGDelay1;
        CPRemoval_stage1Obj;
        CPRemoval_stage2Obj;
        SamplesRepetitionObj;
        FFTShiftTDObj;
        FFTObj;
        SubcarrierSelectorObj;
        DownSamplerObj;
        FFTLengthSig;
        CPLengthSig;
        LGrdSig;
        RGrdSig;
FFTReg
LGrdReg
RGrdReg
        countReg;
        FFTRegDelay;
        LGrdRegDelay;
        RGrdRegDelay;
        index;
        index1;
        readyOut;
        resetSignal;


        readyState;
        validHighCount;
        validLowCount;
        CPLength1;
        FFTLength1;
        readyLow;
        readyDataDelay;
        readyFlag;
        readyHigh;
readyHighReg
        readyLast;
readyLastReg
        validHighFlag;
        validLowFlag;
        LGaurdSub1;
        RGaurdSub1;
        firstValidHighFlag;
        dataInReady;
        validInReady;
validInReadyReg
        dataReadyDelay;
        validReadyDelay;
        fftLenReadyDelay;
        cpLenReadyDelay;
        lgGrdReadyDelay;
        rgGrdReadyDelay;
        resetSigReady;
        dOutReady;
        vOutReady;
        FFTOutReady;
        CPOutReady;
        LGrdOutReady;
        RGrdOutReady;
        vInFFTDelayBal;
        fftInFFTDelayBal;
        LGrdInFFTDelayBal;
        RGrdInFFTDelayBal;
        startFFTDelayBal;
maxFFTMinusVec
scope
    end

    properties(Nontunable,Access=private)
        vecLength;
        numSymbs;
    end

    methods


        function obj=OFDMDemodulator(varargin)
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
            {'scalar','real','positive','integer'},'OFDMDemodulator','FFTLength');
            if(isa(val,'embedded.fi'))
                if dsphdlshared.hdlgetwordsizefromdata(val)<4||val.Signed==1||val.FractionLength>0
                    coder.internal.error('whdl:GenOFDMDemodulator:InvalidFFTWordlength');
                end
            end

            val=double(val);
            if floor(log2(val))~=log2(val)
                coder.internal.error('whdl:GenOFDMDemodulator:FFTNotPowOfTwo');
            else
                validateattributes(val,{'numeric'},{'integer','scalar','>=',2^3,'<=',2^16},'OFDMDemodulator','FFTLength');
            end
            obj.FFTLength=val;
        end

        function set.MaxFFTLength(obj,val)
            validateattributes(val,{'double','single','embedded.fi','uint32','uint16','uint8'},...
            {'scalar','real','positive','integer'},'OFDMDemodulator','MaxFFTLength');
            if(isa(val,'embedded.fi'))
                if dsphdlshared.hdlgetwordsizefromdata(val)<4&&val.Signed==1||val.FractionLength>0
                    coder.internal.error('whdl:GenOFDMDemodulator:InvalidMaxFFTWordlength');
                end
            end

            val=double(val);
            if floor(log2(val))~=log2(val)
                coder.internal.error('whdl:GenOFDMDemodulator:MaxFFTNotPowTwo');
            else
                validateattributes(val,{'numeric'},{'integer','scalar','>=',2^3,'<=',2^16},'OFDMDemodulator','MaxFFTLength');
            end
            obj.MaxFFTLength=val;
        end

        function set.NumLGsC(obj,val)
            validateattributes(val,{'double','single','embedded.fi','uint32','uint16','uint8'},...
            {'scalar','>=',0,'real','integer'},'OFDMDemodulator','NumLGsC');
            if(isa(val,'embedded.fi'))
                if dsphdlshared.hdlgetwordsizefromdata(val)<2||val.Signed==1||val.FractionLength>0
                    coder.internal.error('whdl:GenOFDMDemodulator:InvalidLGsCWordLength');
                end
            end

            if double(val)>=obj.FFTLength/2
                coder.internal.error('whdl:GenOFDMDemodulator:NumLGsCGrtFFTBy2');
            end
            obj.NumLGsC=val;
        end


        function set.NumRGsC(obj,val)
            validateattributes(val,{'double','single','embedded.fi','uint32','uint16','uint8'},...
            {'scalar','>=',0,'real','integer'},'OFDMDemodulator','NumRGsC');
            if(isa(val,'embedded.fi'))
                if(dsphdlshared.hdlgetwordsizefromdata(val)<2)||val.Signed==1||val.FractionLength>0
                    coder.internal.error('whdl:GenOFDMDemodulator:InvalidRGsCWordLength');
                end
            end

            if double(val)>=obj.FFTLength/2
                coder.internal.error('whdl:GenOFDMDemodulator:NumRGsCGrtFFTBy2');
            end
            obj.NumRGsC=val;

        end

        function set.CPLength(obj,val)

            validateattributes(val,{'double','single','embedded.fi','uint32','uint16','uint8'},...
            {'scalar','>=',0,'real','integer'},'OFDMDemodulator','CPLength');
            if(isa(val,'embedded.fi'))
                if dsphdlshared.hdlgetwordsizefromdata(val)<4||val.Signed==1||val.FractionLength>0
                    coder.internal.error('whdl:GenOFDMDemodulator:InvalidCPWordLength');
                end
            end
            if double(val)>obj.FFTLength
                coder.internal.error('whdl:GenOFDMDemodulator:CPGrtFFTErr');
            end
            obj.CPLength=val;
        end

        function set.CPFractionValue(obj,val)
            validateattributes(val,{'double','single','embedded.fi','int32','int16','int8','uint32','uint16','uint8'},...
            {'scalar','real','>=',0,'<=',1},'OFDMDemodulator','CPFractionValue');
            obj.CPFractionValue=val;
        end
    end


    methods(Access=protected)
        function validateInputsImpl(obj,varargin)







            coder.extrinsic('tostringInternalSlName');

            datain=varargin{1};
            if isa(datain,'uint8')||isa(datain,'uint16')||isa(datain,'uint32')||(isa(datain,'embedded.fi')&&~datain.Signed)||isa(datain,'logical')
                coder.internal.error('whdl:GenOFDMDemodulator:InvalidDatatype');
            end
            validateattributes(datain,{'double','single','embedded.fi','int32','int16'},{'vector','column'},'OFDMDemodulator','data');

            pInputVectorSize=length(varargin{1});

            if mod(log2(pInputVectorSize),2)~=floor(mod(log2(pInputVectorSize),2))
                coder.internal.error('whdl:GenOFDMDemodulator:validVectorSize');
            end
            if pInputVectorSize>64
                coder.internal.error('whdl:GenOFDMDemodulator:validVectorSize');
            end
            if pInputVectorSize>obj.FFTLength
                coder.internal.error('whdl:GenOFDMDemodulator:FFTLessInputVectSize');
            end
            if strcmp(obj.OFDMParamsSource,'Input port')

                FFTLen=varargin{3};
                CPLen=varargin{4};
                LGuardSc=varargin{5};
                RGuardSc=varargin{6};

                validateattributes(FFTLen,{'double','single','embedded.fi','uint32','uint16','uint8'},...
                {'scalar','>=',0,'real','integer'},'OFDMDemodulator','FFTLength');
                if(isa(FFTLen,'embedded.fi'))
                    if(dsphdlshared.hdlgetwordsizefromdata(FFTLen)<4||FFTLen.Signed||FFTLen.FractionLength>0)
                        coder.internal.error('whdl:GenOFDMDemodulator:InvalidFFTWordlength');
                    end
                end


                validateattributes(CPLen,{'double','single','embedded.fi','uint32','uint16','uint8'},...
                {'scalar','>=',0,'real','integer'},'OFDMDemodulator','CPLength');
                if(isa(CPLen,'embedded.fi'))
                    if(dsphdlshared.hdlgetwordsizefromdata(CPLen)<4||CPLen.Signed||CPLen.FractionLength>0)
                        coder.internal.error('whdl:GenOFDMDemodulator:InvalidCPWordLength');
                    end
                end


                validateattributes(LGuardSc,{'double','single','embedded.fi','uint32','uint16','uint8'},...
                {'scalar','>=',0,'real','integer'},'OFDMDemodulator','LeftGuardSubcarriers');
                if(isa(LGuardSc,'embedded.fi'))
                    if(dsphdlshared.hdlgetwordsizefromdata(LGuardSc)<2||LGuardSc.Signed||LGuardSc.FractionLength>0)
                        coder.internal.error('whdl:GenOFDMDemodulator:InvalidLGsCWordLength');
                    end
                end


                validateattributes(RGuardSc,{'double','single','embedded.fi','uint32','uint16','uint8'},...
                {'scalar','>=',0,'real','integer'},'OFDMDemodulator','RightGuardSubcarriers');
                if(isa(RGuardSc,'embedded.fi'))
                    if(dsphdlshared.hdlgetwordsizefromdata(RGuardSc)<2||RGuardSc.Signed||RGuardSc.FractionLength>0)
                        coder.internal.error('whdl:GenOFDMDemodulator:InvalidRGsCWordLength');
                    end
                end
            end
            validateBoolean(obj,varargin{:});
        end

        function validateBoolean(obj,varargin)
            validDimension={'scalar'};
            if isempty(coder.target)||~eml_ambiguous_types
                validateattributes(varargin{2},{'logical'},validDimension,'OFDMDemodulator','valid');
                if obj.enableResetInputPort
                    if strcmp(obj.OFDMParamsSource,'Input port')
                        validateattributes(varargin{7},{'logical'},validDimension,'OFDMDemodulator','reset');
                    else
                        validateattributes(varargin{3},{'logical'},validDimension,'OFDMDemodulator','reset');
                    end
                end
            end

        end
    end
    methods(Static,Access=protected)

        function header=getHeaderImpl
            text='Demodulate time domain OFDM samples and return the subcarriers based on OFDM parameters like FFT length, CP length and number of left and right guard subcarriers.';

            header=matlab.system.display.Header('Title','OFDM Demodulator',...
            'Text',text,...
            'ShowSourceLink',false);
        end

        function groups=getPropertyGroupsImpl

            OFDMDemodParams=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'OFDMParamsSource',...
            'MaxFFTLength','FFTLength','CPLength','NumLGsC','NumRGsC',...
            'CPFraction','CPFractionValue','removeDCSubcarriers','enableResetInputPort'...
            });

            FFTBlockParams=matlab.system.display.Section(...
            'Title','FFT Parameters',...
            'PropertyList',{...
            'Normalize','RoundingMethod'});

            main=matlab.system.display.SectionGroup(...
            'Title','Main',...
            'Sections',[OFDMDemodParams,FFTBlockParams]);

            groups=main;
        end
        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end
    end
    methods(Access=protected)
        function icon=getIconImpl(~)
            icon=sprintf('OFDM Demodulator');
        end
        function num=getNumInputsImpl(obj)
            num=2;
            if(~strcmpi(obj.OFDMParamsSource,'Property'))
                num=num+4;
            end
            if(obj.enableResetInputPort)
                num=num+1;
            end
        end

        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='data';
            varargout{2}='valid';
            count=3;

            if(~strcmpi(obj.OFDMParamsSource,'Property'))
                varargout{count}='FFTLen';
                count=count+1;
                varargout{count}='CPLen';
                count=count+1;
                varargout{count}='numLgSc';
                count=count+1;
                varargout{count}='numRgSc';
                count=count+1;
            end
            if obj.enableResetInputPort
                varargout{count}='reset';
            end

        end
        function num=getNumOutputsImpl(obj)
            num=2;
            if(~strcmpi(obj.OFDMParamsSource,'Property'))
                num=num+1;
            end
        end

        function varargout=getOutputNamesImpl(obj)
            varargout{1}='data';
            varargout{2}='valid';

            if(~strcmpi(obj.OFDMParamsSource,'Property'))

                varargout{3}='ready';
            end
        end


        function varargout=getOutputDataTypeImpl(obj)
            inputDT=propagatedInputDataType(obj,1);
            if~isempty(inputDT)
                outputDT=getOutputDT(obj,inputDT);
                varargout{1}=outputDT;

                varargout{2}=numerictype('boolean');
                if strcmpi(obj.OFDMParamsSource,'Input port')
                    varargout{3}=numerictype('boolean');
                end
            else
                for ii=1:getNumOutputs(obj)
                    varargout{ii}=[];
                end
            end
        end



        function varargout=isOutputComplexImpl(obj)
            varargout{1}=true;
            varargout{2}=false;
            if strcmpi(obj.OFDMParamsSource,'Input port')
                varargout{3}=false;
            end
        end



        function varargout=getOutputSizeImpl(obj)
            varargout{1}=propagatedInputSize(obj,1);
            varargout{2}=1;
            if strcmpi(obj.OFDMParamsSource,'Input port')
                varargout{3}=1;
            end
        end

        function varargout=isOutputFixedSizeImpl(obj)
            varargout{1}=true;
            varargout{2}=true;
            if strcmpi(obj.OFDMParamsSource,'Input port')
                varargout{3}=true;
            end
        end

        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if(~strcmpi(obj.OFDMParamsSource,'Property'))
                props=[props,{'FFTLength'},{'CPLength'},{'NumLGsC'},{'NumRGsC'}];
            else
                props=[props,{'MaxFFTLength'}];
            end

            if~obj.CPFraction
                props=[props,{'CPFractionValue'}];
            else
                props=[props];
            end
            flag=ismember(prop,props);
        end
        function flag=getExecutionSemanticsImpl(obj)

            if obj.enableResetInputPort
                flag={'Classic','SynchronousWithResetPort'};
            else
                flag={'Classic','Synchronous'};
            end
        end
    end

    methods(Access=protected)
        function setupImpl(obj,varargin)

            A=varargin{1};
            maxBits=log2(obj.MaxFFTLength)+3;
            vecLen=length(A);
            obj.vecLength=fi(length(varargin{1}),0,maxBits,0,hdlfimath);
            obj.maxFFTMinusVec=fi(obj.MaxFFTLength-obj.vecLength,0,maxBits,0,hdlfimath);
            if obj.Normalize
                BitGrowth=0;
            else
                if strcmp(obj.OFDMParamsSource,'Property')
                    BitGrowth=log2(double(obj.FFTLength));
                else
                    BitGrowth=log2(double(obj.MaxFFTLength));
                end
            end

            obj.dataIn=cast(complex(zeros(vecLen,1)),'like',varargin{1});
            obj.validIn=false;
            if~isfloat(A)
                if isa(A,'embedded.fi')
                    obj.dataOut=fi(complex(zeros(vecLen,1)),1,A.WordLength+BitGrowth,A.FractionLength);
                elseif isa(A,'int8')
                    obj.dataOut=fi(complex(zeros(vecLen,1)),1,8+BitGrowth,0);
                elseif isa(A,'int16')
                    obj.dataOut=fi(complex(zeros(vecLen,1)),1,16+BitGrowth,0);
                elseif isa(A,'int32')
                    obj.dataOut=fi(complex(zeros(vecLen,1)),1,32+BitGrowth,0);
                elseif isa(A,'int64')
                    obj.dataOut=fi(complex(zeros(vecLen,1)),1,64+BitGrowth,0);
                else
                    obj.dataOut=cast(complex(zeros(vecLen,1)),'like',real(A));
                end
            else
                obj.dataOut=cast(complex(zeros(vecLen,1)),'like',A);
            end

            obj.validOut=false;
            obj.readyOut=true;
            obj.resetSigReady=false;
            obj.resetSignal=false;

            if strcmp(obj.OFDMParamsSource,'Property')
                if~obj.CPFraction
                    obj.CPRemoval_stage1Obj=commhdl.internal.CPRemoval_stage1('OFDMSrc',obj.OFDMParamsSource,'FFTLength',obj.FFTLength,'MaxFFTLength',obj.FFTLength,...
                    'CPLength',obj.CPLength,'LGaurdSub',obj.NumLGsC,'RGaurdSub',obj.NumRGsC,'CPFractionVal',1,'resetPort',obj.enableResetInputPort);
                else
                    obj.CPRemoval_stage1Obj=commhdl.internal.CPRemoval_stage1('OFDMSrc',obj.OFDMParamsSource,'FFTLength',obj.FFTLength,'MaxFFTLength',obj.FFTLength,...
                    'CPLength',obj.CPLength,'LGaurdSub',obj.NumLGsC,'RGaurdSub',obj.NumRGsC,'CPFractionVal',obj.CPFractionValue,'resetPort',obj.enableResetInputPort);
                    if obj.CPFractionValue~=1
                        obj.CPRemoval_stage2Obj=commhdl.internal.CPRemoval_stage2('OFDMSrc',obj.OFDMParamsSource,'FFTLength',obj.FFTLength,'MaxFFTLength',obj.FFTLength,...
                        'CPLength',obj.CPLength,'LGaurdSub',obj.NumLGsC,'RGaurdSub',obj.NumRGsC,'CPFractionVal',obj.CPFractionValue,'resetPort',obj.enableResetInputPort);
                    end
                end
                obj.FFTShiftTDObj=commhdl.internal.HDLFFTShift('resetPort',obj.enableResetInputPort);
                obj.FFTObj=dsp.HDLFFT('FFTLength',obj.FFTLength,'Normalize',obj.Normalize,...
                'RoundingMethod',obj.RoundingMethod,'BitReversedOutput',false,'ResetInputPort',obj.enableResetInputPort);
                obj.SubcarrierSelectorObj=commhdl.internal.SubcarrierSelector('OFDMParamSrc',obj.OFDMParamsSource,'maxFFTSize',obj.MaxFFTLength,...
                'FFTSize',obj.FFTLength,'NumLGsC',obj.NumLGsC,'NumRGsC',obj.NumRGsC,'removeDCSubcarrier',obj.removeDCSubcarriers,'resetPort',obj.enableResetInputPort);
            else


                obj.firstValidHighFlag=false;
                obj.firstValidHighFlag=false;
                obj.vInFFTDelayBal=false;
                obj.startFFTDelayBal=false;

                fftLen=varargin{3};
                wordLength=getWordLength(obj,fftLen);
                obj.FFTLength1=fi(obj.MaxFFTLength,0,wordLength,0,hdlfimath);
                obj.FFTLenDelay1=fi(64,0,wordLength,0,hdlfimath);
                obj.FFTLengthSig=fi(64,0,wordLength,0,hdlfimath);
                obj.fftInFFTDelayBal=fi(64,0,wordLength,0,hdlfimath);

                CPLen=varargin{4};
                wordLength=getWordLength(obj,CPLen);
                obj.CPLength1=fi(16,0,wordLength,0,hdlfimath);
                obj.CPLengthSig=fi(16,0,wordLength,0,hdlfimath);

                LGLen=varargin{5};
                wordLength=getWordLength(obj,LGLen);

                obj.LGaurdSub1=fi(6,0,wordLength,0,hdlfimath);
                obj.LGDelay1=fi(6,0,wordLength,0,hdlfimath);
                obj.LGrdSig=fi(6,0,wordLength,0,hdlfimath);
                obj.LGrdInFFTDelayBal=fi(6,0,wordLength,0,hdlfimath);

                RGLen=varargin{6};
                wordLength=getWordLength(obj,RGLen);

                obj.RGaurdSub1=fi(5,0,wordLength,0,hdlfimath);
                obj.RGDelay1=fi(5,0,wordLength,0,hdlfimath);
                obj.RGrdSig=fi(5,0,wordLength,0,hdlfimath);
                obj.RGrdInFFTDelayBal=fi(5,0,wordLength,0,hdlfimath);

                obj.FFTRegDelay=fi(64,0,wordLength,0,hdlfimath);
                obj.LGrdRegDelay=fi(6,0,wordLength,0,hdlfimath);
                obj.RGrdRegDelay=fi(5,0,wordLength,0,hdlfimath);
                obj.countReg=fi(0,0,wordLength,0,hdlfimath);
                obj.index=fi(0,0,7,0,hdlfimath);
                obj.index1=fi(0,0,7,0,hdlfimath);

                obj.dataReadyDelay=cast(complex(zeros(vecLen,1)),'like',varargin{1});
                obj.validReadyDelay=false;
                obj.fftLenReadyDelay=fi(64,0,wordLength,0,hdlfimath);
                obj.cpLenReadyDelay=fi(16,0,wordLength,0,hdlfimath);
                obj.lgGrdReadyDelay=fi(6,0,wordLength,0,hdlfimath);
                obj.rgGrdReadyDelay=fi(5,0,wordLength,0,hdlfimath);

                obj.readyDataDelay=true;
                obj.readyFlag=false;
                obj.readyLast=fi(79,0,17,0,hdlfimath);
                obj.readyLastReg=fi(79,0,17,0,hdlfimath);
                obj.validHighFlag=false;
                obj.validLowFlag=false;

                obj.dOutReady=cast(complex(zeros(vecLen,1)),'like',varargin{1});
                obj.vOutReady=false;
                obj.FFTOutReady=fi(64,0,wordLength,0,hdlfimath);
                obj.CPOutReady=fi(16,0,wordLength,0,hdlfimath);
                obj.LGrdOutReady=fi(6,0,wordLength,0,hdlfimath);
                obj.RGrdOutReady=fi(5,0,wordLength,0,hdlfimath);


                obj.readyState=fi(0,0,2,0);

                obj.validHighCount=fi(0,0,maxBits,0,hdlfimath);
                obj.validLowCount=fi(0,0,maxBits,0,hdlfimath);
                obj.readyHigh=fi(80,0,maxBits,0,hdlfimath);
                obj.readyHighReg=fi(80,0,maxBits,0,hdlfimath);
                obj.readyLow=fi(48,0,maxBits,0,hdlfimath);
                obj.readyOut=true;
                obj.dataDelay1=cast(complex(zeros(vecLen,1)),'like',obj.dataOut);
                obj.validDelay1=false;

                if~obj.CPFraction
                    obj.CPRemoval_stage1Obj=commhdl.internal.CPRemoval_stage1('OFDMSrc',obj.OFDMParamsSource,'MaxFFTLength',obj.MaxFFTLength,'CPFractionVal',1,'resetPort',obj.enableResetInputPort);
                else
                    obj.CPRemoval_stage1Obj=commhdl.internal.CPRemoval_stage1('OFDMSrc',obj.OFDMParamsSource,'MaxFFTLength',obj.MaxFFTLength,'CPFractionVal',obj.CPFractionValue,'resetPort',obj.enableResetInputPort);
                    if obj.CPFractionValue~=1
                        obj.CPRemoval_stage2Obj=commhdl.internal.CPRemoval_stage2('OFDMSrc',obj.OFDMParamsSource,'MaxFFTLength',obj.MaxFFTLength,'CPFractionVal',obj.CPFractionValue,'resetPort',obj.enableResetInputPort);
                    end
                end

                obj.SamplesRepetitionObj=commhdl.internal.SamplesRepetition('MaxFFTLength',obj.MaxFFTLength,'resetPort',obj.enableResetInputPort);
                obj.FFTShiftTDObj=commhdl.internal.HDLFFTShift('resetPort',obj.enableResetInputPort);
                obj.FFTObj=dsp.HDLFFT('FFTLength',obj.MaxFFTLength,'Normalize',obj.Normalize,...
                'RoundingMethod',obj.RoundingMethod,'StartOutputPort',true,'BitReversedOutput',false,'ResetInputPort',obj.enableResetInputPort);
                obj.DownSamplerObj=commhdl.internal.DownSampler('MaxFFTLength',obj.MaxFFTLength,'Normalize',obj.Normalize,'resetPort',obj.enableResetInputPort);
                obj.SubcarrierSelectorObj=commhdl.internal.SubcarrierSelector('OFDMParamSrc',obj.OFDMParamsSource,'maxFFTSize',obj.MaxFFTLength,'removeDCSubcarrier',obj.removeDCSubcarriers,'resetPort',obj.enableResetInputPort);

                obj.validInReadyReg=false;



                latency=obj.FFTObj.getLatency(obj.MaxFFTLength,vecLen);
                obj.numSymbs=ceil(latency*vecLen/obj.MaxFFTLength);
                obj.FFTReg=fi(64*ones(obj.numSymbs,1),0,wordLength,0,hdlfimath);
                obj.LGrdReg=fi(6*ones(obj.numSymbs,1),0,wordLength,0,hdlfimath);
                obj.RGrdReg=fi(5*ones(obj.numSymbs,1),0,wordLength,0,hdlfimath);
            end
        end
        function resetImpl(obj)

            vecLen=length(obj.dataIn);
            obj.maxFFTMinusVec(:)=obj.MaxFFTLength-vecLen;
            obj.dataIn=cast(complex(zeros(vecLen,1)),'like',obj.dataIn);
            obj.validIn=false;
            obj.resetSigReady=false;
            obj.dataOut=cast(complex(zeros(vecLen,1)),'like',obj.dataOut);

            obj.validOut=false;
            obj.readyOut=true;
            obj.resetSignal=false;
            if~obj.enableResetInputPort
                reset(obj.CPRemoval_stage1Obj);
                if obj.CPFraction&&obj.CPFractionValue~=1
                    reset(obj.CPRemoval_stage2Obj);
                end
                reset(obj.FFTShiftTDObj);
                reset(obj.FFTObj);
                reset(obj.SubcarrierSelectorObj);
            end
            if~strcmp(obj.OFDMParamsSource,'Property')
                obj.dataInReady=cast(complex(zeros(vecLen,1)),'like',obj.dataIn);
                obj.validInReady=false;
                obj.validInReadyReg=false;
                obj.dOutReady=cast(complex(zeros(vecLen,1)),'like',obj.dOutReady);
                obj.vOutReady=false;
                obj.FFTOutReady(:)=64;
                obj.CPOutReady(:)=16;
                obj.LGrdOutReady(:)=6;
                obj.RGrdOutReady(:)=5;
                if~obj.enableResetInputPort
                    reset(obj.SamplesRepetitionObj);
                    reset(obj.DownSamplerObj);
                end

                obj.firstValidHighFlag=false;
                obj.FFTReg(:)=64;
                obj.LGrdReg(:)=6;
                obj.RGrdReg(:)=5;
                obj.FFTRegDelay(:)=64;
                obj.LGrdRegDelay(:)=6;
                obj.RGrdRegDelay(:)=5;
                obj.countReg(:)=0;
                obj.index(:)=0;
                obj.index1(:)=0;

                obj.readyDataDelay=true;
                obj.readyFlag=false;
                obj.readyLast(:)=79;
                obj.readyLastReg(:)=79;
                obj.validHighFlag=false;
                obj.validLowFlag=false;

                obj.readyState=fi(0,0,2,0);
                obj.validHighCount(:)=0;
                obj.validLowCount(:)=0;
                obj.readyHigh(:)=80;
                obj.readyHighReg(:)=80;
                obj.readyLow(:)=48;
                obj.readyOut=true;
                obj.FFTLength1(:)=obj.MaxFFTLength;
                obj.CPLength1(:)=16;
                obj.LGaurdSub1(:)=6;
                obj.RGaurdSub1(:)=5;

                obj.dOutReady(:)=(zeros(vecLen,1));
                obj.vOutReady=false;
                obj.FFTOutReady(:)=64;
                obj.CPOutReady(:)=16;
                obj.LGrdOutReady(:)=6;
                obj.RGrdOutReady(:)=5;
                obj.vInFFTDelayBal=false;
                obj.startFFTDelayBal=false;
                obj.validDelay1(:)=false;
            end
        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.dataOut;
            varargout{2}=obj.validOut;
            if~strcmp(obj.OFDMParamsSource,'Property')
                if obj.readyFlag&&varargin{2}
                    if~obj.validLowFlag
                        varargout{3}=false;
                    else
                        varargout{3}=true;
                    end
                    obj.readyFlag=false;
                else
                    varargout{3}=obj.readyOut;
                end
            end
        end

        function varargout=isInputDirectFeedthroughImpl(obj,varargin)


            varargout{1}=true;
            varargout{2}=true;
            if strcmp(obj.OFDMParamsSource,'Input port')
                varargout{3}=true;
                varargout{4}=true;
                varargout{5}=true;
                varargout{6}=true;
                if obj.enableResetInputPort
                    varargout{7}=true;
                end
            else
                if obj.enableResetInputPort
                    varargout{3}=true;
                end
            end

        end
        function ifResetTrue(obj)
            if obj.resetSignal
                resetImpl(obj);
            end
        end
        function updateImpl(obj,varargin)
            obj.dataIn(:)=varargin{1};
            obj.validIn=varargin{2};
            if strcmp(obj.OFDMParamsSource,'Property')
                if obj.enableResetInputPort
                    obj.resetSignal=varargin{3};
                    [dataOut2,validOut2,CPLen2]=obj.CPRemoval_stage1Obj(obj.dataIn,obj.validIn,obj.resetSignal);
                    if~obj.CPFraction
                        dataOut3=dataOut2;
                        validOut3=validOut2;
                    else
                        if obj.CPFractionValue~=1
                            [dataOut3,validOut3]=obj.CPRemoval_stage2Obj(dataOut2,validOut2,CPLen2,obj.resetSignal);
                        else
                            dataOut3=dataOut2;
                            validOut3=validOut2;
                        end
                    end

                    [dataOut4,validOut4]=obj.FFTShiftTDObj(dataOut3,validOut3,obj.resetSignal);
                    [dataOut5,validOut5]=obj.FFTObj(dataOut4,validOut4,obj.resetSignal);
                    [dataOut7,validOut7]=obj.SubcarrierSelectorObj(dataOut5,validOut5,obj.resetSignal);
                    obj.dataOut(:)=dataOut7;
                    obj.validOut=validOut7;
                    ifResetTrue(obj);
                else
                    [dataOut2,validOut2,CPLen2]=obj.CPRemoval_stage1Obj(obj.dataIn,obj.validIn);
                    if~obj.CPFraction
                        dataOut3=dataOut2;
                        validOut3=validOut2;
                    else
                        if obj.CPFractionValue~=1
                            [dataOut3,validOut3]=obj.CPRemoval_stage2Obj(dataOut2,validOut2,CPLen2);
                        else
                            dataOut3=dataOut2;
                            validOut3=validOut2;
                        end
                    end
                    [dataOut4,validOut4]=obj.FFTShiftTDObj(dataOut3,validOut3);
                    [dataOut5,validOut5]=obj.FFTObj(dataOut4,validOut4);
                    [dataOut7,validOut7]=obj.SubcarrierSelectorObj(dataOut5,validOut5);
                    obj.dataOut(:)=dataOut7;
                    obj.validOut=validOut7;
                end
            else
                if obj.validIn
                    if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                        if double(varargin{3})<0
                            coder.internal.error('whdl:GenOFDMDemodulator:FFTNotPowOfTwo');
                        elseif mod(log2(double(varargin{3})),2)~=floor(mod(log2(double(varargin{3})),2))
                            coder.internal.error('whdl:GenOFDMDemodulator:FFTNotPowOfTwo');
                        elseif double(varargin{3})>double(obj.MaxFFTLength)
                            coder.internal.error('whdl:GenOFDMDemodulator:FFTGrtMaxFFT');
                        else
                            validateattributes(double(varargin{3}),{'double'},{'real','integer','scalar','>=',2^3,'<=',2^16},'OFDMDemodulator','FFTLength');
                        end
                        if double(obj.vecLength)>double(varargin{3})
                            coder.internal.error('whdl:GenOFDMDemodulator:FFTLessInputVectSize');
                        end
                        if(double(varargin{4})>double(varargin{3}))
                            coder.internal.error('whdl:GenOFDMDemodulator:CPGrtFFTErr');
                        end
                        validateattributes(double(varargin{4}),{'double'},{'real','integer','scalar','>=',0},'OFDMDemodulator','CPLength');
                        if(double(varargin{5})>=double(varargin{3}/2))
                            coder.internal.error('whdl:GenOFDMDemodulator:NumLGsCGrtFFTBy2');
                        end
                        validateattributes(double(varargin{5}),{'double'},{'real','integer','scalar','>=',0},'OFDMDemodulator','LeftGuardSubcarriers');
                        if(double(varargin{6})>=double(varargin{3}/2))
                            coder.internal.error('whdl:GenOFDMDemodulator:NumRGsCGrtFFTBy2');
                        end
                        validateattributes(double(varargin{6}),{'double'},{'real','integer','scalar','>=',0},'OFDMDemodulator','RightGuardSubcarriers');

                    end

                end


                obj.FFTLengthSig(:)=varargin{3};
                obj.CPLengthSig(:)=varargin{4};
                obj.LGrdSig(:)=varargin{5};
                obj.RGrdSig(:)=varargin{6};

                if obj.enableResetInputPort
                    obj.resetSignal=varargin{7};
                    obj.readyGeneration(obj.dataIn,obj.validIn,obj.FFTLengthSig,obj.CPLengthSig,obj.LGrdSig,obj.RGrdSig,obj.resetSignal);
                    [dataOut2,validOut2,FFTLenOut2,CPLenOut2,LGrdOut2,RGrdOut2]=obj.CPRemoval_stage1Obj(obj.dOutReady,obj.vOutReady,...
                    obj.FFTOutReady,obj.CPOutReady,obj.LGrdOutReady,obj.RGrdOutReady,obj.resetSignal);
                    if~obj.CPFraction
                        dataOut3=dataOut2;
                        validOut3=validOut2;
                        FFTLenOut3=FFTLenOut2;
                        LGrdOut3=LGrdOut2;
                        RGrdOut3=RGrdOut2;
                    else
                        if obj.CPFractionValue~=1
                            [dataOut3,validOut3,FFTLenOut3,LGrdOut3,RGrdOut3]=obj.CPRemoval_stage2Obj(dataOut2,validOut2,...
                            FFTLenOut2,CPLenOut2,LGrdOut2,RGrdOut2,obj.resetSignal);
                        else
                            dataOut3=dataOut2;
                            validOut3=validOut2;
                            FFTLenOut3=FFTLenOut2;
                            LGrdOut3=LGrdOut2;
                            RGrdOut3=RGrdOut2;
                        end
                    end
                    [dataOut4,validOut4,FFTLenOut4,LGrdOut4,RGrdOut4]=obj.SamplesRepetitionObj(dataOut3,validOut3,...
                    FFTLenOut3,LGrdOut3,RGrdOut3,obj.resetSignal);
                    [dataOut5,validOut5]=obj.FFTShiftTDObj(dataOut4,validOut4,...
                    obj.resetSignal);
                    [dataOut6,startSig,validOut6]=obj.FFTObj(dataOut5,validOut5,obj.resetSignal);
                    [FFTLengthOut,LGuardSubOut,RGaurdSubOut]=obj.FFTDelayBalance(validOut5,FFTLenOut4,LGrdOut4,RGrdOut4,startSig);
                    [dataOut7,validOut7,FFTLengthOut1,LGuardSubOut1,RGaurdSubOut1]=obj.DownSamplerObj(obj.dataDelay1,obj.validDelay1,obj.FFTLenDelay1,obj.LGDelay1,obj.RGDelay1,obj.resetSignal);

                    obj.dataDelay1(:)=dataOut6;
                    obj.validDelay1(:)=validOut6;
                    obj.FFTLenDelay1(:)=FFTLengthOut;
                    obj.LGDelay1(:)=LGuardSubOut;
                    obj.RGDelay1(:)=RGaurdSubOut;
                    [dataOut8,validOut8]=obj.SubcarrierSelectorObj(dataOut7,validOut7,FFTLengthOut1,LGuardSubOut1,RGaurdSubOut1,obj.resetSignal);

                    obj.dataOut(:)=dataOut8;
                    obj.validOut(:)=validOut8;
                    ifResetTrue(obj);
                else
                    obj.readyGeneration(obj.dataIn,obj.validIn,obj.FFTLengthSig,obj.CPLengthSig,obj.LGrdSig,obj.RGrdSig);
                    [dataOut2,validOut2,FFTLenOut2,CPLenOut2,LGrdOut2,RGrdOut2]=obj.CPRemoval_stage1Obj(obj.dOutReady,obj.vOutReady,...
                    obj.FFTOutReady,obj.CPOutReady,obj.LGrdOutReady,obj.RGrdOutReady);

                    if~obj.CPFraction
                        dataOut3=dataOut2;
                        validOut3=validOut2;
                        FFTLenOut3=FFTLenOut2;
                        LGrdOut3=LGrdOut2;
                        RGrdOut3=RGrdOut2;
                    else
                        if obj.CPFractionValue~=1
                            [dataOut3,validOut3,FFTLenOut3,LGrdOut3,RGrdOut3]=obj.CPRemoval_stage2Obj(dataOut2,validOut2,...
                            FFTLenOut2,CPLenOut2,LGrdOut2,RGrdOut2);
                        else
                            dataOut3=dataOut2;
                            validOut3=validOut2;
                            FFTLenOut3=FFTLenOut2;
                            LGrdOut3=LGrdOut2;
                            RGrdOut3=RGrdOut2;
                        end
                    end
                    [dataOut4,validOut4,FFTLenOut4,LGrdOut4,RGrdOut4]=obj.SamplesRepetitionObj(dataOut3,validOut3,...
                    FFTLenOut3,LGrdOut3,RGrdOut3);
                    [dataOut5,validOut5]=obj.FFTShiftTDObj(dataOut4,validOut4);
                    [dataOut6,startSig,validOut6]=obj.FFTObj(dataOut5,validOut5);
                    [FFTLengthOut,LGuardSubOut,RGaurdSubOut]=obj.FFTDelayBalance(validOut5,FFTLenOut4,LGrdOut4,RGrdOut4,startSig);
                    [dataOut7,validOut7,FFTLengthOut1,LGuardSubOut1,RGaurdSubOut1]=obj.DownSamplerObj(obj.dataDelay1,obj.validDelay1,obj.FFTLenDelay1,obj.LGDelay1,obj.RGDelay1);

                    obj.dataDelay1(:)=dataOut6;
                    obj.validDelay1(:)=validOut6;
                    obj.FFTLenDelay1(:)=FFTLengthOut;
                    obj.LGDelay1(:)=LGuardSubOut;
                    obj.RGDelay1(:)=RGaurdSubOut;
                    [dataOut8,validOut8]=obj.SubcarrierSelectorObj(dataOut7,validOut7,FFTLengthOut1,LGuardSubOut1,RGaurdSubOut1);

                    obj.dataOut(:)=dataOut8;
                    obj.validOut(:)=validOut8;

                end
            end


        end
        function[fftOut,LGrdOut,RGrdOut]=FFTDelayBalance(obj,vIn,fftIn,LGrdIn,RGrdIn,startSigIn)
            obj.vInFFTDelayBal=vIn;
            obj.fftInFFTDelayBal(:)=fftIn;
            obj.LGrdInFFTDelayBal(:)=LGrdIn;
            obj.RGrdInFFTDelayBal(:)=RGrdIn;
            obj.startFFTDelayBal=startSigIn;
            if obj.vInFFTDelayBal
                if(obj.countReg==0)
                    obj.FFTReg(obj.index+1)=obj.fftInFFTDelayBal;
                    obj.LGrdReg(obj.index+1)=obj.LGrdInFFTDelayBal;
                    obj.RGrdReg(obj.index+1)=obj.RGrdInFFTDelayBal;
                    if obj.index==(obj.numSymbs-1)
                        obj.index(:)=0;
                    else
                        obj.index(:)=obj.index+1;
                    end
                end

                if obj.countReg==obj.MaxFFTLength-obj.vecLength
                    obj.countReg(:)=0;
                else
                    obj.countReg(:)=obj.countReg+obj.vecLength;
                end
            end
            if obj.startFFTDelayBal
                fftOut=obj.FFTReg(obj.index1+1);
                LGrdOut=obj.LGrdReg(obj.index1+1);
                RGrdOut=obj.RGrdReg(obj.index1+1);
                obj.FFTRegDelay(:)=obj.FFTReg(obj.index1+1);
                obj.LGrdRegDelay(:)=obj.LGrdReg(obj.index1+1);
                obj.RGrdRegDelay(:)=obj.RGrdReg(obj.index1+1);
                if obj.index1==obj.numSymbs-1
                    obj.index1(:)=0;
                else
                    obj.index1(:)=obj.index1+1;
                end
            else
                fftOut=obj.FFTRegDelay;
                LGrdOut=obj.LGrdRegDelay;
                RGrdOut=obj.RGrdRegDelay;
            end

        end

        function readyGeneration(obj,varargin)
            obj.dataInReady(:)=varargin{1};
            obj.validInReady=obj.readyDataDelay&&varargin{2}&&~obj.resetSignal;

            if(obj.validInReady&&~obj.firstValidHighFlag)
                obj.firstValidHighFlag=true;
            end








            sampCntLessthanVector=(obj.validHighCount<obj.vecLength);
            samplingSignal=(sampCntLessthanVector&&obj.validInReady);

            if samplingSignal
                obj.FFTLength1(:)=varargin{3};
                obj.CPLength1(:)=varargin{4};
                obj.LGaurdSub1(:)=varargin{5};
                obj.RGaurdSub1(:)=varargin{6};
                obj.validHighFlag=false;
                obj.validLowFlag=false;
            end

            obj.readyLow(:)=obj.maxFFTMinusVec-obj.FFTLength1;

            obj.readyHigh(:)=obj.FFTLength1+obj.CPLength1;

            obj.readyLast(:)=obj.readyHigh-obj.vecLength;


            frstVldANDRdy=obj.firstValidHighFlag&&obj.validInReady;
            frstVldANDRdyN=obj.firstValidHighFlag&&~obj.validInReady;

            if frstVldANDRdy
                obj.validHighCount(:)=obj.validHighCount+obj.vecLength;
            end

            if frstVldANDRdyN
                obj.validLowCount(:)=obj.validLowCount+obj.vecLength;
            end

            if obj.validHighCount>=obj.readyLast&&obj.validHighCount<obj.readyHigh
                obj.readyFlag=true;
            end

            if obj.validHighCount>=(obj.readyHigh)
                obj.validHighFlag=true;
            end

            if obj.validLowCount>=obj.readyLow
                obj.validLowFlag=true;
            end

            vldHvldLN=(obj.validHighFlag&&~obj.validLowFlag);
            vldHvldL=(obj.validHighFlag&&obj.validLowFlag);
            FFTeqMaxFFT=(obj.FFTLength1==obj.MaxFFTLength);

            if vldHvldLN
                obj.readyState=fi(1,0,2,0);
                obj.readyOut=false;
                obj.readyDataDelay=false;
            elseif vldHvldL
                obj.readyDataDelay=(obj.readyState==0);
                obj.readyOut=true;
                obj.readyState=fi(0,0,2,0);
                obj.validHighFlag=false;
                obj.validLowFlag=false;
                obj.validHighCount(:)=obj.validHighCount-obj.readyHigh;
                obj.validLowCount(:)=0;
                obj.firstValidHighFlag=false;
            else
                obj.readyState=fi(0,0,2,0);
                obj.readyOut=true;
                obj.readyDataDelay=true;
            end

            if FFTeqMaxFFT
                obj.readyFlag=false;
                obj.readyState=fi(0,0,2,0);
                obj.readyOut=true;
                obj.readyDataDelay=true;
                obj.validLowFlag=true;
            end

            obj.dOutReady(:)=obj.dataReadyDelay;
            obj.dataReadyDelay=obj.dataInReady;

            obj.vOutReady(:)=obj.validReadyDelay;
            obj.validReadyDelay=obj.validInReady;

            obj.FFTOutReady(:)=obj.fftLenReadyDelay;
            obj.fftLenReadyDelay(:)=obj.FFTLength1;

            obj.CPOutReady(:)=obj.cpLenReadyDelay;
            obj.cpLenReadyDelay=obj.CPLength1;

            obj.LGrdOutReady(:)=obj.lgGrdReadyDelay;
            obj.lgGrdReadyDelay=obj.LGaurdSub1;

            obj.RGrdOutReady(:)=obj.rgGrdReadyDelay;
            obj.rgGrdReadyDelay=obj.RGaurdSub1;

        end

        function wordLength=getWordLength(obj,~)
            wordLength=log2(obj.MaxFFTLength)+2;
        end

        function outputDT=getOutputDT(obj,inputDT)
            if obj.Normalize
                BitGrowth=0;
            else
                if strcmp(obj.OFDMParamsSource,'Property')
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
            elseif strcmpi(inputDT,'int8')
                outputDT=numerictype(1,8+BitGrowth,0);
            elseif strcmpi(inputDT,'int16')
                outputDT=numerictype(1,16+BitGrowth,0);
            elseif strcmpi(inputDT,'int32')
                outputDT=numerictype(1,32+BitGrowth,0);
            elseif strcmpi(inputDT,'int64')
                outputDT=numerictype(1,64+BitGrowth,0);
            else
                outputDT=inputDT;
            end
        end
        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end


        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.dataIn=obj.dataIn;
                s.validIn=obj.validIn;
                s.dataOut=obj.dataOut;
                s.validOut=obj.validOut;
                s.dataDelay1=obj.dataDelay1;
                s.validDelay1=obj.validDelay1;
                s.FFTLenDelay1=obj.FFTLenDelay1;
                s.LGDelay1=obj.LGDelay1;
                s.RGDelay1=obj.RGDelay1;
                s.CPRemoval_stage1Obj=obj.CPRemoval_stage1Obj;
                s.CPRemoval_stage2Obj=obj.CPRemoval_stage2Obj;
                s.SamplesRepetitionObj=obj.SamplesRepetitionObj;
                s.FFTShiftTDObj=obj.FFTShiftTDObj;
                s.FFTObj=obj.FFTObj;
                s.SubcarrierSelectorObj=obj.SubcarrierSelectorObj;
                s.DownSamplerObj=obj.DownSamplerObj;
                s.FFTLengthSig=obj.FFTLengthSig;
                s.CPLengthSig=obj.CPLengthSig;
                s.LGrdSig=obj.LGrdSig;
                s.RGrdSig=obj.RGrdSig;
                s.FFTReg=obj.FFTReg;
                s.LGrdReg=obj.LGrdReg;
                s.RGrdReg=obj.RGrdReg;
                s.countReg=obj.countReg;
                s.FFTRegDelay=obj.FFTRegDelay;
                s.LGrdRegDelay=obj.LGrdRegDelay;
                s.RGrdRegDelay=obj.RGrdRegDelay;
                s.index=obj.index;
                s.index1=obj.index1;
                s.readyOut=obj.readyOut;
                s.resetSignal=obj.resetSignal;
                s.readyState=obj.readyState;
                s.validHighCount=obj.validHighCount;
                s.validLowCount=obj.validLowCount;
                s.CPLength1=obj.CPLength1;
                s.FFTLength1=obj.FFTLength1;
                s.readyLow=obj.readyLow;
                s.readyDataDelay=obj.readyDataDelay;
                s.readyFlag=obj.readyFlag;
                s.readyHigh=obj.readyHigh;
                s.readyHighReg=obj.readyHighReg;
                s.readyLast=obj.readyLast;
                s.readyLastReg=obj.readyLastReg;
                s.validHighFlag=obj.validHighFlag;
                s.validLowFlag=obj.validLowFlag;
                s.LGaurdSub1=obj.LGaurdSub1;
                s.RGaurdSub1=obj.RGaurdSub1;
                s.firstValidHighFlag=obj.firstValidHighFlag;
                s.dataInReady=obj.dataInReady;
                s.validInReady=obj.validInReady;
                s.validInReadyReg=obj.validInReadyReg;
                s.dataReadyDelay=obj.dataReadyDelay;
                s.validReadyDelay=obj.validReadyDelay;
                s.fftLenReadyDelay=obj.fftLenReadyDelay;
                s.cpLenReadyDelay=obj.cpLenReadyDelay;
                s.lgGrdReadyDelay=obj.lgGrdReadyDelay;
                s.rgGrdReadyDelay=obj.rgGrdReadyDelay;
                s.resetSigReady=obj.resetSigReady;
                s.dOutReady=obj.dOutReady;
                s.vOutReady=obj.vOutReady;
                s.FFTOutReady=obj.FFTOutReady;
                s.CPOutReady=obj.CPOutReady;
                s.LGrdOutReady=obj.LGrdOutReady;
                s.RGrdOutReady=obj.RGrdOutReady;
                s.vInFFTDelayBal=obj.vInFFTDelayBal;
                s.fftInFFTDelayBal=obj.fftInFFTDelayBal;
                s.LGrdInFFTDelayBal=obj.LGrdInFFTDelayBal;
                s.RGrdInFFTDelayBal=obj.RGrdInFFTDelayBal;
                s.startFFTDelayBal=obj.startFFTDelayBal;
                s.maxFFTMinusVec=obj.maxFFTMinusVec;
                s.vecLength=obj.vecLength;
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
