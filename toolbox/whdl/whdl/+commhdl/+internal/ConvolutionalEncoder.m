classdef(StrictDefaults)ConvolutionalEncoder<matlab.System







%#codegen





    properties(Constant,Hidden)
        TerminationMethodSet=matlab.system.StringSet({...
        'Continuous',...
        'Terminated',...
        'Truncated'});
    end

    properties(Nontunable)

        ConstraintLength=7

        CodeGenerator=[171,133]

        FeedbackConnection=0


        TerminationMethod='Continuous'


        ResetPort(1,1)logical=false;

        InitialStatePort(1,1)logical=false;

        FinalStatePort(1,1)logical=false;
    end


    properties(Access=private,Nontunable)

        FeedbackEnable;

        TailCount;

        GenPolybin;
        FeedbackPolybin;
        FeedbackPolybinP;

        CodeGenLen;

        buffLen;
    end

    properties(Access=private)


        enbReg;
        enbProcessReg;
        endOutReg;
        enbFramEndOp;
        count;
        startInFlagReg;
        frameGapValidReg;
        startReg;
        endReg;
        validRegReg;


        shiftReg;
        validReg;
        bitReg;
        initstate;


        dataReg;
        dataRegReg;
        delay;
        rstReg;
        rstRegReg;


        dataOutReg;
        ctrlOut;
        finalstateReg;
    end





    methods



        function obj=ConvolutionalEncoder(varargin)
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

        function set.ConstraintLength(obj,val)
            validateattributes(val,{'numeric'},{'integer',...
            'scalar','>',2,'<',10},'ConvolutionalEncoder','Constraint Length');
            obj.ConstraintLength=double(val);
        end

        function set.CodeGenerator(obj,val)
            coder.extrinsic('commprivate');
            coder.extrinsic('boolean');
            CGLength=numel(val);
            validateattributes(val,{'numeric'},{'integer',...
            'row'},'ConvolutionalEncoder','Code Generator');
            coder.internal.errorIf(~boolean(commprivate('isoctal',double(val))),...
            'whdl:ConvolutionalEncoder:InvalidCGType');
            coder.internal.errorIf(~(CGLength>=2&&CGLength<=7),...
            'whdl:ConvolutionalEncoder:InvalidRate');
            obj.CodeGenerator=double(val);
        end

        function set.FeedbackConnection(obj,val)
            coder.extrinsic('commprivate');
            coder.extrinsic('boolean');
            validateattributes(val,{'numeric'},{'integer',...
            'scalar'},'ConvolutionalEncoder','Feedback connection');
            coder.internal.errorIf(~boolean(commprivate('isoctal',val)),...
            'whdl:ConvolutionalEncoder:InvalidFGType');
            obj.FeedbackConnection=double(val);
        end

    end

    methods(Static,Access=protected)


        function header=getHeaderImpl(~)
            text='Convolutionally encode binary data.';


            header=matlab.system.display.Header('commhdl.internal.ConvolutionalEncoder',...
            'Title','Convolutional Encoder',...
            'Text',text,...
            'ShowSourceLink',false);
        end

        function groups=getPropertyGroupsImpl


            parametersSection=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',...
            {'ConstraintLength','CodeGenerator','FeedbackConnection','TerminationMethod'});

            controlPortsSection=matlab.system.display.Section(...
            'Title','Control Ports',...
            'PropertyList',...
            {'ResetPort','InitialStatePort','FinalStatePort'});

            groups=matlab.system.display.SectionGroup(...
            'Title','Main',...
            'Sections',[parametersSection,controlPortsSection]);
        end

        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end

    end

    methods(Access=protected)


        function icon=getIconImpl(~)
            icon='Convolutional\nEncoder';
        end

        function resetImpl(obj)
            reset(obj.delay);
            resetparams(obj);
        end

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end


        function setupImpl(obj,varargin)


            [GenPolybinTmp,FeedbackPolybinTmp,FeedbackPolybinPTmp]=...
            commhdl.internal.ConvolutionalEncoder.CONVMatrixCalculator(obj.CodeGenerator,...
            obj.FeedbackConnection,obj.ConstraintLength);
            obj.GenPolybin=(GenPolybinTmp);
            obj.FeedbackPolybin=(FeedbackPolybinTmp);
            obj.FeedbackPolybinP=(FeedbackPolybinPTmp);

            obj.FeedbackEnable=obj.FeedbackPolybin(1,1)==fi(1,0,1,0);
            obj.CodeGenLen=length(obj.CodeGenerator);
            obj.buffLen=obj.ConstraintLength-1;

            obj.TailCount=...
            fi(obj.ConstraintLength-2,0,floor(log2(obj.ConstraintLength-1))+1,0);
            obj.delay=dsp.Delay(1);
            resetparams(obj);
        end

        function resetparams(obj)

            obj.dataOutReg=fi(false(obj.CodeGenLen,1),0,1,0);
            obj.bitReg=fi(0,0,1,0);
            obj.validReg=false;
            obj.initstate=fi(0,0,obj.ConstraintLength-1,0);
            obj.finalstateReg=fi(0,0,obj.ConstraintLength-1,0);
            obj.enbReg=false;
            obj.enbProcessReg=false;
            obj.frameGapValidReg=false;
            obj.endOutReg=false;
            obj.enbFramEndOp=false;
            obj.count=fi(0,0,floor(log2(obj.ConstraintLength-1))+1,0);
            obj.startInFlagReg=false;
            obj.startReg=false;
            obj.endReg=false;
            obj.validRegReg=false;
            obj.dataReg=fi(0,0,1,0);
            obj.dataRegReg=fi(0,0,1,0);
            obj.rstReg=false;
            obj.rstRegReg=false;
            obj.ctrlOut=struct('start',false,'end',false,'valid',false);
            obj.shiftReg=fi(false(1,obj.ConstraintLength-1),0,1,0);
        end

        function flag=getExecutionSemanticsImpl(obj)
            if obj.ResetPort&&strcmpi(obj.TerminationMethod,'Continuous')

                flag={'Classic','SynchronousWithResetPort'};
            else
                flag={'Classic','Synchronous'};
            end
        end

        function[data,varargout]=outputImpl(obj,varargin)

            data=logical(obj.dataOutReg);
            if strcmpi(obj.TerminationMethod,'Continuous')
                varargout{1}=obj.validRegReg;
            elseif strcmpi(obj.TerminationMethod,'Truncated')
                varargout{1}=obj.ctrlOut;
                if obj.FinalStatePort
                    if obj.InitialStatePort

                        varargout{2}=cast(obj.finalstateReg,'like',varargin{3});
                    else
                        varargout{2}=obj.finalstateReg;
                    end
                end
            else
                varargout{1}=obj.ctrlOut;
            end
        end

        function updateImpl(obj,varargin)

            dataBit=obj.dataReg;
            obj.dataReg=fi(varargin{1},0,1,0);

            switch obj.TerminationMethod
            case 'Continuous'
                validIn=obj.enbReg;
                obj.enbReg=varargin{2};

                if(obj.ResetPort)
                    rst=obj.rstReg;

                    [buffBits,validOut]=convEncContRstUnit(obj,dataBit,...
                    validIn,rst);
                    obj.validRegReg=~(varargin{3}||obj.rstReg||obj.rstRegReg)&&...
                    validOut;

                    obj.rstRegReg=obj.rstReg;
                    obj.rstReg=varargin{3};
                else


                    [buffBits,validOut]=convEncContUnit(obj,dataBit,validIn);
                    obj.validRegReg=validOut;
                end
            case 'Truncated'

                startIn=varargin{2}.start;
                endIn=varargin{2}.end;
                validIn=varargin{2}.valid;

                [startOut1,endOut1,validOut1]=...
                controllerTruncUnit(obj,startIn,endIn,validIn);

                if obj.InitialStatePort
                    if isa(varargin{3},'double')||isa(varargin{3},'single')
                        if~any((0:((2^(obj.ConstraintLength-1))-1))==varargin{3})
                            coder.internal.error('whdl:ConvolutionalEncoder:InvalidState');
                        end
                    end
                    initstateFi=fi(varargin{3},0,obj.ConstraintLength-1,0);
                    obj.initstate=fi(obj.delay(initstateFi),0,...
                    obj.ConstraintLength-1,0);
                end

                [buffBits,startOut2,endOut2,validOut2]=...
                convEncTruncUnit(obj,dataBit,startOut1,endOut1,validOut1);
                obj.ctrlOut.start=startOut2;
                obj.ctrlOut.end=endOut2;
                obj.ctrlOut.valid=validOut2;
            otherwise

                startIn=varargin{2}.start;
                endIn=varargin{2}.end;
                validIn=varargin{2}.valid;

                [startOut1,endOut1,validOut1,tailflag]=...
                controllerTermUnit(obj,startIn,endIn,validIn);

                [buffBits,startOut2,endOut2,validOut2]=...
                convEncTermUnit(obj,dataBit,startOut1,endOut1,...
                validOut1,tailflag);

                obj.ctrlOut.start=startOut2;
                obj.ctrlOut.end=endOut2;
                obj.ctrlOut.valid=validOut2;
            end

            for i=1:obj.CodeGenLen
                polynomial=obj.GenPolybin(i,:);
                obj.dataOutReg(i)=XORingUnit(obj,buffBits,polynomial);
            end
        end

        function[startOut,endOut,validOut,tailflag]=controllerTermUnit(obj,...
            startIn,endIn,validIn)


            startOut=obj.startInFlagReg;
            endOut=obj.endOutReg;
            validOut=obj.enbProcessReg;
            tailflag=obj.frameGapValidReg;


            startInFlag=startIn&&validIn;
            obj.startInFlagReg=startInFlag;



            processStart=startInFlag||obj.enbReg;

            enbProcess=(validIn||obj.enbFramEndOp)&&processStart;
            obj.enbProcessReg=enbProcess;


            frameGapValid=~startInFlag&&obj.enbFramEndOp;
            obj.frameGapValidReg=frameGapValid;


            endOutRegtmp=~startInFlag&&obj.enbFramEndOp&&...
            (obj.count(:)==obj.TailCount);
            enbFrameEndOptmp=obj.enbFramEndOp;

            obj.endOutReg=endOutRegtmp;
            obj.enbReg=processStart&&~endOutRegtmp;

            if(validIn)
                obj.enbFramEndOp=~startIn&&(obj.enbFramEndOp||endIn)&&...
                ~(obj.count(:)==obj.TailCount);
            else
                obj.enbFramEndOp=(obj.enbFramEndOp)&&...
                ~(obj.count(:)==obj.TailCount);
            end

            if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                if(obj.count(:)>=0)&&(enbFrameEndOptmp)
                    if(startInFlag)
                        if(obj.count(:)<=obj.TailCount)
                            coder.internal.warning('whdl:ConvolutionalEncoder:InvalidFrameGap');
                        end
                    end
                end
            end

            if(startInFlag)
                obj.count(:)=0;
            else
                if(enbFrameEndOptmp)
                    obj.count(:)=obj.count+fi(1,0,1,0);
                end
            end
        end

        function[startOut,endOut,validOut]=controllerTruncUnit(obj,...
            startIn,endIn,validIn)


            startOut=obj.startInFlagReg;
            endOut=obj.endOutReg;
            validOut=obj.enbProcessReg;
            startInFlag=startIn&&validIn;
            obj.startInFlagReg=startInFlag;



            processStart=startIn&&validIn||obj.enbReg;

            enbProcess=(validIn)&&processStart;
            obj.enbProcessReg=enbProcess;


            endOutRegtmp=~obj.enbFramEndOp&&endIn&&~startIn&&...
            validIn;
            obj.endOutReg=endOutRegtmp;
            obj.enbReg=processStart&&~endOutRegtmp;
            if(validIn)
                obj.enbFramEndOp=~startIn&&endIn;
            end
        end

        function[buffBits,startOut,endOut,validOut]=convEncTermUnit(obj,...
            bit,startIn,endIn,validIn,tailflag)


            rst=startIn;
            enb=validIn;

            startOut=obj.startReg;
            endOut=obj.endReg;
            validOut=obj.validReg;
            obj.startReg=startIn;
            obj.endReg=endIn;
            obj.validReg=validIn;

            buffBits=[obj.bitReg,obj.shiftReg];
            if obj.FeedbackEnable
                polynomial=obj.FeedbackPolybin(1,:);
                feedbackBits=XORingUnit(obj,buffBits,polynomial);
                polynomial1=obj.FeedbackPolybinP(1,:);
                tailBits=XORingUnit(obj,buffBits,polynomial1);
            else
                feedbackBits=fi(0,0,1,0);
            end

            if(tailflag)
                if obj.FeedbackEnable

                    bittmp=tailBits;
                else

                    bittmp=fi(0,0,1,0);
                end
            else
                bittmp=bit;
            end

            updateShiftRegs(obj,rst,enb,feedbackBits);

            if enb
                obj.bitReg(:)=bittmp;
            end
        end

        function[buffBits,startOut,endOut,validOut]=convEncTruncUnit(obj,...
            bit,startIn,endIn,validIn)


            rst=startIn;
            enb=validIn;

            startOut=obj.startReg;
            endOut=obj.endReg;
            validOut=obj.validReg;
            obj.startReg=startIn;
            obj.endReg=endIn;

            buffBits=[obj.bitReg,obj.shiftReg];
            if obj.FeedbackEnable
                polynomial=obj.FeedbackPolybin(1,:);
                feedbackBits=XORingUnit(obj,buffBits,polynomial);
            else
                feedbackBits=fi(0,0,1,0);
            end
            if obj.FinalStatePort

                if obj.validReg
                    if obj.FeedbackEnable
                        obj.finalstateReg=...
                        bitconcat([feedbackBits,obj.shiftReg(1:end-1)]);
                    else
                        obj.finalstateReg=...
                        bitconcat([obj.bitReg,obj.shiftReg(1:end-1)]);
                    end
                end
            end
            obj.validReg=validIn;

            updateShiftRegs(obj,rst,enb,feedbackBits);

            if enb
                obj.bitReg(:)=bit;
            end
        end

        function[buffBits,validOut]=convEncContUnit(obj,bit,validIn)


            enb=validIn;
            validOut=obj.validReg;
            obj.validReg=validIn;

            buffBits=[obj.bitReg,obj.shiftReg];
            if obj.FeedbackEnable
                polynomial=obj.FeedbackPolybin(1,:);
                feedbackBits=XORingUnit(obj,buffBits,polynomial);
            else
                feedbackBits=fi(0,0,1,0);
            end

            if(enb)
                for i=obj.buffLen:-1:2
                    obj.shiftReg(i)=obj.shiftReg(i-1);
                end
                if obj.FeedbackEnable
                    obj.shiftReg(1)=feedbackBits;
                else
                    obj.shiftReg(1)=obj.bitReg;
                end
                obj.bitReg=bit;
            end
        end

        function[buffBits,validOut]=convEncContRstUnit(obj,...
            bit,validIn,rst)


            enb=validIn;
            validOut=obj.validReg;
            obj.validReg=validIn;

            buffBits=[obj.bitReg,obj.shiftReg];
            if obj.FeedbackEnable
                polynomial=obj.FeedbackPolybin(1,:);
                feedbackBits=XORingUnit(obj,buffBits,polynomial);
            else
                feedbackBits=fi(0,0,1,0);
            end

            updateShiftRegs(obj,rst,enb,feedbackBits);

            if rst
                obj.bitReg(:)=0;
            elseif enb
                obj.bitReg(:)=bit;
            end
        end

        function xorout=XORingUnit(obj,shiftRegs,polynomial)

            tmp=fi(0,0,1,0);
            for ii=1:obj.ConstraintLength
                if polynomial(1,ii)==fi(1,0,1,0)
                    tmp=bitxor(tmp,shiftRegs(ii));
                end
            end
            xorout=tmp;
        end

        function updateShiftRegs(obj,rst,enb,feedbackBits)

            if(rst)
                if(obj.InitialStatePort)&&strcmpi(obj.TerminationMethod,'Truncated')


                    for i=obj.buffLen:-1:1
                        obj.shiftReg(obj.buffLen-i+1)=bitget(obj.initstate,i);
                    end
                else


                    obj.shiftReg(:)=0;
                end
            elseif(enb)
                for i=obj.buffLen:-1:2
                    obj.shiftReg(i)=obj.shiftReg(i-1);
                end
                if obj.FeedbackEnable

                    obj.shiftReg(1)=feedbackBits;
                else

                    obj.shiftReg(1)=obj.bitReg;
                end
            end
        end

        function validatePropertiesImpl(obj)



            CodeGenMatrix=dec2bin(oct2dec(obj.CodeGenerator))-'0';
            if size(CodeGenMatrix,2)~=obj.ConstraintLength||sum(CodeGenMatrix(:,1))==0
                coder.internal.error('whdl:ConvolutionalEncoder:CGNotMatch');
            end

            if obj.FeedbackConnection~=0
                temp=dec2bin(oct2dec(obj.FeedbackConnection));
                if size(temp,2)~=obj.ConstraintLength
                    coder.internal.error('whdl:ConvolutionalEncoder:FBNotMatch');
                end
            end
        end

        function num=getNumInputsImpl(obj)

            switch obj.TerminationMethod
            case 'Continuous'
                num=2+obj.ResetPort;
            case 'Truncated'
                num=2+obj.InitialStatePort;
            otherwise
                num=2;
            end
        end

        function num=getNumOutputsImpl(obj)

            switch obj.TerminationMethod
            case 'Continuous'
                num=2;
            case 'Truncated'
                num=2+obj.FinalStatePort;
            otherwise
                num=2;
            end
        end

        function varargout=getInputNamesImpl(obj)

            varargout=cell(1,getNumInputsImpl(obj));
            varargout{1}='data';
            switch obj.TerminationMethod
            case 'Continuous'
                varargout{2}='valid';
                if(obj.ResetPort)
                    varargout{3}='reset';
                end
            case 'Truncated'
                varargout{2}='ctrl';
                if(obj.InitialStatePort)
                    varargout{3}='ISt';
                end
            otherwise
                varargout{2}='ctrl';
            end
        end

        function validateInputsImpl(obj,varargin)

            coder.extrinsic('tostringInternalSlName');
            if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                validateattributes(varargin{1},{'embedded.fi','logical'},{'scalar'},...
                'ConvolutionalEncoder','data');
                if~isa(varargin{1},'logical')
                    [WL,FL,~]=dsphdlshared.hdlgetwordsizefromdata(varargin{1});
                    errCond=WL>1||(WL==1)&&(FL~=0);
                    if(errCond)
                        coder.internal.error('whdl:ConvolutionalEncoder:InvalidDataType',...
                        tostringInternalSlName(varargin{1}.numerictype));
                    end
                end

                switch obj.TerminationMethod
                case 'Continuous'
                    validateattributes(varargin{2},{'logical'},{'scalar'},'ConvolutionalEncoder',...
                    'valid');
                    if(obj.ResetPort)
                        validateattributes(varargin{3},{'logical'},{'scalar'},'ConvolutionalEncoder',...
                        'reset');
                    end
                case 'Truncated'
                    ctrl=varargin{2};
                    if~isstruct(ctrl)
                        coder.internal.error('whdl:ConvolutionalEncoder:InvalidSampleCtrlBus');
                    end
                    ctrlNames=fieldnames(ctrl);
                    if~isequal(numel(ctrlNames),3)
                        coder.internal.error('whdl:ConvolutionalEncoder:InvalidSampleCtrlBus');
                    end

                    if isfield(ctrl,ctrlNames{1})&&strcmp(ctrlNames{1},'start')
                        validateattributes(ctrl.start,{'logical'},...
                        {'scalar'},'ConvolutionalEncoder','start');
                    else
                        coder.internal.error('whdl:ConvolutionalEncoder:InvalidSampleCtrlBus');
                    end

                    if isfield(ctrl,ctrlNames{2})&&strcmp(ctrlNames{2},'end')
                        validateattributes(ctrl.end,{'logical'},...
                        {'scalar'},'ConvolutionalEncoder','end');
                    else
                        coder.internal.error('whdl:ConvolutionalEncoder:InvalidSampleCtrlBus');
                    end

                    if isfield(ctrl,ctrlNames{3})&&strcmp(ctrlNames{3},'valid')
                        validateattributes(ctrl.valid,{'logical'},...
                        {'scalar'},'ConvolutionalEncoder','valid');
                    else
                        coder.internal.error('whdl:ConvolutionalEncoder:InvalidSampleCtrlBus');
                    end
                    if(obj.InitialStatePort)
                        if((isa(varargin{3},'embedded.fi'))||(obj.ConstraintLength==9)&&(isa(varargin{3},'uint8')))&&isscalar(varargin{3})
                            [WL,FL,Sign]=dsphdlshared.hdlgetwordsizefromdata(varargin{3});
                            errCond=(WL>(obj.ConstraintLength-1))||(WL==obj.ConstraintLength-1)&&(FL~=0)&&Sign||...
                            (WL<(obj.ConstraintLength-1));
                            if(errCond)
                                coder.internal.error('whdl:ConvolutionalEncoder:InvalidStateDataType',...
                                tostringInternalSlName(varargin{3}.numerictype));
                            end
                        else
                            validateattributes(varargin{3},{'double','single','embedded.fi'},{'scalar'},'ConvolutionalEncoder',...
                            'ISt');
                        end
                    end
                otherwise
                    ctrl=varargin{2};
                    if~isstruct(ctrl)
                        coder.internal.error('whdl:ConvolutionalEncoder:InvalidSampleCtrlBus');
                    end
                    ctrlNames=fieldnames(ctrl);
                    if~isequal(numel(ctrlNames),3)
                        coder.internal.error('whdl:ConvolutionalEncoder:InvalidSampleCtrlBus');
                    end

                    if isfield(ctrl,ctrlNames{1})&&strcmp(ctrlNames{1},'start')
                        validateattributes(ctrl.start,{'logical'},...
                        {'scalar'},'ConvolutionalEncoder','start');
                    else
                        coder.internal.error('whdl:ConvolutionalEncoder:InvalidSampleCtrlBus');
                    end

                    if isfield(ctrl,ctrlNames{2})&&strcmp(ctrlNames{2},'end')
                        validateattributes(ctrl.end,{'logical'},...
                        {'scalar'},'ConvolutionalEncoder','end');
                    else
                        coder.internal.error('whdl:ConvolutionalEncoder:InvalidSampleCtrlBus');
                    end

                    if isfield(ctrl,ctrlNames{3})&&strcmp(ctrlNames{3},'valid')
                        validateattributes(ctrl.valid,{'logical'},...
                        {'scalar'},'ConvolutionalEncoder','valid');
                    else
                        coder.internal.error('whdl:ConvolutionalEncoder:InvalidSampleCtrlBus');
                    end
                end
            end
        end


        function varargout=getOutputNamesImpl(obj)

            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='data';
            switch obj.TerminationMethod
            case 'Continuous'
                varargout{2}='valid';
            case 'Truncated'
                varargout{2}='ctrl';
                if obj.FinalStatePort
                    varargout{3}='FSt';
                end
            otherwise
                varargout{2}='ctrl';
            end
        end


        function varargout=getOutputDataTypeImpl(obj,varargin)

            varargout{1}='logical';
            switch obj.TerminationMethod
            case 'Continuous'
                varargout{2}='logical';
            case 'Truncated'
                varargout{2}=samplecontrolbustype;
                if obj.FinalStatePort
                    if obj.InitialStatePort
                        varargout{3}=propagatedInputDataType(obj,3);
                    else
                        varargout{3}=numerictype(0,obj.ConstraintLength-1,0);
                    end
                end
            otherwise
                varargout={'logical',samplecontrolbustype};
            end
        end

        function varargout=isOutputComplexImpl(obj,varargin)

            numOutputs=getNumOutputs(obj);
            varargout=cell(1,numOutputs);
            for i=1:numOutputs
                varargout{i}=false;
            end

        end

        function varargout=getOutputSizeImpl(obj)

            numOutputs=getNumOutputs(obj);
            varargout=cell(1,numOutputs);


            varargout{1}=length(obj.CodeGenerator);

            for i=2:numOutputs
                varargout{i}=1;
            end
        end

        function varargout=isOutputFixedSizeImpl(obj)

            numOutputs=getNumOutputs(obj);
            varargout=cell(1,numOutputs);
            for i=1:numOutputs
                varargout{i}=true;
            end
        end

        function flag=isInactivePropertyImpl(obj,propertyName)

            if strcmp(propertyName,'ResetPort')
                flag=~strcmpi(obj.TerminationMethod,'Continuous');
            elseif strcmp(propertyName,'InitialStatePort')
                flag=~strcmpi(obj.TerminationMethod,'Truncated');
            elseif strcmp(propertyName,'FinalStatePort')
                flag=~strcmpi(obj.TerminationMethod,'Truncated');
            else
                flag=false;
            end
        end

        function s=saveObjectImpl(obj)


            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.dataOutReg=obj.dataOutReg;
                s.bitReg=obj.bitReg;
                s.validReg=obj.validReg;
                s.initstate=obj.initstate;
                s.delay=obj.delay;
                s.finalstateReg=obj.finalstateReg;
                s.enbReg=obj.enbReg;
                s.enbProcessReg=obj.enbProcessReg;
                s.frameGapValidReg=obj.frameGapValidReg;
                s.endOutReg=obj.endOutReg;
                s.enbFramEndOp=obj.enbFramEndOp;
                s.count=obj.count;
                s.startInFlagReg=obj.startInFlagReg;
                s.startReg=obj.startReg;
                s.endReg=obj.endReg;
                s.validRegReg=obj.validRegReg;
                s.dataReg=obj.dataReg;
                s.dataRegReg=obj.dataRegReg;
                s.rstReg=obj.rstReg;
                s.rstRegReg=obj.rstRegReg;
                s.ctrlOut=obj.ctrlOut;
                s.shiftReg=obj.shiftReg;
            end
        end

        function loadObjectImpl(obj,s,~)

            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end
    end

    methods(Static,Hidden)
        function[Conv_Matrix,Feedback_Matrix1,Feedback_Matrix2]=CONVMatrixCalculator(GeneratorPolynomial,FeedbackPolynomial,...
            ConstraintLength)


            CodeGenLen=length(GeneratorPolynomial);
            p=coder.const(reshape(feval('int2bit',oct2dec(GeneratorPolynomial(:)'),(ConstraintLength)),ConstraintLength,[])');
            Gbintmp=fi(p,0,1,0);
            q=coder.const(reshape(feval('int2bit',oct2dec(FeedbackPolynomial(:)'),(ConstraintLength)),ConstraintLength,[])');
            FeedbackPolybin=fi(q,0,1,0);
            FeedbackEnable=FeedbackPolybin(1,1)==fi(1,0,1,0);
            Feedback_Matrix1=FeedbackPolybin;
            if FeedbackEnable
                for i=1:CodeGenLen
                    if Gbintmp(i,1)==1
                        Gbintmp(i,2:end)=...
                        bitxor(Gbintmp(i,2:end),FeedbackPolybin(2:end));
                    end
                end
            end
            Conv_Matrix=(Gbintmp);
            feedbackPolybinTmp=[FeedbackPolybin(2:end),fi(0,0,1,0)];
            if(feedbackPolybinTmp(1,1)==1)
                feedbackPolybinTmp(1,2:end)=...
                bitxor(FeedbackPolybin(2:end),feedbackPolybinTmp(2:end));
            end
            Feedback_Matrix2=feedbackPolybinTmp;
        end

    end
end