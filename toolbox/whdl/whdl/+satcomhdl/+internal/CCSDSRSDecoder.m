classdef(StrictDefaults)CCSDSRSDecoder<matlab.System

%#codegen

    properties(Nontunable)

        MessageLength='223';

        InterleavingDepth='1';


        NumCorrErrPort(1,1)logical=false;
    end

    properties(Hidden,Constant)
        MessageLengthSet=matlab.system.StringSet(...
        {'223','239'});
        InterleavingDepthSet=matlab.system.StringSet(...
        {'1','2','3','4','5','8'});
    end

    properties(Access=private,Constant)

        fullCodeLen=255;
    end

    properties(Nontunable,Access=private)

msgLen

intrlvDepth

errCapability

B

fullCodeBlkLen

nPackets

Latency

nextFrameLowTime

processingTime

inPorts
    end

    properties(Access=private)

PowerTable
LogTable
AntiLogTable
D2C
C2D


DataRAM
RAMWriteAddr
RAMReadAddr


PacketError
PacketReadAddr
PacketWriteAddr
PacketValid
PacketLength
PacketLatency
nCorrections
inputCodeLen


SyndromeRegister
FinalSyndrome


nextFrame
raiseValid
forceEnd
InPacket
firstStart
counterLoad


intrlvIndex
clocksCount
counter
sampleCounter

    end


    methods(Access=public)
        function latency=getLatency(obj)
            if strcmpi(obj.MessageLength,'239')
                errorCorrCap=8;
            else
                errorCorrCap=16;
            end
            intDepth=str2double(obj.InterleavingDepth);
            bmLength=4*errorCorrCap+10;
            convLength=(2*errorCorrCap)*(2*errorCorrCap+1)/2;
            chienLength=256;
            processingDelay=bmLength+convLength+chienLength;
            delayWordSize=nextpow2(processingDelay+1);
            latency=((2.^delayWordSize)+1+255*intDepth);
        end
    end

    methods

        function obj=CCSDSRSDecoder(varargin)
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

        function setupImpl(obj)
            obj.msgLen=str2double(obj.MessageLength);

            if(obj.msgLen==239)
                obj.errCapability=8;
                obj.B=120;
            else
                obj.errCapability=16;
                obj.B=112;
            end

            switch obj.InterleavingDepth
            case '2'
                obj.intrlvDepth=2;
            case '3'
                obj.intrlvDepth=3;
            case '4'
                obj.intrlvDepth=4;
            case '5'
                obj.intrlvDepth=5;
            case '8'
                obj.intrlvDepth=8;
            otherwise
                obj.intrlvDepth=1;
            end

            obj.fullCodeBlkLen=obj.fullCodeLen*obj.intrlvDepth;
            obj.intrlvIndex=fi(0,0,nextpow2(obj.intrlvDepth+1),0);

            coder.extrinsic('HDLCCSDSRSCodeTables');


            if isempty(coder.target)
                [~,~,~,~,tPowerTable,tAntiLogTable,tLogTable,D2CTable,C2DTable]=HDLCCSDSRSCodeTables(obj.msgLen);
            else
                [~,~,~,~,tPowerTable,tAntiLogTable,tLogTable,D2CTable,C2DTable]=coder.internal.const(HDLCCSDSRSCodeTables(obj.msgLen));
            end

            obj.PowerTable=tPowerTable;
            obj.LogTable=tLogTable;
            obj.AntiLogTable=tAntiLogTable;
            obj.D2C=D2CTable;
            obj.C2D=C2DTable;
            bmLength=(4*obj.errCapability)+10;
            convLength=(2*obj.errCapability)*(2*obj.errCapability+1)/2;
            chienLength=256;
            delayTotal=bmLength+convLength+chienLength;
            delayWordSize=nextpow2(delayTotal+1);
            obj.Latency=(2.^delayWordSize)+1;
            if(mod(obj.Latency,obj.fullCodeBlkLen)>2*obj.errCapability*obj.intrlvDepth)
                obj.nPackets=ceil((obj.Latency)/obj.fullCodeBlkLen)+2;
            else
                obj.nPackets=ceil((obj.Latency)/obj.fullCodeBlkLen)+1;
            end
            obj.nextFrame=true;
            obj.processingTime=bmLength+convLength;
            if obj.processingTime>obj.fullCodeBlkLen
                obj.nextFrameLowTime=obj.processingTime-obj.fullCodeBlkLen;
            else
                obj.nextFrameLowTime=0;
            end
            obj.counter=uint32(0);
            obj.sampleCounter=fi(0,0,nextpow2(obj.fullCodeBlkLen+1),0);
            obj.counterLoad=false;
            obj.raiseValid=false;
            obj.forceEnd=false;
            obj.clocksCount=fi(obj.fullCodeBlkLen,0,nextpow2(obj.fullCodeBlkLen+1),0);
            obj.resetStates;
        end


        function resetStates(obj)
            obj.SyndromeRegister=fi(zeros(obj.intrlvDepth,2*obj.errCapability),0,8,0);
            obj.FinalSyndrome=fi(zeros(obj.intrlvDepth,2*obj.errCapability),0,8,0);
            obj.DataRAM=fi(zeros(obj.fullCodeBlkLen,obj.nPackets),0,8,0);
            obj.RAMReadAddr=fi(1,0,nextpow2(obj.fullCodeBlkLen+1+1),0);
            obj.RAMWriteAddr=fi(1,0,nextpow2(obj.fullCodeBlkLen+1+1),0);
            obj.PacketWriteAddr=fi(1,0,nextpow2(obj.nPackets+1)+1,0);
            obj.PacketReadAddr=fi(1,0,nextpow2(obj.nPackets+1)+1,0);
            obj.PacketValid=false(obj.nPackets,1);
            obj.PacketLength=fi(zeros(obj.nPackets,1),0,nextpow2(obj.fullCodeLen+1),0);
            obj.nCorrections=fi(zeros(obj.nPackets,obj.intrlvDepth),0,8,0);
            obj.PacketError=false(obj.nPackets,obj.intrlvDepth);
            obj.PacketLatency=fi(zeros(obj.nPackets,1),0,nextpow2(obj.Latency+obj.fullCodeBlkLen+1)+1,0);
            obj.InPacket=false;
            obj.firstStart=true;
            obj.inputCodeLen=fi(obj.fullCodeLen,0,nextpow2(obj.fullCodeLen+1)+1,0);
        end

        function resetImpl(obj)

            obj.resetStates;
        end


        function varargout=outputImpl(obj,varargin)
            x=varargin{1};


            y=cast(0,'like',x);
            startOut=false;
            endOut=false;
            validOut=false;
            errOut=false;
            numErrors=uint8(0);

            if any(obj.PacketValid)
                if obj.PacketLatency(obj.PacketReadAddr)-obj.Latency==1
                    startOut=true;
                end
                if obj.PacketLatency(obj.PacketReadAddr)>obj.Latency
                    y=cast(obj.C2D(fi(obj.DataRAM(obj.RAMReadAddr,obj.PacketReadAddr),0,9,0)+1),'like',x);
                    validOut=true;
                    if obj.RAMReadAddr==(obj.PacketLength(obj.PacketReadAddr)-2*obj.errCapability)*obj.intrlvDepth
                        endOut=true;
                        if any(obj.PacketError(obj.PacketReadAddr,:))
                            errOut=true;
                            numErrors=uint8(0);
                        else
                            numErrors=uint8(sum(obj.nCorrections(obj.PacketReadAddr,:)));
                            errOut=false;
                        end
                    end
                end
            end
            ctrl.start=startOut;
            ctrl.end=endOut;
            ctrl.valid=validOut;

            varargout{1}=y;
            varargout{2}=ctrl;
            varargout{3}=errOut;
            if obj.NumCorrErrPort
                varargout{4}=uint8(numErrors);
                varargout{5}=obj.nextFrame;
            else
                varargout{4}=obj.nextFrame;
            end
        end

        function updateImpl(obj,varargin)

            dataIn=fi(varargin{1},0,8,0);
            ctrl=varargin{2};


            dataInConvBasis=obj.D2C(fi(dataIn,0,9,0)+1);

            startIn=ctrl.start;
            endIn=ctrl.end;
            validIn=ctrl.valid;

            if isempty(obj.SyndromeRegister)
                obj.resetStates;
            end

            if startIn&&validIn
                obj.counter(:)=0;
                obj.sampleCounter(:)=0;
                obj.intrlvIndex(:)=0;
                obj.inputCodeLen(:)=0;
                obj.raiseValid=false;
                obj.counterLoad=false;
                obj.clocksCount(:)=0;
                obj.InPacket=true;
                if obj.nextFrame




                    if obj.firstStart
                        obj.firstStart=false;
                    else
                        obj.PacketWriteAddr(:)=obj.PacketWriteAddr+1;
                    end
                    if obj.PacketWriteAddr==obj.nPackets+1
                        obj.PacketWriteAddr(:)=1;
                    end
                end



                obj.PacketValid(obj.PacketWriteAddr)=false;
                obj.PacketLatency(obj.PacketWriteAddr)=fi(0,0,nextpow2(obj.Latency+obj.fullCodeBlkLen+1)+1,0);

                obj.SyndromeRegister(:)=zeros(obj.intrlvDepth,2*obj.errCapability);
                obj.FinalSyndrome(:)=zeros(obj.intrlvDepth,2*obj.errCapability);
                obj.nextFrame=false;
            end

            if obj.InPacket&&validIn

                if(obj.intrlvIndex==obj.intrlvDepth)
                    obj.intrlvIndex(:)=1;
                else
                    obj.intrlvIndex(:)=obj.intrlvIndex+1;
                end

                if(obj.intrlvIndex==obj.intrlvDepth)
                    obj.inputCodeLen(:)=obj.inputCodeLen+1;
                end

                obj.sampleCounter(:)=obj.sampleCounter+1;
                if obj.sampleCounter==obj.fullCodeBlkLen
                    obj.forceEnd=true;
                end

                gfx=dataInConvBasis;
                if startIn
                    gtemp=fi(zeros(obj.intrlvDepth,2*obj.errCapability),0,8,0);
                    obj.RAMWriteAddr(:)=1;
                else
                    gtemp=fi(obj.SyndromeRegister,0,8,0);
                end
                obj.DataRAM(obj.RAMWriteAddr,obj.PacketWriteAddr)=gfx;
                obj.RAMWriteAddr(:)=obj.RAMWriteAddr+1;

                for ii=1:2*obj.errCapability
                    obj.SyndromeRegister(obj.intrlvIndex,ii)=bitxor(obj.PowerTable(ii+obj.B,fi(gtemp(obj.intrlvIndex,ii),0,9,0)+1),gfx);
                end

            end

            if obj.InPacket&&~startIn&&(endIn||obj.forceEnd)&&validIn

                obj.sampleCounter(:)=0;
                obj.forceEnd=false;
                obj.InPacket=false;


                if(obj.inputCodeLen<(2*obj.errCapability+1))
                    obj.nextFrame=true;
                    obj.PacketWriteAddr(:)=obj.PacketWriteAddr-1;
                    coder.internal.warning('whdl:CCSDSRSDecoder:InvalidCWLen1')
                elseif(obj.intrlvIndex~=obj.intrlvDepth)
                    obj.nextFrame=true;
                    obj.PacketWriteAddr(:)=obj.PacketWriteAddr-1;
                    coder.internal.warning('whdl:CCSDSRSDecoder:InvalidCWLen2')
                else
                    obj.counterLoad=true;
                    obj.raiseValid=true;
                    obj.PacketLength(obj.PacketWriteAddr)=obj.inputCodeLen;
                    if obj.RAMWriteAddr>obj.fullCodeBlkLen
                        obj.RAMWriteAddr(:)=1;
                    end

                    obj.FinalSyndrome=obj.SyndromeRegister;
                    cPoly=obj.massey();
                    cPolyOrder=(sum(double(cPoly~=0),2))';
                    [correctionLocations,corrections,nCorrs]=obj.chien(cPoly);
                    obj.nCorrections(obj.PacketWriteAddr,:)=nCorrs;
                    obj.PacketError(obj.PacketWriteAddr,:)=false(1,obj.intrlvDepth);

                    for intrlvInd=1:obj.intrlvDepth
                        if all(cPoly(intrlvInd,:)==0)
                            obj.PacketError(obj.PacketWriteAddr,intrlvInd)=false;
                        elseif(cPolyOrder(intrlvInd)>obj.errCapability+1)||...
                            (fi(cPolyOrder(intrlvInd)-1,0,8,0)>nCorrs(intrlvInd))
                            obj.PacketError(obj.PacketWriteAddr,intrlvInd)=true;
                        elseif nCorrs(intrlvInd)~=0
                            for ii=1:nCorrs(intrlvInd)
                                addr=obj.intrlvDepth*(correctionLocations(intrlvInd,:)-1)+intrlvInd;
                                obj.DataRAM(addr(ii),obj.PacketWriteAddr)=...
                                bitxor(obj.DataRAM(addr(ii),obj.PacketWriteAddr),...
                                corrections(intrlvInd,ii));
                            end
                        end
                    end

                end
            end

            if(obj.clocksCount<obj.fullCodeBlkLen)
                obj.clocksCount(:)=obj.clocksCount+1;
            end

            if(obj.counterLoad&&obj.clocksCount==obj.fullCodeBlkLen)
                obj.counter(:)=obj.counter(:)+1;
                if(obj.counter(:)==obj.nextFrameLowTime+1)
                    obj.counter(:)=0;
                    obj.counterLoad=false;
                    obj.nextFrame=true;
                end
            end

            if(obj.clocksCount==obj.fullCodeBlkLen)
                if(obj.raiseValid)
                    obj.PacketValid(obj.PacketWriteAddr)=true;
                    obj.raiseValid=false;
                end
            end


            if any(obj.PacketValid)
                if obj.PacketLatency(obj.PacketReadAddr)>obj.Latency
                    if obj.RAMReadAddr==(obj.PacketLength(obj.PacketReadAddr)-2*obj.errCapability)*obj.intrlvDepth

                        obj.PacketValid(obj.PacketReadAddr)=false;
                        obj.PacketError(obj.PacketReadAddr,:)=false(1,obj.intrlvDepth);
                        obj.PacketLength(obj.PacketReadAddr)=fi(0,0,nextpow2(obj.fullCodeLen+1),0);
                        obj.nCorrections(obj.PacketReadAddr,:)=fi(zeros(1,obj.intrlvDepth),0,8,0);
                        obj.PacketLatency(obj.PacketReadAddr)=fi(0,0,nextpow2(obj.Latency+obj.fullCodeBlkLen+1)+1,0);
                        obj.RAMReadAddr(:)=1;

                        obj.PacketReadAddr(:)=obj.PacketReadAddr+1;
                        if obj.PacketReadAddr==obj.nPackets+1
                            obj.PacketReadAddr(:)=1;
                        end
                    else
                        obj.RAMReadAddr(:)=obj.RAMReadAddr+1;
                        if obj.RAMReadAddr>obj.fullCodeBlkLen
                            obj.RAMReadAddr(:)=1;
                        end
                    end
                end

                obj.PacketLatency(obj.PacketValid)=fi(obj.PacketLatency(obj.PacketValid)+1,0,nextpow2(obj.Latency+obj.fullCodeBlkLen+1)+1,0);
            end

        end

        function result=GFMultiply(obj,a,b)
            if(a==0)||(b==0)
                result=fi(0,0,8,0);
            elseif(a==1)
                result=fi(b,0,8,0);
            elseif(b==1)
                result=fi(a,0,8,0);
            else
                loga=fi(obj.LogTable(a),0,9,0);
                logb=fi(obj.LogTable(b),0,9,0);
                tempSum=loga+logb;
                tempMod=mod(tempSum,fi(255,0,8,0));
                if tempMod==0
                    result=fi(1,0,8,0);
                else
                    result=fi(obj.AntiLogTable(tempMod),0,8,0);
                end
            end
        end

        function result=GFInverse(obj,a)
            if a==0
                result=fi(0,0,8,0);
            else
                loga=obj.LogTable(a);
                logresult=fi(255,0,8,0)-loga;
                result=fi(obj.AntiLogTable(logresult),0,8,0);
            end
        end

        function cPolyAll=massey(obj)

            cPolyAll=fi(zeros(obj.intrlvDepth,2*obj.errCapability),0,8,0);

            for intrlvInd=1:obj.intrlvDepth
                cPoly=zeros(1,2*obj.errCapability);
                cPoly(1)=1;
                pPoly=zeros(1,2*obj.errCapability);
                pPoly(1)=1;
                LReg=0;
                SyndromeShiftRegister=fi(zeros(1,2*obj.errCapability),0,8,0);
                LShift=false(1,2*obj.errCapability);
                LShift(1)=true;
                currentShift=1;
                dm=fi(1,0,8,0);
                zerosConst=zeros(1,2*obj.errCapability);

                for kk=1:2*obj.errCapability
                    d=fi(0,0,8,0);
                    SyndromeShiftRegister=[obj.FinalSyndrome(intrlvInd,kk),SyndromeShiftRegister(1:end-1)];
                    for ii=1:2*obj.errCapability
                        if LShift(ii)
                            mulTemp=obj.GFMultiply(cPoly(ii),SyndromeShiftRegister(ii));
                            d=(bitxor(d,mulTemp));
                        end
                    end

                    if d==0
                        currentShift=currentShift+1;
                    else

                        pPolyShift=[zerosConst(1:currentShift),pPoly(1:end-currentShift)];
                        tempPoly=cPoly;
                        dmInv=obj.GFInverse(dm);

                        for ii=1:2*obj.errCapability
                            stepXOR=obj.GFMultiply(d,obj.GFMultiply(dmInv,pPolyShift(ii)));
                            cPoly(ii)=bitxor(fi(cPoly(ii),0,8,0),stepXOR);
                        end
                        if 2*LReg>=kk
                            currentShift=currentShift+1;
                        else
                            LReg=kk-LReg;
                            dm=d;
                            for ii=1:LReg+1
                                if ii<=2*obj.errCapability
                                    LShift(ii)=true;
                                end
                            end
                            currentShift=1;
                            pPoly=tempPoly;
                        end
                    end

                end
                cPolyAll(intrlvInd,:)=fi(cPoly,0,8,0);
            end
        end


        function[correctionLocationsAll,correctionsAll,nCorrectionsAll]=chien(obj,cPoly)

            correctionLocationsAll=fi(zeros(obj.intrlvDepth,64),0,8,0);
            correctionsAll=fi(zeros(obj.intrlvDepth,64),0,8,0);
            nCorrectionsAll=fi(zeros(1,obj.intrlvDepth),0,8,0);

            for intrlvInd=1:obj.intrlvDepth

                correctionLocations=zeros(1,64);
                corrections=zeros(1,64);
                currentCorrection=1;



                omegaPoly=fi(zeros(1,2*obj.errCapability),0,8,0);
                for kk=1:2*obj.errCapability
                    for jj=1:kk
                        omegaProduct=obj.GFMultiply(obj.FinalSyndrome(intrlvInd,jj),cPoly(intrlvInd,kk-jj+1));
                        omegaPoly(kk)=bitxor(fi(omegaPoly(kk),0,8,0),omegaProduct);
                    end
                end

                chienReg=cPoly(intrlvInd,:);

                for ii=1:obj.fullCodeLen
                    chienValue=chienReg(1);
                    omegaValue=omegaPoly(1);
                    derivValue=0;
                    for jj=2:2*obj.errCapability
                        chienReg(jj)=obj.PowerTable(jj,chienReg(jj)+1);
                        chienValue=bitxor(chienValue,chienReg(jj));
                        omegaPoly(jj)=obj.PowerTable(jj,omegaPoly(jj)+1);
                        omegaValue=bitxor(omegaValue,omegaPoly(jj));
                        if mod(jj,2)==0
                            derivValue=double(bitxor(fi(derivValue,0,8,0),chienReg(jj)));
                        end
                    end

                    if chienValue==0

                        if fi(obj.fullCodeLen-ii,0,8,0)<obj.PacketLength(obj.PacketWriteAddr)
                            correctionLocations(currentCorrection)=obj.PacketLength(obj.PacketWriteAddr)-(obj.fullCodeLen-ii);
                            tempCorrection=obj.GFMultiply(omegaValue,obj.GFInverse(derivValue));


                            tempPolyScale=ii*obj.B*11;
                            tempPolyScaleMod=mod(tempPolyScale,obj.fullCodeLen);
                            if(tempPolyScaleMod~=0)
                                tempCorrection=obj.GFMultiply(tempCorrection,obj.AntiLogTable(tempPolyScaleMod));
                            end

                            corrections(currentCorrection)=tempCorrection;
                            currentCorrection=currentCorrection+1;
                        end
                    end
                end

                nCorrectionsAll(intrlvInd)=fi(currentCorrection-1,0,8,0);
                correctionLocationsAll(intrlvInd,:)=fi(correctionLocations,0,8,0);
                correctionsAll(intrlvInd,:)=fi(corrections,0,8,0);
            end
        end

        function flag=getExecutionSemanticsImpl(~)

            flag={'Classic','Synchronous'};
        end

        function num=getNumInputsImpl(~)
            num=2;
        end

        function num=getNumOutputsImpl(obj)
            if(obj.NumCorrErrPort)
                num=5;
            else
                num=4;
            end
        end

        function s=saveObjectImpl(obj)



            s=saveObjectImpl@matlab.System(obj);


            if obj.isLocked

                s.msgLen=obj.msgLen;
                s.errCapability=obj.errCapability;
                s.intrlvDepth=obj.intrlvDepth;
                s.B=obj.B;
                s.fullCodeBlkLen=obj.fullCodeBlkLen;
                s.nPackets=obj.nPackets;
                s.Latency=obj.Latency;
                s.nextFrameLowTime=obj.nextFrameLowTime;
                s.processingTime=obj.processingTime;

                s.PowerTable=obj.PowerTable;
                s.LogTable=obj.LogTable;
                s.AntiLogTable=obj.AntiLogTable;
                s.D2C=obj.D2C;
                s.C2D=obj.C2D;
                s.DataRAM=obj.DataRAM;
                s.RAMWriteAddr=obj.RAMWriteAddr;
                s.nCorrections=obj.nCorrections;
                s.counter=obj.counter;
                s.sampleCounter=obj.sampleCounter;
                s.inputCodeLen=obj.inputCodeLen;
                s.counterLoad=obj.counterLoad;
                s.InPacket=obj.InPacket;
                s.firstStart=obj.firstStart;
                s.PacketLatency=obj.PacketLatency;
                s.SyndromeRegister=obj.SyndromeRegister;
                s.FinalSyndrome=obj.FinalSyndrome;
                s.nextFrame=obj.nextFrame;
                s.intrlvIndex=obj.intrlvIndex;
                s.forceEnd=obj.forceEnd;
                s.PacketError=obj.PacketError;
                s.RAMReadAddr=obj.RAMReadAddr;
                s.PacketReadAddr=obj.PacketReadAddr;
                s.PacketWriteAddr=obj.PacketWriteAddr;
                s.PacketValid=obj.PacketValid;
                s.PacketLength=obj.PacketLength;
                s.clocksCount=obj.clocksCount;
                s.raiseValid=obj.raiseValid;

            end
        end


        function obj=loadObjectImpl(obj,s,wasLocked)



            loadObjectImpl@matlab.System(obj,s,wasLocked);

            if wasLocked

                obj.msgLen=s.msgLen;
                obj.errCapability=s.errCapability;
                obj.intrlvDepth=s.intrlvDepth;
                obj.B=s.B;
                obj.fullCodeBlkLen=s.fullCodeBlkLen;
                obj.nPackets=s.nPackets;
                obj.Latency=s.Latency;
                obj.nextFrameLowTime=s.nextFrameLowTime;
                obj.processingTime=s.processingTime;

                obj.PowerTable=s.PowerTable;
                obj.LogTable=s.LogTable;
                obj.AntiLogTable=s.AntiLogTable;
                obj.D2C=s.D2C;
                obj.C2D=s.C2D;
                obj.DataRAM=s.DataRAM;
                obj.RAMWriteAddr=s.RAMWriteAddr;
                obj.nCorrections=s.nCorrections;
                obj.counter=s.counter;
                obj.sampleCounter=s.sampleCounter;
                obj.inputCodeLen=s.inputCodeLen;
                obj.counterLoad=s.counterLoad;
                obj.InPacket=s.InPacket;
                obj.firstStart=s.firstStart;
                obj.PacketLatency=s.PacketLatency;
                obj.SyndromeRegister=s.SyndromeRegister;
                obj.FinalSyndrome=s.FinalSyndrome;
                obj.nextFrame=s.nextFrame;
                obj.intrlvIndex=s.intrlvIndex;
                obj.forceEnd=s.forceEnd;
                obj.PacketError=s.PacketError;
                obj.RAMReadAddr=s.RAMReadAddr;
                obj.PacketReadAddr=s.PacketReadAddr;
                obj.PacketWriteAddr=s.PacketWriteAddr;
                obj.PacketValid=s.PacketValid;
                obj.PacketLength=s.PacketLength;
                obj.clocksCount=s.clocksCount;
                obj.raiseValid=s.raiseValid;

            end
        end

        function validateInputsImpl(obj,varargin)

            dataIn=varargin{1};
            ctrlIn=varargin{2};


            validateattributes(dataIn,{'double','single','uint8','embedded.fi'},...
            {'real','scalar'},'CCSDSRSDecoder','data');
            if isa(dataIn,'embedded.fi')
                if(strcmp(dataIn.Signedness,'Signed')||...
                    dataIn.WordLength~=8||dataIn.FractionLength~=0)
                    coder.internal.error('whdl:CCSDSRSDecoder:InvalidInputDataType');
                end
            end


            if isstruct(ctrlIn)
                test=fieldnames(ctrlIn);
                truth={'start';'end';'valid'};
                if isequal(test,truth)
                    validateattributes(ctrlIn.start,{'logical'},{'scalar'},'CCSDSRSDecoder','start');
                    validateattributes(ctrlIn.end,{'logical'},{'scalar'},'CCSDSRSDecoder','end');
                    validateattributes(ctrlIn.valid,{'logical'},{'scalar'},'CCSDSRSDecoder','valid');
                else
                    coder.internal.error('whdl:CCSDSRSDecoder:InvalidSampleCtrlBus');
                end
            else
                coder.internal.error('whdl:CCSDSRSDecoder:InvalidSampleCtrlBus');
            end

            obj.inPorts=~isempty(dataIn);
        end


        function icon=getIconImpl(obj)
            if(obj.inPorts)
                icon=sprintf('CCSDS RS Decoder\nLatency = %d',getLatency(obj));
            else
                icon=sprintf('CCSDS RS Decoder\nLatency = --');
            end
        end

        function varargout=getInputNamesImpl(~)
            varargout{1}='data';
            varargout{2}='ctrl';
        end

        function varargout=getOutputNamesImpl(obj)
            varargout{1}='data';
            varargout{2}='ctrl';
            varargout{3}='err';
            if(~obj.NumCorrErrPort)
                varargout{4}='nextFrame';
            else
                varargout{4}='numCorrErr';
                varargout{5}='nextFrame';
            end
        end

        function varargout=getOutputSizeImpl(obj)
            varargout{1}=propagatedInputSize(obj,1);
            varargout{2}=[1,1];
            varargout{3}=[1,1];
            varargout{4}=[1,1];
            if(obj.NumCorrErrPort)
                varargout{5}=[1,1];
            end
        end

        function varargout=getOutputDataTypeImpl(obj)
            if(obj.NumCorrErrPort)
                varargout={propagatedInputDataType(obj,1),...
                samplecontrolbustype,'logical','uint8','logical'};
            else
                varargout={propagatedInputDataType(obj,1),...
                samplecontrolbustype,'logical','logical'};
            end
        end

        function varargout=isOutputComplexImpl(obj)
            varargout{1}=false;
            varargout{2}=false;
            varargout{3}=false;
            varargout{4}=false;
            if(obj.NumCorrErrPort)
                varargout{5}=false;
            end
        end

        function varargout=isOutputFixedSizeImpl(obj)
            varargout{1}=true;
            varargout{2}=true;
            varargout{3}=true;
            varargout{4}=true;
            if(obj.NumCorrErrPort)
                varargout{5}=true;
            end
        end


    end

    methods(Access=protected,Static)

        function header=getHeaderImpl
            text1='Decode and recover message from Reed-Solomon (RS) codeword according to the CCSDS standard.';
            header=matlab.system.display.Header('satcomhdl.internal.CCSDSRSDecoder',...
            'Title','CCSDS RS Decoder',...
            'Text',text1,...
            'ShowSourceLink',false);
        end

        function group=getPropertyGroupsImpl

            group=matlab.system.display.Section(...
            'Title','Parameters','PropertyList',{'MessageLength','InterleavingDepth','NumCorrErrPort'});
        end

        function flag=showSimulateUsingImpl

            flag=false;
        end

    end
end