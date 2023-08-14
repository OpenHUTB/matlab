classdef(StrictDefaults)Depuncturer<matlab.System













%#codegen





    properties(Nontunable)



        OperationMode='Continuous';


        SpecifyInputs='Input port'


        PuncturingVector=[1;1;0;1;1;0]

    end

    properties(Access=private)


        dataOut;
        ctrlOut;
        validOut;
        erasureOut;


        dataOutD;
        ctrlOutD;
        validOutD;
        erasureOutD;


        dataIn;
        dataInReg;
        ctrlIn;
        ctrlInReg;
        validIn;
        validInReg;
        syncStart;
        syncStartReg;


        fsm;
        NullSym;
        Pattern;
        PatternReg;
        maxCount;


        start_vld;


        delayBalancer1;
        delayBalancer2;
        delayBalancer3;
        delayBalancer4;
        delayBalancer5;
        delayBalancer6;
        delayBalancer7;

    end

    properties(Constant,Hidden)

        OperationModeSet=matlab.system.StringSet({'Continuous','Frame'});

        SpecifyInputsSet=matlab.system.StringSet({'Input port','Property'});

    end





    methods



        function obj=Depuncturer(varargin)
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



        function set.PuncturingVector(obj,val)
            PVlength=numel(val);
            validateattributes(val,{'double','logical'},{'vector','binary',...
            'column'},'Depuncturer','Puncture vector');
            coder.internal.errorIf(~(PVlength>=4&&PVlength<=28&&...
            (~rem(PVlength,2))),...
            'whdl:Depuncturer:InvalidPunctureVectorLength');
            if strcmpi(obj.SpecifyInputs,'Property')%#ok<*MCSUP> 
                obj.PuncturingVector=val;
                for i=1:2:PVlength
                    coder.internal.errorIf(~(val(i)||val(i+1)),...
                    'whdl:Depuncturer:InvalidPunctureVector');
                end
            end
        end
    end

    methods(Static,Access=protected)


        function header=getHeaderImpl
            text=...
