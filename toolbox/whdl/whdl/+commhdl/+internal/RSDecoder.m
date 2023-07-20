classdef(StrictDefaults)RSDecoder<matlab.System




%#codegen
%#ok<*EMCLS>

    properties(Nontunable)

















        CodewordLength=7;




        MessageLength=3;







        PrimitivePolynomialSource='Auto';










        PrimitivePolynomial=[1,0,1,1];



        BSource='Auto';





        B=1;


        NumErrorsOutputPort(1,1)logical=false;
    end

    properties(Constant,Hidden)
        PrimitivePolynomialSourceSet=matlab.system.StringSet({...
        'Auto',...
        'Property'});
        BSourceSet=matlab.system.StringSet({...
        'Auto',...
        'Property'});
    end

    properties(Access=private)

        MultTable;
        PowerTable;
        Corr;
        WordSize;
        LogTable;
        AntiLogTable;
        Latency;


        SyndromeRegister;
        FinalSyndrome;
        DataRAM;
        RAMWriteAddr;
        RAMReadAddr;
        PacketWriteAddr;
        PacketReadAddr;
        PacketValid;
        PacketLength;
        PacketError;
        nCorrections;
        PacketLatency;

        InPacket;

        nPackets;
        counter;
        counterLoad;
        nextFrame;
        processingTime;
        nextFrameLowTime;
        firstStart;
        sampleCounter;
        forceEnd;
        inPorts;
        recevCodeWordLength;
        startIn;
        endIn;
        validIn;
        dataIn;
        InpacketNxt;
        nextFrameDelay;
        nextFrameCount;
        nextFrameEnd;
        startReg;
        actualNextFrameLowTime;
    end
    methods(Access=public)
        function latency=getLatency(obj)
            coder.extrinsic('HDLRSGenPoly');
            tWordSize=ceil(log2(obj.CodewordLength));
            doubleTCorr=double((obj.CodewordLength-obj.MessageLength)/2);
            bmLength=4*doubleTCorr+10;
            convLength=(doubleTCorr*2)*(doubleTCorr*2+1)/2;
            chienLength=2.^double(tWordSize);
            processingDelay=bmLength+convLength+chienLength;
            delayWordSize=ceil(log2(processingDelay));
            latency=uint32((2.^delayWordSize)+chienLength+1);
        end
    end
    methods(Static,Access=protected)
        function header=getHeaderImpl


            header=matlab.system.display.Header('commhdl.internal.RSDecoder',...
            'ShowSourceLink',false,...
            'Title','RS Decoder');
        end
    end

    methods
        function obj=RSDecoder(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','LTE_HDL_Toolbox'))
                    error(message('whdl:whdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','LTE_HDL_Toolbox');
            end
            setProperties(obj,nargin,varargin{:},'CodewordLength','MessageLength');
        end















































    end

    methods(Access=protected)
        function s=saveObjectImpl(obj)


            s=saveObjectImpl@matlab.System(obj);

            s.MultTable=obj.MultTable;
            s.PowerTable=obj.PowerTable;
            s.Corr=obj.Corr;
            s.WordSize=obj.WordSize;
            s.LogTable=obj.LogTable;
            s.AntiLogTable=obj.AntiLogTable;
            s.Latency=obj.Latency;

            s.SyndromeRegister=obj.SyndromeRegister;
            s.FinalSyndrome=obj.FinalSyndrome;
            s.DataRAM=obj.DataRAM;
            s.RAMWriteAddr=obj.RAMWriteAddr;
            s.RAMReadAddr=obj.RAMReadAddr;
            s.PacketWriteAddr=obj.PacketWriteAddr;
            s.PacketReadAddr=obj.PacketReadAddr;
            s.PacketValid=obj.PacketValid;
            s.PacketLength=obj.PacketLength;
            s.PacketError=obj.PacketError;
            s.nCorrections=obj.nCorrections;
            s.PacketLatency=obj.PacketLatency;

            s.InPacket=obj.InPacket;

            s.nPackets=obj.nPackets;
            s.counter=obj.counter;
            s.counterLoad=obj.counterLoad;
            s.nextFrame=obj.nextFrame;
            s.processingTime=obj.processingTime;
            s.nextFrameLowTime=obj.nextFrameLowTime;
            s.firstStart=obj.firstStart;
            s.recevCodeWordLength=obj.recevCodeWordLength;
            s.startIn=obj.startIn;
            s.endIn=obj.endIn;
            s.validIn=obj.validIn;
            s.dataIn=obj.dataIn;
            s.InpacketNxt=obj.InpacketNxt;
            s.nextFrameDelay=obj.nextFrameDelay;
            s.nextFrameCount=obj.nextFrameCount;
            s.nextFrameEnd=obj.nextFrameEnd;
            s.startReg=obj.startReg;
            s.actualNextFrameLowTime=obj.actualNextFrameLowTime;
        end

        function obj=loadObjectImpl(obj,s,~)


            loadObjectImpl@matlab.System(obj,s);
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
        function[varargout]=outputImpl(obj,x,ctrl)


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
                    y=cast(obj.DataRAM(obj.RAMReadAddr,obj.PacketReadAddr),'like',x);
                    validOut=true;
                    if obj.RAMReadAddr==obj.PacketLength(obj.PacketReadAddr)-(2*obj.Corr)
                        endOut=true;
                        if obj.PacketError(obj.PacketReadAddr)
                            errOut=true;
                            numErrors=uint8(0);
                        else
                            numErrors=uint8(obj.nCorrections(obj.PacketReadAddr));
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
            if obj.NumErrorsOutputPort
                varargout{4}=uint8(numErrors);
                varargout{5}=obj.nextFrame;
            else
                varargout{4}=obj.nextFrame;
            end
        end

        function updateImpl(obj,x,ctrl)

            if isempty(obj.SyndromeRegister)
                obj.resetStates;
            end

            if obj.startIn&&obj.validIn
                if obj.firstStart
                    obj.PacketWriteAddr=obj.PacketWriteAddr;
                    obj.firstStart=false;
                else
                    if obj.nextFrameDelay
                        obj.PacketWriteAddr=obj.PacketWriteAddr+1;
                    end
                    if obj.PacketWriteAddr==obj.nPackets+1
                        obj.PacketWriteAddr=uint32(1);
                    end
                end
                obj.counter(:)=0;
                obj.sampleCounter(:)=0;
                obj.counterLoad=false;
                obj.InPacket=true;


                obj.PacketLatency(obj.PacketWriteAddr)=uint32(0);
                obj.SyndromeRegister=zeros(obj.CodewordLength-obj.MessageLength,1,'uint32');
                obj.FinalSyndrome=zeros(obj.CodewordLength-obj.MessageLength,1,'uint32');

            end

            if obj.InPacket&&obj.validIn

                obj.sampleCounter(:)=obj.sampleCounter+1;
                if obj.sampleCounter==obj.CodewordLength
                    obj.actualNextFrameLowTime=uint32(obj.CodewordLength-obj.sampleCounter+obj.nextFrameLowTime+1);
                    obj.forceEnd=true;
                end
                gfx=uint32(obj.dataIn);
                if obj.startIn
                    gtemp=uint32(zeros(obj.CodewordLength-obj.MessageLength,1));
                    obj.RAMWriteAddr=uint32(1);
                else
                    gtemp=obj.SyndromeRegister;
                end
                obj.DataRAM(obj.RAMWriteAddr,obj.PacketWriteAddr)=gfx;
                obj.RAMWriteAddr=obj.RAMWriteAddr+1;

                for ii=1:2*obj.Corr
                    obj.SyndromeRegister(ii)=bitand(bitxor(obj.PowerTable(ii+obj.B,gtemp(ii)+1),gfx),...
                    2.^obj.WordSize-1);
                end
            end

            if obj.InPacket&&~obj.startIn&&(obj.endIn||obj.forceEnd)&&obj.validIn
                obj.InPacket=false;
                obj.sampleCounter(:)=0;
                obj.FinalSyndrome=obj.SyndromeRegister;
                obj.forceEnd=false;
            end
            if obj.endIn
                obj.PacketValid(obj.PacketWriteAddr)=true;
                obj.PacketLatency(obj.PacketWriteAddr)=uint32(0);
                obj.PacketLength(obj.PacketWriteAddr)=obj.RAMWriteAddr-1;
                if obj.RAMWriteAddr>obj.CodewordLength
                    obj.RAMWriteAddr(:)=1;
                end
                cPoly=obj.massey();

                cPolyOrder=sum(double(cPoly~=0));
                [correctionLocations,corrections,nCorrs]=obj.chien(cPoly);
                obj.nCorrections(obj.PacketWriteAddr)=nCorrs;
                obj.PacketError(obj.PacketWriteAddr)=false;
                if all(cPoly==0)
                    obj.PacketError(obj.PacketWriteAddr)=false;
                elseif(cPolyOrder>obj.Corr+1)||...
                    (cPolyOrder-1>nCorrs)
                    obj.PacketError(obj.PacketWriteAddr)=true;
                elseif nCorrs~=0
                    for ii=1:nCorrs
                        obj.DataRAM(correctionLocations(ii),obj.PacketWriteAddr)=...
                        bitxor(obj.DataRAM(correctionLocations(ii),obj.PacketWriteAddr),...
                        corrections(ii));
                    end
                end

            end


            if any(obj.PacketValid)

                if obj.PacketLatency(obj.PacketReadAddr)>obj.Latency
                    if obj.RAMReadAddr==obj.PacketLength(obj.PacketReadAddr)-(2*obj.Corr)


                        obj.PacketValid(obj.PacketReadAddr)=false;
                        obj.PacketError(obj.PacketReadAddr)=false;
                        obj.PacketLength(obj.PacketReadAddr)=uint32(0);
                        obj.nCorrections(obj.PacketReadAddr)=uint32(0);
                        obj.PacketLatency(obj.PacketReadAddr)=uint32(0);
                        obj.RAMReadAddr=uint32(1);

                        obj.PacketReadAddr=obj.PacketReadAddr+1;
                        if obj.PacketReadAddr==obj.nPackets+1
                            obj.PacketReadAddr=uint32(1);
                        end
                    else

                        obj.RAMReadAddr=obj.RAMReadAddr+1;
                        if obj.RAMReadAddr>obj.CodewordLength
                            obj.RAMReadAddr(:)=1;
                        end
                    end
                end

                obj.PacketLatency(obj.PacketValid)=obj.PacketLatency(obj.PacketValid)+1;
            end



            obj.dataIn(:)=x;
            sampleBusCtrl(obj,ctrl);
            nextFrameControl(obj);

        end
        function obj=sampleBusCtrl(obj,ctrl)

            if ctrl.start&&ctrl.valid
                obj.startReg=true;
                obj.startIn=true;
            else
                obj.startIn=false;
            end
            if ctrl.valid&&obj.startReg
                obj.validIn=true;
            else
                obj.validIn=false;
            end
            if ctrl.end&&obj.startReg&&ctrl.valid&&~obj.startIn

                obj.endIn=true;
                obj.startReg=false;
            else
                obj.endIn=false;
            end
        end
        function obj=nextFrameControl(obj)
            obj.nextFrameDelay=obj.nextFrame;
            if obj.startIn&&obj.validIn
                obj.nextFrame=false;
                obj.counter(:)=0;
                obj.counterLoad=false;
                obj.InpacketNxt=true;
            end
            if obj.InpacketNxt&&obj.validIn
                obj.nextFrameCount(:)=obj.nextFrameCount+1;
                if obj.nextFrameCount==obj.CodewordLength

                    obj.nextFrameCount(:)=0;
                    obj.nextFrameEnd=true;
                else
                    obj.nextFrameEnd=false;
                end
            end
            if obj.InpacketNxt&&(obj.endIn||obj.nextFrameEnd)&&obj.validIn
                obj.actualNextFrameLowTime=uint32(obj.CodewordLength-obj.sampleCounter-1+obj.nextFrameLowTime+1);
                obj.nextFrame=obj.actualNextFrameLowTime==1;
                obj.nextFrameCount(:)=0;
                obj.InpacketNxt=false;
                obj.counterLoad=true;
                obj.counter(:)=0;
            end
            if obj.counterLoad
                obj.counter(:)=obj.counter(:)+1;
                if obj.counter(:)==obj.actualNextFrameLowTime
                    obj.counter(:)=0;
                    obj.counterLoad=false;
                    obj.nextFrame=true;
                end
            end
        end
        function result=GFMultiply(obj,a,b)
            if(a==0)||(b==0)
                result=uint32(0);
            elseif(a==1)
                result=b;
            elseif(b==1)
                result=a;
            else
                codeSize=uint32(2.^obj.WordSize);
                loga=obj.LogTable(a);
                logb=obj.LogTable(b);
                tempSum=loga+logb;
                tempMod=mod(tempSum,codeSize-1);
                if tempMod==0
                    result=uint32(1);
                else
                    result=obj.AntiLogTable(tempMod);
                end
            end
        end

        function result=GFInverse(obj,a)
            if a==0
                result=uint32(0);
            else
                fieldCharacteristic=uint32((2.^obj.WordSize)-1);
                loga=obj.LogTable(a);
                logresult=fieldCharacteristic-loga;
                result=obj.AntiLogTable(logresult);
            end
        end


        function cPoly=massey(obj)
            codeSize=2.^obj.WordSize;
            cPoly=zeros(1,obj.CodewordLength-obj.MessageLength,'uint32');
            cPoly(1)=uint32(1);
            pPoly=zeros(1,obj.CodewordLength-obj.MessageLength,'uint32');
            pPoly(1)=uint32(1);
            LReg=uint32(0);
            SyndromeShiftRegister=zeros(1,obj.CodewordLength-obj.MessageLength,'uint32');
            LShift=false(1,obj.CodewordLength-obj.MessageLength);
            LShift(1)=true;
            currentShift=uint32(1);
            dm=uint32(1);
            zerosConst=zeros(1,obj.CodewordLength-obj.MessageLength,'uint32');

            for k=1:2*obj.Corr
                d=uint32(0);
                SyndromeShiftRegister=[obj.FinalSyndrome(k),SyndromeShiftRegister(1:end-1)];
                for ii=1:2*obj.Corr
                    if LShift(ii)
                        mulTemp=obj.GFMultiply(cPoly(ii),SyndromeShiftRegister(ii));

                        d=bitand(bitxor(d,mulTemp),codeSize-1);
                    end
                end

                if d==0
                    currentShift=currentShift+1;
                else


                    pPolyShift=[zerosConst(1:currentShift),pPoly(1:end-currentShift)];
                    tempPoly=cPoly;
                    dmInv=obj.GFInverse(dm);

                    for ii=1:2*obj.Corr
                        stepXOR=obj.GFMultiply(d,obj.GFMultiply(dmInv,pPolyShift(ii)));
                        cPoly(ii)=bitand(bitxor(cPoly(ii),stepXOR),codeSize-1);
                    end
                    if 2*LReg>=k
                        currentShift=currentShift+1;
                    else
                        LReg=k-LReg;
                        dm=d;
                        for ii=1:LReg+1
                            if ii<=2*obj.Corr
                                LShift(ii)=true;
                            end
                        end
                        currentShift=uint32(1);
                        pPoly=tempPoly;
                    end
                end

            end

        end

        function[correctionLocations,corrections,nCorrections]=chien(obj,cPoly)

            codeSize=2.^obj.WordSize;

            correctionLocations=zeros(1,64,'uint32');
            corrections=zeros(1,64,'uint32');
            currentCorrection=uint32(1);



            omegaPoly=zeros(1,obj.CodewordLength-obj.MessageLength,'uint32');
            for kk=1:2*obj.Corr
                for jj=1:kk
                    omegaProduct=obj.GFMultiply(obj.FinalSyndrome(jj),cPoly(kk-jj+1));
                    omegaPoly(kk)=bitand(bitxor(omegaPoly(kk),omegaProduct),codeSize-1);
                end
            end

            chienReg=cPoly;

            for ii=1:codeSize-1 %#ok<BDSCI>
                chienValue=chienReg(1);
                omegaValue=omegaPoly(1);
                derivValue=uint32(0);
                for jj=2:2*obj.Corr
                    chienReg(jj)=obj.PowerTable(jj,chienReg(jj)+1);
                    chienValue=bitand(bitxor(chienValue,chienReg(jj)),codeSize-1);
                    omegaPoly(jj)=obj.PowerTable(jj,omegaPoly(jj)+1);
                    omegaValue=bitand(bitxor(omegaValue,omegaPoly(jj)),codeSize-1);
                    if mod(jj,2)==0
                        derivValue=bitand(bitxor(derivValue,chienReg(jj)),codeSize-1);
                    end
                end

                if chienValue==0

                    if(codeSize-1-ii)<obj.PacketLength(obj.PacketWriteAddr)
                        correctionLocations(currentCorrection)=obj.PacketLength(obj.PacketWriteAddr)-(codeSize-1-ii);
                        tempCorrection=obj.GFMultiply(omegaValue,obj.GFInverse(derivValue));


                        if obj.B~=0
                            tempPolyScale=ii*obj.B;
                            tempPolyScaleMod=mod(tempPolyScale,codeSize-1);
                            if(tempPolyScaleMod~=0)
                                tempCorrection=obj.GFMultiply(tempCorrection,obj.AntiLogTable(tempPolyScaleMod));
                            end
                        end

                        corrections(currentCorrection)=tempCorrection;
                        currentCorrection=currentCorrection+1;
                    end
                end
            end
            nCorrections=currentCorrection-1;
        end






        function resetStates(obj)

            obj.SyndromeRegister=zeros(obj.CodewordLength-obj.MessageLength,1,'uint32');
            obj.FinalSyndrome=zeros(obj.CodewordLength-obj.MessageLength,1,'uint32');
            obj.DataRAM=zeros(obj.CodewordLength,obj.nPackets,'uint32');
            obj.RAMReadAddr=uint32(1);
            obj.RAMWriteAddr=uint32(1);
            obj.PacketWriteAddr=uint32(1);
            obj.PacketReadAddr=uint32(1);
            obj.PacketValid=false(obj.nPackets,1);
            obj.PacketLength=zeros(obj.nPackets,1,'uint32');
            obj.nCorrections=zeros(obj.nPackets,1,'uint32');
            obj.PacketError=false(obj.nPackets,1);
            obj.PacketLatency=zeros(obj.nPackets,1,'uint32');
            obj.InPacket=false;
            obj.firstStart=true;
            obj.recevCodeWordLength=uint32(0);
            obj.sampleCounter=uint32(0);
            obj.startIn=false;
            obj.endIn=false;
            obj.validIn=false;
            obj.dataIn(:)=0;
            obj.InpacketNxt=false;
            obj.nextFrameDelay=true;
            obj.nextFrameCount=uint32(0);
            obj.nextFrameEnd=false;
            obj.actualNextFrameLowTime=uint32(0);
        end

        function validateInputsImpl(obj,dataIn,ctrlIn)


            validateattributes(dataIn,{'numeric','embedded.fi','logical'},{'scalar'},'RSDecoder','dataIn');
            wl=ceil(log2(obj.CodewordLength));
            if isa(dataIn,'int8')||isa(dataIn,'int16')
                coder.internal.error('whdl:RSCode:InputUnsigned');
            end
            if isa(dataIn,'embedded.fi')
                if strcmp(dataIn.Signedness,'Signed')&&dataIn.FractionLength>0
                    coder.internal.error('whdl:RSCode:InputUnsignedFracLenZero');
                end
                if strcmp(dataIn.Signedness,'Signed')
                    coder.internal.error('whdl:RSCode:InputUnsigned');
                end
                if dataIn.FractionLength>0
                    coder.internal.error('whdl:RSCode:InputFracLenZero');
                end
            end
            if~(isa(dataIn,'double')||isa(dataIn,'single'))
                [inWL,~,~]=dsphdlshared.hdlgetwordsizefromdata(dataIn);
                coder.internal.errorIf(inWL~=ceil(log2(obj.CodewordLength)),...
                'whdl:RSCode:InputWLMisMatch',wl,obj.CodewordLength);
            end




            if isstruct(ctrlIn)
                test=fieldnames(ctrlIn);
                truth={'start';'end';'valid'};
                if isequal(test,truth)
                    validateattributes(ctrlIn.start,{'logical'},{'scalar'},'RSDecoder','startIn');
                    validateattributes(ctrlIn.end,{'logical'},{'scalar'},'RSDecoder','endIn');
                    validateattributes(ctrlIn.valid,{'logical'},{'scalar'},'RSDecoder','validIn');
                else
                    coder.internal.error('whdl:RSCode:InvalidCtrlBusType');
                end
            else
                coder.internal.error('whdl:RSCode:InvalidCtrlBusType');
            end
            obj.inPorts=~isempty(dataIn);
        end
        function validatePropertiesImpl(obj)

            validateattributes(obj.CodewordLength,...
            {'numeric'},{'scalar','integer','>=',7,'<=',65535},'RSDecoder','CodewordLength');

            validateattributes(obj.MessageLength,...
            {'numeric'},{'scalar','integer','>=',3,'<=',obj.CodewordLength-2},'RSDecoder','MessageLength');

            validateattributes(obj.CodewordLength-obj.MessageLength,...
            {'numeric'},{'scalar','even','integer','>=',2},'RSDecoder','CodewordLength - MessageLength');

            if~strcmp(obj.PrimitivePolynomialSource,'Auto')
                validateattributes(obj.PrimitivePolynomial,{'numeric'},{'integer'},'RSDecoder','PrimitivePolynomial');
                [row,col]=size(obj.PrimitivePolynomial);
                ind=find(obj.PrimitivePolynomial>1);
                if(row>1&&col>1)
                    coder.internal.error('whdl:RSCode:InvalidPrimPoly');
                end
                len=length(obj.PrimitivePolynomial);
                if len>1
                    if~isempty(ind)
                        coder.internal.error('whdl:RSCode:InvalidBinaryInput');
                    else
                        val1=bin2dec(num2str(obj.PrimitivePolynomial));
                    end
                else
                    val1=obj.PrimitivePolynomial;
                end
                wordlength=ceil(log2(obj.CodewordLength));
                if val1<=2^wordlength-1||val1>=2^(wordlength+1)
                    coder.internal.error('whdl:RSCode:InvalidPrimPolyRange',2^wordlength-1,2^(wordlength+1),obj.CodewordLength);
                end
            end


            if~strcmp(obj.BSource,'Auto')
                validateattributes(obj.B,{'numeric'},{'scalar','integer','>=',0,'<=',obj.CodewordLength},'RSDecoder','B');
            end

        end

        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end

        function setupImpl(obj,~,~,~,~,varargin)

            coder.extrinsic('HDLRSGenPoly');
            if strcmp(obj.PrimitivePolynomialSource,'Auto')
                if isempty(coder.target)
                    [tMultTable,tPowerTable,tCorr,tWordSize,tAntiLogTable,tLogTable]=HDLRSGenPoly(obj.CodewordLength,obj.MessageLength,obj.B);
                else
                    [tMultTable,tPowerTable,tCorr,tWordSize,tAntiLogTable,tLogTable]=coder.internal.const(...
                    HDLRSGenPoly(obj.CodewordLength,obj.MessageLength,obj.B));
                end
            else
                if isempty(coder.target)
                    [tMultTable,tPowerTable,tCorr,tWordSize,tAntiLogTable,tLogTable]=HDLRSGenPoly(obj.CodewordLength,obj.MessageLength,obj.B,obj.PrimitivePolynomial);
                else
                    [tMultTable,tPowerTable,tCorr,tWordSize,tAntiLogTable,tLogTable]=coder.internal.const(...
                    HDLRSGenPoly(obj.CodewordLength,obj.MessageLength,obj.B,obj.PrimitivePolynomial));
                end
            end
            if isempty(tAntiLogTable)||isempty(tLogTable)
                coder.internal.error('whdl:RSCode:MissingGFTables');
            end
            obj.startIn=false;
            obj.endIn=false;
            obj.validIn=false;
            obj.dataIn=fi(0,0,tWordSize,0);
            obj.MultTable=tMultTable;
            obj.PowerTable=tPowerTable;
            obj.Corr=tCorr;
            obj.WordSize=tWordSize;
            obj.LogTable=tLogTable;
            obj.AntiLogTable=tAntiLogTable;







            doubleTCorr=double(tCorr);
            bmLength=4*doubleTCorr+10;
            convLength=(doubleTCorr*2)*(doubleTCorr*2+1)/2;
            chienLength=2.^double(tWordSize);
            delayTotal=bmLength+convLength+chienLength;
            delayWordSize=ceil(log2(delayTotal));
            obj.Latency=uint32((2.^delayWordSize)+1);
            obj.nPackets=ceil((2.^delayWordSize)/obj.CodewordLength)+1;
            obj.counterLoad=false;
            obj.counter=uint32(0);
            obj.sampleCounter=uint32(0);
            obj.recevCodeWordLength=uint32(0);
            obj.nextFrame=true;
            obj.processingTime=bmLength+convLength;
            if obj.processingTime>obj.CodewordLength
                obj.nextFrameLowTime=uint32(obj.processingTime-obj.CodewordLength);
            else
                obj.nextFrameLowTime=uint32(0);
            end
            obj.resetStates;
            obj.forceEnd=false;

            obj.InpacketNxt=false;
            obj.nextFrameDelay=true;
            obj.nextFrameCount=uint32(0);
            obj.nextFrameEnd=false;
            obj.startReg=false;
            obj.actualNextFrameLowTime=uint32(0);
        end

        function num=getNumInputsImpl(obj)%#ok
            num=2;
        end

        function num=getNumOutputsImpl(obj)
            if obj.NumErrorsOutputPort
                num=5;
            else
                num=4;
            end
        end

        function icon=getIconImpl(obj)

            if isempty(obj.inPorts)
                icon=sprintf('RS Decoder\nLatency = --');
            else
                if~isempty(obj.CodewordLength)&&~isempty(obj.MessageLength)&&~isempty(obj.PrimitivePolynomial)&&~isempty(obj.B)
                    icon=sprintf('RS Decoder\nLatency = %d',getLatency(obj));
                else
                    icon=sprintf('RS Decoder');
                end
            end
        end

        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='data';
            varargout{2}='ctrl';
        end

        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='data';
            varargout{2}='ctrl';
            varargout{3}='err';

            if obj.NumErrorsOutputPort
                varargout{4}='numErrors';
                varargout{5}='nextFrame';
            else
                varargout{4}='nextFrame';
            end
        end
        function varargout=getOutputSizeImpl(obj)
            varargout=cell(1,getNumOutputs(obj));

            varargout{1}=1;
            varargout{2}=propagatedInputSize(obj,2);
            varargout{3}=1;
            if obj.NumErrorsOutputPort
                varargout{4}=1;
                varargout{5}=1;
            else
                varargout{4}=1;
            end
        end

        function varargout=isOutputComplexImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}=propagatedInputComplexity(obj,1);
            varargout{2}=false;
            varargout{3}=false;
            varargout{4}=false;
            if obj.NumErrorsOutputPort
                varargout{5}=false;
            end
        end

        function varargout=getOutputDataTypeImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}=propagatedInputDataType(obj,1);

            varargout{2}=samplecontrolbustype;
            varargout{3}='logical';
            if obj.NumErrorsOutputPort
                varargout{4}='uint8';
                varargout{5}='logical';
            else
                varargout{4}='logical';
            end
        end

        function varargout=isOutputFixedSizeImpl(obj)
            numOuts=getNumOutputs(obj);
            varargout=cell(1,numOuts);
            varargout{1}=true;
            varargout{2}=true;
            varargout{3}=true;
            varargout{4}=true;
            if obj.NumErrorsOutputPort
                varargout{5}=true;
            end

        end











        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case 'PrimitivePolynomial'
                if strcmp(obj.PrimitivePolynomialSource,'Auto')
                    flag=true;
                end
            case 'B'
                if strcmp(obj.BSource,'Auto')
                    flag=true;
                end




            end
        end
    end

    methods(Static,Access=protected)
        function isVisible=showSimulateUsingImpl

            isVisible=false;
        end
    end

    methods(Access=protected)
        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end
    end

end

