classdef(StrictDefaults)SymbolModulator<matlab.System








%#codegen




    properties(Nontunable)

        ModulationSource='Property';

        ModulationScheme='BPSK';



        OutputDataType='double';

        WordLength=16;
    end

    properties(Constant,Hidden)
        ModulationSourceSet=matlab.system.StringSet({...
        'Property','Input port'});
        ModulationSchemeSet=matlab.system.StringSet({...
        'BPSK','QPSK','16-QAM','64-QAM','256-QAM','pi/2-BPSK'});
        OutputDataTypeSet=matlab.system.StringSet({...
        'double','single','Custom'});
    end


    properties(Access=private)

        dataInReg;
        enbReg;
        loadReg;
        modSelReg;

        shiftReg;
        piby2BPSKPosFlag;
        count;
        symIndReg;
        Iaddr;
        Qaddr;
        validReg;
        offsetReg;
        modSelRegReg;
        loadRegReg;

        Ireg;
        Qreg;
        validRegReg;
    end

    properties(Nontunable,Access=private)

        LUT;

        numOfBitsPerSymCnt;
        modOrder;
        buffLen;
        inDisp;
    end




    methods

        function obj=SymbolModulator(varargin)
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

        function set.WordLength(obj,val)
            validateattributes(val,{'numeric'},{'integer',...
            'scalar','>',2,'<',33},'NRSymbolModulator','Word length');
            obj.WordLength=val;
        end
    end

    methods(Access=public)
        function latency=getLatency(obj,varargin)
            latency=[];
            if strcmpi(obj.ModulationSource,'Property')
                latency=modNumBitSym(obj)+3;
            end
        end
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl
            text=['Modulates the data bits to complex data symbols.',newline,newline...
            ,'For HDL code generation select output data type as custom with word lengths from 3 to 32.'];

            header=matlab.system.display.Header(mfilename('class'),...
            'Title','NR Symbol Modulator',...
            'Text',text,...
            'ShowSourceLink',false);
        end

        function groups=getPropertyGroupsImpl

            struc=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'ModulationSource','ModulationScheme'});
            main=matlab.system.display.SectionGroup(...
            'Title','Main',...
            'Sections',struc);
            dataTypeProp=matlab.system.display.Section(...
            'Title','',...
            'PropertyList',{'OutputDataType','WordLength'});

            dataType=matlab.system.display.SectionGroup(...
            'Title','Data Types',...
            'Sections',dataTypeProp);
            groups=[main,dataType];
        end

        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end
    end

    methods(Access=protected)
        function icon=getIconImpl(obj,varargin)
            if isempty(obj.inDisp)
                if strcmpi(obj.ModulationSource,'Property')
                    icon=sprintf('NR Symbol Modulator\nLatency = --');
                else
                    icon=sprintf('NR Symbol Modulator');
                end
            elseif strcmpi(obj.ModulationSource,'Property')
                icon=sprintf('NR Symbol Modulator\nLatency = %d',...
                getLatency(obj));
            else
                icon=sprintf('NR Symbol Modulator');
            end
        end

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end


        function resetImpl(obj)
            resetparams(obj)
        end

        function resetparams(obj)
            obj.enbReg=false;
            obj.validRegReg=false;
            obj.validReg=false;
            obj.symIndReg=false;
            obj.dataInReg=false;
            obj.piby2BPSKPosFlag=false;
            if strcmpi(obj.ModulationSource,'Property')

                obj.modOrder=modNumBitSym(obj);
                obj.shiftReg=false(obj.modOrder,1);
                obj.count=fi(0,0,floor(log2(obj.modOrder)+1),0,hdlfimath);
                obj.buffLen=obj.modOrder;
                obj.numOfBitsPerSymCnt=cast(obj.modOrder-1,'like',obj.count);
                obj.Iaddr=fi(0,0,ceil(obj.modOrder/2),0,hdlfimath);
                obj.Qaddr=fi(0,0,ceil(obj.modOrder/2),0,hdlfimath);
            else

                obj.count=fi(0,0,3,0,hdlfimath);
                obj.offsetReg=fi(0,0,5,0,hdlfimath);
                obj.shiftReg=false(8,1);
                obj.buffLen=8;
                obj.modSelReg=fi(1,0,3,0);
                obj.modSelRegReg=fi(1,0,3,0);
                obj.loadReg=false;
                obj.loadRegReg=false;
                obj.Iaddr=fi(0,0,5,0,hdlfimath);
                obj.Qaddr=fi(0,0,5,0,hdlfimath);
            end
            obj.Ireg=cast(0,'like',obj.LUT);
            obj.Qreg=cast(0,'like',obj.LUT);
        end

        function setupImpl(obj,varargin)

            initSymbolTable(obj);
            resetparams(obj);
        end

        function flag=getExecutionSemanticsImpl(~)

            flag={'Classic','Synchronous'};
        end

        function[data,valid]=outputImpl(obj,varargin)

            valid=obj.validRegReg;
            data=cast(obj.Ireg+1i*obj.Qreg,'like',obj.Ireg);
        end

        function updateImpl(obj,varargin)

            bit=varargin{1};
            enb=varargin{2};

            enbRegtmp=obj.enbReg;
            dataIntmp=obj.dataInReg;
            buffBits=buffer(obj,dataIntmp,enbRegtmp);
            if strcmpi(obj.ModulationSource,'Property')


                symInd=symIndProp(obj,enbRegtmp);

                [IaddrOut,QaddrOut,validOut]=addrsGenProp(obj,...
                symInd,buffBits);
            else

                if isempty(coder.target)||~coder.internal.isAmbiguousTypes


                    if~any((0:5)==(varargin{3}))
                        coder.internal.warning('whdl:NRSymbolModulator:InvalidModSelValue');
                    end
                end

                if isa(varargin{3},'double')||isa(varargin{3},'single')
                    if~ismember(varargin{3},(0:5))
                        modSel=fi(1,0,3,0);
                    else
                        modSel=fi(varargin{3},0,3,0);
                    end
                else
                    modSel=fi(varargin{3},0,3,0);
                end
                load=varargin{4};

                modSelRegRegtmp=obj.modSelRegReg;
                modSelRegtmp=obj.modSelReg;
                loadRegRegtmp=obj.loadRegReg;

                obj.modSelRegReg=obj.modSelReg;
                if(load)
                    if(modSel>fi(5,0,3,0))
                        obj.modSelReg=fi(1,0,3,0);
                    else
                        obj.modSelReg=modSel;
                    end
                end

                symInd=symIndPort(obj,enbRegtmp,load,...
                modSelRegtmp);
                b0=buffBits(1);
                b1=buffBits(2);
                b2=buffBits(3);
                b3=buffBits(4);
                b4=buffBits(5);
                b5=buffBits(6);
                b6=buffBits(7);
                b7=buffBits(8);

                offAdrs=offsetCalc(obj,modSelRegtmp);

                [IaddrOut,QaddrOut,validOut]=addrsGenPort(obj,modSelRegRegtmp,...
                symInd,loadRegRegtmp,offAdrs,b0,b1,b2,b3,b4,b5,b6,b7);

                obj.loadRegReg=obj.loadReg;
                obj.loadReg=load;
            end

            [Iout,Qout]=symbolTable(obj,IaddrOut,QaddrOut,validOut);


            obj.enbReg=enb;
            obj.dataInReg(:)=bit;

            obj.Ireg=Iout;
            obj.Qreg=Qout;
            obj.validRegReg=validOut;
        end

        function[modOrder]=modNumBitSym(obj)

            switch(obj.ModulationScheme)
            case 'BPSK'
                modOrder=1;
            case 'QPSK'
                modOrder=2;
            case '16-QAM'
                modOrder=4;
            case '64-QAM'
                modOrder=6;
            case '256-QAM'
                modOrder=8;
            case 'pi/2-BPSK'
                modOrder=1;
            otherwise
                modOrder=2;
            end
        end

        function offAdrs=offsetCalc(obj,modSel)


            offAdrs=obj.offsetReg;

            switch(uint32(modSel))
            case 0
                obj.offsetReg=fi(0,0,5,0,hdlfimath);
            case 1
                obj.offsetReg=fi(0,0,5,0,hdlfimath);
            case 2
                obj.offsetReg=fi(2,0,5,0,hdlfimath);
            case 3
                obj.offsetReg=fi(6,0,5,0,hdlfimath);
            case 4
                obj.offsetReg=fi(14,0,5,0,hdlfimath);
            case 5
                obj.offsetReg=fi(0,0,5,0,hdlfimath);
            otherwise
                obj.offsetReg=fi(0,0,5,0,hdlfimath);
            end
        end

        function buffBits=buffer(obj,bit,enb)

            buffBits=obj.shiftReg(end:-1:1);

            if(enb)
                for i=obj.buffLen:-1:2
                    obj.shiftReg(i)=obj.shiftReg(i-1);
                end
                obj.shiftReg(1)=bit;
            end
        end

        function symInd=symIndProp(obj,enb)

            symInd=obj.symIndReg;
            obj.symIndReg(:)=(obj.count==obj.numOfBitsPerSymCnt)&&enb;

            if(enb)
                if((obj.count(:)==obj.numOfBitsPerSymCnt))
                    obj.count(:)=0;
                else
                    obj.count(:)=obj.count+fi(1,0,1,0,hdlfimath);
                end
            end
        end

        function symInd=symIndPort(obj,enb,load,modSel)

            symInd=obj.symIndReg;

            reset=load;

            switch(int32(modSel))
            case 0
                bitsPerSymCnt=fi(0,0,3,0,hdlfimath);
            case 1
                bitsPerSymCnt=fi(1,0,3,0,hdlfimath);
            case 2
                bitsPerSymCnt=fi(3,0,3,0,hdlfimath);
            case 3
                bitsPerSymCnt=fi(5,0,3,0,hdlfimath);
            case 4
                bitsPerSymCnt=fi(7,0,3,0,hdlfimath);
            case 5
                bitsPerSymCnt=fi(0,0,3,0,hdlfimath);
            otherwise
                bitsPerSymCnt=fi(1,0,3,0,hdlfimath);
            end

            obj.symIndReg=(obj.count==bitsPerSymCnt)&&enb;

            if(reset)
                obj.count(:)=0;
            elseif(enb)
                if((obj.count(:)==bitsPerSymCnt))
                    obj.count(:)=0;
                else
                    obj.count(:)=obj.count+fi(1,0,1,0,hdlfimath);
                end
            end
        end

        function[IaddrOut,QaddrOut,validOut]=addrsGenProp(obj,symInd,bufferBits)

            IaddrOut=obj.Iaddr;
            QaddrOut=obj.Qaddr;
            validOut=obj.validReg;

            if strcmpi(obj.ModulationScheme,'pi/2-BPSK')
                bit=bufferBits;
                signChange=obj.piby2BPSKPosFlag;
                obj.Iaddr(:)=bitxor(fi(signChange,0,1,0),fi(bit,0,1,0));
                obj.Qaddr(:)=fi(bit,0,1,0);
                if(symInd)
                    obj.piby2BPSKPosFlag=~signChange;
                end
            elseif strcmpi(obj.ModulationScheme,'BPSK')
                bit=bufferBits;
                obj.Iaddr(:)=fi(bit,0,1,0);
                obj.Qaddr(:)=fi(bit,0,1,0);
            else

                evenPosBits=fi(bufferBits(end-1:-2:1),0,1,0);
                oddPosBits=fi(bufferBits(end:-2:2),0,1,0);
                obj.Iaddr(:)=bitconcat(evenPosBits);
                obj.Qaddr(:)=bitconcat(oddPosBits);
            end
            obj.validReg=symInd;
        end

        function[IaddrOut,QaddrOut,validOut]=addrsGenPort(obj,modSel,symInd,...
            load,offAddrs,b0,b1,b2,b3,b4,b5,b6,b7)

            IaddrOut=obj.Iaddr;
            QaddrOut=obj.Qaddr;
            validOut=obj.validReg;
            ufix1Const=fi(0,0,1,0);

            signChange=obj.piby2BPSKPosFlag&&~load;

            switch(modSel)
            case 0

                btmpI0=fi(b7,0,1,0);
                btmpI1=ufix1Const;
                btmpI2=ufix1Const;
                btmpI3=ufix1Const;
                btmpQ0=fi(b7,0,1,0);
                btmpQ1=ufix1Const;
                btmpQ2=ufix1Const;
                btmpQ3=ufix1Const;
            case 1

                btmpI0=fi(b6,0,1,0);
                btmpI1=ufix1Const;
                btmpI2=ufix1Const;
                btmpI3=ufix1Const;
                btmpQ0=fi(b7,0,1,0);
                btmpQ1=ufix1Const;
                btmpQ2=ufix1Const;
                btmpQ3=ufix1Const;
            case 2

                btmpI0=fi(b4,0,1,0);
                btmpI1=fi(b6,0,1,0);
                btmpI2=ufix1Const;
                btmpI3=ufix1Const;
                btmpQ0=fi(b5,0,1,0);
                btmpQ1=fi(b7,0,1,0);
                btmpQ2=ufix1Const;
                btmpQ3=ufix1Const;
            case 3

                btmpI0=fi(b2,0,1,0);
                btmpI1=fi(b4,0,1,0);
                btmpI2=fi(b6,0,1,0);
                btmpI3=ufix1Const;
                btmpQ0=fi(b3,0,1,0);
                btmpQ1=fi(b5,0,1,0);
                btmpQ2=fi(b7,0,1,0);
                btmpQ3=ufix1Const;
            case 4

                btmpI0=fi(b0,0,1,0);
                btmpI1=fi(b2,0,1,0);
                btmpI2=fi(b4,0,1,0);
                btmpI3=fi(b6,0,1,0);
                btmpQ0=fi(b1,0,1,0);
                btmpQ1=fi(b3,0,1,0);
                btmpQ2=fi(b5,0,1,0);
                btmpQ3=fi(b7,0,1,0);
            case 5


                btmpI0=bitxor(fi(signChange,0,1,0),fi(b7,0,1,0));
                btmpI1=ufix1Const;
                btmpI2=ufix1Const;
                btmpI3=ufix1Const;
                btmpQ0=fi(b7,0,1,0);
                btmpQ1=ufix1Const;
                btmpQ2=ufix1Const;
                btmpQ3=ufix1Const;

            otherwise

                btmpI0=fi(b6,0,1,0);
                btmpI1=ufix1Const;
                btmpI2=ufix1Const;
                btmpI3=ufix1Const;
                btmpQ0=fi(b7,0,1,0);
                btmpQ1=ufix1Const;
                btmpQ2=ufix1Const;
                btmpQ3=ufix1Const;
            end

            obj.Iaddr(:)=bitconcat(btmpI3,btmpI2,btmpI1,btmpI0)+offAddrs;
            obj.Qaddr(:)=bitconcat(btmpQ3,btmpQ2,btmpQ1,btmpQ0)+offAddrs;

            if(symInd&&(modSel==fi(5,0,3,0)))
                obj.piby2BPSKPosFlag=~signChange;
            end

            obj.validReg=symInd;
        end

        function[I,Q]=symbolTable(obj,absIAddr,absQAddr,validIn)

            if(validIn)
                I=obj.LUT(absIAddr+fi(1,0,1,0,hdlfimath));
                Q=obj.LUT(absQAddr+fi(1,0,1,0,hdlfimath));
            else
                I=obj.Ireg;
                Q=obj.Qreg;
            end
        end

        function initSymbolTable(obj)

            if strcmpi(obj.ModulationSource,'Input port')


                symbolLUT=[QPSKSymInit(obj)
                QAM16SymInit(obj)
                QAM64SymInit(obj)
                QAM256SymInit(obj)];
            else

                switch(obj.ModulationScheme)
                case 'BPSK'
                    symbolLUT=BPSKSymInit(obj);
                case 'QPSK'
                    symbolLUT=QPSKSymInit(obj);
                case '16-QAM'
                    symbolLUT=QAM16SymInit(obj);
                case '64-QAM'
                    symbolLUT=QAM64SymInit(obj);
                case '256-QAM'
                    symbolLUT=QAM256SymInit(obj);
                case 'pi/2-BPSK'
                    symbolLUT=piby2BPSKSymInit(obj);
                otherwise
                    symbolLUT=QPSKSymInit(obj);
                end
            end

            if strcmpi(obj.OutputDataType,'double')||strcmpi(obj.OutputDataType,'single')
                if(strcmpi(obj.OutputDataType,'single'))
                    obj.LUT=single(symbolLUT);
                else
                    obj.LUT=double(symbolLUT);
                end
            else
                obj.LUT=fi(symbolLUT,1,obj.WordLength,...
                obj.WordLength-2);
            end
        end

        function symOutInit=BPSKSymInit(~)

            symo=(1-2*0);
            sym1=(1-2*1);
            symOutInit=[symo;sym1]/sqrt(2);
        end

        function symOutInit=QPSKSymInit(~)

            symo=(1-2*0);
            sym1=(1-2*1);
            symOutInit=[symo;sym1]/sqrt(2);
        end

        function symOutInit=QAM16SymInit(~)

            bits=(reshape(coder.const(feval('int2bit',0:3,2,false)),2,[])).';
            symi=(1-2*bits(:,1)).*(2-(1-2*bits(:,2)));
            symOutInit=symi/sqrt(10);
        end

        function symOutInit=QAM64SymInit(~)

            bits=(reshape(coder.const(feval('int2bit',0:7,3,false)),3,[])).';
            symi=(1-2*bits(:,1)).*(4-((1-2*bits(:,2)).*(2-(1-2*bits(:,3)))));
            symOutInit=symi/sqrt(42);
        end

        function symOutInit=QAM256SymInit(~)

            bits=(reshape(coder.const(feval('int2bit',0:15,4,false)),4,[])).';
            symi=(1-2*bits(:,1)).*(8-(1-2*bits(:,2)).*...
            (4-((1-2*bits(:,3)).*(2-(1-2*bits(:,4))))));
            symOutInit=symi/sqrt(170);
        end

        function symOutInit=piby2BPSKSymInit(~)

            symo=(1-2*0);
            sym1=(1-2*1);
            symOutInit=[symo;sym1]/sqrt(2);
        end

        function num=getNumInputsImpl(obj)
            num=2;
            if strcmpi(obj.ModulationSource,'Input port')
                num=num+2;
            end
        end

        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='data';
            varargout{2}='valid';
            if strcmpi(obj.ModulationSource,'Input port')
                varargout{3}='modSel';
                varargout{4}='load';
            end
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end

        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='data';
            varargout{2}='valid';
        end

        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if strcmpi(obj.ModulationSource,'Input Port')
                props=[props,...
                {'ModulationScheme'}];
            end
            if~strcmpi(obj.OutputDataType,'Custom')
                props=[props,...
                {'WordLength'}];
            end
            flag=ismember(prop,props);
        end

        function validateInputsImpl(obj,varargin)
            coder.extrinsic('tostringInternalSlName');
            if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                validateattributes(varargin{1},...
                {'logical','embedded.fi'},{'scalar'},...
                'NRSymbolModulator','data');
                if isa(varargin{1},'embedded.fi')
                    [WL,FL,~]=dsphdlshared.hdlgetwordsizefromdata(varargin{1});
                    errCond=WL>1||(WL==1)&&(FL~=0);
                    if(errCond)
                        coder.internal.error('whdl:NRSymbolModulator:InvalidDataType',...
                        tostringInternalSlName(varargin{1}.numerictype));
                    end
                end
                validateattributes(varargin{2},{'logical'},{'scalar'},...
                'NRSymbolModulator','valid');
                if strcmpi(obj.ModulationSource,'Input Port')
                    validateattributes(varargin{3},{'double','single','embedded.fi'},...
                    {'scalar'},'NRSymbolModulator','modSel');
                    if isa(varargin{3},'embedded.fi')
                        [WL,FL,~]=dsphdlshared.hdlgetwordsizefromdata(varargin{3});
                        errCond=~((WL==3)&&(FL==0));
                        if(errCond)
                            coder.internal.error('whdl:NRSymbolModulator:InvalidModSelType',...
                            tostringInternalSlName(varargin{3}.numerictype));
                        end
                    end
                    validateattributes(varargin{4},{'logical'},...
                    {'scalar'},'NRSymbolModulator','load');
                end
                obj.inDisp=~isempty(varargin{1});
            end
        end



        function varargout=getOutputDataTypeImpl(obj,varargin)
            if strcmpi(obj.OutputDataType,'double')||strcmpi(obj.OutputDataType,'single')
                varargout={obj.OutputDataType,'logical'};
            else
                varargout={numerictype(1,obj.WordLength,obj.WordLength-2),'logical'};
            end
        end

        function varargout=isOutputComplexImpl(~)
            varargout={true,false};
        end

        function[sz1,sz2]=getOutputSizeImpl(~)
            sz1=[1,1];
            sz2=[1,1];
        end

        function varargout=isOutputFixedSizeImpl(~)
            varargout={true,true};
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked

                s.dataInReg=obj.dataInReg;
                s.enbReg=obj.enbReg;
                s.loadReg=obj.loadReg;
                s.modSelReg=obj.modSelReg;
                s.shiftReg=obj.shiftReg;
                s.modOrder=obj.modOrder;
                s.piby2BPSKPosFlag=obj.piby2BPSKPosFlag;
                s.count=obj.count;
                s.symIndReg=obj.symIndReg;
                s.Iaddr=obj.Iaddr;
                s.Qaddr=obj.Qaddr;
                s.validReg=obj.validReg;
                s.offsetReg=obj.offsetReg;
                s.modSelRegReg=obj.modSelRegReg;
                s.loadRegReg=obj.loadRegReg;
                s.inDisp=obj.inDisp;

                s.Ireg=obj.Ireg;
                s.Qreg=obj.Qreg;
                s.validRegReg=obj.validRegReg;
                s.numOfBitsPerSymCnt=obj.numOfBitsPerSymCnt;
                s.buffLen=obj.buffLen;
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


