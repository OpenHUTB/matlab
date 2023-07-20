classdef(StrictDefaults)DVBS2SymbolDemodulator<matlab.System








%#codegen







    properties(Nontunable)

        ModulationSourceParams='Input port';

        ModulationScheme='QPSK';

        CodeRateAPSK='3/4';

        DecisionType='Approximate log-likelihood ratio';

        OutputType='Vector';
    end


    properties(Constant,Hidden)
        ModulationSourceParamsSet=matlab.system.StringSet({...
        'Input port','Property'});

        ModulationSchemeSet=matlab.system.StringSet({...
        'QPSK','8-PSK','16-APSK','32-APSK','pi/2-BPSK'});

        CodeRateAPSKSet=matlab.system.StringSet({...
        '2/3','3/4','4/5','5/6','8/9','9/10'});

        DecisionTypeSet=matlab.system.StringSet({...
        'Hard','Approximate log-likelihood ratio'});

        OutputTypeSet=matlab.system.StringSet({...
        'Scalar','Vector'});
    end

    properties(Nontunable)%#ok<*MTMAT>

        UnitAveragePower(1,1)logical=false;

        EnbNoiseVar(1,1)logical=false;
    end


    properties(Access=private)

        SymDemodPiBy2BPSKObj;
        SymDemodQPSKObj;
        SymDemod8PSKObj;
        SymDemod16APSKObj;
        SymDemod32APSKObj;


        dataIn;
        dataInReal;
        dataInImag;
        ctrl;


        startInFlag;
        endInFlag;
        endInFlagReg;
        startOutFlag;
        evenSymFlag;


        bitsPerSym;
        lutIdx;
        bitsPerSymReg;
        nVar;
        nVarReg;
        modIndx;
        codeRateIndx;
        idx;


        buffVec1;
        buffVec2;
        intermedBuff;
        intermedNVarBuff;
        nVarVec;


        vectorSize;


        countVecElem;
        countIntermedBuffElem;
        countSym;


        numeratorOne;
        validNVarValuesLUT;
        nVarZeroWarningFlag;


        delayBalDataOut;
        delayBalStartOut;
        delayBalEndOut;
        delayBalValidOut;
        delayBalScalarValidOut;


        dataOutDelay;
        dataOut;
        ctrlOut;
        validOut;
        readyReg;
        countBitsPerSym;
        numBitsPerSym;
        inputReceiveFlag;
        scalarValid;
        scalarValidOut;
        outputReadyFlag;
    end

    methods
        function obj=DVBS2SymbolDemodulator(varargin)
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

    end

    methods(Static,Access=protected)

        function header=getHeaderImpl
            text=...
            ['Demodulate complex constellation symbol to set of LLR values or data bits according to DVB-S2 standard.'...
            ,newline...
            ,newline...
            ,'When the modIdx port value is set to 0, 1, or 4, the block ignores the input port'...
            ,' codeRateIdx and the parameter Unit average power. The values 0, 1, and 4 indicate the modulation types'...
            ,' QPSK, 8-PSK, and pi/2-BSPK, respectively.'];

            header=matlab.system.display.Header(mfilename('class'),...
            'Title','DVB-S2 Symbol Demodulator',...
            'Text',text,...
            'ShowSourceLink',false);
        end



        function groups=getPropertyGroupsImpl
            struc=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'ModulationSourceParams','ModulationScheme','CodeRateAPSK','DecisionType','OutputType',...
            'UnitAveragePower','EnbNoiseVar'});

            main=matlab.system.display.SectionGroup(...
            'TitleSource','Auto',...
            'Sections',struc);

            groups=main;
        end



        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end

    end



    methods(Access=protected)

        function icon=getIconImpl(~)
            icon=sprintf('DVB-S2 Symbol\nDemodulator');
        end

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end

        function varargout=isInputDirectFeedthroughImpl(obj,varargin)
            varargout={false,true,true,false,false};
        end

        function resetImpl(obj)

            obj.vectorSize(:)=8;
            obj.dataOut(:)=0;
            obj.dataIn(:)=0;
            obj.dataInReal(:)=0;
            obj.dataInImag(:)=0;
            obj.ctrl(:)=struct('start',false,'end',false,'valid',false);
            obj.ctrlOut(:)=struct('start',false,'end',false,'valid',false);
            obj.startInFlag(:)=false;
            obj.endInFlag(:)=false;
            obj.endInFlagReg(:)=false;
            obj.startOutFlag(:)=false;
            obj.buffVec1(:)=0;
            obj.buffVec2(:)=0;
            obj.intermedBuff(:)=0;
            obj.intermedNVarBuff(:)=1;
            obj.bitsPerSym(:)=2;
            obj.lutIdx(:)=2;
            obj.bitsPerSymReg(:)=2;
            obj.countIntermedBuffElem(:)=0;
            obj.countSym(:)=0;
            obj.numeratorOne(:)=1;
            if(strcmpi(obj.DecisionType,'Approximate log-likelihood ratio'))&&obj.EnbNoiseVar
                obj.validNVarValuesLUT(:)=2.^(-(0:16));
            end
            obj.nVarZeroWarningFlag(:)=true;
            obj.countVecElem(:)=0;
            obj.nVar(:)=1;
            obj.nVarReg(:)=1;
            obj.nVarVec(:)=1;
            obj.evenSymFlag(:)=true;
            obj.modIndx(:)=5;
            obj.codeRateIndx(:)=4;
            obj.idx(:)=0;
            obj.validOut(:)=false;
            obj.readyReg(:)=true;
            obj.countBitsPerSym(:)=0;
            obj.numBitsPerSym(:)=0;
            obj.inputReceiveFlag(:)=false;
            obj.scalarValid(:)=false;
            obj.scalarValidOut(:)=false;
            obj.outputReadyFlag(:)=false;
            obj.dataOutDelay(:)=0;


            reset(obj.delayBalDataOut);
            reset(obj.delayBalStartOut);
            reset(obj.delayBalEndOut);
            reset(obj.delayBalValidOut);
            reset(obj.delayBalScalarValidOut);


            reset(obj.SymDemod16APSKObj);
            reset(obj.SymDemod32APSKObj);
            reset(obj.SymDemod8PSKObj);
            reset(obj.SymDemodPiBy2BPSKObj);
            reset(obj.SymDemodQPSKObj);
        end

        function setupImpl(obj,varargin)

            if(~strcmpi(obj.OutputType,'Scalar'))
                VL=8;
            else
                VL=1;
            end
            dIn=varargin{1};
            obj.ctrl=struct('start',false,'end',false,'valid',false);


            obj.startInFlag=false;
            obj.endInFlag=false;
            obj.endInFlagReg=false;
            obj.startOutFlag=false;
            obj.evenSymFlag=true;
            obj.nVarZeroWarningFlag=true;


            obj.dataIn=cast(0,'like',varargin{1});
            obj.dataInReal=cast(0,'like',real(dIn));
            obj.dataInImag=cast(0,'like',real(dIn));


            obj.vectorSize=fi(8,0,4,0,hdlfimath);
            obj.bitsPerSym=fi(2,0,3,0,hdlfimath);
            obj.lutIdx=fi(2,0,3,0,hdlfimath);
            obj.bitsPerSymReg=fi(2,0,3,0,hdlfimath);
            obj.countIntermedBuffElem=fi(0,0,3,0,hdlfimath);
            obj.countSym=fi(0,0,4,0,hdlfimath);
            obj.modIndx=fi(5,0,3,0,hdlfimath);
            obj.codeRateIndx=fi(4,0,4,0,hdlfimath);
            obj.idx=fi(0,0,4,0,hdlfimath);


            obj.countVecElem=fi(0,0,4,0,hdlfimath);

            if(strcmpi(obj.DecisionType,'Approximate log-likelihood ratio'))&&obj.EnbNoiseVar
                if strcmpi(obj.ModulationSourceParams,'Input port')
                    nVarIn=varargin{5};
                else
                    nVarIn=varargin{3};
                end
                valuesFL=-(0:16);
                obj.validNVarValuesLUT=fi(2.^(valuesFL),0,17,16);

                if~isfloat(nVarIn)
                    obj.numeratorOne=fi(1,0,32,31,hdlfimath);
                else
                    obj.numeratorOne=cast(1,'like',nVarIn);
                end

                obj.nVar=cast(1,'like',nVarIn);
                obj.nVarReg=cast(1,'like',nVarIn);
                obj.nVarVec=cast(ones(8,1),'like',nVarIn);
                obj.intermedNVarBuff=cast(ones(5,1),'like',nVarIn);
            end


            if~isfloat(dIn)

                if isa(dIn,'int8')
                    inpData=fi(0,1,8,0);
                elseif(isa(dIn,'int16'))
                    inpData=fi(0,1,16,0);
                elseif(isa(dIn,'int32'))
                    inpData=fi(0,1,32,0);
                else
                    inpData=dIn;
                end
                if(strcmpi(obj.DecisionType,'Approximate log-likelihood ratio'))
                    if~obj.EnbNoiseVar
                        bGWLMul=3;
                    else
                        bGWLMul=14;
                    end

                    obj.dataOut=fi(zeros(VL,1),1,inpData.WordLength+bGWLMul,inpData.FractionLength,hdlfimath);
                    obj.dataOutDelay=fi(zeros(VL,1),1,inpData.WordLength+bGWLMul,inpData.FractionLength,hdlfimath);
                    obj.buffVec1=fi(zeros(5,1),1,inpData.WordLength+3,inpData.FractionLength,hdlfimath);
                    obj.buffVec2=fi(zeros(8,1),1,inpData.WordLength+3,inpData.FractionLength,hdlfimath);
                    obj.intermedBuff=fi(zeros(5,1),1,inpData.WordLength+3,inpData.FractionLength,hdlfimath);
                else
                    obj.dataOut=boolean(zeros(VL,1));
                    obj.dataOutDelay=boolean(zeros(VL,1));
                    obj.buffVec1=boolean(zeros(5,1));
                    obj.buffVec2=boolean(zeros(8,1));
                    obj.intermedBuff=boolean(zeros(5,1));
                end
                if(strcmpi(obj.OutputType,'Vector'))
                    if(strcmpi(obj.DecisionType,'Hard'))
                        angMagBlkDelayFac=7;
                        bGAng=7;
                        delayValue=inpData.WordLength+angMagBlkDelayFac+8+1+15+2+bGAng;
                    else
                        if obj.EnbNoiseVar
                            delayValue=18+36+3;
                        else
                            delayValue=18;
                        end
                    end
                else
                    if(strcmpi(obj.DecisionType,'Hard'))
                        bGAng=7;
                        delayValue=2+inpData.WordLength+15+7+3+3+bGAng;
                    else
                        if obj.EnbNoiseVar
                            delayValue=(2+3+9+1)+(36-15)+3;
                        else
                            delayValue=(2+3+9+1);
                        end
                    end
                end
            else
                if(strcmpi(obj.DecisionType,'Approximate log-likelihood ratio'))
                    obj.dataOut=cast(zeros(VL,1),'like',real(dIn));
                    obj.dataOutDelay=cast(zeros(VL,1),'like',real(dIn));
                    obj.buffVec1=cast(zeros(5,1),'like',real(dIn));
                    obj.buffVec2=cast(zeros(8,1),'like',real(dIn));
                    obj.intermedBuff=cast(zeros(5,1),'like',real(dIn));
                else
                    obj.dataOut=boolean(zeros(VL,1));
                    obj.dataOutDelay=boolean(zeros(VL,1));
                    obj.buffVec1=boolean(zeros(5,1));
                    obj.buffVec2=boolean(zeros(8,1));
                    obj.intermedBuff=boolean(zeros(5,1));
                end
                delayValue=0;
            end

            obj.ctrlOut=struct('start',false,'end',false,'valid',false);
            obj.validOut=false;
            obj.readyReg=true;
            obj.countBitsPerSym=fi(0,0,3,0,hdlfimath);
            obj.numBitsPerSym=fi(0,0,3,0,hdlfimath);
            obj.inputReceiveFlag=false;
            obj.scalarValid=false;
            obj.scalarValidOut=false;
            obj.outputReadyFlag=false;



            if(~strcmpi(obj.OutputType,'Scalar'))
                obj.delayBalDataOut=dsp.Delay('Length',(delayValue*(8)));
            else
                obj.delayBalDataOut=dsp.Delay('Length',(delayValue*(1)));
            end
            obj.delayBalStartOut=dsp.Delay(delayValue);
            obj.delayBalEndOut=dsp.Delay(delayValue);
            obj.delayBalValidOut=dsp.Delay(delayValue);
            obj.delayBalScalarValidOut=dsp.Delay(delayValue);


            obj.SymDemodPiBy2BPSKObj=satcomhdl.internal.SymDemodPiBy2BPSK('DecisionType',obj.DecisionType);
            obj.SymDemodQPSKObj=satcomhdl.internal.SymDemodQPSK('DecisionType',obj.DecisionType);
            obj.SymDemod8PSKObj=satcomhdl.internal.SymDemod8PSK('DecisionType',obj.DecisionType);
            obj.SymDemod16APSKObj=satcomhdl.internal.SymDemod16APSK('DecisionType',obj.DecisionType,'UnitAvgPower',obj.UnitAveragePower);
            obj.SymDemod32APSKObj=satcomhdl.internal.SymDemod32APSK('DecisionType',obj.DecisionType,'UnitAvgPower',obj.UnitAveragePower);
        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.dataOut;
            if(strcmpi(obj.OutputType,'Scalar'))
                varargout{2}=obj.scalarValidOut;
                validIn=varargin{2};
                obj.scalarValid=validIn&&obj.readyReg;

                if obj.scalarValid
                    obj.inputReceiveFlag(:)=true;
                    if~strcmpi(obj.ModulationSourceParams,'Property')
                        obj.modIndx(:)=varargin{3};
                    end
                    obj.numBitsPerSym(:)=calBitsPerSym(obj);
                end

                if obj.inputReceiveFlag
                    bitsPerSymCounter(obj);
                end
                varargout{3}=((obj.numBitsPerSym==obj.countBitsPerSym)||(obj.countBitsPerSym==0&&~obj.scalarValid));
                if((obj.numBitsPerSym==obj.countBitsPerSym)||(obj.countBitsPerSym==0&&~obj.scalarValid))
                    obj.readyReg=true;
                    obj.inputReceiveFlag(:)=false;
                    obj.countBitsPerSym(:)=0;
                else
                    obj.readyReg=false;
                end
            else
                varargout{2}=obj.ctrlOut;
            end
        end

        function updateImpl(obj,varargin)
            if((strcmpi(obj.DecisionType,'Approximate log-likelihood ratio')&&obj.EnbNoiseVar))
                obj.nVar(:)=obj.nVarReg(:);
            end

            obj.endInFlagReg(:)=obj.endInFlag(:);
            if obj.endInFlag
                obj.startInFlag(:)=false;
                obj.evenSymFlag(:)=true;
                obj.endInFlag=false;
            end

            obj.dataIn(:)=varargin{1};
            obj.dataInReal(:)=real(varargin{1});
            obj.dataInImag(:)=imag(varargin{1});

            if(~strcmpi(obj.OutputType,'Scalar'))
                obj.ctrl.start=varargin{2}.start;
                obj.ctrl.end=varargin{2}.end;
                obj.ctrl.valid=varargin{2}.valid;
            end
            if obj.ctrl.start&&obj.ctrl.valid&&~obj.ctrl.end
                if obj.startInFlag
                    resetImpl(obj);
                    obj.dataIn(:)=varargin{1};
                    obj.dataInReal(:)=real(varargin{1});
                    obj.dataInImag(:)=imag(varargin{1});
                    if(~strcmpi(obj.OutputType,'Scalar'))
                        obj.ctrl.start=varargin{2}.start;
                        obj.ctrl.end=varargin{2}.end;
                        obj.ctrl.valid=varargin{2}.valid;
                    end
                end
                startSample=true;
            else
                startSample=false;
            end
            validSample=obj.ctrl.valid&&obj.startInFlag;

            if(strcmpi(obj.ModulationSourceParams,'Input port'))
                if startSample||obj.scalarValid
                    if(varargin{3}<0)||(varargin{3}>4)||(varargin{3}>0&&varargin{3}<1)...
                        ||(varargin{3}>1&&varargin{3}<2)||(varargin{3}>2&&varargin{3}<3)||(varargin{3}>3&&varargin{3}<4)
                        coder.internal.warning('whdl:DVBS2SymbolDemodulator:InvalidModIdxValue');
                    end
                    if varargin{3}==2
                        if(varargin{4}<5)||(varargin{4}>10)||(varargin{4}>5&&varargin{4}<6)||(varargin{4}>6&&varargin{4}<7)...
                            ||(varargin{4}>7&&varargin{4}<8)||(varargin{4}>8&&varargin{4}<9)||(varargin{4}>9&&varargin{4}<10)
                            coder.internal.warning('whdl:DVBS2SymbolDemodulator:InvalidCodeRateIdxValue16APSK');
                        end
                    end
                    if varargin{3}==3
                        if varargin{4}<6||varargin{4}>10||(varargin{4}>6&&varargin{4}<7)...
                            ||(varargin{4}>7&&varargin{4}<8)||(varargin{4}>8&&varargin{4}<9)||(varargin{4}>9&&varargin{4}<10)
                            coder.internal.warning('whdl:DVBS2SymbolDemodulator:InvalidCodeRateIdxValue32APSK');
                        end
                    end
                    obj.modIndx(:)=varargin{3};
                    obj.codeRateIndx(:)=varargin{4};
                end
                if((strcmpi(obj.DecisionType,'Approximate log-likelihood ratio')&&obj.EnbNoiseVar))&&(startSample||validSample||obj.scalarValid)
                    obj.nVarReg(:)=varargin{5};
                    validateNoiseVarValue(obj);
                end
            else
                if((strcmpi(obj.DecisionType,'Approximate log-likelihood ratio')&&obj.EnbNoiseVar))&&(startSample||validSample||obj.scalarValid)
                    obj.nVarReg(:)=varargin{3};
                    validateNoiseVarValue(obj);
                end
            end
            obj.bitsPerSymReg(:)=obj.bitsPerSym(:);

            if(~strcmpi(obj.OutputType,'Scalar'))
                if startSample
                    obj.bitsPerSym(:)=calBitsPerSym(obj);
                    calCodeRateIndex(obj);
                    obj.startInFlag(:)=true;
                    obj.evenSymFlag(:)=true;
                end
            else
                if obj.scalarValid
                    obj.bitsPerSym(:)=calBitsPerSym(obj);
                    calCodeRateIndex(obj);
                end
            end

            if(startSample||validSample)
                if obj.countSym(:)>=fi(8,0,4,0,hdlfimath)
                    obj.countSym(:)=obj.countSym(:)-fi(8,0,4,0,hdlfimath);
                end
                obj.countSym(:)=obj.countSym(:)+obj.bitsPerSym(:);
            end

            if~obj.ctrl.start&&obj.ctrl.end&&obj.ctrl.valid&&~obj.endInFlag&&obj.startInFlag
                obj.endInFlag(:)=true;
                if obj.countSym(:)~=fi(8,0,4,0,hdlfimath)
                    coder.internal.warning('whdl:DVBS2SymbolDemodulator:SymLenNonMulti8Warning');
                end
                obj.countSym(:)=0;
            end
            fillVectorBuff1(obj);
            if obj.validOut
                copyBuff1ToBuff2(obj);
                obj.outputReadyFlag(:)=true;
            end
            startOutDelay=false;
            endOutDelay=false;
            validOutDelay=false;
            scalarValidOutDelay=false;
            if(~strcmpi(obj.OutputType,'Scalar'))
                if obj.validOut
                    if(obj.countVecElem==obj.vectorSize)
                        if~obj.startOutFlag
                            startOutDelay=true;
                            obj.startOutFlag(:)=true;
                        end
                        if(strcmpi(obj.DecisionType,'Approximate log-likelihood ratio')&&obj.EnbNoiseVar)
                            oneByNvar=obj.numeratorOne(:)./obj.nVarVec(:);
                            obj.dataOutDelay(:)=obj.buffVec2(:).*oneByNvar;
                        else
                            obj.dataOutDelay(:)=obj.buffVec2(:);
                        end
                        if obj.endInFlagReg&&obj.countIntermedBuffElem==0
                            endOutDelay=true;
                            obj.startOutFlag(:)=false;
                        end

                        if obj.endInFlagReg&&obj.countIntermedBuffElem~=0
                            obj.startOutFlag(:)=false;
                            obj.countIntermedBuffElem(:)=0;
                        end

                        validOutDelay=true;
                        obj.countVecElem(:)=0;
                        obj.buffVec2(:)=0;
                        if(strcmpi(obj.DecisionType,'Approximate log-likelihood ratio')&&obj.EnbNoiseVar)
                            obj.nVarVec(:)=1;
                        end
                    else
                        if obj.endInFlagReg
                            obj.startOutFlag(:)=false;
                            obj.countIntermedBuffElem(:)=0;
                            obj.countVecElem(:)=0;
                            obj.buffVec2(:)=0;
                            if(strcmpi(obj.DecisionType,'Approximate log-likelihood ratio')&&obj.EnbNoiseVar)
                                obj.nVarVec(:)=1;
                            end
                        end
                        obj.dataOut(:)=0;
                        obj.ctrlOut(:)=struct('start',false,'end',false,'valid',false);
                    end
                else
                    obj.dataOut(:)=0;
                    obj.ctrlOut(:)=struct('start',false,'end',false,'valid',false);
                end
            else
                if obj.outputReadyFlag
                    if(strcmpi(obj.DecisionType,'Approximate log-likelihood ratio')&&obj.EnbNoiseVar)
                        oneByNvar=obj.numeratorOne(:)/obj.nVarVec(obj.countVecElem(:)+1);
                        obj.dataOutDelay(:)=obj.buffVec2(obj.countVecElem(:)+1)*oneByNvar;
                    else
                        obj.dataOutDelay(:)=obj.buffVec2(obj.countVecElem(:)+1);
                    end
                    scalarValidOutDelay=true;
                    obj.countVecElem(:)=obj.countVecElem(:)+1;
                    if(obj.countVecElem(:)==obj.bitsPerSymReg)
                        obj.outputReadyFlag(:)=false;
                        obj.countVecElem(:)=0;
                    end
                else
                    obj.dataOut(:)=0;
                    scalarValidOutDelay=false;
                end
            end

            obj.dataOut(:)=obj.delayBalDataOut(obj.dataOutDelay);
            obj.dataOutDelay(:)=0;
            obj.ctrlOut.start(:)=obj.delayBalStartOut(startOutDelay);
            obj.ctrlOut.end(:)=obj.delayBalEndOut(endOutDelay);
            obj.ctrlOut.valid(:)=obj.delayBalValidOut(validOutDelay);
            obj.scalarValidOut(:)=obj.delayBalScalarValidOut(scalarValidOutDelay);
        end




        function num=getNumInputsImpl(obj)
            num=2;
            if strcmpi(obj.ModulationSourceParams,'Input port')
                num=num+2;
            end
            if obj.EnbNoiseVar&&strcmpi(obj.DecisionType,'Approximate log-likelihood ratio')
                num=num+1;
            end
        end



        function num=getNumOutputsImpl(obj)
            num=2;
            if strcmpi(obj.OutputType,'Scalar')
                num=num+1;
            end
        end



        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='data';
            if strcmpi(obj.OutputType,'Scalar')
                varargout{2}='valid';
            else
                varargout{2}='ctrl';
            end
            varargoutInd=2;
            if strcmpi(obj.ModulationSourceParams,'Input port')
                varargoutInd=varargoutInd+1;
                varargout{varargoutInd}='modIdx';
                varargoutInd=varargoutInd+1;
                varargout{varargoutInd}='codeRateIdx';
            end
            if obj.EnbNoiseVar&&strcmpi(obj.DecisionType,'Approximate log-likelihood ratio')
                varargoutInd=varargoutInd+1;
                varargout{varargoutInd}='nVar';
            end
        end

        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='data';
            if strcmpi(obj.OutputType,'Scalar')
                varargout{2}='valid';
                varargout{3}='ready';
            else
                varargout{2}='ctrl';
            end
        end


        function validatePropertiesImpl(obj)
            if strcmpi(obj.ModulationScheme,'32-APSK')&&...
                strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.CodeRateAPSK,'2/3')
                coder.internal.error('whdl:DVBS2SymbolDemodulator:InvalidCodeRate32APSK');
            end
        end

        function validateInputsImpl(obj,varargin)
            coder.extrinsic('tostringInternalSlName');
            if isempty(coder.target)||~coder.internal.isAmbiguousTypes

                validateattributes(varargin{1},...
                {'single','double','embedded.fi','int8','int16','int32'},{'scalar'},'DVBS2SymbolDemodulator','data');
                if isa(varargin{1},'embedded.fi')
                    [WL,~,~]=dsphdlshared.hdlgetwordsizefromdata(varargin{1});
                    if(~issigned(varargin{1}))
                        coder.internal.error('whdl:DVBS2SymbolDemodulator:InvalidDataType');
                    end
                    if WL>32
                        coder.internal.error('whdl:DVBS2SymbolDemodulator:InvalidWordLength');
                    end
                end

                if~strcmpi(obj.OutputType,'Scalar')
                    ctrlIn=varargin{2};
                    if~isstruct(ctrlIn)
                        coder.internal.error('whdl:DVBS2SymbolDemodulator:InvalidSampleCtrlBus');
                    end

                    ctrlNames=fieldnames(ctrlIn);
                    if~isequal(numel(ctrlNames),3)
                        coder.internal.error('whdl:DVBS2SymbolDemodulator:InvalidSampleCtrlBus');
                    end

                    if isfield(ctrlIn,ctrlNames{1})&&strcmp(ctrlNames{1},'start')
                        validateattributes(ctrlIn.start,{'logical'},...
                        {'scalar'},'DVBS2SymbolDemodulator','start');
                    else
                        coder.internal.error('whdl:DVBS2SymbolDemodulator:InvalidSampleCtrlBus');
                    end

                    if isfield(ctrlIn,ctrlNames{2})&&strcmp(ctrlNames{2},'end')
                        validateattributes(ctrlIn.end,{'logical'},...
                        {'scalar'},'DVBS2SymbolDemodulator','end');
                    else
                        coder.internal.error('whdl:DVBS2SymbolDemodulator:InvalidSampleCtrlBus');
                    end

                    if isfield(ctrlIn,ctrlNames{3})&&strcmp(ctrlNames{3},'valid')
                        validateattributes(ctrlIn.valid,{'logical'},...
                        {'scalar'},'DVBS2SymbolDemodulator','valid');
                    else
                        coder.internal.error('whdl:DVBS2SymbolDemodulator:InvalidSampleCtrlBus');
                    end
                else
                    validateattributes(varargin{2},{'logical'},{'scalar'},...
                    'DVBS2SymbolDemodulator','valid');
                end


                if obj.EnbNoiseVar&&strcmpi(obj.DecisionType,'Approximate log-likelihood ratio')
                    dIn=varargin{1};
                    if strcmpi(obj.ModulationSourceParams,'Input Port')
                        nVarDT=varargin{5};
                    else
                        nVarDT=varargin{3};
                    end
                    validateattributes(nVarDT,{'double','single','embedded.fi','uint16','uint8'},...
                    {'scalar','real','nonnegative'},'DVBS2SymbolDemodulator','nVar');
                    if~isfloat(dIn)&&isfloat(nVarDT)
                        coder.internal.error('whdl:DVBS2SymbolDemodulator:dataNVarFloatFixMix');
                    elseif isfloat(dIn)&&~isfloat(nVarDT)
                        coder.internal.error('whdl:DVBS2SymbolDemodulator:dataNVarFloatFixMix');
                    else
                        if isa(nVarDT,'embedded.fi')
                            [WLnVar,FLnVar,signedBitnVar]=dsphdlshared.hdlgetwordsizefromdata(nVarDT);
                            if(isa(nVarDT,'embedded.fi')&&signedBitnVar)||...
                                (isa(nVarDT,'embedded.fi')&&(WLnVar>16))||...
                                (isa(nVarDT,'embedded.fi')&&(FLnVar>WLnVar))
                                coder.internal.error('whdl:DVBS2SymbolDemodulator:InvalidnVarDatatype');
                            end
                        end
                    end
                end


                if strcmpi(obj.ModulationSourceParams,'Input Port')


                    if isa(varargin{3},'uint8')||isa(varargin{3},'int8')||isa(varargin{3},'uint16')||isa(varargin{3},'int16')||...
                        isa(varargin{3},'uint32')||isa(varargin{3},'int32')||isa(varargin{3},'logical')
                        coder.internal.error('whdl:DVBS2SymbolDemodulator:InvalidModIdxType');
                    end

                    if isa(varargin{3},'embedded.fi')
                        [WL,FL,~]=dsphdlshared.hdlgetwordsizefromdata(varargin{3});
                        errCond=~((WL==3)&&(FL==0)&&~issigned(varargin{3}));
                        if(errCond)
                            coder.internal.error('whdl:DVBS2SymbolDemodulator:InvalidModIdxType');
                        end
                    end

                    validateattributes(varargin{3},{'double','single','embedded.fi'},...
                    {'real','scalar'},'DVBS2SymbolDemodulator','modIdx');



                    if isa(varargin{4},'uint8')||isa(varargin{4},'int8')||isa(varargin{4},'uint16')||isa(varargin{4},'int16')||...
                        isa(varargin{4},'uint32')||isa(varargin{4},'int32')||isa(varargin{4},'logical')
                        coder.internal.error('whdl:DVBS2SymbolDemodulator:InvalidCodeRateIdxType');
                    end

                    if isa(varargin{4},'embedded.fi')
                        [WL,FL,~]=dsphdlshared.hdlgetwordsizefromdata(varargin{4});
                        errCond=~((WL==4)&&(FL==0)&&~issigned(varargin{4}));
                        if(errCond)
                            coder.internal.error('whdl:DVBS2SymbolDemodulator:InvalidCodeRateIdxType');
                        end
                    end

                    validateattributes(varargin{4},{'double','single','embedded.fi'},...
                    {'real','scalar'},'DVBS2SymbolDemodulator','codeRateIdx');

                end
            end
        end




        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if(~strcmpi(obj.ModulationSourceParams,'Property'))
                props=[props,{'ModulationScheme'},{'CodeRateAPSK'}];
            else
                props=[props];
            end
            if(strcmpi(obj.ModulationSourceParams,'Property')&&...
                ~strcmpi(obj.ModulationScheme,'16-APSK')&&...
                ~strcmpi(obj.ModulationScheme,'32-APSK'))
                props=[props,{'UnitAveragePower'},{'CodeRateAPSK'}];
            else
                props=[props];
            end
            if(~strcmpi(obj.DecisionType,'Approximate log-likelihood ratio'))
                props=[props,{'EnbNoiseVar'}];
            else
                props=[props];
            end
            flag=ismember(prop,props);
        end

        function numBitsPerSym=calBitsPerSym(obj)
            if(obj.modIndx==0)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.ModulationScheme,'QPSK'))
                numBitsPerSym=fi(2,0,3,0,hdlfimath);
            elseif(obj.modIndx==1)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.ModulationScheme,'8-PSK'))
                numBitsPerSym=fi(3,0,3,0,hdlfimath);
            elseif(obj.modIndx==2)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.ModulationScheme,'16-APSK'))
                numBitsPerSym=fi(4,0,3,0,hdlfimath);
            elseif(obj.modIndx==3)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.ModulationScheme,'32-APSK'))
                numBitsPerSym=fi(5,0,3,0,hdlfimath);
            elseif(obj.modIndx==4)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.ModulationScheme,'pi/2-BPSK'))
                numBitsPerSym=fi(1,0,3,0,hdlfimath);
            else
                numBitsPerSym=fi(2,0,3,0,hdlfimath);
            end
        end

        function obj=bitsPerSymCounter(obj)
            obj.countBitsPerSym(:)=obj.countBitsPerSym+fi(1,0,1,0,hdlfimath);
        end

        function obj=calCodeRateIndex(obj)
            if(obj.codeRateIndx==5)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.CodeRateAPSK,'2/3'))
                if(obj.modIndx==3)&&(~strcmpi(obj.ModulationSourceParams,'Property'))
                    obj.lutIdx(:)=fi(2,0,3,0,hdlfimath);
                else
                    obj.lutIdx(:)=fi(1,0,3,0,hdlfimath);
                end
            elseif(obj.codeRateIndx==6)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.CodeRateAPSK,'3/4'))
                obj.lutIdx(:)=fi(2,0,3,0,hdlfimath);
            elseif(obj.codeRateIndx==7)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.CodeRateAPSK,'4/5'))
                obj.lutIdx(:)=fi(3,0,3,0,hdlfimath);
            elseif(obj.codeRateIndx==8)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.CodeRateAPSK,'5/6'))
                obj.lutIdx(:)=fi(4,0,3,0,hdlfimath);
            elseif(obj.codeRateIndx==9)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.CodeRateAPSK,'8/9'))
                obj.lutIdx(:)=fi(5,0,3,0,hdlfimath);
            elseif(obj.codeRateIndx==10)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.CodeRateAPSK,'9/10'))
                obj.lutIdx(:)=fi(6,0,3,0,hdlfimath);
            else
                obj.lutIdx(:)=fi(2,0,3,0,hdlfimath);
            end
        end

        function validateNoiseVarValue(obj)
            if obj.nVarReg==0
                if~isfloat(obj.nVarReg)
                    if obj.nVarZeroWarningFlag
                        coder.internal.warning('whdl:DVBS2SymbolDemodulator:InvalidnVarValFixPt');
                        obj.nVarZeroWarningFlag=false;
                    end
                    if isa(obj.nVarReg,'uint8')
                        obj.nVarReg(:)=obj.validNVarValuesLUT(1);
                    elseif isa(obj.nVarReg,'uint16')
                        obj.nVarReg(:)=obj.validNVarValuesLUT(1);
                    else
                        obj.nVarReg(:)=obj.validNVarValuesLUT(obj.nVarReg.FractionLength+1);
                    end
                else
                    if isa(obj.nVarReg,'double')
                        if obj.nVarZeroWarningFlag
                            coder.internal.warning('whdl:DVBS2SymbolDemodulator:InvalidnVarValDouble');
                            obj.nVarZeroWarningFlag=false;
                        end
                        obj.nVarReg(:)=obj.validNVarValuesLUT(17);
                    else
                        if obj.nVarZeroWarningFlag
                            coder.internal.warning('whdl:DVBS2SymbolDemodulator:InvalidnVarValSingle');
                            obj.nVarZeroWarningFlag=false;
                        end
                        obj.nVarReg(:)=obj.validNVarValuesLUT(12);
                    end
                end
            end
        end


        function obj=fillVectorBuff1(obj)
            dataInReg=obj.dataIn(:);
            dataCtrlInpValid=(obj.ctrl.valid&&obj.startInFlag)||obj.scalarValid;
            evenFlag=obj.evenSymFlag;
            bitsPerSymb=obj.bitsPerSym;
            lutIndex=obj.lutIdx;


            if obj.evenSymFlag
                [buffVecPiBy2BPSK,validOutPiBy2BPSK]=obj.SymDemodPiBy2BPSKObj(dataInReg,dataCtrlInpValid,evenFlag,bitsPerSymb);
                if dataCtrlInpValid
                    obj.evenSymFlag(:)=false;
                end
            else
                [buffVecPiBy2BPSK,validOutPiBy2BPSK]=obj.SymDemodPiBy2BPSKObj(dataInReg,dataCtrlInpValid,evenFlag,bitsPerSymb);
                if dataCtrlInpValid
                    obj.evenSymFlag(:)=true;
                end
            end

            [buffVecQPSK,validOutQPSK]=obj.SymDemodQPSKObj(dataInReg,dataCtrlInpValid,bitsPerSymb);

            [buffVec8PSK,validOut8PSK]=obj.SymDemod8PSKObj(dataInReg,dataCtrlInpValid,bitsPerSymb);

            [buffVec16APSK,validOut16APSK]=obj.SymDemod16APSKObj(dataInReg,dataCtrlInpValid,bitsPerSymb,lutIndex);

            [buffVec32APSK,validOut32APSK]=obj.SymDemod32APSKObj(dataInReg,dataCtrlInpValid,bitsPerSymb,lutIndex-1);

            switch obj.bitsPerSymReg
            case 1
                obj.buffVec1(:)=buffVecPiBy2BPSK;
                obj.validOut(:)=validOutPiBy2BPSK;
            case 2
                obj.buffVec1(:)=buffVecQPSK;
                obj.validOut(:)=validOutQPSK;
            case 3
                obj.buffVec1(:)=buffVec8PSK;
                obj.validOut(:)=validOut8PSK;
            case 4
                obj.buffVec1(:)=buffVec16APSK;
                obj.validOut(:)=validOut16APSK;
            case 5
                obj.buffVec1(:)=buffVec32APSK;
                obj.validOut(:)=validOut32APSK;
            end
        end

        function obj=copyBuff1ToBuff2(obj)
            if(~strcmpi(obj.OutputType,'Scalar'))
                for count=1:obj.vectorSize
                    if(count<=obj.countIntermedBuffElem)

                        obj.buffVec2(obj.countVecElem+count)=obj.intermedBuff(count);
                        if(strcmpi(obj.DecisionType,'Approximate log-likelihood ratio')&&obj.EnbNoiseVar)
                            obj.nVarVec(obj.countVecElem+count)=obj.intermedNVarBuff(count);
                        end
                    else
                        if(count<=obj.countIntermedBuffElem+obj.bitsPerSymReg)
                            if(obj.countVecElem+count<=obj.vectorSize)
                                obj.buffVec2(obj.countVecElem+count)=obj.buffVec1(count-obj.countIntermedBuffElem);
                                if(strcmpi(obj.DecisionType,'Approximate log-likelihood ratio')&&obj.EnbNoiseVar)
                                    obj.nVarVec(obj.countVecElem+count)=obj.nVar;
                                end
                            end
                        end
                    end
                end

                if obj.countIntermedBuffElem==0
                    if obj.vectorSize>(obj.bitsPerSymReg+obj.countVecElem)
                        obj.countVecElem(:)=obj.bitsPerSymReg+obj.countVecElem;
                    else
                        obj.idx(:)=obj.vectorSize-obj.countVecElem;
                        obj.countVecElem(:)=obj.vectorSize;
                    end
                else
                    if obj.vectorSize>(obj.bitsPerSymReg+obj.countIntermedBuffElem)
                        obj.countVecElem(:)=obj.bitsPerSymReg+obj.countIntermedBuffElem;
                    else
                        obj.idx(:)=obj.vectorSize-obj.countIntermedBuffElem;
                        obj.countVecElem(:)=obj.vectorSize;
                    end
                end
                obj.countIntermedBuffElem(:)=0;
                obj.intermedBuff(:)=0;
                if(strcmpi(obj.DecisionType,'Approximate log-likelihood ratio')&&obj.EnbNoiseVar)
                    obj.intermedNVarBuff(:)=1;
                end
                indx=fi(0,0,4,0,hdlfimath);
                for count=1:obj.vectorSize
                    if(count<=obj.bitsPerSymReg)
                        if(count>obj.idx)
                            if(obj.countVecElem==obj.vectorSize)
                                obj.intermedBuff(indx+1)=obj.buffVec1(count);
                                if(strcmpi(obj.DecisionType,'Approximate log-likelihood ratio')&&obj.EnbNoiseVar)
                                    obj.intermedNVarBuff(indx+1)=obj.nVar;
                                end
                                indx(:)=indx+1;
                            end
                        end
                    end
                end

                if(obj.countVecElem==obj.vectorSize)
                    obj.countIntermedBuffElem(:)=indx;
                end
            else
                for count=1:obj.bitsPerSymReg
                    obj.buffVec2(count)=obj.buffVec1(count);
                    if(strcmpi(obj.DecisionType,'Approximate log-likelihood ratio')&&obj.EnbNoiseVar)
                        obj.nVarVec(count)=obj.nVar;
                    end
                end
            end
            obj.buffVec1(:)=0;
        end





        function varargout=getOutputDataTypeImpl(obj,varargin)
            if(strcmp(obj.DecisionType,'Hard'))
                if strcmpi(obj.OutputType,'Scalar')
                    varargout={'logical','logical','logical'};
                else
                    varargout={'logical',samplecontrolbustype};
                end
            else
                inputDT=propagatedInputDataType(obj,1);
                if~obj.EnbNoiseVar
                    bGWLMul=3;
                else
                    bGWLMul=14;
                end
                if isnumerictype(inputDT)||isfi(inputDT)
                    outputDT=numerictype(1,inputDT.WordLength+bGWLMul,inputDT.FractionLength);
                elseif strcmpi(inputDT,'int8')
                    outputDT=numerictype(1,8+bGWLMul,0);
                elseif strcmpi(inputDT,'int16')
                    outputDT=numerictype(1,16+bGWLMul,0);
                elseif strcmpi(inputDT,'int32')
                    outputDT=numerictype(1,32+bGWLMul,0);
                else
                    outputDT=inputDT;
                end
                if strcmpi(obj.OutputType,'Scalar')
                    varargout={outputDT,'logical','logical'};
                else
                    varargout={outputDT,samplecontrolbustype};
                end
            end
        end



        function varargout=isOutputComplexImpl(obj)
            if strcmpi(obj.OutputType,'Scalar')
                varargout={false,false,false};
            else
                varargout={false,false};
            end
        end



        function varargout=getOutputSizeImpl(obj)
            if strcmpi(obj.OutputType,'vector')
                varargout{1}=[8,1];
            else
                varargout{1}=[1,1];
            end
            varargout{2}=[1,1];
            varargout{3}=[1,1];
            if strcmpi(obj.OutputType,'vector')
                varargout{4}=[1,1];
            end
        end



        function varargout=isOutputFixedSizeImpl(obj)
            if strcmpi(obj.OutputType,'vector')
                varargout={true,true};
            else
                varargout={true,true,true};
            end
        end



        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.dataIn=obj.dataIn;
                s.dataOutDelay=obj.dataOutDelay;
                s.dataOut=obj.dataOut;
                s.dataInReal=obj.dataInReal;
                s.dataInImag=obj.dataInImag;
                s.ctrl=obj.ctrl;
                s.ctrlOut=obj.ctrlOut;
                s.startInFlag=obj.startInFlag;
                s.endInFlag=obj.endInFlag;
                s.endInFlagReg=obj.endInFlagReg;
                s.startOutFlag=obj.startOutFlag;
                s.vectorSize=obj.vectorSize;
                s.buffVec1=obj.buffVec1;
                s.bitsPerSym=obj.bitsPerSym;
                s.lutIdx=obj.lutIdx;
                s.bitsPerSymReg=obj.bitsPerSymReg;
                s.countIntermedBuffElem=obj.countIntermedBuffElem;
                s.countSym=obj.countSym;
                s.buffVec2=obj.buffVec2;
                s.intermedBuff=obj.intermedBuff;
                s.intermedNVarBuff=obj.intermedNVarBuff;
                s.nVarVec=obj.nVarVec;
                s.nVar=obj.nVar;
                s.nVarReg=obj.nVarReg;
                s.evenSymFlag=obj.evenSymFlag;
                s.modIndx=obj.modIndx;
                s.codeRateIndx=obj.codeRateIndx;
                s.idx=obj.idx;
                s.validOut=obj.validOut;
                s.readyReg=obj.readyReg;
                s.countBitsPerSym=obj.countBitsPerSym;
                s.numBitsPerSym=obj.numBitsPerSym;
                s.inputReceiveFlag=obj.inputReceiveFlag;
                s.scalarValid=obj.scalarValid;
                s.scalarValidOut=obj.scalarValidOut;
                s.outputReadyFlag=obj.outputReadyFlag;
                s.delayBalDataOut=obj.delayBalDataOut;
                s.delayBalStartOut=obj.delayBalStartOut;
                s.delayBalEndOut=obj.delayBalEndOut;
                s.delayBalValidOut=obj.delayBalValidOut;
                s.SymDemodPiBy2BPSKObj=obj.SymDemodPiBy2BPSKObj;
                s.SymDemodQPSKObj=obj.SymDemodQPSKObj;
                s.SymDemod8PSKObj=obj.SymDemod8PSKObj;
                s.SymDemod16APSKObj=obj.SymDemod16APSKObj;
                s.SymDemod32APSKObj=obj.SymDemod32APSKObj;
                s.delayBalScalarValidOut=obj.delayBalScalarValidOut;
                s.countVecElem=obj.countVecElem;
                s.numeratorOne=obj.numeratorOne;
                s.validNVarValuesLUT=obj.validNVarValuesLUT;
                s.nVarZeroWarningFlag=obj.nVarZeroWarningFlag;
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