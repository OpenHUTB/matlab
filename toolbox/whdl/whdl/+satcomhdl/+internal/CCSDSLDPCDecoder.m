classdef(StrictDefaults)CCSDSLDPCDecoder<matlab.System







%#codegen


    properties(Nontunable)


        LDPCConfiguration='(8160,7136) LDPC'


        Termination='Max';


        SpecifyInputs='Property'


        NumIterations=8;


        MaxNumIterations=8;
    end

    properties(Nontunable)

        ParityCheckStatus(1,1)logical=false;
    end

    properties(Constant,Hidden)
        LDPCConfigurationSet=matlab.system.StringSet({'(8160,7136) LDPC','AR4JA LDPC'});
        SpecifyInputsSet=matlab.system.StringSet({'Input port','Property'});
        TerminationSet=matlab.system.StringSet({'Max','Early'});
    end

    properties(Access=private,Nontunable)
        scalarFlag;
        vectorSize;
        alphaWL;
        alphaFL;
        betaWL;
        minWL;
        betaCompWL;
        betaIdxWL;
    end


    properties(Access=private)

        codeParameters;
        ldpcDecoderCore;


        blockLen;
        codeRate;
        numIter;
        endInd;
        frameValid;
        invalidBlockLength;
        invalidCodeRate;
        maxCount;
        countData;
        invalidLength;
        blkLenLUT;
        ctrlOutReg;


        dataOut;
        ctrlOut;
        iterOut;
        parCheck;
        nextFrame;
    end

    methods


        function obj=CCSDSLDPCDecoder(varargin)
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

        function set.NumIterations(obj,val)
            validateattributes(val,{'double'},{'scalar','integer'},'CCSDSLDPCDecoder','Number of iterations');
            coder.internal.errorIf(~(val>=1&&val<=63),...
            'whdl:CCSDSLDPCDecoder:InvalidNumIterations');
            obj.NumIterations=val;
        end

        function set.MaxNumIterations(obj,val)
            validateattributes(val,{'double'},{'scalar','integer'},'CCSDSLDPCDecoder','Maximum number of iterations');
            coder.internal.errorIf(~(val>=1&&val<=63),...
            'whdl:CCSDSLDPCDecoder:InvalidMaxNumIterations');
            obj.MaxNumIterations=val;
        end

    end

    methods(Static,Access=protected)

        function header=getHeaderImpl
            text=[...
'Decode low-density parity-check (LDPC) code according to CCSDS Telemetry standard.'...
            ,newline...
            ,newline...
            ,'The block supports scalar and vector inputs of size 8 and uses layered '...
            ,'belief propagation with Min-sum approximation algorithm.'
            ];

            header=matlab.system.display.Header('satcomhdl.internal.CCSDSLDPCDecoder',...
            'Title','CCSDS LDPC Decoder',...
            'Text',text,...
            'ShowSourceLink',false);
        end

        function groups=getPropertyGroupsImpl
            struc=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'LDPCConfiguration','Termination','SpecifyInputs','NumIterations','MaxNumIterations','ParityCheckStatus'});

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
            icon=sprintf('CCSDS LDPC Decoder');
        end

        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

        function resetImpl(obj)

            reset(obj.codeParameters);
            reset(obj.ldpcDecoderCore);

            obj.dataOut(:)=zeros(obj.vectorSize,1);
            obj.ctrlOut(:)=struct('start',false,'end',false,'valid',false);
            obj.iterOut(:)=uint8(0);
            obj.parCheck(:)=false;
            obj.nextFrame(:)=true;
        end

        function setupImpl(obj,varargin)

            obj.scalarFlag=isscalar(varargin{1});
            if obj.scalarFlag
                obj.vectorSize=1;
            else
                obj.vectorSize=8;
            end

            if isa(varargin{1},'int8')
                WL=8;
                obj.alphaFL=0;
            elseif isa(varargin{1},'int16')
                WL=16;
                obj.alphaFL=0;
            elseif isa(varargin{1},'embedded.fi')
                WL=varargin{1}.WordLength;
                obj.alphaFL=varargin{1}.FractionLength;
            else
                WL=4;
                obj.alphaFL=0;
            end

            intwl=WL-obj.alphaFL;
            obj.alphaWL=intwl+2+obj.alphaFL;
            obj.betaWL=intwl+obj.alphaFL;
            obj.minWL=intwl-1+obj.alphaFL;

            if strcmpi(obj.LDPCConfiguration,'(8160,7136) LDPC')
                obj.betaCompWL=32;
                obj.betaIdxWL=8;
            else
                obj.betaCompWL=31;
                obj.betaIdxWL=7;
            end



            obj.codeParameters=satcomhdl.internal.CCSDSLDPCCodeParameters('LDPCConfiguration',obj.LDPCConfiguration);


            obj.ldpcDecoderCore=satcomhdl.internal.CCSDSLDPCDecoderCore('LDPCConfiguration',obj.LDPCConfiguration,...
            'Termination',obj.Termination,'alphaWL',obj.alphaWL,'alphaFL',obj.alphaFL,'betaWL',obj.betaWL,...
            'minWL',obj.minWL,'betaCompWL',obj.betaCompWL,'betaIdxWL',obj.betaIdxWL,...
            'ParityCheckStatus',obj.ParityCheckStatus);

            obj.blockLen=fi(0,0,2,0);
            obj.codeRate=fi(0,0,2,0);
            obj.numIter=uint8(8);
            obj.endInd=false;
            obj.frameValid=false;
            obj.invalidBlockLength=false;
            obj.invalidCodeRate=false;
            obj.maxCount=fi(1,0,16,0);
            obj.countData=fi(1,0,16,0);
            obj.invalidLength=false;
            obj.ctrlOutReg=struct('start',false,'end',false,'valid',false);


            obj.dataOut=zeros(obj.vectorSize,1)>0;
            obj.parCheck=false;
            obj.nextFrame=true;
            obj.ctrlOut=struct('start',false,'end',false,'valid',false);
            obj.iterOut=uint8(0);

            if strcmpi(obj.LDPCConfiguration,'(8160,7136) LDPC')
                obj.blkLenLUT=8160/obj.vectorSize;
            else
                obj.blkLenLUT=[2048,1536,1280,1280,8192,6144,5120,5120...
                ,32768,24576,20480,20480,1280,5120,20480,20480]/obj.vectorSize;
            end

        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.dataOut;
            varargout{2}=obj.ctrlOut;
            if strcmpi(obj.Termination,'Early')
                varargout{3}=obj.iterOut;
                if obj.ParityCheckStatus
                    varargout{4}=obj.parCheck;
                    varargout{5}=obj.nextFrame;
                else
                    varargout{4}=obj.nextFrame;
                end
            else
                if obj.ParityCheckStatus
                    varargout{3}=obj.parCheck;
                    varargout{4}=obj.nextFrame;
                else
                    varargout{3}=obj.nextFrame;
                end
            end
        end

        function updateImpl(obj,varargin)
            datain=varargin{1};
            ctrlin=varargin{2};


            if strcmpi(obj.LDPCConfiguration,'AR4JA LDPC')
                blocklen=varargin{3};
                rate=varargin{4};
                if ctrlin.start&&ctrlin.valid
                    obj.blockLen(:)=blocklen;
                    obj.codeRate(:)=rate;

                    if obj.blockLen==fi(3,0,2,0)
                        obj.invalidBlockLength(:)=true;
                        obj.blockLen(:)=0;
                        if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                            coder.internal.warning('whdl:CCSDSLDPCDecoder:InvalidBlockLengthIdx');
                        end
                    else
                        obj.invalidBlockLength(:)=false;
                    end

                    if obj.codeRate==fi(3,0,2,0)
                        obj.invalidCodeRate(:)=true;
                        obj.codeRate(:)=0;
                        if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                            coder.internal.warning('whdl:CCSDSLDPCDecoder:InvalidCodeRateIdx');
                        end
                    else
                        obj.invalidCodeRate(:)=false;
                    end
                end
            end

            if strcmpi(obj.SpecifyInputs,'Input port')
                if strcmpi(obj.LDPCConfiguration,'AR4JA LDPC')
                    iterin=varargin{5};
                else
                    iterin=varargin{3};
                end
                if ctrlin.start&&ctrlin.valid

                    if(iterin>63)||(iterin<1)
                        obj.numIter(:)=8;
                        if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                            coder.internal.warning('whdl:CCSDSLDPCDecoder:InvalidNumIter');
                        end
                    else
                        obj.numIter(:)=iterin;
                    end
                end
            else
                if(strcmpi(obj.Termination,'Early'))
                    obj.numIter(:)=obj.MaxNumIterations;
                else
                    obj.numIter(:)=obj.NumIterations;
                end
            end


            [data_cp,valid_cp,framevalid_cp,reset,endind]=obj.codeParameters(datain,ctrlin,obj.nextFrame);

            data_core=fi(data_cp,1,obj.alphaWL,obj.alphaFL);
            fvalid_core=~framevalid_cp;
            softreset=endind&&~(obj.endInd);
            obj.endInd(:)=endind;


            if strcmpi(obj.LDPCConfiguration,'(8160,7136) LDPC')
                obj.maxCount(:)=obj.blkLenLUT;
            else
                obj.maxCount(:)=obj.blkLenLUT(bitconcat(obj.blockLen,obj.codeRate)+1);
            end
            endvalid=ctrlin.end&&ctrlin.valid&&obj.frameValid;

            if ctrlin.start&&ctrlin.valid
                obj.frameValid(:)=true;
                obj.countData(:)=0;
                obj.invalidLength(:)=false;
            elseif endvalid
                obj.frameValid(:)=false;
            end


            if endvalid&&~obj.nextFrame
                if(~obj.invalidCodeRate&&~obj.invalidBlockLength)
                    if obj.countData~=obj.maxCount-1
                        obj.invalidLength(:)=true;
                        if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                            coder.internal.warning('whdl:CCSDSLDPCDecoder:InvalidInputLength');
                        end
                    else
                        obj.invalidLength(:)=false;
                    end
                end
            end

            validframe=(obj.frameValid&&ctrlin.valid);

            if(validframe)
                obj.countData(:)=obj.countData+fi(1,0,1,0,hdlfimath);
            end

            core_reset=reset||obj.nextFrame;


            [data_out,ctrl_out,iter_out,parcheck_out]=obj.ldpcDecoderCore(data_core,valid_cp,...
            fvalid_core,core_reset,softreset,obj.numIter,obj.blockLen,obj.codeRate);

            if obj.nextFrame||obj.frameValid
                obj.dataOut(:)=zeros(obj.vectorSize,1)>0;
                obj.ctrlOut(:)=struct('start',false,'end',false,'valid',false);
                obj.iterOut(:)=uint8(0);
                obj.parCheck(:)=false;
            else
                obj.dataOut(:)=data_out;
                obj.ctrlOut(:)=ctrl_out;
                obj.parCheck(:)=parcheck_out;
                obj.iterOut(:)=iter_out;
            end


            if ctrlin.start&&ctrlin.valid
                obj.nextFrame(:)=false;
            elseif((obj.ctrlOutReg.end&&obj.ctrlOutReg.valid)||...
                ((obj.invalidCodeRate||obj.invalidLength||obj.invalidBlockLength)&&(ctrlin.end&&ctrlin.valid)))
                obj.nextFrame(:)=true;
            end
            obj.ctrlOutReg(:)=obj.ctrlOut;
        end

        function num=getNumInputsImpl(obj)
            if strcmpi(obj.LDPCConfiguration,'(8160,7136) LDPC')
                num=2;
            else
                num=4;
            end
            if strcmpi(obj.SpecifyInputs,'Input port')
                num=num+1;
            end
        end

        function num=getNumOutputsImpl(obj)
            if strcmpi(obj.Termination,'Early')
                num=4;
            else
                num=3;
            end
            if obj.ParityCheckStatus
                num=num+1;
            end
        end

        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='data';
            varargout{2}='ctrl';
            if strcmpi(obj.LDPCConfiguration,'AR4JA LDPC')
                varargout{3}='blkLenIdx';
                varargout{4}='codeRateIdx';
                if strcmpi(obj.SpecifyInputs,'Input port')
                    varargout{5}='iter';
                end
            else
                if strcmpi(obj.SpecifyInputs,'Input port')
                    varargout{3}='iter';
                end
            end
        end

        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='data';
            varargout{2}='ctrl';
            if(strcmpi(obj.Termination,'Early'))
                varargout{3}='actIter';
                if obj.ParityCheckStatus
                    varargout{4}='parityCheck';
                    varargout{5}='nextFrame';
                else
                    varargout{4}='nextFrame';
                end
            else
                if obj.ParityCheckStatus
                    varargout{3}='parityCheck';
                    varargout{4}='nextFrame';
                else
                    varargout{3}='nextFrame';
                end
            end
        end

        function validateInputsImpl(obj,varargin)
            if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                datain=varargin{1};
                if isscalar(datain)
                    validateattributes(datain,{'embedded.fi','int8','int16'},{'scalar','real'},'CCSDSLDPCDecoder','data');
                else
                    if(length(datain)~=8)
                        coder.internal.error('whdl:CCSDSLDPCDecoder:InvalidVecLength');
                    end
                    validateattributes(datain,{'embedded.fi','int8','int16'},{'vector','real'},'CCSDSLDPCDecoder','data');
                end


                if isa(datain,'embedded.fi')
                    if~(issigned(datain))
                        coder.internal.error('whdl:CCSDSLDPCDecoder:InvalidSignedType');
                    end
                    maxWordLength=16;
                    minWordLength=4;
                    coder.internal.errorIf(...
                    ((datain.WordLength>maxWordLength)||(datain.WordLength<minWordLength)),...
                    'whdl:CCSDSLDPCDecoder:InvalidInputWordLength');
                end
                ctrlIn=varargin{2};
                if~isstruct(ctrlIn)
                    coder.internal.error('whdl:CCSDSLDPCDecoder:InvalidSampleCtrlBus');
                end

                ctrlNames=fieldnames(ctrlIn);
                if~isequal(numel(ctrlNames),3)
                    coder.internal.error('whdl:CCSDSLDPCDecoder:InvalidSampleCtrlBus');
                end

                if isfield(ctrlIn,ctrlNames{1})&&strcmp(ctrlNames{1},'start')
                    validateattributes(ctrlIn.start,{'logical'},...
                    {'scalar'},'CCSDSLDPCDecoder','start');
                else
                    coder.internal.error('whdl:CCSDSLDPCDecoder:InvalidSampleCtrlBus');
                end

                if isfield(ctrlIn,ctrlNames{2})&&strcmp(ctrlNames{2},'end')
                    validateattributes(ctrlIn.end,{'logical'},...
                    {'scalar'},'CCSDSLDPCDecoder','end');
                else
                    coder.internal.error('whdl:CCSDSLDPCDecoder:InvalidSampleCtrlBus');
                end

                if isfield(ctrlIn,ctrlNames{3})&&strcmp(ctrlNames{3},'valid')
                    validateattributes(ctrlIn.valid,{'logical'},...
                    {'scalar'},'CCSDSLDPCDecoder','valid');
                else
                    coder.internal.error('whdl:CCSDSLDPCDecoder:InvalidSampleCtrlBus');
                end

                if strcmpi(obj.LDPCConfiguration,'AR4JA LDPC')
                    lenidx=varargin{3};
                    rateidx=varargin{4};
                    validateattributes(lenidx,{'embedded.fi'},{'scalar','real'},'CCSDSLDPCDecoder','blkLenIdx');
                    validateattributes(rateidx,{'embedded.fi'},{'scalar','real'},'CCSDSLDPCDecoder','codeRateIdx');
                    if isa(lenidx,'embedded.fi')
                        if(issigned(lenidx))
                            coder.internal.error('whdl:CCSDSLDPCDecoder:InvalidBlockLengthUnsignedType');
                        end
                        coder.internal.errorIf(...
                        ~((lenidx.WordLength==2)&&(lenidx.FractionLength==0)),...
                        'whdl:CCSDSLDPCDecoder:InvalidBlockLengthType');
                    end
                    if isa(rateidx,'embedded.fi')
                        if(issigned(rateidx))
                            coder.internal.error('whdl:CCSDSLDPCDecoder:InvalidCodeRateUnsignedType');
                        end
                        coder.internal.errorIf(...
                        ~((rateidx.WordLength==2)&&(rateidx.FractionLength==0)),...
                        'whdl:CCSDSLDPCDecoder:InvalidCodeRateType');
                    end
                    if strcmpi(obj.SpecifyInputs,'Input port')
                        niter=varargin{5};
                        validateattributes(niter,{'uint8'},{'scalar','real'},'CCSDSLDPCDecoder','Number of iterations');
                    end
                else
                    if strcmpi(obj.SpecifyInputs,'Input port')
                        niter=varargin{3};
                        validateattributes(niter,{'uint8'},{'scalar','real'},'CCSDSLDPCDecoder','Number of iterations');
                    end
                end
            end
        end

        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            switch obj.Termination
            case 'Early'
                props=[props,...
                {'NumIterations'}];
                switch obj.SpecifyInputs
                case 'Input port'
                    props=[props,...
                    {'MaxNumIterations'}];
                end
            case 'Max'
                props=[props,...
                {'MaxNumIterations'}];
                switch obj.SpecifyInputs
                case 'Input port'
                    props=[props,...
                    {'NumIterations'}];
                end
            end
            flag=ismember(prop,props);
        end





        function varargout=getOutputDataTypeImpl(obj,varargin)
            if strcmpi(obj.Termination,'Early')
                varargout={'logical',samplecontrolbustype,numerictype(0,8,0),'logical','logical'};
            else
                varargout={'logical',samplecontrolbustype,'logical','logical'};
            end
        end



        function varargout=isOutputComplexImpl(obj)
            if strcmpi(obj.Termination,'Early')
                varargout={false,false,false,false,false,false,false,false};
            else
                varargout={false,false,false,false,false,false,false};
            end
        end



        function[sz1,sz2,sz3,sz4,sz5,sz6]=getOutputSizeImpl(obj)
            sz1=propagatedInputSize(obj,1);sz2=[1,1];sz3=[1,1];sz4=[1,1];sz5=[1,1];sz6=[1,1];
        end



        function varargout=isOutputFixedSizeImpl(obj)
            if strcmpi(obj.Termination,'Early')
                varargout={true,true,true,true,true,true,true,true};
            else
                varargout={true,true,true,true,true,true,true};
            end
        end




        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.alphaWL=obj.alphaWL;
                s.alphaFL=obj.alphaFL;
                s.betaWL=obj.betaWL;
                s.minWL=obj.minWL;
                s.betaCompWL=obj.betaCompWL;
                s.betaIdxWL=obj.betaIdxWL;
                s.scalarFlag=obj.scalarFlag;
                s.vectorSize=obj.vectorSize;

                s.codeParameters=obj.codeParameters;
                s.ldpcDecoderCore=obj.ldpcDecoderCore;


                s.blockLen=obj.blockLen;
                s.codeRate=obj.codeRate;
                s.numIter=obj.numIter;
                s.endInd=obj.endInd;
                s.frameValid=obj.frameValid;
                s.invalidBlockLength=obj.invalidBlockLength;
                s.invalidCodeRate=obj.invalidCodeRate;
                s.maxCount=obj.maxCount;
                s.countData=obj.countData;
                s.invalidLength=obj.invalidLength;
                s.blkLenLUT=obj.blkLenLUT;
                s.ctrlOutReg=obj.ctrlOutReg;


                s.dataOut=obj.dataOut;
                s.ctrlOut=obj.ctrlOut;
                s.iterOut=obj.iterOut;
                s.parCheck=obj.parCheck;
                s.nextFrame=obj.nextFrame;

            end
        end



        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end

    end
end
