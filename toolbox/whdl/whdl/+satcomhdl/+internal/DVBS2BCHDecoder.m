classdef(StrictDefaults)DVBS2BCHDecoder<matlab.System




%#codegen


    properties(Nontunable)


        FECFrameType='Normal';



        CodeRateSource='Property';



        CodeRateNormal='1/4';


        CodeRateShort='1/4';


        NumErrorsOutputPort(1,1)logical=false;
    end

    properties(Constant,Hidden)
        FECFrameTypeSet=matlab.system.StringSet({...
        'Normal',...
        'Short'});
        CodeRateSourceSet=matlab.system.StringSet({...
        'Property',...
        'Input port'});
        CodeRateNormalSet=matlab.system.StringSet({'1/4','1/3','2/5','1/2','3/5','2/3','3/4','4/5','5/6','8/9','9/10'});
        CodeRateShortSet=matlab.system.StringSet({'1/4','1/3','2/5','1/2','3/5','2/3','3/4','4/5','5/6','8/9'});
    end
    properties(Access=private,Nontunable)
        vecLen;
    end
    properties(Access=private)

        MultTable;
        PowerTable;
        tCorr;
        WordSize;
        LogTable;
        AntiLogTable;
        Latency;
        N;
        K;
        N_long;
        K_long;
        cheinDone;
        DataRAM;
        RAMWriteAddr;
        PacketWriteAddr;
        RAMReadAddr;
        PacketReadAddr;
        counter;
        sampleCounter;
        InPacket;
        syndrome;
        syndrometemp;
        syntemp;
        eleIdx;
        eleVal;
        gfTable1_16;
        gfTable2_16;
        gfTable1_14;
        gfTable2_14;
        GFTable1;
        GFTable2;
        codeRateIndex;
        frameType;
        doubleCorr;
        forceEnd;
        errPos;
        cnumerrInt;
        errLocatorPoly;
        L;
        dataOut;
        dataIn;
        startIn;
        startInput;
        endInput;
        endIn;
        validIn;
        validInput;
        nextFrame;

        counterLoad;
        InpacketNxt;
        syndromeEnd;
        endDetected;
        sampCounter;
        inStart;
        CodewordLength;
        MessageLength;
        startOut;
        validOut;
        endOut;
        nextFrameOut;
        errOut;
        syndromeOut;
        latencyCount;
        latencyEnb;
    end
    methods(Access=public)

    end
    methods(Static,Access=protected)
        function header=getHeaderImpl

            text='Decode and recover a message from Bose-Chaudhuri-Hocquenghem (BCH) codeword.';

            header=matlab.system.display.Header('satcomhdl.internal.DVBS2BCHDecoder',...
            'ShowSourceLink',false,...
            'Text',text,...
            'Title','DVB-S2 BCH Decoder');
        end
        function groups=getPropertyGroupsImpl
            struc=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'FECFrameType','CodeRateSource','CodeRateNormal',...
            'CodeRateShort','NumErrorsOutputPort'});

            main=matlab.system.display.SectionGroup(...
            'TitleSource','Auto',...
            'Sections',struc);

            groups=main;
        end
    end

    methods
        function obj=DVBS2BCHDecoder(varargin)
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

    methods(Access=protected)

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.N=obj.N;
                s.NumErrorsOutputPort=obj.NumErrorsOutputPort;
                s.MultTable=obj.MultTable;
                s.PowerTable=obj.PowerTable;
                s.tCorr=obj.tCorr;
                s.WordSize=obj.WordSize;
                s.LogTable=obj.LogTable;
                s.AntiLogTable=obj.AntiLogTable;
                s.Latency=obj.Latency;
                s.K=obj.K;
                s.N_long=obj.N_long;
                s.K_long=obj.K_long;
                s.cheinDone=obj.cheinDone;
                s.DataRAM=obj.DataRAM;
                s.RAMWriteAddr=obj.RAMWriteAddr;
                s.PacketWriteAddr=obj.PacketWriteAddr;
                s.RAMReadAddr=obj.RAMReadAddr;
                s.PacketReadAddr=obj.PacketReadAddr;
                s.tCorr=obj.tCorr;
                s.counter=obj.counter;
                s.sampleCounter=obj.sampleCounter;
                s.InPacket=obj.InPacket;
                s.syndrome=obj.syndrome;
                s.syndrometemp=obj.syndrometemp;
                s.syntemp=obj.syntemp;
                s.eleIdx=obj.eleIdx;
                s.eleVal=obj.eleVal;
                s.gfTable1_16=obj.gfTable1_16;
                s.gfTable2_16=obj.gfTable2_16;
                s.gfTable1_14=obj.gfTable1_14;
                s.gfTable2_14=obj.gfTable2_14;
                s.GFTable1=obj.GFTable1;
                s.GFTable2=obj.GFTable2;
                s.codeRateIndex=obj.codeRateIndex;
                s.frameType=obj.frameType;
                s.doubleCorr=obj.doubleCorr;
                s.forceEnd=obj.forceEnd;
                s.errPos=obj.errPos;
                s.cnumerrInt=obj.cnumerrInt;
                s.errLocatorPoly=obj.errLocatorPoly;
                s.L=obj.L;
                s.dataOut=obj.dataOut;
                s.dataIn=obj.dataIn;
                s.startIn=obj.startIn;
                s.startInput=obj.startInput;
                s.endIn=obj.endIn;
                s.validIn=obj.validIn;
                s.validInput=obj.validInput;
                s.nextFrame=obj.nextFrame;

                s.counterLoad=obj.counterLoad;
                s.InpacketNxt=obj.InpacketNxt;
                s.vecLen=obj.vecLen;
                s.inStart=obj.inStart;
                s.syndromeEnd=obj.syndromeEnd;
                s.sampCounter=obj.sampCounter;
                s.endDetected=obj.endDetected;
                s.startOut=obj.startOut;
                s.validOut=obj.validOut;
                s.endOut=obj.endOut;
                s.nextFrameOut=obj.nextFrameOut;
                s.errOut=obj.errOut;
                s.syndromeOut=obj.syndromeOut;
                s.latencyEnb=obj.latencyEnb;
                s.latencyCount=obj.latencyCount;
            end
        end

        function obj=loadObjectImpl(obj,s,~)


            f=fieldnames(s);
            for ii=1:numel(f)
                obj.(f{ii})=s.(f{ii});
            end
        end

        function resetImpl(obj)
            obj.resetStates;
        end
    end

    methods(Access=protected)
        function[varargout]=outputImpl(obj,varargin)
            ctrl.start=obj.startOut;
            ctrl.end=obj.endOut;
            ctrl.valid=obj.validOut;


            if obj.NumErrorsOutputPort
                varargout{3}=obj.errOut;
                varargout{4}=obj.nextFrameOut;

            else
                varargout{3}=obj.nextFrameOut;


            end
            varargout{2}=ctrl;
            varargout{1}=obj.dataOut;
        end

        function updateImpl(obj,varargin)

            ctrl=varargin{2};
            if ctrl.start&&ctrl.valid
                resetImpl(obj);
            end
            obj.startIn=ctrl.start;
            obj.endIn=ctrl.end;
            obj.validIn=ctrl.valid;
            obj.dataIn=varargin{1};

            sampleCtrl(obj);
            if strcmp(obj.CodeRateSource,'Input port')
                obj.codeRateIndex=varargin{3};
            end

            if obj.startInput&&obj.validInput

                if obj.frameType==0
                    switch obj.codeRateIndex
                    case 0
                        obj.N=uint32(16200);
                        obj.K=uint32(16008);
                        obj.tCorr=uint32(12);
                    case 1
                        obj.N=uint32(21600);
                        obj.K=uint32(21408);
                        obj.tCorr=uint32(12);
                    case 2
                        obj.N=uint32(25920);
                        obj.K=uint32(25728);
                        obj.tCorr=uint32(12);
                    case 3
                        obj.N=uint32(32400);
                        obj.K=uint32(32208);
                        obj.tCorr=uint32(12);
                    case 4
                        obj.N=uint32(38880);
                        obj.K=uint32(38688);
                        obj.tCorr=uint32(12);
                    case 5
                        obj.N=uint32(43200);
                        obj.K=uint32(43040);
                        obj.tCorr=uint32(10);
                    case 6
                        obj.N=uint32(48600);
                        obj.K=uint32(48408);
                        obj.tCorr=uint32(12);
                    case 7
                        obj.N=uint32(51840);
                        obj.K=uint32(51648);
                        obj.tCorr=uint32(12);
                    case 8
                        obj.N=uint32(54000);
                        obj.K=uint32(53840);
                        obj.tCorr=uint32(10);
                    case 9
                        obj.N=uint32(57600);
                        obj.K=uint32(57472);
                        obj.tCorr=uint32(8);
                    case 10
                        obj.N=uint32(58320);
                        obj.K=uint32(58192);
                        obj.tCorr=uint32(8);
                    otherwise

                        coder.internal.warning('whdl:DVBS2BCHCode:InvalidCodeRateIndex');
                        obj.inStart=false;
                        obj.startInput=false;
                        obj.sampCounter(:)=0;
                        obj.nextFrame=true;
                    end
                    obj.N_long=uint32(2^16-1);
                    obj.K_long=uint32(obj.N_long-uint32(obj.tCorr));
                    obj.GFTable1=obj.gfTable1_16;
                    obj.GFTable2=obj.gfTable2_16;
                    obj.Latency=uint16(24*obj.tCorr*24*5+22+24*16+1+3+1);
                else
                    obj.tCorr=uint32(12);
                    switch obj.codeRateIndex
                    case 0
                        obj.N=uint32(3240);
                        obj.K=uint32(3072);
                    case 1
                        obj.N=uint32(5400);
                        obj.K=uint32(5232);
                    case 2
                        obj.N=uint32(6480);
                        obj.K=uint32(6312);
                    case 3
                        obj.N=uint32(7200);
                        obj.K=uint32(7032);
                    case 4
                        obj.N=uint32(9720);
                        obj.K=uint32(9552);
                    case 5
                        obj.N=uint32(10800);
                        obj.K=uint32(10632);
                    case 6
                        obj.N=uint32(11880);
                        obj.K=uint32(11712);
                    case 7
                        obj.N=uint32(12600);
                        obj.K=uint32(12432);
                    case 8
                        obj.N=uint32(13320);
                        obj.K=uint32(13152);
                    case 9
                        obj.N=uint32(14400);
                        obj.K=uint32(14232);
                    otherwise
                        coder.internal.warning('whdl:DVBS2BCHCode:InvalidCodeRateIndex');
                        obj.inStart=false;
                        obj.startInput=false;
                        obj.sampCounter(:)=0;
                        obj.nextFrame=true;
                    end
                    obj.N_long=uint32(2^14-1);
                    obj.K_long=uint32(obj.N_long-obj.tCorr);
                    obj.GFTable1=obj.gfTable1_14;
                    obj.GFTable2=obj.gfTable2_14;
                    obj.Latency=uint16(24*obj.tCorr*24*5+22+24*14+1+3+1);
                end

                obj.sampleCounter=uint32(0);
                obj.InPacket=true;
                obj.doubleCorr=uint32(2*obj.tCorr);
                obj.syndrome=uint32(zeros(obj.doubleCorr,1));
                obj.syndrometemp=uint32(zeros(obj.doubleCorr,1));
                obj.syntemp=uint32(zeros(obj.doubleCorr,obj.vecLen));
                obj.eleIdx=obj.N-1:-1:0;
                obj.eleIdx(end)=obj.N_long;
                obj.eleVal=zeros(obj.vecLen,1);
                obj.RAMWriteAddr(:)=uint16(1:obj.vecLen);
            end
            if obj.endInput
                obj.latencyEnb=true;
            end
            if obj.latencyEnb
                obj.latencyCount(:)=obj.latencyCount+1;

            end
            if obj.InPacket&&obj.validInput

                obj.DataRAM(obj.RAMWriteAddr,obj.PacketWriteAddr)=obj.dataIn;
                obj.RAMWriteAddr(:)=obj.RAMWriteAddr+obj.vecLen;




                for kk=1:obj.vecLen

                    if obj.dataIn(kk)==1

                        for ii=1:obj.doubleCorr
                            obj.eleVal(kk)=mod((ii*obj.eleIdx(obj.sampleCounter+kk)),obj.N_long);
                            if obj.eleVal(kk)==0
                                obj.eleVal(kk)=obj.N_long;
                            end
                            obj.syntemp(ii,kk)=bitxor(obj.syntemp(ii,kk),obj.GFTable1(obj.eleVal(kk)));
                        end
                    end

                end

                if obj.syndromeEnd
                    obj.InPacket=false;
                    for ii=1:obj.doubleCorr
                        for kk=1:obj.vecLen
                            obj.syndrometemp(ii)=bitxor(obj.syndrometemp(ii),obj.syntemp(ii,kk));
                        end
                        if obj.syndrometemp(ii)==1
                            obj.syndrome(ii)=obj.N_long;
                        elseif obj.syndrometemp(ii)~=0
                            obj.syndrome(ii)=obj.GFTable2(obj.syndrometemp(ii));
                        end
                    end
                    obj.syndromeEnd=false;
                end
                if obj.RAMWriteAddr(end)>obj.N
                    obj.RAMWriteAddr(:)=uint16(1:obj.vecLen);
                end
                obj.sampleCounter(:)=obj.sampleCounter+obj.vecLen;
                if obj.sampleCounter==obj.N
                    obj.forceEnd=true;
                end
            end
            if obj.endInput
                if sum(obj.syndrome)>0


                    [obj.errLocatorPoly,obj.L]=massey(obj);

                    [obj.errPos,obj.cnumerrInt]=cheinSearch(obj.errLocatorPoly,obj.L,obj);
                    if obj.cnumerrInt>0
                        obj.DataRAM(obj.errPos(1:obj.L),obj.PacketWriteAddr)=xor(1,obj.DataRAM(obj.errPos(1:obj.L),obj.PacketWriteAddr));
                    end
                else
                    obj.cheinDone=true;
                end
                if obj.PacketWriteAddr==1
                    obj.PacketWriteAddr(:)=2;
                else
                    obj.PacketWriteAddr(:)=1;
                end
            end
            nextFrameCtrl(obj);
            if obj.cheinDone&&obj.latencyCount>=obj.Latency
                for ii=1:obj.vecLen
                    obj.dataOut(ii)=obj.DataRAM(obj.RAMReadAddr(ii),obj.PacketReadAddr);
                end
                if obj.RAMReadAddr(1)==1
                    obj.startOut=true;
                else
                    obj.startOut=false;
                end
                if obj.RAMReadAddr(obj.vecLen)==obj.K
                    obj.endOut=true;
                    if obj.NumErrorsOutputPort
                        obj.errOut=fi(obj.cnumerrInt,1,5,0);
                    end
                else
                    obj.endOut=false;
                end
                obj.validOut=true;

                obj.RAMReadAddr(:)=uint32(obj.RAMReadAddr(:)+obj.vecLen);

                if obj.RAMReadAddr(end)>obj.K
                    for ii=1:obj.vecLen
                        obj.RAMReadAddr(ii)=uint32(ii);
                    end
                    if obj.PacketReadAddr==1
                        obj.PacketReadAddr=uint8(2);
                    else
                        obj.PacketReadAddr=uint8(1);
                    end
                    obj.cheinDone=false;

                    obj.latencyCount(:)=0;
                    obj.latencyEnb=false;

                end

                obj.nextFrameOut=obj.nextFrame;
                obj.syndromeOut=obj.syndrome(1);

            else
                obj.startOut=false;
                obj.endOut=false;
                obj.validOut=false;
                for ii=1:obj.vecLen
                    obj.dataOut(ii)=false;
                end

                if obj.NumErrorsOutputPort
                    obj.errOut=fi(0,1,5,0);
                    obj.nextFrameOut=obj.nextFrame;
                    obj.syndromeOut=obj.syndrome(1);
                else
                    obj.nextFrameOut=obj.nextFrame;
                    obj.syndromeOut=obj.syndrome(1);

                end
            end
        end
        function sampleCtrl(obj)


            if obj.startIn==1&&obj.validIn==1

                obj.inStart=true;
                obj.startInput=true;
                obj.sampCounter(:)=0;


            else
                obj.startInput=false;
            end

            if obj.validIn&&obj.inStart
                obj.validInput=true;
                obj.sampCounter(:)=obj.sampCounter+uint16(obj.vecLen);
            else
                obj.validInput=false;
            end

            if obj.validInput&&obj.endIn&&obj.inStart
                if obj.sampCounter==obj.N
                    obj.endInput=true;
                    obj.syndromeEnd=true;
                    obj.sampCounter(:)=0;
                else
                    obj.nextFrame=true;
                    obj.endInput=false;
                    obj.syndromeEnd=false;
                    if strcmp(obj.FECFrameType,'Normal')
                        if strcmp(obj.CodeRateSource,'Input port')
                            coder.internal.warning('whdl:DVBS2BCHCode:InvalidInputLengthNormal',double(obj.N),double(obj.codeRateIndex));
                        else
                            coder.internal.warning('whdl:DVBS2BCHCode:InvalidInputLengthNormalProperty',double(obj.N),obj.CodeRateNormal);
                        end
                    else
                        if strcmp(obj.CodeRateSource,'Input port')
                            coder.internal.warning('whdl:DVBS2BCHCode:InvalidInputLengthShort',double(obj.N),double(obj.codeRateIndex));
                        else
                            coder.internal.warning('whdl:DVBS2BCHCode:InvalidInputLengthShortProperty',double(obj.N),obj.CodeRateShort);
                        end
                    end
                end
                obj.inStart=false;
            elseif obj.sampCounter==obj.N&&~obj.endIn
                obj.endInput=false;
                obj.syndromeEnd=false;
                obj.inStart=false;
                obj.nextFrame=true;
                obj.sampCounter(:)=0;
                if strcmp(obj.FECFrameType,'Normal')
                    if strcmp(obj.CodeRateSource,'Input port')
                        coder.internal.warning('whdl:DVBS2BCHCode:InvalidInputLengthNormal',double(obj.N),double(obj.codeRateIndex));
                    else
                        coder.internal.warning('whdl:DVBS2BCHCode:InvalidInputLengthNormalProperty',double(obj.N),obj.CodeRateNormal);
                    end
                else
                    if strcmp(obj.CodeRateSource,'Input port')
                        coder.internal.warning('whdl:DVBS2BCHCode:InvalidInputLengthShort',double(obj.N),double(obj.codeRateIndex));
                    else
                        coder.internal.warning('whdl:DVBS2BCHCode:InvalidInputLengthShortProperty',double(obj.N),obj.CodeRateShort);
                    end
                end
            else
                obj.endInput=false;
                obj.syndromeEnd=false;
            end

        end

        function nextFrameCtrl(obj)
            if obj.endOut&&obj.validOut
                obj.nextFrame=true;
            end
            if obj.startInput&&obj.validInput
                obj.nextFrame=false;
            end

        end

        function[lambda,L]=massey(obj)

            t2=int8(obj.doubleCorr);
            L=int8(0);
            kCC=int8(-1);
            lambda=uint32([obj.N_long;zeros(t2-1,1)]);
            Dz=uint32([0;obj.N_long;zeros(t2-2,1)]);
            syn=uint32(obj.syndrome);


            for nCC=0:t2-1
                discrep=uint32(0);


                for ii=0:L
                    if(lambda(ii+1,1)~=0&&syn(nCC-ii+1)~=0)
                        temp=lambda(ii+1,1)+syn(nCC-ii+1);
                        discrep=obj.gfAdd(discrep,temp,obj.N_long,obj.GFTable1,obj.GFTable2);
                    end
                end


                if(discrep)


                    lambdastar=lambda;
                    for jj=1:t2
                        if(Dz(jj)~=0)
                            lambdastar(jj)=obj.gfAdd(lambda(jj),discrep+Dz(jj),obj.N_long,obj.GFTable1,obj.GFTable2);
                        end
                    end


                    if(L<nCC-kCC)


                        Lstar=nCC-kCC;
                        kCC=nCC-L;
                        for jj=1:t2
                            if lambda(jj)~=0
                                Dz(jj)=mod(lambda(jj)+obj.N_long-discrep,obj.N_long);
                                if(Dz(jj)==0)
                                    Dz(jj)=int32(obj.N_long);
                                end
                            else
                                Dz(jj)=int32(0);
                            end
                        end
                        L=Lstar;
                    end

                    lambda=lambdastar;

                end



                Dz(2:end)=Dz(1:end-1);
                Dz(1)=int32(0);
            end
        end

        function[errPos,cnumerr]=cheinSearch(lambda,L,obj)
            t2=obj.doubleCorr;
            cnumerr=fi(0,1,5,0);
            errPos=zeros(obj.tCorr,1,'int32');

            deglambda=uint32(0);
            for ii=1:t2
                if lambda(ii)>0
                    deglambda=ii-1;
                end
            end

            if((deglambda~=L)||(deglambda<1))
                cnumerr=fi(-1,1,5,0);
                return;
            else

                errIdx=fi(0,1,5,0);
                for ii=0:ceil(obj.N_long)-1
                    tempXOR=uint32(0);
                    temp=uint32(zeros(t2,1));
                    tempGF=uint32(zeros(t2,1));
                    for jj=1:t2
                        if(lambda(jj)~=0)
                            temp(jj)=lambda(jj)+(ii*(jj-1));
                            if temp(jj)>obj.N_long
                                temp(jj)=mod(temp(jj),obj.N_long);

                            end
                            if temp(jj)==0
                                temp(jj)=obj.N_long;
                            end
                            tempGF(jj)=obj.GFTable1(temp(jj));
                            if jj==2
                                tempXOR=bitxor(tempGF(jj-1),tempGF(jj));
                            elseif jj>2
                                tempXOR=bitxor(tempXOR,tempGF(jj));
                            end
                        end
                    end
                    sumVal=tempXOR;
                    if(sumVal==0&&errIdx<obj.tCorr)
                        errIdx(:)=errIdx+1;
                        if ii==0
                            errPos(errIdx)=obj.N_long;
                        else
                            errPos(errIdx)=ii-(obj.N_long-obj.N);
                        end
                    end
                end
                cnumerr(:)=errIdx;




                if cnumerr~=deglambda
                    cnumerr=fi(-1,1,5,0);
                end
                if nnz(errPos)~=L
                    cnumerr=fi(-1,1,5,0);
                end
            end

            obj.cheinDone=true;
        end

        function gfaddval=gfAdd(~,ele1,ele2,n,e2p,p2e)
            if(ele1>n)
                ele1=mod(ele1,n);
                if ele1==0
                    ele1=uint32(n);
                end
            end
            if(ele2>n)
                ele2=mod(ele2,n);
                if ele2==0
                    ele2=uint32(n);
                end
            end
            if ele1==0
                gfaddval=ele2;
            elseif ele2==0
                gfaddval=ele1;
            else
                gfaddval=bitxor(e2p(ele1),e2p(ele2));
                if gfaddval==1
                    gfaddval=uint32(n);
                elseif gfaddval~=0
                    gfaddval=p2e(gfaddval);
                end
            end
        end
        function result=GFMultiply(obj,a,b,e2p,p2e)

            if(a==0)||(b==0)
                result=uint32(0);
            elseif(a==1)
                result=b;
            elseif(b==1)
                result=a;
            else

                loga=e2p(a);
                logb=e2p(b);
                tempSum=loga+logb;
                tempMod=mod(tempSum,obj.N_long);
                if tempMod==0
                    result=uint32(1);
                else
                    result=uint32(p2e(tempMod));
                end
            end
        end

        function result=GFInverse(obj,a,e2p,p2e)
            if a==0
                result=uint32(0);
            else
                fieldCharacteristic=uint32(obj.N_long);
                loga=e2p(a);
                logresult=fieldCharacteristic-loga;
                result=uint32(p2e(logresult));
            end
        end

        function flag=isInputSizeMutableImpl(~,~)
            flag=false;
        end

        function flag=isInputComplexityMutableImpl(~,~)
            flag=false;
        end


        function resetStates(obj)

            obj.startIn=false;
            obj.endIn=false;
            obj.validIn=false;
            obj.startInput=false;
            obj.endDetected=false;
            obj.validInput=false;
            obj.RAMWriteAddr=uint32(1:obj.vecLen);
            obj.PacketWriteAddr=uint8(1);
            obj.cheinDone=false;
            obj.InPacket=false;

            obj.DataRAM=false(2^16-1,2);
            obj.RAMReadAddr=uint32(1:obj.vecLen);
            obj.PacketReadAddr=uint8(1);

            obj.eleVal=zeros(obj.vecLen,1);
            obj.eleIdx=uint32(2^16-1:-1:1);
            obj.doubleCorr=uint32(2*12);

            obj.tCorr=uint32(12);
            obj.N=uint32(16200);
            obj.K=uint32(16008);
            obj.N_long=uint32(2^16-1);
            obj.K_long=uint32(obj.N_long-obj.tCorr);
            obj.GFTable1=obj.gfTable1_14;
            obj.GFTable2=obj.gfTable2_14;

            obj.dataIn=false(obj.vecLen,1);
            obj.dataOut=false(obj.vecLen,1);
            obj.cnumerrInt=fi(0,1,5,0);
            obj.sampleCounter=uint32(0);
            obj.InPacket=true;
            obj.doubleCorr=uint32(2*obj.tCorr);
            obj.syndrome=uint32(zeros(obj.doubleCorr,1));
            obj.syndrometemp=uint32(zeros(obj.doubleCorr,1));
            obj.syntemp=uint32(zeros(obj.doubleCorr,obj.vecLen));
            obj.codeRateIndex=fi(0,0,4,0);
            if strcmp(obj.FECFrameType,'Normal')
                obj.frameType=false;
                switch obj.CodeRateNormal
                case '1/4'
                    obj.codeRateIndex(:)=0;
                case '1/3'
                    obj.codeRateIndex(:)=1;
                case '2/5'
                    obj.codeRateIndex(:)=2;
                case '1/2'
                    obj.codeRateIndex(:)=3;
                case '3/5'
                    obj.codeRateIndex(:)=4;
                case '2/3'
                    obj.codeRateIndex(:)=5;
                case '3/4'
                    obj.codeRateIndex(:)=6;
                case '4/5'
                    obj.codeRateIndex(:)=7;
                case '5/6'
                    obj.codeRateIndex(:)=8;
                case '8/9'
                    obj.codeRateIndex(:)=9;
                case '9/10'
                    obj.codeRateIndex(:)=10;
                otherwise
                    error('Invalid code rate');
                end
            else
                switch obj.CodeRateShort
                case '1/4'
                    obj.codeRateIndex(:)=0;
                case '1/3'
                    obj.codeRateIndex(:)=1;
                case '2/5'
                    obj.codeRateIndex(:)=2;
                case '1/2'
                    obj.codeRateIndex(:)=3;
                case '3/5'
                    obj.codeRateIndex(:)=4;
                case '2/3'
                    obj.codeRateIndex(:)=5;
                case '3/4'
                    obj.codeRateIndex(:)=6;
                case '4/5'
                    obj.codeRateIndex(:)=7;
                case '5/6'
                    obj.codeRateIndex(:)=8;
                case '8/9'
                    obj.codeRateIndex(:)=9;
                otherwise
                    error('Invalid code rate');
                end
                obj.frameType=true;
            end
            obj.forceEnd=false;
            obj.errPos=zeros(12,1,'int32');
            obj.errLocatorPoly=uint32(zeros(12,1));
            obj.L=int8(0);

            obj.nextFrame=true;

            obj.counterLoad=false;
            obj.InpacketNxt=false;

            obj.syndromeEnd=false;
            obj.sampCounter=uint16(0);
            obj.inStart=false;
            obj.latencyEnb=false;
            obj.latencyCount=uint16(0);
        end

        function validateInputsImpl(obj,varargin)

            data=varargin{1};
            validateattributes(data,{'logical'},{'scalar'},'DVBS2BCHDecoder','dataIn');
            ctrl=varargin{2};
            if isstruct(ctrl)
                test=fieldnames(ctrl);
                truth={'start';'end';'valid'};
                if isequal(test,truth)
                    validateattributes(ctrl.start,{'logical'},{'scalar'},'DVBS2BCHDecoder','startIn');
                    validateattributes(ctrl.end,{'logical'},{'scalar'},'DVBS2BCHDecoder','endIn');
                    validateattributes(ctrl.valid,{'logical'},{'scalar'},'DVBS2BCHDecoder','validIn');
                else
                    coder.internal.error('whdl:DVBS2BCHCode:InvalidCtrlBusType');
                end
            else
                coder.internal.error('whdl:DVBS2BCHCode:InvalidCtrlBusType');
            end

            if strcmp(obj.CodeRateSource,'Input port')

                codeRate=varargin{3};
                validateattributes(codeRate,{'embedded.fi'},{'scalar'},'DVBS2BCHDecoder','codeRate');
                if isa(codeRate,'embedded.fi')
                    if strcmp(codeRate.Signedness,'Signed')&&codeRate.FractionLength>0
                        coder.internal.error('whdl:DVBS2BCHCode:CodeRateUnsignedFracLenZero');
                    end
                    if strcmp(codeRate.Signedness,'Signed')
                        coder.internal.error('whdl:DVBS2BCHCode:CodeRateUnsigned');
                    end
                    if codeRate.WordLength~=4
                        coder.internal.error('whdl:DVBS2BCHCode:CodeRateWordLength');
                    end
                    if codeRate.FractionLength>0
                        coder.internal.error('whdl:DVBS2BCHCode:CodeRateFracLenZero');
                    end
                end
            end

        end


        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end

        function setupImpl(obj,dataIn,~)
            gfTables=coder.load('whdl/+satcomhdl/+internal/dvbs2BCH_GFTables.mat','GFTable');

            obj.gfTable1_16=uint32(gfTables.GFTable(1).table1);
            obj.gfTable2_16=uint32(gfTables.GFTable(1).table2);
            obj.gfTable2_16(1)=uint32(2^16-1);


            obj.gfTable1_14=uint32(gfTables.GFTable(2).table1);
            obj.gfTable2_14=uint32(gfTables.GFTable(2).table2);
            obj.gfTable2_14(1)=uint32(2^14-1);


            obj.startIn=false;
            obj.startInput=false;
            obj.validInput=false;
            obj.endInput=false;
            obj.endIn=false;
            obj.validIn=false;
            obj.vecLen=uint32(length(dataIn));
            obj.RAMWriteAddr=uint32(1:obj.vecLen);
            obj.PacketWriteAddr=uint8(1);
            obj.cheinDone=false;
            obj.InPacket=false;
            obj.endDetected=false;

            obj.DataRAM=false(2^16-1,2);
            obj.RAMReadAddr=uint32(1:obj.vecLen);
            obj.PacketReadAddr=uint8(1);

            obj.eleVal=zeros(obj.vecLen,1);
            obj.eleIdx=uint32(2^16-1:-1:1);
            obj.doubleCorr=uint32(2*12);

            obj.tCorr=uint32(12);
            obj.N=uint32(16200);
            obj.K=uint32(16008);
            obj.N_long=uint32(2^16-1);
            obj.K_long=uint32(obj.N_long-obj.tCorr);
            obj.GFTable1=obj.gfTable1_14;
            obj.GFTable2=obj.gfTable2_14;

            obj.dataIn=false(obj.vecLen,1);
            obj.dataOut=false(obj.vecLen,1);
            obj.cnumerrInt=fi(0,1,5,0);
            obj.sampleCounter=uint32(0);
            obj.InPacket=true;
            obj.doubleCorr=uint32(2*obj.tCorr);
            obj.syndrome=uint32(zeros(obj.doubleCorr,1));
            obj.syndrometemp=uint32(zeros(obj.doubleCorr,1));
            obj.syntemp=uint32(zeros(obj.doubleCorr,obj.vecLen));
            obj.codeRateIndex=fi(0,0,4,0);
            obj.Latency=uint16(24*12*24+22+24*16);
            obj.latencyEnb=false;
            obj.latencyCount=uint16(0);
            if strcmp(obj.FECFrameType,'Normal')
                obj.frameType=false;
                switch obj.CodeRateNormal
                case '1/4'
                    obj.codeRateIndex(:)=0;
                case '1/3'
                    obj.codeRateIndex(:)=1;
                case '2/5'
                    obj.codeRateIndex(:)=2;
                case '1/2'
                    obj.codeRateIndex(:)=3;
                case '3/5'
                    obj.codeRateIndex(:)=4;
                case '2/3'
                    obj.codeRateIndex(:)=5;
                case '3/4'
                    obj.codeRateIndex(:)=6;
                case '4/5'
                    obj.codeRateIndex(:)=7;
                case '5/6'
                    obj.codeRateIndex(:)=8;
                case '8/9'
                    obj.codeRateIndex(:)=9;
                case '9/10'
                    obj.codeRateIndex(:)=10;
                otherwise
                    coder.internal.warning('whdl:DVBS2BCHCode:InvalidCodeRateIndex');
                end
            else
                switch obj.CodeRateShort
                case '1/4'
                    obj.codeRateIndex(:)=0;
                case '1/3'
                    obj.codeRateIndex(:)=1;
                case '2/5'
                    obj.codeRateIndex(:)=2;
                case '1/2'
                    obj.codeRateIndex(:)=3;
                case '3/5'
                    obj.codeRateIndex(:)=4;
                case '2/3'
                    obj.codeRateIndex(:)=5;
                case '3/4'
                    obj.codeRateIndex(:)=6;
                case '4/5'
                    obj.codeRateIndex(:)=7;
                case '5/6'
                    obj.codeRateIndex(:)=8;
                case '8/9'
                    obj.codeRateIndex(:)=9;
                otherwise
                    coder.internal.warning('whdl:DVBS2BCHCode:InvalidCodeRateIndex');
                end
                obj.frameType=true;
            end

            obj.forceEnd=false;
            obj.errPos=zeros(12,1,'int32');
            obj.errLocatorPoly=uint32(zeros(12,1));
            obj.L=int8(0);

            obj.nextFrame=true;

            obj.counterLoad=false;
            obj.InpacketNxt=false;

            obj.syndromeEnd=false;
            obj.sampCounter=uint16(0);
            obj.inStart=false;
            obj.CodewordLength=obj.N;
            obj.MessageLength=obj.K;

            obj.startOut=false;
            obj.validOut=false;
            obj.endOut=false;
            obj.nextFrameOut=true;
            obj.errOut=fi(0,1,5,0);
            obj.syndromeOut=uint32(0);
        end

        function num=getNumInputsImpl(obj)
            num=2;
            if strcmp(obj.CodeRateSource,'Input port')
                num=3;
            end


        end

        function num=getNumOutputsImpl(obj)
            num=3;
            if obj.NumErrorsOutputPort
                num=4;
            end
        end

        function icon=getIconImpl(~)






            icon=sprintf('DVB-S2 \n BCH Decoder');


        end

        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='data';
            varargout{2}='ctrl';
            if strcmp(obj.CodeRateSource,'Input port')
                varargout{3}='codeRateIdx';

            end

        end

        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='data';
            varargout{2}='ctrl';

            if obj.NumErrorsOutputPort
                varargout{3}='numCorrErr';
                varargout{4}='nextFrame';

            else
                varargout{3}='nextFrame';

            end
        end
        function varargout=getOutputSizeImpl(obj)
            varargout=cell(1,getNumOutputs(obj));

            varargout{1}=propagatedInputSize(obj,1);
            varargout{2}=propagatedInputSize(obj,2);

            if obj.NumErrorsOutputPort
                varargout{3}=1;
                varargout{4}=1;
                varargout{5}=1;
            else
                varargout{3}=1;
                varargout{4}=1;

            end
        end

        function varargout=isOutputComplexImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}=propagatedInputComplexity(obj,1);
            varargout{2}=false;

            if obj.NumErrorsOutputPort
                varargout{3}=false;
                varargout{4}=false;
                varargout{5}=false;

            else
                varargout{3}=false;
                varargout{4}=false;

            end
        end

        function varargout=getOutputDataTypeImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}=propagatedInputDataType(obj,1);
            varargout{2}=samplecontrolbustype;

            if obj.NumErrorsOutputPort
                varargout{3}=numerictype(1,5,0);
                varargout{4}='logical';


            else
                varargout{3}='logical';

            end
        end

        function varargout=isOutputFixedSizeImpl(obj)
            numOuts=getNumOutputs(obj);
            varargout=cell(1,numOuts);
            varargout{1}=true;
            varargout{2}=true;

            if obj.NumErrorsOutputPort
                varargout{3}=true;
                varargout{4}=true;

            else
                varargout{3}=true;

            end
        end

        function flag=isInactivePropertyImpl(obj,prop)

            if strcmpi(obj.FECFrameType,'Normal')
                props={'CodeRateShort'};
                if strcmpi(obj.CodeRateSource,'Input port')
                    props=[props,{'CodeRateNormal'}];
                end
            else
                props={'CodeRateNormal'};
                if strcmpi(obj.CodeRateSource,'Input port')
                    props=[props,{'CodeRateShort'}];
                end
            end
            flag=ismember(prop,props);
        end
    end

    methods(Static,Access=protected)
        function isVisible=showSimulateUsingImpl

            isVisible=false;
        end
    end
end

