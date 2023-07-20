classdef(StrictDefaults)SymbolDemodulator<matlab.System








%#codegen





    properties(Nontunable)

        ModulationSource='Property';

        ModulationScheme='BPSK'

        DecisionType='Soft'




        RoundingMethod='Floor';
    end

    properties(Access=private)

        dataInReal;
        dataInImag;
        modSelReg;
        modSelReg1;
        modSelReg2;

        dataOut;
        validOut;
        dataOutReg;
        validOutReg;
        readyReg;
        addOut;
        dataTerm;
        dataRI;
        dataRIReg;
        dataRIReg1;
        dataAbs;
        dataAbsReg;
        dataSetReg;

        index;
        count;
        BPSKflag;
        piby2BPSKflag;
        evenSC;
        modSwitch;

        regionBoundReg;
        region4;
        region16;
        region64;
        region256;

        multLUT256;
        multLUT64;
        multLUT16;
        multLUT4;
        multLUT;
        multLUTProp;

        addLUT256N;
        addLUT256P;
        addLUT64N;
        addLUT64P;
        addLUT16N;
        addLUT16P;
        addLUT4N;
        addLUT4P;
        addLUT;
        addLUTProp;

        modAddrReg;
        addressReg;
        addr1;
        addr2;
        prodOut;
        prodIn1;
        prodIn2;
        condition;

