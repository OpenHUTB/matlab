classdef(StrictDefaults)NRLDPCDecoder<matlab.System






%#codegen


    properties(Nontunable)


        Algorithm='Min-sum';


        ScalingFactor=0.75;


        Termination='Max';


        SpecifyInputs='Property'


        NumIterations=8;


        MaxNumIterations=8;


        RateCompatible(1,1)logical=false;

        ParityCheckStatus(1,1)logical=false;
    end

    properties(Constant,Hidden)
        SpecifyInputsSet=matlab.system.StringSet({'Input port','Property'});
        AlgorithmSet=matlab.system.StringSet({'Min-sum','Normalized min-sum'});
        TerminationSet=matlab.system.StringSet({'Max','Early'});
    end

    properties(Access=private,Nontunable)
        alphaWL;
        alphaFL;
        betaWL;
        minWL;
        betadecmpWL;
        memDepth;
        SF;
        vectorSize;
    end


    properties(Access=private)

        codeParameters;
        ldpcCoreDecoder;


        dataround;
        frameValid;
        bgn;
        liftingSize;
        countData;
        maxCount;
        invalidLength;

        data;
        ctrl;
        baseGraph;
        liftingSizeIn;
        numIter;
        dataOutReg;
        ctrlOutReg;
        iterOutReg;
        parCheckReg;
        numRows;


        dataOut;
        ctrlOut;