'Depunctures the data according to the given Puncture vector.'...
            ;

            header=matlab.system.display.Header('commhdl.internal.Depuncturer',...
            'Title','Depuncturer',...
            'Text',text,...
            'ShowSourceLink',false);
        end



        function groups=getPropertyGroupsImpl
            struc=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'OperationMode','SpecifyInputs','PuncturingVector'});

            main=matlab.system.display.SectionGroup(...
            'Title','Main',...
            'Sections',struc);

            groups=main;
        end

        function supported=supportsMultipleInstanceImpl(~)
            supported=true;
        end



        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end

    end


    methods(Access=protected)



        function icon=getIconImpl(~)
            icon=sprintf('Depuncturer');
        end



        function resetImpl(obj)

            obj.dataOut(:)=zeros(2,1);
            obj.ctrlOut=struct('start',false,'end',false,'valid',false);
            obj.validOut=false;
            obj.erasureOut=[false;false];
            obj.dataIn(:)=0;
            obj.dataInReg(:)=0;
            obj.ctrlIn=struct('start',false,'end',false,'valid',false);
            obj.ctrlInReg=struct('start',false,'end',false,'valid',false);
            obj.validIn=false;
            obj.validInReg=false;
            obj.syncStart=false;
            obj.syncStartReg=false;

            obj.fsm.dataStream1(:)=0;
            obj.fsm.dataStream2(:)=0;
            obj.fsm.eraStream1(:)=false;
            obj.fsm.eraStream2(:)=false;
            obj.fsm.validOut(:)=false;

            reset(obj.delayBalancer1);
            reset(obj.delayBalancer2);
            reset(obj.delayBalancer3);
            reset(obj.delayBalancer4);
            reset(obj.delayBalancer5);
            reset(obj.delayBalancer6);
            reset(obj.delayBalancer7);

        end


        function setupImpl(obj,varargin)

            obj.dataOut=zeros([2,1],'like',varargin{1});
            obj.ctrlOut=struct('start',false,'end',false,'valid',false);
            obj.validOut=false;
            obj.erasureOut=[false;false];
            obj.dataOutD=zeros([2,1],'like',varargin{1});
            obj.ctrlOutD=struct('start',false,'end',false,'valid',false);
            obj.validOutD=false;
            obj.erasureOutD=[false;false];
            obj.dataIn=cast(0,'like',varargin{1});
            obj.dataInReg=cast(0,'like',varargin{1});
            obj.ctrlIn=struct('start',false,'end',false,'valid',false);
            obj.ctrlInReg=struct('start',false,'end',false,'valid',false);
            obj.validIn=false;
            obj.validInReg=false;
            obj.syncStart=false;
            obj.syncStartReg=false;
            obj.fsm=struct(...
            'startOut',false,...
            'endOut',false,...
            'validOut',false,...
            'strtInd',false,...
            'endInd',false,...
            'ctrlInd',false,...
            'enbDepunc',false,...
            'state',fi(0,0,2,0),...
            'enbCount',false,...
            'intPos',true,...
            'toggle',true,...
            'count',fi(1,0,5,0,hdlfimath),...
            'initCount',fi(1,0,5,0),...
            'buffer',cast(0,'like',varargin{1}),...
            'bufferactive',false,...
            'dataStream1',cast(0,'like',varargin{1}),...
            'dataStream2',cast(0,'like',varargin{1}),...
            'eraStream1',false,...
            'eraStream2',false);



            dataInclass=class(varargin{1});
            isFi=~isempty(strfind(dataInclass,'fi'));%#ok<*STREMP>
            isInt=~isempty(strfind(dataInclass,'int'));
            isLogical=~isempty(strfind(dataInclass,'logical'));

            if(isFi)
                NsDec=varargin{1}.WordLength;
                fNsDec=(2^varargin{1}.FractionLength);

                if(issigned(varargin{1})||NsDec==1)
                    obj.NullSym=cast(0,'like',varargin{1});
                else
                    obj.NullSym=cast(2^(NsDec-1)/fNsDec,'like',varargin{1});
                end
            else
                if(isInt)
                    if(strcmpi(dataInclass,'uint8'))
                        obj.NullSym=fi(2^7,0,8,0);
                    elseif(strcmpi(dataInclass,'uint16'))
                        obj.NullSym=fi(2^15,0,16,0);
                    elseif(strcmpi(dataInclass,'int8'))
                        obj.NullSym=fi(0,1,8,0);
                    elseif(strcmpi(dataInclass,'int16'))
                        obj.NullSym=fi(0,1,16,0);
                    elseif(strcmpi(dataInclass,'uint32'))
                        obj.NullSym=fi(2^31,0,32,0);
                    elseif(strcmpi(dataInclass,'uint64'))
                        obj.NullSym=fi(2^63,0,64,0);
                    elseif(strcmpi(dataInclass,'int32'))
                        obj.NullSym=fi(0,1,32,0);
                    elseif(strcmpi(dataInclass,'int64'))
                        obj.NullSym=fi(0,1,64,0);
                    end
                else
                    if(isLogical)
                        obj.NullSym=false;
                    else
                        obj.NullSym=cast(0,'like',varargin{1});
                    end
                end
            end



            if strcmpi(obj.SpecifyInputs,'Input port')
                obj.Pattern=fi(zeros(length(varargin{2}),1),0,1,0);

                obj.maxCount=fi(length(varargin{2})-1,0,5,0);
                obj.PatternReg=fi(zeros(length(varargin{2}),1),0,1,0);
            else
                obj.Pattern=fi(obj.PuncturingVector,0,1,0);

                obj.maxCount=fi(length(obj.PuncturingVector)-1,0,5,0);
                obj.PatternReg=fi(obj.PuncturingVector,0,1,0);
            end
            obj.start_vld=false;


            if(strcmpi(obj.OperationMode,'Continuous'))
                delaynum=3;
            else
                delaynum=2;
            end
            obj.delayBalancer1=dsp.Delay(delaynum);
            obj.delayBalancer2=dsp.Delay(delaynum);
            obj.delayBalancer3=dsp.Delay(delaynum);
            obj.delayBalancer4=dsp.Delay(delaynum);
            obj.delayBalancer5=dsp.Delay(delaynum);
            obj.delayBalancer6=dsp.Delay(delaynum);
            obj.delayBalancer7=dsp.Delay(delaynum);
        end

        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end


        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.dataOut;
            if strcmpi(obj.OperationMode,'Continuous')
                varargout{2}=obj.validOut;
            else
                varargout{2}=obj.ctrlOut;
            end
            varargout{3}=obj.erasureOut;
        end

        function updateImpl(obj,varargin)

            obj.dataOutD=[obj.fsm.dataStream1;obj.fsm.dataStream2];
            obj.erasureOutD=[obj.fsm.eraStream1;obj.fsm.eraStream2];

            if strcmpi(obj.OperationMode,'Continuous')
                obj.validOutD=obj.fsm.validOut;

                obj.dataOut(1)=obj.delayBalancer1(obj.dataOutD(1));
                obj.dataOut(2)=obj.delayBalancer2(obj.dataOutD(2));
                obj.validOut=obj.delayBalancer3(obj.validOutD);
                obj.erasureOut(1)=obj.delayBalancer4(obj.erasureOutD(1));
                obj.erasureOut(2)=obj.delayBalancer5(obj.erasureOutD(2));
            else
                obj.ctrlOutD.start=obj.fsm.startOut;
                obj.ctrlOutD.end=obj.fsm.endOut;
                obj.ctrlOutD.valid=obj.fsm.validOut;

                obj.dataOut(1)=obj.delayBalancer1(obj.dataOutD(1));
                obj.dataOut(2)=obj.delayBalancer2(obj.dataOutD(2));
                obj.ctrlOut.start=obj.delayBalancer3(obj.ctrlOutD.start);
                obj.ctrlOut.end=obj.delayBalancer4(obj.ctrlOutD.end);
                obj.ctrlOut.valid=obj.delayBalancer5(obj.ctrlOutD.valid);
                obj.erasureOut(1)=obj.delayBalancer6(obj.erasureOutD(1));
                obj.erasureOut(2)=obj.delayBalancer7(obj.erasureOutD(2));
            end


            fsmnext=obj.fsm;

            fsmreg=obj.fsm;

            obj.PatternReg=obj.Pattern;
            obj.dataIn=obj.dataInReg;
            obj.dataInReg=varargin{1};

            if strcmpi(obj.OperationMode,'Continuous')

                obj.validIn=obj.validInReg;
                obj.syncStart=obj.syncStartReg;

                if strcmpi(obj.SpecifyInputs,'Input port')
                    obj.validInReg=varargin{4};
                    obj.syncStartReg=varargin{3};
                else
                    obj.validInReg=varargin{3};
                    obj.syncStartReg=varargin{2};
                end



                if(obj.validInReg&&(obj.syncStartReg||fsmnext.toggle))
                    fsmnext.toggle=false;
                    fsmnext.enbDepunc=true;
                    fsmnext.buffer(:)=0;
                    fsmnext.bufferactive=false;
                    fsmnext.intPos=true;


                    if strcmpi(obj.SpecifyInputs,'Input port')

                        obj.Pattern(:)=varargin{2};

                        [fsmnext.initCount,fsmnext.intPos]...
                        =extractPuncturingVector(obj,obj.Pattern,...
                        fsmnext.initCount,fsmnext.intPos);



                        if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                            for i=fsmnext.initCount:2:obj.maxCount
                                if~(obj.Pattern(i)||obj.Pattern(i+fi(1,0,5,0)))
                                    coder.internal.warning('whdl:Depuncturer:InvalidPunctureVector');
                                end
                            end
                        end

                        fsmnext.count(:)=fsmnext.initCount;
                    else

                        fsmnext.count(:)=fsmnext.initCount;
                    end
                end
            else

                obj.ctrlIn=obj.ctrlInReg;

                if strcmpi(obj.SpecifyInputs,'Input port')
                    obj.ctrlInReg=varargin{3};
                else
                    obj.ctrlInReg=varargin{2};
                end
                obj.start_vld=obj.ctrlInReg.start&&obj.ctrlInReg.valid;

                if(obj.start_vld)
                    fsmnext.enbDepunc=true;
                    fsmnext.intPos=true;
                    fsmnext.bufferactive=false;


                    if strcmpi(obj.SpecifyInputs,'Input port')

                        obj.Pattern(:)=varargin{2};

                        [fsmnext.initCount,fsmnext.intPos]...
                        =extractPuncturingVector(obj,obj.Pattern,...
                        fsmnext.initCount,fsmnext.intPos);



                        if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                            for i=fsmnext.initCount:2:obj.maxCount
                                if~(obj.Pattern(i)||obj.Pattern(i+fi(1,0,5,0)))
                                    coder.internal.warning('whdl:Depuncturer:InvalidPunctureVector');
                                end
                            end
                        end

                        fsmnext.count(:)=fsmnext.initCount;
                    else
                        fsmnext.count(:)=fsmnext.initCount;
                    end
                end

            end


            fsmreg.state=bitconcat(obj.PatternReg(fsmreg.count),...
            obj.PatternReg(fsmreg.count+fi(1,0,1,0)));

            if((strcmpi(obj.OperationMode,'Continuous')&&obj.validIn)||...
                (~strcmpi(obj.OperationMode,'Continuous')&&...
                (obj.ctrlIn.valid))&&fsmreg.enbDepunc)

                switch fsmreg.state

                case 1
                    fsmreg.dataStream1(:)=obj.NullSym;
                    fsmreg.dataStream2(:)=obj.dataIn;
                    fsmreg.eraStream1(:)=true;
                    fsmreg.eraStream2(:)=false;
                    fsmreg.ctrlInd=true;
                    fsmreg.buffer(:)=0;
                    fsmreg.bufferactive=false;
                    fsmreg.enbCount=true;

                case 2
                    fsmreg.dataStream1(:)=obj.dataIn;
                    fsmreg.dataStream2(:)=obj.NullSym;
                    fsmreg.eraStream1(:)=false;
                    fsmreg.eraStream2(:)=true;
                    fsmreg.ctrlInd=true;
                    fsmreg.buffer(:)=0;
                    fsmreg.bufferactive=false;
                    fsmreg.enbCount=true;

                case 3
                    if(fsmreg.bufferactive)
                        fsmreg.dataStream1(:)=fsmreg.buffer;
                        fsmreg.dataStream2(:)=obj.dataIn;
                        fsmreg.eraStream1(:)=false;
                        fsmreg.eraStream2(:)=false;
                        fsmreg.ctrlInd=true;
                        fsmreg.enbCount=true;
                        fsmreg.buffer(:)=0;
                        fsmreg.bufferactive=false;
                    else


                        if(obj.ctrlIn.end&&~obj.ctrlIn.start&&...
                            strcmpi(obj.OperationMode,'Frame'))
                            fsmreg.dataStream1(:)=obj.dataIn;
                            fsmreg.dataStream2(:)=obj.NullSym;
                            fsmreg.eraStream1(:)=false;
                            fsmreg.eraStream2(:)=true;
                            fsmreg.ctrlInd=true;
                            fsmreg.buffer(:)=0;
                            fsmreg.bufferactive=false;
                            fsmreg.enbCount=false;

                        else
                            fsmreg.dataStream1(:)=0;
                            fsmreg.dataStream2(:)=0;
                            fsmreg.eraStream1(:)=false;
                            fsmreg.eraStream2(:)=false;
                            fsmreg.ctrlInd=false;
                            fsmreg.buffer=obj.dataIn;
                            fsmreg.bufferactive=true;
                            fsmreg.enbCount=false;
                        end
                    end

                otherwise
                    fsmreg.dataStream1(:)=0;
                    fsmreg.dataStream2(:)=0;
                    fsmreg.eraStream1(:)=false;
                    fsmreg.eraStream2(:)=false;
                    fsmreg.ctrlInd=false;
                    fsmreg.buffer(:)=0;
                    fsmreg.bufferactive=false;
                    fsmreg.enbCount=true;
                end
            else
                fsmreg.dataStream1(:)=0;
                fsmreg.dataStream2(:)=0;
                fsmreg.eraStream1(:)=false;
                fsmreg.eraStream2(:)=false;
                fsmreg.ctrlInd=false;
                fsmreg.enbCount=false;
            end


            fsmreg.count=countPosPuncVector(obj,fsmreg.count,fsmreg.enbCount,...
            obj.maxCount,fsmreg.initCount);


            [fsmreg.startOut,fsmreg.endOut,fsmreg.validOut,fsmreg.strtInd,...
            fsmreg.endInd,fsmreg.enbDepunc]=controlSignalGen(obj,...
            fsmreg.ctrlInd,obj.ctrlIn,obj.validIn,fsmreg.strtInd,...
            fsmreg.endInd,fsmreg.enbDepunc);


            if((strcmpi(obj.OperationMode,'Continuous')&&(obj.validInReg...
                &&(obj.syncStartReg||fsmreg.toggle)))||...
                (~strcmpi(obj.OperationMode,'Continuous')&&obj.start_vld))
                obj.fsm=fsmnext;
                obj.fsm.dataStream1=fsmreg.dataStream1;
                obj.fsm.dataStream2=fsmreg.dataStream2;
                obj.fsm.eraStream1=fsmreg.eraStream1;
                obj.fsm.eraStream2=fsmreg.eraStream2;
                obj.fsm.endInd=fsmreg.endInd;
                obj.fsm.startOut=fsmreg.startOut;
                obj.fsm.endOut=fsmreg.endOut;
                obj.fsm.validOut=fsmreg.validOut;
            else
                obj.fsm=fsmreg;
            end

        end


        function[initcount,intpos]=extractPuncturingVector(~,pattern,...
            initcount,intpos)
            x=false;
            for i=1:length(pattern)
                x=~(x);
                if(pattern(i)&&intpos)
                    intpos=false;
                    if(x)
                        initcount(:)=i;
                    else
                        initcount(:)=fi(i-1,0,5,0);
                    end
                end
            end
        end


        function count=countPosPuncVector(~,count,enbcount,maxcount,initcount)
            if(enbcount)
                if(count(:)==maxcount)
                    count(:)=initcount;
                else
                    count(:)=count+fi(2,0,5,0);
                end
            end
        end


        function[startOut,endOut,validOut,strtInd,endInd,enbDepunc]...
            =controlSignalGen(obj,ctrlInd,ctrlIn,validIn,strtInd,...
            endInd,enbDepunc)
            if strcmpi(obj.OperationMode,'Continuous')
                startOut=false;
                endOut=false;
                if(validIn)
                    enbDepunc=true;
                end
                if(ctrlInd)
                    validOut=true;
                else
                    validOut=false;
                end
            else
                if(ctrlIn.valid)
                    if(ctrlIn.start)
                        strtInd=true;
                        enbDepunc=true;
                    elseif(ctrlIn.end&&enbDepunc)
                        endInd=true;
                        enbDepunc=false;
                    end
                end
                if(ctrlInd)
                    if(strtInd)
                        startOut=true;
                        strtInd=false;
                    else
                        startOut=false;
                    end
                    validOut=true;
                    if(endInd)
                        endOut=true;
                        endInd=false;
                    else
                        endOut=false;
                    end
                else
                    validOut=false;
                    startOut=false;
                    endOut=false;
                end
            end
        end

        function num=getNumInputsImpl(obj)
            if strcmpi(obj.OperationMode,'Continuous')
                if strcmpi(obj.SpecifyInputs,'Input port')
                    num=4;
                else
                    num=3;
                end
            else
                if strcmpi(obj.SpecifyInputs,'Input port')
                    num=3;
                else
                    num=2;
                end
            end
        end

        function num=getNumOutputsImpl(~)
            num=3;
        end

        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            inputPortInd=1;
            varargout{inputPortInd}='data';
            if strcmpi(obj.SpecifyInputs,'Input port')
                inputPortInd=inputPortInd+1;
                varargout{inputPortInd}='puncVector';
            end
            if strcmpi(obj.OperationMode,'Continuous')
                inputPortInd=inputPortInd+1;
                varargout{inputPortInd}='syncPunc';
                inputPortInd=inputPortInd+1;
                varargout{inputPortInd}='valid';
            else
                inputPortInd=inputPortInd+1;
                varargout{inputPortInd}='ctrl';
            end
        end

        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            outputPortInd=1;
            varargout{outputPortInd}='data';
            if strcmpi(obj.OperationMode,'Continuous')
                outputPortInd=outputPortInd+1;
                varargout{outputPortInd}='valid';
            else
                outputPortInd=outputPortInd+1;
                varargout{outputPortInd}='ctrl';
            end
            outputPortInd=outputPortInd+1;
            varargout{outputPortInd}='erasure';
        end

        function validateInputsImpl(obj,varargin)
            coder.extrinsic('tostringInternalSlName');
            if isempty(coder.target)||~coder.internal.isAmbiguousTypes

                validateattributes(varargin{1},{'logical','embedded.fi','double','single','numeric'},...
                {'scalar','real'},'Depuncturer','data');

                if strcmpi(obj.SpecifyInputs,'Input port')
                    coder.internal.errorIf(~(length(varargin{2})>=4&&...
                    length(varargin{2})<=28&&(~rem(length(varargin{2}),2))),...
                    'whdl:Depuncturer:InvalidPunctureVectorLength');
                    validateattributes(varargin{2},{'logical'},...
                    {'binary','vector','column'},'Depuncturer','puncVector');
                    if strcmpi(obj.OperationMode,'Continuous')
                        validateattributes(varargin{3},{'logical'},{'scalar'},...
                        'Depuncturer','syncPunc');
                        validateattributes(varargin{4},{'logical'},{'scalar'},...
                        'Depuncturer','valid');
                    else
                        validateattributes(varargin{3}.start,{'logical'},...
                        {'scalar'},'Depuncturer','start');
                        validateattributes(varargin{3}.end,{'logical'},...
                        {'scalar'},'Depuncturer','end');
                        validateattributes(varargin{3}.valid,{'logical'},...
                        {'scalar'},'Depuncturer','valid');
                    end
                else
                    if strcmpi(obj.OperationMode,'Continuous')
                        validateattributes(varargin{2},{'logical'},{'scalar'},...
                        'Depuncturer','syncPunc');
                        validateattributes(varargin{3},{'logical'},{'scalar'},...
                        'Depuncturer','valid');
                    else
                        validateattributes(varargin{2}.start,{'logical'},{'scalar'},...
                        'Depuncturer','start');
                        validateattributes(varargin{2}.end,{'logical'},{'scalar'},...
                        'Depuncturer','end');
                        validateattributes(varargin{2}.valid,{'logical'},{'scalar'},...
                        'Depuncturer','valid');
                    end
                end
            end
        end

        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            switch obj.SpecifyInputs
            case 'Input port'
                props={'PuncturingVector'};
            end
            flag=ismember(prop,props);
        end





        function varargout=getOutputDataTypeImpl(obj,varargin)
            if strcmpi(obj.OperationMode,'Continuous')
                varargout={propagatedInputDataType(obj,1),'logical','logical'};
            else
                varargout={propagatedInputDataType(obj,1),samplecontrolbustype,...
                'logical'};
            end
        end



        function varargout=isOutputComplexImpl(~)
            varargout={false,false,false};
        end



        function[sz1,sz2,sz3]=getOutputSizeImpl(~)
            sz1=[2,1];
            sz2=[1,1];
            sz3=[2,1];
        end



        function varargout=isOutputFixedSizeImpl(obj)
            if strcmpi(obj.OperationMode,'Continuous')
                varargout={true,true,true,true,true};
            else
                varargout={true,true,true,true,true,true,true};
            end
        end



        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.dataOut=obj.dataOut;
                s.ctrlOut=obj.ctrlOut;
                s.validOut=obj.validOut;
                s.erasureOut=obj.erasureOut;
                s.dataOutD=obj.dataOutD;
                s.ctrlOutD=obj.ctrlOutD;
                s.validOutD=obj.validOutD;
                s.erasureOutD=obj.erasureOutD;
                s.dataIn=obj.dataIn;
                s.dataInReg=obj.dataInReg;
                s.ctrlIn=obj.ctrlIn;
                s.ctrlInReg=obj.ctrlInReg;
                s.validIn=obj.validIn;
                s.validInReg=obj.validInReg;
                s.syncStart=obj.syncStart;
                s.syncStartReg=obj.syncStartReg;
                s.fsm=obj.fsm;
                s.Pattern=obj.Pattern;
                s.maxCount=obj.maxCount;
                s.PatternReg=obj.PatternReg;
                s.delayBalancer1=obj.delayBalancer1;
                s.delayBalancer2=obj.delayBalancer2;
                s.delayBalancer3=obj.delayBalancer3;
                s.delayBalancer4=obj.delayBalancer4;
                s.delayBalancer5=obj.delayBalancer5;
                s.delayBalancer6=obj.delayBalancer6;
                s.delayBalancer7=obj.delayBalancer7;
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