delayModSel
        delayModAddr;
        delayValid;
        delayCount;
        delayProdIn1;
        delayProdIn2;
        delayAddr;
        delayData;
        userFimath;
    end

    properties(Constant,Hidden)
        ModulationSourceSet=matlab.system.StringSet({...
        'Input port','Property'});

        ModulationSchemeSet=matlab.system.StringSet({...
        'BPSK','QPSK','16-QAM','64-QAM','256-QAM','pi/2-BPSK'});

        DecisionTypeSet=matlab.system.StringSet({'Hard','Soft'});

        RoundingMethodSet=matlab.system.StringSet({...
        'Ceiling','Convergent','Floor','Nearest','Round','Zero'});
    end





    methods


        function obj=SymbolDemodulator(varargin)
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
            text='Demodulates the input complex constellation symbol into a set of LLR values or bits.';

            header=matlab.system.display.Header(mfilename('class'),...
            'Title','NR Symbol Demodulator',...
            'Text',text,...
            'ShowSourceLink',false);
        end



        function groups=getPropertyGroupsImpl
            struc=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'ModulationSource','ModulationScheme','DecisionType','RoundingMethod'});

            main=matlab.system.display.SectionGroup(...
            'Title','Main',...
            'Sections',struc);

            groups=main;
        end



        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end

    end



    methods(Access=public)
        function latency=getLatency(~)
            latency=13;
        end
    end



    methods(Access=protected)



        function icon=getIconImpl(obj)
            if strcmpi(obj.ModulationSource,'Property')
                icon=sprintf('NR Symbol Demodulator \nLatency = %d',getLatency(obj));
            else
                icon=sprintf('NR Symbol \nDemodulator');
            end
        end

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end



        function resetImpl(obj)
            obj.dataOut(:)=0;
            obj.dataOutReg(:)=0;
            obj.dataInReal(:)=0;
            obj.dataInImag(:)=0;
            obj.addOut(:)=0;
            obj.prodOut(:)=0;
            obj.prodIn1(:)=0;
            obj.prodIn2(:)=0;
            obj.userFimath=fimath('RoundingMethod',obj.RoundingMethod,'OverflowAction','Wrap');

            obj.multLUT256(:)=(4*[1,4,2,1,2,3,1,1,3,2,1,1,4,1,2,1,5,1,2,1,6,2,1,1,7,3,1,1,8,4,2,1]/sqrt(170));
            obj.multLUT64(:)=(4*[1,2,1,1,2,1,1,1,3,1,1,1,4,2,1,1,4,2,1,1,4,2,1,1,4,2,1,1,4,2,1,1]/sqrt(42));
            obj.multLUT16(:)=(4*[1,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1]/sqrt(10));
            obj.multLUT4(:)=(4*ones(1,32)/sqrt(2));
            obj.multLUT(:)=[obj.multLUT4,obj.multLUT4,obj.multLUT16,obj.multLUT64,obj.multLUT256,obj.multLUT4,obj.multLUT4,obj.multLUT16,obj.multLUT64,obj.multLUT256];

            obj.addLUT256N(:)=([0,5,-3,-2,1,6,-4,-2,2,7,-4,6,3,8,-5,6,4,8,11,-10,5,9,12,-10,6,10,12,14,7,11,13,14]/sqrt(170));
            obj.addLUT256P(:)=([0,5,-3,-2,-1,6,-4,-2,-2,7,-4,6,-3,8,-5,6,-4,8,11,-10,-5,9,12,-10,-6,10,12,14,-7,11,13,14]/sqrt(170));
            obj.addLUT64N(:)=([0,3,-2,0,1,4,-2,0,2,4,6,0,3,5,6,0,3,5,6,0,3,5,6,0,3,5,6,0,3,5,6,0]/sqrt(42));
            obj.addLUT64P(:)=([0,3,-2,0,-1,4,-2,0,-2,4,6,0,-3,5,6,0,-3,5,6,0,-3,5,6,0,-3,5,6,0,-3,5,6,0]/sqrt(42));
            obj.addLUT16N(:)=([0,2,0,0,1,2,0,0,1,2,0,0,1,2,0,0,1,2,0,0,1,2,0,0,1,2,0,0,1,2,0,0]/sqrt(10));
            obj.addLUT16P(:)=([0,2,0,0,-1,2,0,0,-1,2,0,0,-1,2,0,0,-1,2,0,0,-1,2,0,0,-1,2,0,0,-1,2,0,0]/sqrt(10));
            obj.addLUT4N(:)=zeros(1,32);
            obj.addLUT4P(:)=zeros(1,32);
            obj.addLUT(:)=[obj.addLUT4P,obj.addLUT4P,obj.addLUT16P,obj.addLUT64P,obj.addLUT256P,obj.addLUT4N,obj.addLUT4N,obj.addLUT16N,obj.addLUT64N,obj.addLUT256N];

            obj.regionBoundReg(:)=zeros(7,1);
            obj.region256(:)=([2;4;6;8;10;12;14]/sqrt(170));
            obj.region64(:)=([2;4;6;8;10;12;14]/sqrt(42));
            obj.region16(:)=([2;4;6;8;10;12;14]/sqrt(10));
            obj.region4(:)=([2;4;6;8;10;12;14]/sqrt(2));
            obj.dataRI(:)=0;
            obj.dataAbs(:)=0;
            obj.dataAbsReg(:)=0;
            obj.dataRIReg(:)=0;
            obj.dataRIReg1(:)=0;
            obj.dataSetReg(:)=zeros(4,1);
            obj.dataTerm(:)=0;
            if(strcmpi(obj.ModulationScheme,'BPSK'))
                obj.addLUTProp=[obj.addLUT4P,obj.addLUT4N];
                obj.multLUTProp=[obj.multLUT4,obj.multLUT4];
            elseif(strcmpi(obj.ModulationScheme,'QPSK'))
                obj.addLUTProp=[obj.addLUT4P,obj.addLUT4N];
                obj.multLUTProp=[obj.multLUT4,obj.multLUT4];
            elseif(strcmpi(obj.ModulationScheme,'16-QAM'))
                obj.addLUTProp=[obj.addLUT16P,obj.addLUT16N];
                obj.multLUTProp=[obj.multLUT16,obj.multLUT16];
            elseif(strcmpi(obj.ModulationScheme,'64-QAM'))
                obj.addLUTProp=[obj.addLUT64P,obj.addLUT64N];
                obj.multLUTProp=[obj.multLUT64,obj.multLUT64];
            elseif(strcmpi(obj.ModulationScheme,'256-QAM'))
                obj.addLUTProp=[obj.addLUT256P,obj.addLUT256N];
                obj.multLUTProp=[obj.multLUT256,obj.multLUT256];
            elseif(strcmpi(obj.ModulationScheme,'pi/2-BPSK'))
                obj.addLUTProp=[obj.addLUT4P,obj.addLUT4N];
                obj.multLUTProp=[obj.multLUT4,obj.multLUT4];
            else
                obj.addLUTProp=cast(zeros(1,64),'like',real(dIn));
                obj.multLUTProp=cast(zeros(1,64),'like',real(dIn));
            end
            obj.validOut(:)=false;
            obj.validOutReg(:)=false;
            obj.readyReg(:)=true;
            obj.count(:)=fi(0,0,4,0,hdlfimath);
            obj.index(:)=fi(0,0,4,0,hdlfimath);
            obj.modSelReg(:)=fi(0,0,3,0);
            obj.modSelReg1(:)=fi(0,0,3,0);
            obj.modSelReg2(:)=fi(0,0,3,0);
            obj.modSwitch(:)=false;
            obj.evenSC(:)=false;
            obj.BPSKflag(:)=false;
            obj.modAddrReg(:)=fi(0,0,9,0,hdlfimath);
            obj.addressReg(:)=fi(0,0,9,0,hdlfimath);
            obj.addr1(:)=fi(0,0,9,0,hdlfimath);
            obj.addr2(:)=fi(0,0,9,0,hdlfimath);
            obj.condition(:)=false(1,13);


            if(strcmpi(obj.ModulationSource,'Input port'))
                reset(obj.delayModSel);
                reset(obj.delayModAddr);
            end
            reset(obj.delayValid);
            reset(obj.delayCount);
            reset(obj.delayProdIn1);
            reset(obj.delayProdIn2);
            reset(obj.delayAddr);
            reset(obj.delayData);
        end


        function setupImpl(obj,varargin)
            dIn=varargin{1};
            obj.userFimath=fimath('RoundingMethod',obj.RoundingMethod,'OverflowAction','Wrap');
            if~isfloat(dIn)
                bitGrowth=3;
                if isa(dIn,'int8')
                    inpData=fi(0,1,8,0);
                elseif(isa(dIn,'int16'))
                    inpData=fi(0,1,16,0);
                elseif(isa(dIn,'int32'))
                    inpData=fi(0,1,32,0);
                else
                    inpData=dIn;
                end
                if(strcmpi(obj.DecisionType,'Hard'))
                    obj.dataOut=false;
                    obj.dataOutReg=false;
                else

                    obj.dataOut=fi(0,1,inpData.WordLength+bitGrowth,inpData.FractionLength,obj.userFimath);
                    obj.dataOutReg=fi(0,1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);

                end
                obj.dataInReal=fi(0,1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                obj.dataInImag=fi(0,1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                obj.addOut=fi(0,1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                obj.prodOut=fi(0,1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                obj.prodIn1=fi(0,1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                obj.prodIn2=fi(0,1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);

                if inpData.FractionLength~=0
                    obj.multLUT256=fi(4*[1,4,2,1,2,3,1,1,3,2,1,1,4,1,2,1,5,1,2,1,6,2,1,1,7,3,1,1,8,4,2,1]/sqrt(170),0,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                    obj.multLUT64=fi(4*[1,2,1,1,2,1,1,1,3,1,1,1,4,2,1,1,4,2,1,1,4,2,1,1,4,2,1,1,4,2,1,1]/sqrt(42),0,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                    obj.multLUT16=fi(4*[1,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1]/sqrt(10),0,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                    obj.multLUT4=fi(4*ones(1,32)/sqrt(2),0,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                    obj.multLUT=[obj.multLUT4,obj.multLUT4,obj.multLUT16,obj.multLUT64,obj.multLUT256,obj.multLUT4,obj.multLUT4,obj.multLUT16,obj.multLUT64,obj.multLUT256];

                    obj.addLUT256N=fi([0,5,-3,-2,1,6,-4,-2,2,7,-4,6,3,8,-5,6,4,8,11,-10,5,9,12,-10,6,10,12,14,7,11,13,14]/sqrt(170),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                    obj.addLUT256P=fi([0,5,-3,-2,-1,6,-4,-2,-2,7,-4,6,-3,8,-5,6,-4,8,11,-10,-5,9,12,-10,-6,10,12,14,-7,11,13,14]/sqrt(170),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                    obj.addLUT64N=fi([0,3,-2,0,1,4,-2,0,2,4,6,0,3,5,6,0,3,5,6,0,3,5,6,0,3,5,6,0,3,5,6,0]/sqrt(42),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                    obj.addLUT64P=fi([0,3,-2,0,-1,4,-2,0,-2,4,6,0,-3,5,6,0,-3,5,6,0,-3,5,6,0,-3,5,6,0,-3,5,6,0]/sqrt(42),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                    obj.addLUT16N=fi([0,2,0,0,1,2,0,0,1,2,0,0,1,2,0,0,1,2,0,0,1,2,0,0,1,2,0,0,1,2,0,0]/sqrt(10),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                    obj.addLUT16P=fi([0,2,0,0,-1,2,0,0,-1,2,0,0,-1,2,0,0,-1,2,0,0,-1,2,0,0,-1,2,0,0,-1,2,0,0]/sqrt(10),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                    obj.addLUT4N=fi(zeros(1,32),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                    obj.addLUT4P=fi(zeros(1,32),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                else
                    obj.multLUT256=fi(4*[1,4,2,1,2,3,1,1,3,2,1,1,4,1,2,1,5,1,2,1,6,2,1,1,7,3,1,1,8,4,2,1]/sqrt(170),0,inpData.WordLength+bitGrowth,inpData.WordLength,hdlfimath);
                    obj.multLUT64=fi(4*[1,2,1,1,2,1,1,1,3,1,1,1,4,2,1,1,4,2,1,1,4,2,1,1,4,2,1,1,4,2,1,1]/sqrt(42),0,inpData.WordLength+bitGrowth,inpData.WordLength,hdlfimath);
                    obj.multLUT16=fi(4*[1,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1]/sqrt(10),0,inpData.WordLength+bitGrowth,inpData.WordLength,hdlfimath);
                    obj.multLUT4=fi(4*ones(1,32)/sqrt(2),0,inpData.WordLength+bitGrowth,inpData.WordLength,hdlfimath);
                    obj.multLUT=[obj.multLUT4,obj.multLUT4,obj.multLUT16,obj.multLUT64,obj.multLUT256,obj.multLUT4,obj.multLUT4,obj.multLUT16,obj.multLUT64,obj.multLUT256];

                    obj.addLUT256N=fi([0,5,-3,-2,1,6,-4,-2,2,7,-4,6,3,8,-5,6,4,8,11,-10,5,9,12,-10,6,10,12,14,7,11,13,14]/sqrt(170),1,inpData.WordLength+bitGrowth,inpData.WordLength,hdlfimath);
                    obj.addLUT256P=fi([0,5,-3,-2,-1,6,-4,-2,-2,7,-4,6,-3,8,-5,6,-4,8,11,-10,-5,9,12,-10,-6,10,12,14,-7,11,13,14]/sqrt(170),1,inpData.WordLength+bitGrowth,inpData.WordLength,hdlfimath);
                    obj.addLUT64N=fi([0,3,-2,0,1,4,-2,0,2,4,6,0,3,5,6,0,3,5,6,0,3,5,6,0,3,5,6,0,3,5,6,0]/sqrt(42),1,inpData.WordLength+bitGrowth,inpData.WordLength,hdlfimath);
                    obj.addLUT64P=fi([0,3,-2,0,-1,4,-2,0,-2,4,6,0,-3,5,6,0,-3,5,6,0,-3,5,6,0,-3,5,6,0,-3,5,6,0]/sqrt(42),1,inpData.WordLength+bitGrowth,inpData.WordLength,hdlfimath);
                    obj.addLUT16N=fi([0,2,0,0,1,2,0,0,1,2,0,0,1,2,0,0,1,2,0,0,1,2,0,0,1,2,0,0,1,2,0,0]/sqrt(10),1,inpData.WordLength+bitGrowth,inpData.WordLength,hdlfimath);
                    obj.addLUT16P=fi([0,2,0,0,-1,2,0,0,-1,2,0,0,-1,2,0,0,-1,2,0,0,-1,2,0,0,-1,2,0,0,-1,2,0,0]/sqrt(10),1,inpData.WordLength+bitGrowth,inpData.WordLength,hdlfimath);
                    obj.addLUT4N=fi(zeros(1,32),1,inpData.WordLength+bitGrowth,inpData.WordLength,hdlfimath);
                    obj.addLUT4P=fi(zeros(1,32),1,inpData.WordLength+bitGrowth,inpData.WordLength,hdlfimath);
                end
                obj.addLUT=[obj.addLUT4P,obj.addLUT4P,obj.addLUT16P,obj.addLUT64P,obj.addLUT256P,obj.addLUT4N,obj.addLUT4N,obj.addLUT16N,obj.addLUT64N,obj.addLUT256N];

                if inpData.FractionLength~=0
                    obj.regionBoundReg=fi(zeros(7,1),0,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                    obj.region256=fi([2;4;6;8;10;12;14]/sqrt(170),0,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                    obj.region64=fi([2;4;6;8;10;12;14]/sqrt(42),0,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                    obj.region16=fi([2;4;6;8;10;12;14]/sqrt(10),0,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                    obj.region4=fi([2;4;6;8;10;12;14]/sqrt(2),0,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                else
                    obj.regionBoundReg=fi(zeros(7,1),0,inpData.WordLength+bitGrowth,inpData.WordLength,hdlfimath);
                    obj.region256=fi([2;4;6;8;10;12;14]/sqrt(170),0,inpData.WordLength+bitGrowth,inpData.WordLength,hdlfimath);
                    obj.region64=fi([2;4;6;8;10;12;14]/sqrt(42),0,inpData.WordLength+bitGrowth,inpData.WordLength,hdlfimath);
                    obj.region16=fi([2;4;6;8;10;12;14]/sqrt(10),0,inpData.WordLength+bitGrowth,inpData.WordLength,hdlfimath);
                    obj.region4=fi([2;4;6;8;10;12;14]/sqrt(2),0,inpData.WordLength+bitGrowth,inpData.WordLength,hdlfimath);
                end

                obj.dataRI=fi(0,1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                obj.dataAbs=fi(0,1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                obj.dataAbsReg=fi(0,1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                obj.dataRIReg=fi(0,1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                obj.dataRIReg1=fi(0,1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                obj.dataSetReg=fi(zeros(4,1),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                obj.dataTerm=fi(0,1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);

            else
                if(strcmpi(obj.DecisionType,'Hard'))
                    obj.dataOut=false;
                    obj.dataOutReg=false;
                else
                    obj.dataOut=cast(0,'like',real(dIn));
                    obj.dataOutReg=cast(0,'like',real(dIn));
                end
                obj.dataInReal=cast(0,'like',real(dIn));
                obj.dataInImag=cast(0,'like',real(dIn));
                obj.addOut=cast(0,'like',real(dIn));
                obj.prodOut=cast(0,'like',real(dIn));
                obj.prodIn1=cast(0,'like',real(dIn));
                obj.prodIn2=cast(0,'like',real(dIn));

                obj.multLUT256=cast(4*[1,4,2,1,2,3,1,1,3,2,1,1,4,1,2,1,5,1,2,1,6,2,1,1,7,3,1,1,8,4,2,1]/sqrt(170),'like',real(dIn));
                obj.multLUT64=cast(4*[1,2,1,1,2,1,1,1,3,1,1,1,4,2,1,1,4,2,1,1,4,2,1,1,4,2,1,1,4,2,1,1]/sqrt(42),'like',real(dIn));
                obj.multLUT16=cast(4*[1,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1]/sqrt(10),'like',real(dIn));
                obj.multLUT4=cast(4*ones(1,32)/sqrt(2),'like',real(dIn));
                obj.multLUT=[obj.multLUT4,obj.multLUT4,obj.multLUT16,obj.multLUT64,obj.multLUT256,obj.multLUT4,obj.multLUT4,obj.multLUT16,obj.multLUT64,obj.multLUT256];

                obj.addLUT256N=cast([0,5,-3,-2,1,6,-4,-2,2,7,-4,6,3,8,-5,6,4,8,11,-10,5,9,12,-10,6,10,12,14,7,11,13,14]/sqrt(170),'like',real(dIn));
                obj.addLUT256P=cast([0,5,-3,-2,-1,6,-4,-2,-2,7,-4,6,-3,8,-5,6,-4,8,11,-10,-5,9,12,-10,-6,10,12,14,-7,11,13,14]/sqrt(170),'like',real(dIn));
                obj.addLUT64N=cast([0,3,-2,0,1,4,-2,0,2,4,6,0,3,5,6,0,3,5,6,0,3,5,6,0,3,5,6,0,3,5,6,0]/sqrt(42),'like',real(dIn));
                obj.addLUT64P=cast([0,3,-2,0,-1,4,-2,0,-2,4,6,0,-3,5,6,0,-3,5,6,0,-3,5,6,0,-3,5,6,0,-3,5,6,0]/sqrt(42),'like',real(dIn));
                obj.addLUT16N=cast([0,2,0,0,1,2,0,0,1,2,0,0,1,2,0,0,1,2,0,0,1,2,0,0,1,2,0,0,1,2,0,0]/sqrt(10),'like',real(dIn));
                obj.addLUT16P=cast([0,2,0,0,-1,2,0,0,-1,2,0,0,-1,2,0,0,-1,2,0,0,-1,2,0,0,-1,2,0,0,-1,2,0,0]/sqrt(10),'like',real(dIn));
                obj.addLUT4N=cast(zeros(1,32),'like',real(dIn));
                obj.addLUT4P=cast(zeros(1,32),'like',real(dIn));
                obj.addLUT=[obj.addLUT4P,obj.addLUT4P,obj.addLUT16P,obj.addLUT64P,obj.addLUT256P,obj.addLUT4N,obj.addLUT4N,obj.addLUT16N,obj.addLUT64N,obj.addLUT256N];

                obj.regionBoundReg=cast(zeros(7,1),'like',real(dIn));
                obj.region256=cast([2;4;6;8;10;12;14]/sqrt(170),'like',real(dIn));
                obj.region64=cast([2;4;6;8;10;12;14]/sqrt(42),'like',real(dIn));
                obj.region16=cast([2;4;6;8;10;12;14]/sqrt(10),'like',real(dIn));
                obj.region4=cast([2;4;6;8;10;12;14]/sqrt(2),'like',real(dIn));

                obj.dataRI=cast(0,'like',real(dIn));
                obj.dataAbs=cast(0,'like',real(dIn));
                obj.dataAbsReg=cast(0,'like',real(dIn));
                obj.dataRIReg=cast(0,'like',real(dIn));
                obj.dataRIReg1=cast(0,'like',real(dIn));
                obj.dataSetReg=cast(zeros(4,1),'like',real(dIn));
                obj.dataTerm=cast(0,'like',real(dIn));
            end

            if(strcmpi(obj.ModulationScheme,'BPSK'))
                obj.addLUTProp=[obj.addLUT4P,obj.addLUT4N];
                obj.multLUTProp=[obj.multLUT4,obj.multLUT4];
            elseif(strcmpi(obj.ModulationScheme,'QPSK'))
                obj.addLUTProp=[obj.addLUT4P,obj.addLUT4N];
                obj.multLUTProp=[obj.multLUT4,obj.multLUT4];
            elseif(strcmpi(obj.ModulationScheme,'16-QAM'))
                obj.addLUTProp=[obj.addLUT16P,obj.addLUT16N];
                obj.multLUTProp=[obj.multLUT16,obj.multLUT16];
            elseif(strcmpi(obj.ModulationScheme,'64-QAM'))
                obj.addLUTProp=[obj.addLUT64P,obj.addLUT64N];
                obj.multLUTProp=[obj.multLUT64,obj.multLUT64];
            elseif(strcmpi(obj.ModulationScheme,'256-QAM'))
                obj.addLUTProp=[obj.addLUT256P,obj.addLUT256N];
                obj.multLUTProp=[obj.multLUT256,obj.multLUT256];
            elseif(strcmpi(obj.ModulationScheme,'pi/2-BPSK'))
                obj.addLUTProp=[obj.addLUT4P,obj.addLUT4N];
                obj.multLUTProp=[obj.multLUT4,obj.multLUT4];
            else
                obj.addLUTProp=cast(zeros(1,64),'like',real(dIn));
                obj.multLUTProp=cast(zeros(1,64),'like',real(dIn));
            end

            obj.validOut=false;
            obj.validOutReg=false;
            obj.readyReg=true;
            obj.count=fi(0,0,4,0,hdlfimath);
            obj.index=fi(0,0,4,0,hdlfimath);
            obj.modSelReg=fi(0,0,3,0);
            obj.modSelReg1=fi(0,0,3,0);
            obj.modSelReg2=fi(0,0,3,0);
            obj.modSwitch=false;
            obj.evenSC=false;
            obj.BPSKflag=false;
            obj.modAddrReg=fi(0,0,9,0,hdlfimath);
            obj.addressReg=fi(0,0,9,0,hdlfimath);
            obj.addr1=fi(0,0,9,0,hdlfimath);
            obj.addr2=fi(0,0,9,0,hdlfimath);
            obj.condition=false(1,13);


            if(strcmpi(obj.ModulationSource,'Input port'))
                obj.delayModSel=dsp.Delay(3);
                obj.delayModAddr=dsp.Delay(3);
            end
            obj.delayValid=dsp.Delay(11);
            obj.delayCount=dsp.Delay(4);
            obj.delayProdIn1=dsp.Delay(2);
            obj.delayProdIn2=dsp.Delay(3);
            obj.delayAddr=dsp.Delay(2);
            obj.delayData=dsp.Delay(3);
        end



        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end



        function varargout=isInputDirectFeedthroughImpl(~,varargin)
            varargout{1}=false;
            varargout{2}=true;
            varargout{3}=true;
        end



        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.dataOut;
            varargout{2}=obj.validOutReg;


            validIn=varargin{2};
            rdyReg=obj.readyReg;
            dataValid=validIn&&rdyReg;

            flg=strcmpi(obj.ModulationSource,'Input Port');
            if(flg)
                val=varargin{3};
            else
                val=1;
            end
            nextIndex=obj.indexCalc(dataValid,flg,val);
            nextCount=obj.counter(dataValid,nextIndex,rdyReg);

            varargout{3}=((nextCount==nextIndex)||(nextCount==0&&~dataValid));

        end



        function updateImpl(obj,varargin)
            validIn=varargin{2};
            dataValid=validIn&&obj.readyReg;


            if(strcmpi(obj.ModulationSource,'Input port'))
                if isempty(coder.target)||~coder.internal.isAmbiguousTypes


                    if~any((0:5)==(varargin{3}))
                        coder.internal.warning('whdl:NRSymbolDemodulator:InvalidModSelValue');
                    end
                end

                [modAddr,regionBounds]=SelectRegionBounds(obj,obj.modSelReg1);
                modAddrD=obj.delayModAddr(modAddr);
                obj.modSelReg1(:)=obj.modSelReg;
                modSel=obj.delayModSel(obj.modSelReg1);

                [dataSet]=Region2data(obj,obj.dataRIReg1,obj.dataAbsReg,obj.condition,modSel);

                [addr]=Region2Address(obj,obj.dataRIReg1,obj.condition);


                obj.dataRIReg1(:)=obj.dataRI;
                RealImagSelectionUnit(obj,obj.dataInReal,obj.dataInImag,obj.count,obj.BPSKflag,obj.evenSC);

                obj.dataAbsReg(:)=obj.dataAbs;
                obj.dataAbs(:)=abs(obj.dataRI);

                getCondition(obj,obj.dataAbsReg,regionBounds);


                countRL=bitsrl(obj.count,1);
                countRLReg=obj.delayCount(countRL);


                obj.dataTerm(:)=dataSet(countRLReg+fi(1,0,1,0));
                dataTermReg=obj.delayData(obj.dataTerm);

                addRess=cast(obj.addr1+modAddrD,'like',obj.addr1);
                obj.addr1(:)=addr+countRLReg;
                addRessReg=obj.delayAddr(addRess);

                addTerm=obj.addLUT(addRessReg+fi(1,0,1,0));
                multTerm=obj.multLUT(addRessReg+fi(1,0,1,0));

                obj.prodIn2(:)=obj.delayProdIn2(multTerm);

                if(strcmpi(obj.DecisionType,'Soft'))
                    obj.dataOut(:)=obj.prodOut;

                    obj.prodOut(:)=obj.prodIn1*obj.prodIn2;
                else
                    obj.dataOut(:)=obj.prodOut<0;
                    obj.prodOut(:)=obj.prodIn1;
                end

                obj.addOut(:)=dataTermReg+addTerm;

                obj.prodIn1(:)=obj.delayProdIn1(obj.addOut);

                if(dataValid)
                    obj.modSelReg(:)=varargin{3};
                    obj.dataInReal(:)=real(varargin{1});
                    obj.dataInImag(:)=imag(varargin{1});

                    obj.modSwitch(:)=(obj.modSelReg~=obj.modSelReg1);
                    if(obj.modSwitch)
                        obj.evenSC(:)=false;
                        obj.BPSKflag(:)=false;
                    end

                    if(obj.modSelReg==0)
                        obj.index(:)=0;
                        obj.BPSKflag(:)=true;
                        obj.evenSC(:)=true;
                    elseif(obj.modSelReg==1)
                        obj.index(:)=1;
                    elseif(obj.modSelReg==2)
                        obj.index(:)=3;
                    elseif(obj.modSelReg==3)
                        obj.index(:)=5;
                    elseif(obj.modSelReg==4)
                        obj.index(:)=7;
                    elseif(obj.modSelReg==5)
                        obj.index(:)=0;
                        obj.BPSKflag(:)=true;
                        if(obj.evenSC)
                            obj.evenSC(:)=false;
                        else
                            obj.evenSC(:)=true;
                        end
                    else
                        obj.index(:)=1;
                    end
                end

            else

                [dataSet]=Region2data(obj,obj.dataRIReg1,obj.dataAbsReg,obj.condition,obj.modSelReg);

                [addr]=Region2Address(obj,obj.dataRIReg1,obj.condition);


                obj.dataRIReg1(:)=obj.dataRI;
                RealImagSelectionUnit(obj,obj.dataInReal,obj.dataInImag,obj.count,obj.BPSKflag,obj.evenSC);

                obj.dataAbsReg(:)=obj.dataAbs;
                obj.dataAbs(:)=abs(obj.dataRI);

                getCondition(obj,obj.dataAbsReg,obj.regionBoundReg);


                countRL=bitsrl(obj.count,1);
                countRLReg=obj.delayCount(countRL);


                obj.dataTerm(:)=dataSet(countRLReg+fi(1,0,1,0));
                dataTermReg=obj.delayData(obj.dataTerm);

                addRess=cast(obj.addr1,'like',obj.addr1);
                obj.addr1(:)=addr+countRLReg;
                addRessReg=obj.delayAddr(addRess);

                addTerm=obj.addLUTProp(addRessReg+fi(1,0,1,0));
                multTerm=obj.multLUTProp(addRessReg+fi(1,0,1,0));

                obj.prodIn2(:)=obj.delayProdIn2(multTerm);

                if(strcmpi(obj.DecisionType,'Soft'))
                    obj.dataOut(:)=obj.prodOut;

                    obj.prodOut(:)=obj.prodIn1*obj.prodIn2;
                else
                    obj.dataOut(:)=obj.prodOut<0;
                    obj.prodOut(:)=obj.prodIn1;
                end

                obj.addOut(:)=dataTermReg+addTerm;

                obj.prodIn1(:)=obj.delayProdIn1(obj.addOut);

                if(dataValid)

                    obj.dataInReal(:)=real(varargin{1});
                    obj.dataInImag(:)=imag(varargin{1});


                    if(strcmpi(obj.ModulationScheme,'BPSK'))
                        obj.modSelReg(:)=0;
                        obj.regionBoundReg(:)=obj.region4;
                        obj.index(:)=0;
                        obj.BPSKflag(:)=true;
                        obj.evenSC(:)=true;
                    elseif(strcmpi(obj.ModulationScheme,'QPSK'))
                        obj.modSelReg(:)=1;
                        obj.regionBoundReg(:)=obj.region4;
                        obj.index(:)=1;
                    elseif(strcmpi(obj.ModulationScheme,'16-QAM'))
                        obj.modSelReg(:)=2;
                        obj.regionBoundReg(:)=obj.region16;
                        obj.index(:)=3;
                    elseif(strcmpi(obj.ModulationScheme,'64-QAM'))
                        obj.modSelReg(:)=3;
                        obj.regionBoundReg(:)=obj.region64;
                        obj.index(:)=5;
                    elseif(strcmpi(obj.ModulationScheme,'256-QAM'))
                        obj.modSelReg(:)=4;
                        obj.regionBoundReg(:)=obj.region256;
                        obj.index(:)=7;
                    elseif(strcmpi(obj.ModulationScheme,'pi/2-BPSK'))
                        obj.modSelReg(:)=5;
                        obj.regionBoundReg(:)=obj.region4;
                        obj.index(:)=0;
                        obj.BPSKflag(:)=true;
                        if(obj.evenSC)
                            obj.evenSC(:)=false;
                        else
                            obj.evenSC(:)=true;
                        end
                    else
                        obj.modSelReg(:)=1;
                        obj.index(:)=1;
                    end
                end

            end

            obj.count=obj.counter(dataValid,obj.index,obj.readyReg);


            obj.readyReg=((obj.count==obj.index)||(obj.count==0&&~dataValid));
            obj.validOutReg(:)=obj.delayValid(obj.validOut);
            obj.validOut(:)=(obj.count~=0)||dataValid;

            if~obj.validOutReg
                obj.dataOut(:)=0;
            end

        end



        function[modAddr,region]=SelectRegionBounds(obj,modSel)
            region=obj.regionBoundReg;
            modAddr=obj.modAddrReg;
            if(modSel==2)
                obj.regionBoundReg(:)=obj.region16;
                obj.modAddrReg(:)=fi(64,0,9,0,hdlfimath);
            elseif(modSel==3)
                obj.regionBoundReg(:)=obj.region64;
                obj.modAddrReg(:)=fi(96,0,9,0,hdlfimath);
            elseif(modSel==4)
                obj.regionBoundReg(:)=obj.region256;
                obj.modAddrReg(:)=fi(128,0,9,0,hdlfimath);
            elseif(modSel==1)
                obj.regionBoundReg(:)=obj.region4;
                obj.modAddrReg(:)=fi(32,0,9,0,hdlfimath);
            else
                obj.regionBoundReg(:)=obj.region4;
                obj.modAddrReg(:)=fi(0,0,9,0,hdlfimath);
            end
        end



        function RealImagSelectionUnit(obj,dataRe,dataIm,cnt,flag,evnSC)
            obj.dataRI(:)=obj.dataRIReg;

            if(cnt==0)
                if(flag)
                    if(evnSC)
                        obj.dataRIReg(:)=dataRe+dataIm;
                    else
                        obj.dataRIReg(:)=dataIm-dataRe;
                    end
                else
                    obj.dataRIReg(:)=dataRe;
                end
            elseif(cnt==1)
                obj.dataRIReg(:)=dataIm;
            elseif(cnt==2)
                obj.dataRIReg(:)=dataRe;
            elseif(cnt==3)
                obj.dataRIReg(:)=dataIm;
            elseif(cnt==4)
                obj.dataRIReg(:)=dataRe;
            elseif(cnt==5)
                obj.dataRIReg(:)=dataIm;
            elseif(cnt==6)
                obj.dataRIReg(:)=dataRe;
            else
                obj.dataRIReg(:)=dataIm;
            end
        end



        function[address]=Region2Address(obj,dataReIm,cndtn)

            address=obj.addressReg;
            if(cndtn(1))
                addrs=fi(0,0,5,0,hdlfimath);
            elseif(cndtn(2)&&cndtn(3))
                addrs=fi(4,0,5,0,hdlfimath);
            elseif(cndtn(4)&&cndtn(5))
                addrs=fi(8,0,5,0,hdlfimath);
            elseif(cndtn(6)&&cndtn(7))
                addrs=fi(12,0,5,0,hdlfimath);
            elseif(cndtn(8)&&cndtn(9))
                addrs=fi(16,0,5,0,hdlfimath);
            elseif(cndtn(10)&&cndtn(11))
                addrs=fi(20,0,5,0,hdlfimath);
            elseif(cndtn(12)&&cndtn(13))
                addrs=fi(24,0,5,0,hdlfimath);
            else
                addrs=fi(28,0,5,0,hdlfimath);
            end

            if dataReIm<0
                if strcmpi(obj.ModulationSource,'Input port')
                    obj.addressReg(:)=addrs+fi(160,0,8,0,hdlfimath);
                else
                    obj.addressReg(:)=addrs+fi(32,0,6,0,hdlfimath);
                end
            else
                obj.addressReg(:)=addrs+fi(0,0,1,0,hdlfimath);
            end
        end



        function getCondition(obj,dataRIAbs,regions)
            obj.condition(1)=(dataRIAbs<=regions(1));
            obj.condition(2)=(dataRIAbs>regions(1));
            obj.condition(3)=(dataRIAbs<=regions(2));
            obj.condition(4)=(dataRIAbs>regions(2));
            obj.condition(5)=(dataRIAbs<=regions(3));
            obj.condition(6)=(dataRIAbs>regions(3));
            obj.condition(7)=(dataRIAbs<=regions(4));
            obj.condition(8)=(dataRIAbs>regions(4));
            obj.condition(9)=(dataRIAbs<=regions(5));
            obj.condition(10)=(dataRIAbs>regions(5));
            obj.condition(11)=(dataRIAbs<=regions(6));
            obj.condition(12)=(dataRIAbs>regions(6));
            obj.condition(13)=(dataRIAbs<=regions(7));
        end



        function[dataSet]=Region2data(obj,dataReIm,dataReImAbs,cndtn,modSel)
            dataSet=obj.dataSetReg;
            dataReImAbsM=-dataReImAbs;

            set1=[dataReIm;dataReImAbsM;dataReImAbs;dataReImAbs];
            set2=[dataReIm;dataReImAbsM;dataReImAbs;dataReImAbsM];
            set3=[dataReIm;dataReImAbsM;dataReImAbsM;dataReImAbs];
            set4=[dataReIm;dataReImAbsM;dataReImAbsM;dataReImAbsM];

            if(cndtn(3))
                obj.dataSetReg(:)=set1;
            elseif(cndtn(4)&&cndtn(7))
                if(modSel==3)
                    obj.dataSetReg(:)=set4;
                else
                    obj.dataSetReg(:)=set2;
                end
            elseif(cndtn(8)&&cndtn(11))
                obj.dataSetReg(:)=set3;
            else
                obj.dataSetReg(:)=set4;
            end
        end



        function ind=indexCalc(obj,dataValid,flag,val)
            ind=obj.index;
            if(dataValid)
                if(flag)
                    if(val==0)
                        ind(:)=0;
                    elseif(val==2)
                        ind(:)=3;
                    elseif(val==3)
                        ind(:)=5;
                    elseif(val==4)
                        ind(:)=7;
                    elseif(val==5)
                        ind(:)=0;
                    else
                        ind(:)=1;
                    end
                else
                    if(strcmpi(obj.ModulationScheme,'BPSK'))
                        ind(:)=0;
                    elseif(strcmpi(obj.ModulationScheme,'16-QAM'))
                        ind(:)=3;
                    elseif(strcmpi(obj.ModulationScheme,'64-QAM'))
                        ind(:)=5;
                    elseif(strcmpi(obj.ModulationScheme,'256-QAM'))
                        ind(:)=7;
                    elseif(strcmpi(obj.ModulationScheme,'pi/2-BPSK'))
                        ind(:)=0;
                    else
                        ind(:)=1;
                    end
                end
            else
                ind(:)=obj.index;
            end
        end



        function nextCount=counter(obj,dataValid,ind,rdReg)
            nextCount=obj.count;

            if(dataValid||rdReg)
                nextCount(:)=0;
            else
                if(nextCount==ind)
                    nextCount(:)=0;
                else
                    nextCount(:)=nextCount+fi(1,0,1,0,hdlfimath);
                end
            end
        end



        function num=getNumInputsImpl(obj)
            num=2;
            if strcmpi(obj.ModulationSource,'Input port')
                num=num+1;
            end

        end



        function num=getNumOutputsImpl(~)
            num=3;
        end



        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            inputPortInd=1;
            varargout{inputPortInd}='data';
            inputPortInd=inputPortInd+1;
            varargout{inputPortInd}='valid';
            if strcmpi(obj.ModulationSource,'Input port')
                inputPortInd=inputPortInd+1;
                varargout{inputPortInd}='modSel';
            end
        end



        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            outputPortInd=1;
            varargout{outputPortInd}='data';
            outputPortInd=outputPortInd+1;
            varargout{outputPortInd}='valid';
            outputPortInd=outputPortInd+1;
            varargout{outputPortInd}='ready';
        end



        function validateInputsImpl(obj,varargin)
            coder.extrinsic('tostringInternalSlName');
            if isempty(coder.target)||~coder.internal.isAmbiguousTypes

                validateattributes(varargin{1},...
                {'single','double','embedded.fi','int8','int16','int32'},{'scalar'},'NRSymbolDemodulator','data');
                if isa(varargin{1},'embedded.fi')
                    [WL,~,~]=dsphdlshared.hdlgetwordsizefromdata(varargin{1});
                    if(~issigned(varargin{1}))
                        coder.internal.error('whdl:NRSymbolDemodulator:InvalidDataType',...
                        tostringInternalSlName(varargin{1}.numerictype));
                    end
                    if WL>32
                        coder.internal.error('whdl:NRSymbolDemodulator:InvalidWordLength');
                    end
                end
                if isa(varargin{1},'int64')
                    coder.internal.error('whdl:NRSymbolDemodulator:InvalidWordLength');
                end


                validateattributes(varargin{2},{'logical'},{'scalar'},...
                'NRSymbolDemodulator','valid');

                if strcmpi(obj.ModulationSource,'Input Port')
                    validateattributes(varargin{3},{'double','single','embedded.fi'},...
                    {'scalar'},'NRSymbolDemodulator','modSel');
                    if isa(varargin{3},'embedded.fi')
                        [WL,FL,~]=dsphdlshared.hdlgetwordsizefromdata(varargin{3});
                        errCond=~((WL==3)&&(FL==0)&&~issigned(varargin{3}));
                        if(errCond)
                            coder.internal.error('whdl:NRSymbolDemodulator:InvalidModSelType',...
                            tostringInternalSlName(varargin{3}.numerictype));
                        end
                    end
                end
            end
        end



        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            switch obj.ModulationSource
            case 'Input port'
                props={'ModulationScheme'};
            end
            flag=ismember(prop,props);
        end





        function varargout=getOutputDataTypeImpl(obj,varargin)
            if(strcmp(obj.DecisionType,'Hard'))
                varargout={'logical','logical','logical'};
            else
                inputDT=propagatedInputDataType(obj,1);
                totalBitGrowth=3;
                if isnumerictype(inputDT)||isfi(inputDT)
                    outputDT=numerictype(1,inputDT.WordLength+totalBitGrowth,inputDT.FractionLength);
                elseif strcmpi(inputDT,'int8')
                    outputDT=numerictype(1,8+totalBitGrowth,0);
                elseif strcmpi(inputDT,'int16')
                    outputDT=numerictype(1,16+totalBitGrowth,0);
                elseif strcmpi(inputDT,'int32')
                    outputDT=numerictype(1,32+totalBitGrowth,0);
                else
                    outputDT=inputDT;
                end
                varargout={outputDT,'logical','logical'};
            end
        end



        function varargout=isOutputComplexImpl(~)
            varargout={false,false,false};
        end



        function[sz1,sz2,sz3]=getOutputSizeImpl(~)
            sz1=[1,1];
            sz2=[1,1];
            sz3=[1,1];
        end



        function varargout=isOutputFixedSizeImpl(~)
            varargout={true,true,true};
        end



        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.dataOut=obj.dataOut;
                s.dataOutReg=obj.dataOutReg;
                s.dataInReal=obj.dataInReal;
                s.dataInImag=obj.dataInImag;
                s.addOut=obj.addOut;
                s.prodOut=obj.prodOut;
                s.prodIn1=obj.prodIn1;
                s.prodIn2=obj.prodIn2;
                s.multLUT256=obj.multLUT256;
                s.multLUT64=obj.multLUT64;
                s.multLUT16=obj.multLUT16;
                s.multLUT4=obj.multLUT4;
                s.multLUT=obj.multLUT;
                s.addLUT256N=obj.addLUT256N;
                s.addLUT256P=obj.addLUT256P;
                s.addLUT64N=obj.addLUT64N;
                s.addLUT64P=obj.addLUT64P;
                s.addLUT16N=obj.addLUT16N;
                s.addLUT16P=obj.addLUT16P;
                s.addLUT4N=obj.addLUT4N;
                s.addLUT4P=obj.addLUT4P;
                s.addLUT=obj.addLUT;
                s.regionBoundReg=obj.regionBoundReg;
                s.region256=obj.region256;
                s.region64=obj.region64;
                s.region16=obj.region16;
                s.region4=obj.region4;
                s.dataRI=obj.dataRI;
                s.dataAbs=obj.dataAbs;
                s.dataAbsReg=obj.dataAbsReg;
                s.dataRIReg=obj.dataRIReg;
                s.dataRIReg1=obj.dataRIReg1;
                s.dataSetReg=obj.dataSetReg;
                s.dataTerm=obj.dataTerm;
                s.addLUTProp=obj.addLUTProp;
                s.multLUTProp=obj.multLUTProp;
                s.validOut=obj.validOut;
                s.validOutReg=obj.validOutReg;
                s.readyReg=obj.readyReg;
                s.count=obj.count;
                s.index=obj.index;
                s.modSelReg=obj.modSelReg;
                s.modSelReg1=obj.modSelReg1;
                s.modSelReg2=obj.modSelReg2;
                s.modSwitch=obj.modSwitch;
                s.evenSC=obj.evenSC;
                s.BPSKflag=obj.BPSKflag;
                s.modAddrReg=obj.modAddrReg;
                s.addressReg=obj.addressReg;
                s.addr1=obj.addr1;
                s.addr2=obj.addr2;
                s.condition=obj.condition;
                s.delayModSel=obj.delayModSel;
                s.delayModAddr=obj.delayModAddr;
                s.delayValid=obj.delayValid;
                s.delayCount=obj.delayCount;
                s.delayProdIn1=obj.delayProdIn1;
                s.delayProdIn2=obj.delayProdIn2;
                s.delayAddr=obj.delayAddr;
                s.delayData=obj.delayData;
                s.userFimath=obj.userFimath;
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