iterOut
        nextFrame;
        liftingSizeOut;
        parChkOut;

        dataOutD;
        ctrlOutD;
        iterOutD;
        liftingSizeOutD;
        parityCheck;
    end

    methods


        function obj=NRLDPCDecoder(varargin)
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

        function set.ScalingFactor(obj,val)
            NMSVec=[1,0.5,0.5625,0.625,0.6875,0.75,0.8125,0.875,0.9375];
            validateattributes(val,{'double'},{'scalar'},'NRLDPCDecoder','Scaling factor');
            coder.internal.errorIf(~(any(val==NMSVec)),...
            'whdl:NRLDPCDecoder:InvalidScalingFactor');
            obj.ScalingFactor=val;
        end

        function set.NumIterations(obj,val)
            validateattributes(val,{'double'},{'scalar','integer'},'NRLDPCDecoder','Number of iterations');
            coder.internal.errorIf(~(val>=1&&val<=63),...
            'whdl:NRLDPCDecoder:InvalidNumIterations');
            obj.NumIterations=val;
        end

        function set.MaxNumIterations(obj,val)
            validateattributes(val,{'double'},{'scalar','integer'},'NRLDPCDecoder','Maximum number of iterations');
            coder.internal.errorIf(~(val>=1&&val<=63),...
            'whdl:NRLDPCDecoder:InvalidMaxNumIterations');
            obj.MaxNumIterations=val;
        end

    end

    methods(Static,Access=protected)

        function header=getHeaderImpl
            text=[...
'Decode low-density parity-check (LDPC) code using layered belief'...
            ,newline...
            ,'propagation with min-sum or normalized min-sum approximation algorithm.'...
            ,newline...
            ,newline...
            ,'To enable numRows input port, select the Enable multiple code rates parameter.'
            ];

            header=matlab.system.display.Header('nrhdl.internal.NRLDPCDecoder',...
            'Title','NR LDPC Decoder',...
            'Text',text,...
            'ShowSourceLink',false);
        end

        function groups=getPropertyGroupsImpl
            struc=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'Algorithm','ScalingFactor','Termination','SpecifyInputs','NumIterations','MaxNumIterations','RateCompatible','ParityCheckStatus'});

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
            icon=sprintf('NR LDPC Decoder');
        end

        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

        function resetImpl(obj)

            reset(obj.codeParameters);
            reset(obj.ldpcCoreDecoder);
            obj.frameValid=false;

            obj.bgn=false;
            obj.liftingSize=fi(0,0,16,0);
            obj.invalidLength=false;
            if obj.vectorSize==64
                obj.maxCount=fi(66,0,9,0,hdlfimath);
                obj.countData=fi(0,0,9,0,hdlfimath);
            else
                obj.maxCount=fi(66,0,15,0,hdlfimath);
                obj.countData=fi(0,0,15,0,hdlfimath);
            end


            obj.dataOut(:)=zeros(obj.vectorSize,1);
            obj.ctrlOut=struct('start',false,'end',false,'valid',false);
            obj.nextFrame=true;
            obj.liftingSizeOut(:)=0;
            obj.iterOut(:)=0;
            obj.parChkOut(:)=false;

            obj.dataOutD(:)=zeros(obj.vectorSize,1);
            obj.ctrlOutD=struct('start',false,'end',false,'valid',false);
            obj.liftingSizeOutD(:)=0;
            obj.iterOutD(:)=0;
            obj.parityCheck(:)=false;
        end

        function setupImpl(obj,varargin)

            if isa(varargin{1},'int8')
                WL=8;
                FL=0;
            elseif isa(varargin{1},'int16')
                WL=16;
                FL=0;
            elseif isa(varargin{1},'embedded.fi')
                WL=varargin{1}.WordLength;
                FL=varargin{1}.FractionLength;
            else
                WL=4;
                FL=0;
            end

            if isscalar(varargin{1})
                obj.vectorSize=1;
                obj.maxCount=fi(66,0,15,0,hdlfimath);
                obj.countData=fi(0,0,15,0,hdlfimath);
            else
                obj.vectorSize=64;
                obj.maxCount=fi(66,0,9,0,hdlfimath);
                obj.countData=fi(0,0,9,0,hdlfimath);
            end

            intwl=WL-FL;

            if(strcmpi(obj.Algorithm,'Min-sum'))
                obj.SF=1;
            else
                obj.SF=obj.ScalingFactor;
            end

            if obj.SF==1
                obj.alphaFL=FL;
            else
                obj.alphaFL=FL+4;
            end

            obj.alphaWL=intwl+2+obj.alphaFL;

            if strcmpi(obj.Termination,'Early')&&(obj.SF~=1&&obj.SF~=0.75)
                obj.betaWL=intwl+obj.alphaFL+1;
                obj.minWL=intwl-1+obj.alphaFL+1;
            else
                obj.betaWL=intwl+obj.alphaFL;
                obj.minWL=intwl-1+obj.alphaFL;
            end

            obj.betadecmpWL=2*(obj.minWL);

            castWL=obj.alphaWL;
            castFL=obj.alphaFL;

            if obj.vectorSize==64
                obj.memDepth=384;
            else
                obj.memDepth=64;
            end

            obj.frameValid=false;

            obj.dataround=fi(zeros(obj.vectorSize,1),1,castWL,castFL);
            obj.dataOut=zeros(obj.vectorSize,1)>0;

            obj.data=cast(zeros(obj.vectorSize,1),'like',varargin{1});
            obj.ctrl=struct('start',false,'end',false,'valid',false);
            obj.baseGraph=false;
            obj.liftingSizeIn=uint16(2);
            obj.numIter=uint8(8);
            obj.dataOutReg=zeros(obj.vectorSize,1)>0;
            obj.ctrlOutReg=struct('start',false,'end',false,'valid',false);
            obj.iterOutReg=uint8(0);
            obj.parCheckReg=false;
            obj.numRows=fi(46,0,6,0);



            obj.codeParameters=nrhdl.internal.NRLDPCDecoderCodeParameters('Termination',obj.Termination,'SpecifyInputs',...
            obj.SpecifyInputs,'vectorSize',obj.vectorSize,'RateCompatible',obj.RateCompatible);


            obj.ldpcCoreDecoder=nrhdl.internal.NRLDPCDecoderCore('SpecifyInputs',...
            obj.SpecifyInputs,'NumIterations',obj.NumIterations,...
            'ScalingFactor',obj.SF,'alphaWL',obj.alphaWL,...
            'alphaFL',obj.alphaFL,'betaWL',obj.betaWL,'minWL',obj.minWL,...
            'betadecmpWL',obj.betadecmpWL,'memDepth',obj.memDepth,'vectorSize',obj.vectorSize,'Termination',obj.Termination,...
            'RateCompatible',obj.RateCompatible,'ParityCheckStatus',obj.ParityCheckStatus,'MaxNumIterations',obj.MaxNumIterations);


            obj.ctrlOut=struct('start',false,'end',false,'valid',false);
            obj.nextFrame=true;
            obj.liftingSizeOut=uint16(0);
            obj.iterOut=uint8(0);
            obj.parChkOut=false;

            obj.dataOutD=zeros(obj.vectorSize,1)>0;
            obj.ctrlOutD=struct('start',false,'end',false,'valid',false);
            obj.liftingSizeOutD=uint16(0);
            obj.iterOutD=uint8(0);
            obj.parityCheck=false;

        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.dataOutD;
            varargout{2}=obj.ctrlOutD;
            varargout{3}=obj.liftingSizeOutD;

            if strcmpi(obj.Termination,'Early')
                varargout{4}=obj.iterOutD;
                if obj.ParityCheckStatus
                    varargout{5}=obj.parityCheck;
                    varargout{6}=obj.nextFrame;
                else
                    varargout{5}=obj.nextFrame;
                end
            else
                if obj.ParityCheckStatus
                    varargout{4}=obj.parityCheck;
                    varargout{5}=obj.nextFrame;
                else
                    varargout{4}=obj.nextFrame;
                end
            end
        end

        function updateImpl(obj,varargin)

            datainreg=obj.data;

            ctrlin.start=obj.ctrl.start;
            ctrlin.end=obj.ctrl.end;
            ctrlin.valid=obj.ctrl.valid;

            basegraph=obj.baseGraph;
            liftingsize=obj.liftingSizeIn;

            obj.data=varargin{1};

            obj.ctrl.start=varargin{2}.start;
            obj.ctrl.end=varargin{2}.end;
            obj.ctrl.valid=varargin{2}.valid;

            obj.baseGraph=varargin{3};
            obj.liftingSizeIn=varargin{4};

            dataout=obj.dataOutReg;
            ctrlout=obj.ctrlOutReg;
            iterout=obj.iterOutReg;
            parcheck=obj.parCheckReg;

            numiter=obj.numIter;
            numrows=obj.numRows;

            if(strcmpi(obj.SpecifyInputs,'Input port'))

                if obj.ctrl.start&&obj.ctrl.valid
                    obj.numIter(:)=varargin{5};
                    if obj.RateCompatible
                        obj.numRows(:)=varargin{6};
                    else
                        obj.numRows(:)=fi(46,0,6,0);
                    end
                end

                [in_data,in_valid,frame_valid,reset,bgno,setindex,...
                liftsize,endind,num_iter,zaddr,nextframe,numrows_o]=obj.codeParameters(datainreg,ctrlin,basegraph,liftingsize,numiter,numrows);

                datain=cast(in_data,'like',obj.dataround);

                if strcmpi(obj.Termination,'Early')
                    [obj.dataOutReg,obj.ctrlOutReg,obj.iterOutReg,obj.parCheckReg]=obj.ldpcCoreDecoder(datain,in_valid,frame_valid,...
                    reset,bgno,setindex,liftsize,endind,num_iter,zaddr,numrows_o);
                else
                    [obj.dataOutReg,obj.ctrlOutReg,obj.parCheckReg]=obj.ldpcCoreDecoder(datain,in_valid,frame_valid,...
                    reset,bgno,setindex,liftsize,endind,num_iter,zaddr,numrows_o);
                end


            else

                if obj.RateCompatible
                    if obj.ctrl.start&&obj.ctrl.valid
                        obj.numRows(:)=varargin{5};
                    end
                else
                    obj.numRows(:)=fi(46,0,6,0);
                end

                [in_data,in_valid,frame_valid,reset,bgno,setindex,...
                liftsize,endind,~,zaddr,nextframe,numrows_o]=obj.codeParameters(datainreg,ctrlin,basegraph,liftingsize,numrows);

                datain=cast(in_data,'like',obj.dataround);

                if strcmpi(obj.Termination,'Early')
                    [obj.dataOutReg,obj.ctrlOutReg,obj.iterOutReg,obj.parCheckReg]=obj.ldpcCoreDecoder(datain,in_valid,frame_valid,...
                    reset,bgno,setindex,liftsize,endind,zaddr,numrows_o);
                else
                    [obj.dataOutReg,obj.ctrlOutReg,obj.parCheckReg]=obj.ldpcCoreDecoder(datain,in_valid,frame_valid,...
                    reset,bgno,setindex,liftsize,endind,zaddr,numrows_o);
                end
            end


            endValid=obj.ctrl.end&&obj.ctrl.valid&&obj.frameValid;

            if obj.ctrl.start&&obj.ctrl.valid
                obj.frameValid(:)=true;
                obj.countData(:)=0;
                obj.invalidLength(:)=false;
            elseif endValid
                obj.frameValid(:)=false;
            end

            if endValid&&~nextframe
                if obj.countData~=obj.maxCount-1
                    obj.invalidLength=true;
                    if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                        if obj.RateCompatible
                            coder.internal.warning('whdl:NRLDPCDecoder:InvalidNumRowInputLength');
                        else
                            coder.internal.warning('whdl:NRLDPCDecoder:InvalidInputLength');
                        end
                    end
                end
            end

            validframe=(obj.frameValid&&obj.ctrl.valid);

            if(validframe)
                obj.countData(:)=obj.countData+fi(1,0,1,0,hdlfimath);
            end

            if obj.ctrl.start&&obj.ctrl.valid
                obj.nextFrame(:)=false;
                obj.bgn(:)=obj.baseGraph;
                obj.liftingSize(:)=obj.liftingSizeIn;
            elseif((((obj.ctrlOut.end&&obj.ctrlOut.valid)&&obj.vectorSize==64)||...
                ((obj.ctrlOutD.end&&obj.ctrlOutD.valid)&&obj.vectorSize==1))||...
                (endValid&&nextframe)||obj.invalidLength)
                obj.nextFrame(:)=true;
            end

            if obj.nextFrame||(obj.ctrl.start&&obj.ctrl.valid)
                obj.liftingSizeOut(:)=0;
            elseif(((ctrlout.start&&ctrlout.valid)&&obj.vectorSize==64)||...
                ((obj.ctrlOut.start&&obj.ctrlOut.valid)&&obj.vectorSize==1))
                obj.liftingSizeOut(:)=liftsize;
            end

            if obj.vectorSize==1
                obj.dataOutD(:)=obj.dataOut;
                obj.ctrlOutD(:)=obj.ctrlOut;
                obj.iterOutD(:)=obj.iterOut;
                obj.liftingSizeOutD(:)=obj.liftingSizeOut;
                obj.parityCheck(:)=obj.parChkOut;
            end

            shift=ceil(double(obj.liftingSize)/obj.vectorSize);


            if obj.RateCompatible
                if(obj.bgn)
                    obj.maxCount(:)=(double(obj.numRows)+8)*shift;
                else
                    obj.maxCount(:)=(double(obj.numRows)+20)*shift;
                end
            else
                if(obj.bgn)
                    obj.maxCount(:)=50*shift;
                else
                    obj.maxCount(:)=66*shift;
                end
            end

            if obj.frameValid||obj.nextFrame
                obj.dataOut(:)=zeros(obj.vectorSize,1)>0;
                obj.ctrlOut(:)=struct('start',false,'end',false,'valid',false);
                obj.iterOut(:)=0;
                obj.parChkOut(:)=false;
            else
                obj.dataOut(:)=dataout;
                obj.ctrlOut(:)=ctrlout;
                obj.iterOut(:)=iterout;
                obj.parChkOut(:)=parcheck;
            end

            if obj.vectorSize==64
                obj.dataOutD(:)=obj.dataOut;
                obj.ctrlOutD(:)=obj.ctrlOut;
                obj.iterOutD(:)=obj.iterOut;
                obj.liftingSizeOutD(:)=obj.liftingSizeOut;
                obj.parityCheck(:)=obj.parChkOut;
            end

        end

        function num=getNumInputsImpl(obj)
            if(strcmpi(obj.SpecifyInputs,'Input port'))
                num=5;
            else
                num=4;
            end

            if obj.RateCompatible
                num=num+1;
            end
        end

        function num=getNumOutputsImpl(obj)
            if strcmpi(obj.Termination,'Early')
                num=5;
            else
                num=4;
            end

            if obj.ParityCheckStatus
                num=num+1;
            end
        end

        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='data';
            varargout{2}='ctrl';
            varargout{3}='bgn';
            varargout{4}='liftingSize';

            if strcmpi(obj.SpecifyInputs,'Input port')
                varargout{5}='iter';
                if obj.RateCompatible
                    varargout{6}='numRows';
                end
            else
                if obj.RateCompatible
                    varargout{5}='numRows';
                end
            end

        end

        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='data';
            varargout{2}='ctrl';
            varargout{3}='liftingSize';
            if(strcmpi(obj.Termination,'Early'))
                varargout{4}='actIter';
                if obj.ParityCheckStatus
                    varargout{5}='parityCheck';
                    varargout{6}='nextFrame';
                else
                    varargout{5}='nextFrame';
                end
            else
                if obj.ParityCheckStatus
                    varargout{4}='parityCheck';
                    varargout{5}='nextFrame';
                else
                    varargout{4}='nextFrame';
                end
            end
        end

        function validateInputsImpl(obj,varargin)
            if isempty(coder.target)||~coder.internal.isAmbiguousTypes

                if isscalar(varargin{1})
                    validateattributes(varargin{1},{'embedded.fi','int8','int16'},{'scalar','real'},'NRLDPCDecoder','data');
                else
                    vecLen=64;
                    if(length(varargin{1})~=vecLen)
                        coder.internal.error('whdl:NRLDPCDecoder:InvalidVecLength');
                    end
                    validateattributes(varargin{1},{'embedded.fi','int8','int16'},{'vector','real'},'NRLDPCDecoder','data');
                end


                if isa(varargin{1},'embedded.fi')
                    if~(issigned(varargin{1}))
                        coder.internal.error('whdl:NRLDPCDecoder:InvalidSignedType');
                    end
                    maxWordLength=16;
                    minWordLength=4;
                    coder.internal.errorIf(...
                    ((varargin{1}.WordLength>maxWordLength)||(varargin{1}.WordLength<minWordLength)),...
                    'whdl:NRLDPCDecoder:InvalidInputWordLength');

                end

                ctrlIn=varargin{2};
                if~isstruct(ctrlIn)
                    coder.internal.error('whdl:NRLDPCDecoder:InvalidSampleCtrlBus');
                end

                ctrlNames=fieldnames(ctrlIn);
                if~isequal(numel(ctrlNames),3)
                    coder.internal.error('whdl:NRLDPCDecoder:InvalidSampleCtrlBus');
                end

                if isfield(ctrlIn,ctrlNames{1})&&strcmp(ctrlNames{1},'start')
                    validateattributes(ctrlIn.start,{'logical'},...
                    {'scalar'},'NRLDPCDecoder','start');
                else
                    coder.internal.error('whdl:NRLDPCDecoder:InvalidSampleCtrlBus');
                end

                if isfield(ctrlIn,ctrlNames{2})&&strcmp(ctrlNames{2},'end')
                    validateattributes(ctrlIn.end,{'logical'},...
                    {'scalar'},'NRLDPCDecoder','end');
                else
                    coder.internal.error('whdl:NRLDPCDecoder:InvalidSampleCtrlBus');
                end

                if isfield(ctrlIn,ctrlNames{3})&&strcmp(ctrlNames{3},'valid')
                    validateattributes(ctrlIn.valid,{'logical'},...
                    {'scalar'},'NRLDPCDecoder','valid');
                else
                    coder.internal.error('whdl:NRLDPCDecoder:InvalidSampleCtrlBus');
                end

                validateattributes(varargin{3},{'logical'},{'scalar'},'NRLDPCDecoder','bgn');

                validateattributes(varargin{4},{'uint16'},{'scalar','real'},'NRLDPCDecoder','Lifting Size');

                if strcmpi(obj.SpecifyInputs,'Input port')
                    niter=varargin{5};
                    validateattributes(niter,{'uint8'},{'scalar','real'},'NRLDPCDecoder','Number of iterations');
                    if obj.RateCompatible
                        nrows=varargin{6};
                    end
                else
                    if obj.RateCompatible
                        nrows=varargin{5};
                    end
                end

                if obj.RateCompatible

                    validateattributes(nrows,{'embedded.fi'},{'scalar','real'},'NRLDPCDecoder','Number of rows');
                    if isa(nrows,'embedded.fi')
                        if(issigned(nrows))
                            coder.internal.error('whdl:NRLDPCDecoder:InvalidNumRowsDatatype');
                        end
                        if((nrows.WordLength~=6)||(nrows.FractionLength~=0))
                            coder.internal.error('whdl:NRLDPCDecoder:InvalidNumRowsDatatype');
                        end
                    end
                end

            end
        end

        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if strcmpi(obj.Termination,'Max')
                props=[props,...
                {'MaxNumIterations'}];
            end
            switch obj.SpecifyInputs
            case 'Input port'
                props=[props,...
                {'NumIterations'}];
                props=[props,...
                {'MaxNumIterations'}];
            end
            switch obj.Algorithm
            case 'Min-sum'
                props=[props,...
                {'ScalingFactor'}];
            end
            switch obj.Termination
            case 'Early'
                props=[props,...
                {'NumIterations'}];
            end
            flag=ismember(prop,props);
        end





        function varargout=getOutputDataTypeImpl(obj,varargin)
            if strcmpi(obj.Termination,'Early')
                varargout={'logical',samplecontrolbustype,numerictype(0,16,0),numerictype(0,8,0),'logical','logical'};
            else
                varargout={'logical',samplecontrolbustype,numerictype(0,16,0),'logical','logical'};
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

                s.codeParameters=obj.codeParameters;
                s.ldpcCoreDecoder=obj.ldpcCoreDecoder;


                s.dataround=obj.dataround;
                s.frameValid=obj.frameValid;
                s.bgn=obj.bgn;
                s.liftingSize=obj.liftingSize;
                s.countData=obj.countData;
                s.maxCount=obj.maxCount;
                s.invalidLength=obj.invalidLength;
                s.data=obj.data;
                s.ctrl=obj.ctrl;
                s.baseGraph=obj.baseGraph;
                s.liftingSizeIn=obj.liftingSizeIn;
                s.numIter=obj.numIter;
                s.dataOutReg=obj.dataOutReg;
                s.ctrlOutReg=obj.ctrlOutReg;
                s.iterOutReg=obj.iterOutReg;
                s.parCheckReg=obj.parCheckReg;
                s.numRows=obj.numRows;


                s.dataOut=obj.dataOut;
                s.ctrlOut=obj.ctrlOut;
                s.iterOut=obj.iterOut;
                s.nextFrame=obj.nextFrame;
                s.liftingSizeOut=obj.liftingSizeOut;
                s.alphaWL=obj.alphaWL;
                s.alphaFL=obj.alphaFL;
                s.betaWL=obj.betaWL;
                s.minWL=obj.minWL;
                s.betadecmpWL=obj.betadecmpWL;
                s.memDepth=obj.memDepth;
                s.ScalingFactor=obj.ScalingFactor;
                s.SF=obj.SF;
                s.vectorSize=obj.vectorSize;
                s.parChkOut=obj.parChkOut;

                s.dataOutD=obj.dataOutD;
                s.ctrlOutD=obj.ctrlOutD;
                s.iterOutD=obj.iterOutD;
                s.liftingSizeOutD=obj.liftingSizeOutD;
                s.parityCheck=obj.parityCheck;
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
