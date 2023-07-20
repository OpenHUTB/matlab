classdef(StrictDefaults)LTESymbolDemodulator<matlab.System








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

        dataOut;
        validOut;
        dataOutReg;
        dataOutReg1;
        dataOutReg2;
        delayValid;
        validOutReg;
        readyReg;
        addOut;
        addOutReg;
        delayAddOut;
        addIn1;
        addIn2;

        index;
        count;
        portFlagBPSK;
        portFlagBPSKReg;
        delayBPSKflag;

        scalingBPSK;
        scaling16QAM;
        scaling64QAM;
        scaling256QAM;
        scalingpiby2BPSK;
        userFimath;
    end

    properties(Constant,Hidden)
        ModulationSourceSet=matlab.system.StringSet({...
        'Input port','Property'});

        ModulationSchemeSet=matlab.system.StringSet({...
        'BPSK','QPSK','16-QAM','64-QAM','256-QAM'});

        DecisionTypeSet=matlab.system.StringSet({...
        'Hard','Soft'});

        RoundingMethodSet=matlab.system.StringSet({...
        'Ceiling','Convergent','Floor','Nearest','Round','Zero'});

    end





    methods


        function obj=LTESymbolDemodulator(varargin)
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
            'Title','LTE Symbol Demodulator',...
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
            latency=7;
        end
    end


    methods(Access=protected)



        function icon=getIconImpl(obj)
            if strcmpi(obj.ModulationSource,'Property')
                icon=sprintf('LTE Symbol Demodulator \nLatency = %d',getLatency(obj));
            else
                icon=sprintf('LTE Symbol \nDemodulator');
            end
        end



        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

        function resetImpl(obj)
            obj.dataInReal(:)=0;
            obj.dataInImag(:)=0;
            obj.modSelReg(:)=0;
            obj.dataOut(:)=0;
            obj.validOut(:)=false;
            obj.dataOutReg(:)=0;
            obj.dataOutReg1(:)=0;
            obj.dataOutReg2(:)=0;
            obj.validOutReg(:)=false;
            obj.readyReg(:)=true;
            obj.addOut(:)=0;
            obj.addIn1(:)=zeros(1,2);
            obj.index(:)=0;
            obj.count(:)=0;
            obj.portFlagBPSK(:)=false;
            obj.portFlagBPSKReg(:)=false;
            obj.scalingBPSK(:)=1/sqrt(2);


            if(strcmpi(obj.ModulationSource,'Input port')||strcmpi(obj.ModulationScheme,'256-QAM'))
                obj.addIn2(:)=zeros(1,8);
                obj.scaling16QAM(:)=-[0,0,2,2,0,0,0,0]/sqrt(10);
                obj.scaling64QAM(:)=-[0,0,4,4,2,2,0,0]./sqrt(42);
                obj.scaling256QAM(:)=-[0,0,8,8,4,4,2,2]./sqrt(170);
            elseif(strcmpi(obj.ModulationScheme,'64-QAM'))
                obj.addIn2(:)=zeros(1,6);
                obj.scaling64QAM(:)=-[0,0,4,4,2,2]./sqrt(42);
            elseif(strcmpi(obj.ModulationScheme,'16-QAM'))
                obj.addIn2(:)=zeros(1,4);
                obj.scaling16QAM(:)=-[0,0,2,2]/sqrt(10);
            else
                obj.addIn2(:)=zeros(1,2);
            end

            reset(obj.delayValid);
            reset(obj.delayAddOut);
            if(strcmpi(obj.ModulationSource,'Input port'))
                reset(obj.delayBPSKflag);
            else
                obj.delayBPSKflag=false;
            end
        end



        function setupImpl(obj,varargin)
            dIn=varargin{1};
            obj.userFimath=fimath('RoundingMethod',obj.RoundingMethod,'OverflowAction','Wrap');
            if~isfloat(dIn)
                bitGrowth=2;
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
                    obj.dataOutReg1=false;
                    obj.dataOutReg2=false;
                else

                    obj.dataOut=fi(0,1,inpData.WordLength+bitGrowth,inpData.FractionLength,obj.userFimath);
                    obj.dataOutReg=fi(0,1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                    obj.dataOutReg1=fi(0,1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                    obj.dataOutReg2=fi(0,1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);

                end

                obj.dataInReal=fi(0,1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                obj.dataInImag=fi(0,1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                obj.addOut=fi(0,1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                obj.addOutReg=fi(0,1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                obj.addIn1=fi(zeros(1,2),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);


                if(strcmpi(obj.ModulationSource,'Input port')||strcmpi(obj.ModulationScheme,'256-QAM'))
                    obj.addIn2=fi(zeros(1,8),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                    if inpData.FractionLength~=0
                        obj.scaling16QAM=fi(-[0,0,2,2,0,0,0,0]/sqrt(10),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                        obj.scaling64QAM=fi(-[0,0,4,4,2,2,0,0]./sqrt(42),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                        obj.scaling256QAM=fi(-[0,0,8,8,4,4,2,2]./sqrt(170),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                    else
                        obj.scaling16QAM=fi(-[0,0,2,2,0,0,0,0]/sqrt(10),1,inpData.WordLength+bitGrowth,inpData.WordLength,hdlfimath);
                        obj.scaling64QAM=fi(-[0,0,4,4,2,2,0,0]./sqrt(42),1,inpData.WordLength+bitGrowth,inpData.WordLength,hdlfimath);
                        obj.scaling256QAM=fi(-[0,0,8,8,4,4,2,2]./sqrt(170),1,inpData.WordLength+bitGrowth,inpData.WordLength,hdlfimath);
                    end
                elseif(strcmpi(obj.ModulationScheme,'64-QAM'))
                    obj.addIn2=fi(zeros(1,6),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                    if inpData.FractionLength~=0
                        obj.scaling64QAM=fi(-[0,0,4,4,2,2]./sqrt(42),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                    else
                        obj.scaling64QAM=fi(-[0,0,4,4,2,2]./sqrt(42),1,inpData.WordLength+bitGrowth,inpData.WordLength,hdlfimath);
                    end
                elseif(strcmpi(obj.ModulationScheme,'16-QAM'))
                    obj.addIn2=fi(zeros(1,4),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                    if inpData.FractionLength~=0
                        obj.scaling16QAM=fi(-[0,0,2,2]/sqrt(10),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                    else
                        obj.scaling16QAM=fi(-[0,0,2,2]/sqrt(10),1,inpData.WordLength+bitGrowth,inpData.WordLength,hdlfimath);
                    end
                else
                    obj.addIn2=fi(zeros(1,2),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                end
                if inpData.FractionLength~=0
                    obj.scalingBPSK=fi(1/sqrt(2),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                else
                    obj.scalingBPSK=fi(1/sqrt(2),1,inpData.WordLength+bitGrowth,inpData.WordLength,hdlfimath);
                end
            else
                if(strcmpi(obj.DecisionType,'Hard'))
                    obj.dataOut=false;
                    obj.dataOutReg=false;
                    obj.dataOutReg1=false;
                    obj.dataOutReg2=false;
                else
                    obj.dataOut=cast(0,'like',real(dIn));
                    obj.dataOutReg=cast(0,'like',real(dIn));
                    obj.dataOutReg1=cast(0,'like',real(dIn));
                    obj.dataOutReg2=cast(0,'like',real(dIn));
                end
                obj.dataInReal=cast(0,'like',real(dIn));
                obj.dataInImag=cast(0,'like',real(dIn));
                obj.addOut=cast(0,'like',real(dIn));
                obj.addOutReg=cast(0,'like',real(dIn));
                obj.addIn1=cast(zeros(1,2),'like',real(dIn));
                if(strcmpi(obj.ModulationSource,'Input port')||strcmpi(obj.ModulationScheme,'256-QAM'))
                    obj.addIn2=cast(zeros(1,8),'like',real(dIn));
                    obj.scaling16QAM=cast(-[0,0,2,2,0,0,0,0]./sqrt(10),'like',real(dIn));
                    obj.scaling64QAM=cast(-[0,0,4,4,2,2,0,0]./sqrt(42),'like',real(dIn));
                    obj.scaling256QAM=cast(-[0,0,8,8,4,4,2,2]./sqrt(170),'like',real(dIn));
                elseif(strcmpi(obj.ModulationScheme,'64-QAM'))
                    obj.addIn2=cast(zeros(1,6),'like',real(dIn));
                    obj.scaling64QAM=cast(-[0,0,4,4,2,2]./sqrt(42),'like',real(dIn));
                elseif(strcmpi(obj.ModulationScheme,'16-QAM'))
                    obj.addIn2=cast(zeros(1,4),'like',real(dIn));
                    obj.scaling16QAM=cast(-[0,0,2,2]./sqrt(10),'like',real(dIn));
                else
                    obj.addIn2=cast(zeros(1,2),'like',real(dIn));
                end
                obj.scalingBPSK=cast(1/sqrt(2),'like',real(dIn));
            end
            obj.validOut=false;
            obj.validOutReg=false;
            obj.readyReg=true;
            obj.count=fi(0,0,3,0,hdlfimath);
            obj.index=fi(0,0,3,0,hdlfimath);
            obj.modSelReg=fi(0,0,3,0,hdlfimath);
            obj.portFlagBPSK=false;
            obj.portFlagBPSKReg=false;

            obj.delayValid=dsp.Delay(6);
            obj.delayAddOut=dsp.Delay(2);
            if(strcmpi(obj.ModulationSource,'Input port'))
                obj.delayBPSKflag=dsp.Delay(3);
            else
                obj.delayBPSKflag=false;
            end
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
            rdReg=obj.readyReg;

            dataValid=validIn&&rdReg;


            if(strcmpi(obj.ModulationSource,'Input Port'))
                flg=true;
                val=varargin{3};
            else
                flg=false;
                val=1;
            end
            nextIndex=obj.indexCalc(dataValid,flg,val);
            nextCount=obj.counter(dataValid,nextIndex,rdReg);
            varargout{3}=((nextCount==nextIndex)||(nextCount==0&&~dataValid));

        end



        function updateImpl(obj,varargin)
            validIn=varargin{2};
            dataValid=validIn&&obj.readyReg;


            if(strcmpi(obj.ModulationSource,'Input port'))

                if isempty(coder.target)||~coder.internal.isAmbiguousTypes


                    if~any((0:4)==(varargin{3}))
                        coder.internal.warning('whdl:LTESymbolDemodulator:InvalidModSelValue');
                    end
                end

                obj.dataOut(:)=obj.dataOutReg1;
                if(obj.portFlagBPSKReg)
                    obj.dataOutReg1(:)=obj.dataOutReg;
                else
                    obj.dataOutReg1(:)=obj.dataOutReg2;
                end
                if strcmpi(obj.DecisionType,'Soft')
                    obj.dataOutReg(:)=obj.addOut*obj.scalingBPSK;
                    obj.dataOutReg2(:)=obj.addOut;
                else
                    obj.dataOutReg(:)=obj.addOut>0;
                    obj.dataOutReg2(:)=obj.addOut>0;
                end

                obj.portFlagBPSK=(obj.modSelReg==0);
                obj.portFlagBPSKReg=obj.delayBPSKflag(obj.portFlagBPSK);

                obj.addOutReg(:)=obj.addIn1(1)+obj.addIn2(1);

                obj.addIn1(1)=obj.addIn1(2);
                obj.addIn1(2)=abs(obj.addOutReg);

                obj.addIn2(1)=obj.addIn2(2);
                obj.addIn2(2)=obj.addIn2(3);
                obj.addIn2(3)=obj.addIn2(4);
                obj.addIn2(4)=obj.addIn2(5);
                obj.addIn2(5)=obj.addIn2(6);
                obj.addIn2(6)=obj.addIn2(7);
                obj.addIn2(7)=obj.addIn2(8);
                obj.addIn2(8)=obj.addIn2(1);

                obj.addOut(:)=obj.delayAddOut(obj.addOutReg);


                if(dataValid)
                    obj.modSelReg(:)=varargin{3};
                    obj.dataInReal(:)=real(varargin{1});
                    obj.dataInImag(:)=imag(varargin{1});

                    obj.addIn1(1)=-obj.dataInReal;
                    obj.addIn1(2)=-obj.dataInImag;

                    if(obj.modSelReg(:)==0)
                        obj.addIn2(:)=[-obj.dataInImag,zeros(1,7)];
                        obj.index(:)=0;
                    elseif(obj.modSelReg(:)==2)
                        obj.addIn2(:)=obj.scaling16QAM;
                        obj.index(:)=3;
                    elseif(obj.modSelReg(:)==3)
                        obj.addIn2(:)=obj.scaling64QAM;
                        obj.index(:)=5;
                    elseif(obj.modSelReg(:)==4)
                        obj.addIn2(:)=obj.scaling256QAM;
                        obj.index(:)=7;
                    else
                        obj.addIn2(:)=zeros(1,8);
                        obj.index(:)=1;
                    end

                end

            else

                obj.dataOut(:)=obj.dataOutReg1;
                if(strcmpi(obj.ModulationScheme,'BPSK'))
                    obj.dataOutReg1(:)=obj.dataOutReg;
                    if strcmpi(obj.DecisionType,'Soft')
                        obj.dataOutReg(:)=obj.addOut*obj.scalingBPSK;
                    else
                        obj.dataOutReg(:)=obj.addOut>0;
                    end
                else
                    obj.dataOutReg1(:)=obj.dataOutReg;
                    if strcmpi(obj.DecisionType,'Soft')
                        obj.dataOutReg(:)=obj.addOut;
                    else
                        obj.dataOutReg(:)=obj.addOut>0;
                    end
                end

                obj.addOutReg(:)=obj.addIn1(1)+obj.addIn2(1);

                obj.addIn1(1)=obj.addIn1(2);
                obj.addIn1(2)=abs(obj.addOutReg);
                if(strcmpi(obj.ModulationScheme,'256-QAM'))
                    obj.addIn2(1)=obj.addIn2(2);
                    obj.addIn2(2)=obj.addIn2(3);
                    obj.addIn2(3)=obj.addIn2(4);
                    obj.addIn2(4)=obj.addIn2(5);
                    obj.addIn2(5)=obj.addIn2(6);
                    obj.addIn2(6)=obj.addIn2(7);
                    obj.addIn2(7)=obj.addIn2(8);
                    obj.addIn2(8)=obj.addIn2(1);
                elseif(strcmpi(obj.ModulationScheme,'64-QAM'))
                    obj.addIn2(1)=obj.addIn2(2);
                    obj.addIn2(2)=obj.addIn2(3);
                    obj.addIn2(3)=obj.addIn2(4);
                    obj.addIn2(4)=obj.addIn2(5);
                    obj.addIn2(5)=obj.addIn2(6);
                    obj.addIn2(6)=obj.addIn2(1);
                elseif(strcmpi(obj.ModulationScheme,'16-QAM'))
                    obj.addIn2(1)=obj.addIn2(2);
                    obj.addIn2(2)=obj.addIn2(3);
                    obj.addIn2(3)=obj.addIn2(4);
                    obj.addIn2(4)=obj.addIn2(1);
                else
                    obj.addIn2(1)=obj.addIn2(2);
                    obj.addIn2(2)=obj.addIn2(1);
                end

                obj.addOut(:)=obj.delayAddOut(obj.addOutReg);


                if(dataValid)
                    obj.dataInReal(:)=real(varargin{1});
                    obj.dataInImag(:)=imag(varargin{1});

                    obj.addIn1(1)=-obj.dataInReal;
                    obj.addIn1(2)=-obj.dataInImag;

                    if(strcmpi(obj.ModulationScheme,'BPSK'))
                        obj.addIn2(:)=[-obj.dataInImag,0];
                        obj.index(:)=0;
                    elseif(strcmpi(obj.ModulationScheme,'16-QAM'))
                        obj.addIn2(:)=obj.scaling16QAM;
                        obj.index(:)=3;
                    elseif(strcmpi(obj.ModulationScheme,'64-QAM'))
                        obj.addIn2(:)=obj.scaling64QAM;
                        obj.index(:)=5;
                    elseif(strcmpi(obj.ModulationScheme,'256-QAM'))
                        obj.addIn2(:)=obj.scaling256QAM;
                        obj.index(:)=7;
                    else
                        obj.addIn2(:)=zeros(1,2);
                        obj.index(:)=1;
                    end

                end
            end

            obj.count=obj.counter(dataValid,obj.index,obj.readyReg);


            obj.readyReg(:)=((obj.count==obj.index)||(obj.count==0&&~dataValid));
            obj.validOut(:)=(obj.count~=0)||dataValid;
            obj.validOutReg=obj.delayValid(obj.validOut);

            if~obj.validOutReg
                obj.dataOut(:)=0;
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
                {'single','double','embedded.fi','int8','int16','int32'},{'scalar'},'LTESymbolDemodulator','data');
                if isa(varargin{1},'embedded.fi')
                    [WL,~,~]=dsphdlshared.hdlgetwordsizefromdata(varargin{1});
                    if(~issigned(varargin{1}))
                        coder.internal.error('whdl:LTESymbolDemodulator:InvalidDataType',...
                        tostringInternalSlName(varargin{1}.numerictype));
                    end
                    if WL>32
                        coder.internal.error('whdl:LTESymbolDemodulator:InvalidWordLength');
                    end
                end
                if isa(varargin{1},'int64')
                    coder.internal.error('whdl:LTESymbolDemodulator:InvalidWordLength');
                end

                validateattributes(varargin{2},{'logical'},{'scalar'},...
                'LTESymbolDemodulator','valid');

                if strcmpi(obj.ModulationSource,'Input Port')
                    validateattributes(varargin{3},{'double','single','embedded.fi'},...
                    {'scalar'},'LTESymbolDemodulator','modSel');
                    if isa(varargin{3},'embedded.fi')
                        [WL,FL,~]=dsphdlshared.hdlgetwordsizefromdata(varargin{3});
                        errCond=~((WL==3)&&(FL==0)&&~issigned(varargin{3}));
                        if(errCond)
                            coder.internal.error('whdl:LTESymbolDemodulator:InvalidModSelType',...
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
                totalBitGrowth=2;
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
                s.dataInReal=obj.dataInReal;
                s.dataInImag=obj.dataInImag;
                s.modSelReg=obj.modSelReg;
                s.dataOut=obj.dataOut;
                s.validOut=obj.validOut;
                s.dataOutReg=obj.dataOutReg;
                s.dataOutReg1=obj.dataOutReg1;
                s.dataOutReg2=obj.dataOutReg2;
                s.validOutReg=obj.validOutReg;
                s.readyReg=obj.readyReg;
                s.addOut=obj.addOut;
                s.addIn1=obj.addIn1;
                s.addIn2=obj.addIn2;
                s.index=obj.index;
                s.count=obj.count;
                s.portFlagBPSK=obj.portFlagBPSK;
                s.portFlagBPSKReg=obj.portFlagBPSKReg;
                s.scalingBPSK=obj.scalingBPSK;
                s.scaling16QAM=obj.scaling16QAM;
                s.scaling64QAM=obj.scaling64QAM;
                s.scaling256QAM=obj.scaling256QAM;
                s.delayValid=obj.delayValid;
                s.delayAddOut=obj.delayAddOut;
                s.delayBPSKflag=obj.delayBPSKflag;
                s.addOutReg=obj.addOutReg;
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
