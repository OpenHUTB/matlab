classdef(StrictDefaults)HDLRSDecoder<matlab.System




























































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




        PrimitivePolynomialSourceSet=comm.CommonSetsHDL.getSet('AutoOrProperty');
        BSourceSet=comm.CommonSetsHDL.getSet('AutoOrProperty');
    end

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...

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

    end

    methods(Static,Access=protected)
        function header=getHeaderImpl


            header=matlab.system.display.Header('comm.HDLRSDecoder',...
            'ShowSourceLink',false,...
            'Title','Integer-Output RS Decoder HDL Optimized');
        end
    end

    methods
        function obj=HDLRSDecoder(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','Communication_Toolbox'))
                    error(message('comm:system:HDLRSDecoder:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','Communication_Toolbox');
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

        end

        function obj=loadObjectImpl(obj,s,~)


            loadObjectImpl@matlab.System(obj,s);
            f=fieldnames(s);
            for ii=1:numel(f)
                obj.(f{ii})=s.(f{ii});
            end
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
        end

        function resetImpl(obj)
            obj.resetStates;
        end

...
...
...
...

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
    end

    methods(Access=protected)
        function[y,startOut,endOut,validOut,errOut,numErrors]=outputImpl(obj,x,startIn,endIn,validIn)


            y=comm.HDLRSDecoder.dtcast(0,x);
            startOut=false;
            endOut=false;
            validOut=false;
            errOut=false;
            numErrors=uint8(0);
...
...
...
...
...

            if any(obj.PacketValid)
                if obj.PacketLatency(obj.PacketReadAddr)-obj.Latency==1
                    startOut=true;
                end
                if obj.PacketLatency(obj.PacketReadAddr)>obj.Latency
                    y=comm.HDLRSDecoder.dtcast(obj.DataRAM(obj.RAMReadAddr,obj.PacketReadAddr),x);
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
        end

        function updateImpl(obj,x,startIn,endIn,validIn)

            if isempty(obj.SyndromeRegister)
                obj.resetStates;
            end

            if startIn&&validIn
                obj.InPacket=true;
            end

            if obj.InPacket&&validIn
                gfx=uint32(x);
                if startIn
                    gtemp=uint32(zeros(128,1));
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


            if obj.InPacket&&~startIn&&endIn&&validIn
                obj.FinalSyndrome=obj.SyndromeRegister;
                obj.InPacket=false;
                obj.PacketValid(obj.PacketWriteAddr)=true;
                obj.PacketLength(obj.PacketWriteAddr)=obj.RAMWriteAddr-1;
                cPoly=obj.massey();
                cPolyOrder=sum(double(cPoly~=0));
                [correctionLocations,corrections,nCorrs]=obj.chien(cPoly);
                obj.nCorrections(obj.PacketWriteAddr)=nCorrs;













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

                obj.PacketWriteAddr=obj.PacketWriteAddr+1;
                if obj.PacketWriteAddr==5
                    obj.PacketWriteAddr=uint32(1);
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
                        if obj.PacketReadAddr==5
                            obj.PacketReadAddr=uint32(1);
                        end
                    else
                        obj.RAMReadAddr=obj.RAMReadAddr+1;
                    end
                end

                obj.PacketLatency(obj.PacketValid)=obj.PacketLatency(obj.PacketValid)+1;
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
            cPoly=zeros(1,128,'uint32');
            cPoly(1)=uint32(1);
            pPoly=zeros(1,128,'uint32');
            pPoly(1)=uint32(1);
            LReg=uint32(0);
            SyndromeShiftRegister=zeros(1,128,'uint32');
            LShift=false(1,128);
            LShift(1)=true;
            currentShift=uint32(1);
            dm=uint32(1);
            zerosConst=zeros(1,128,'uint32');

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
                            LShift(ii)=true;
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



            omegaPoly=zeros(1,128,'uint32');
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
            nPackets=4;

            obj.SyndromeRegister=zeros(128,1,'uint32');
            obj.FinalSyndrome=zeros(128,1,'uint32');
            obj.DataRAM=zeros(65536,nPackets,'uint32');
            obj.RAMWriteAddr=uint32(1);
            obj.RAMReadAddr=uint32(1);
            obj.PacketWriteAddr=uint32(1);
            obj.PacketReadAddr=uint32(1);
            obj.PacketValid=false(nPackets,1);
            obj.PacketLength=zeros(nPackets,1,'uint32');
            obj.nCorrections=zeros(nPackets,1,'uint32');
            obj.PacketError=false(nPackets,1);
            obj.PacketLatency=zeros(nPackets,1,'uint32');
            obj.InPacket=false;
        end

        function validateInputsImpl(obj,x,startIn,endIn,validIn)
            validateattributes(obj.CodewordLength,...
            {'numeric'},{'scalar','integer','>=',1,'<=',65536},'','CodewordLength');
            validateattributes(obj.MessageLength,...
            {'numeric'},{'scalar','integer','>=',1,'<',obj.CodewordLength},'','MessageLength');
            validateattributes(obj.CodewordLength-obj.MessageLength,...
            {'numeric'},{'scalar','even','integer','>=',2},'','CodewordLength - MessageLength');

            if~strcmp(obj.PrimitivePolynomialSource,'Auto')
                validateattributes(obj.PrimitivePolynomial,{'numeric'},{'integer'},'','PrimitivePolynomial');
            end
            if~strcmp(obj.BSource,'Auto')
                validateattributes(obj.B,{'numeric'},{'scalar','integer','nonnegative'},'','B');
            end






            validateattributes(x,{'numeric','embedded.fi'},{'scalar'},'','x');

            if isempty(coder.target)||~coder.internal.isAmbiguousTypes


                validateattributes(startIn,{'logical'},{'scalar'},'','startIn');
                validateattributes(endIn,{'logical'},{'scalar'},'','endIn');
                validateattributes(validIn,{'logical'},{'scalar'},'','validIn');
            end
        end

        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end

        function setupImpl(obj,x,~,~,~,varargin)

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

            coder.internal.errorIf((isempty(tAntiLogTable)||isempty(tLogTable)),...
            'comm:system:HDLRSDecoder:MissingGFTables');

            obj.MultTable=tMultTable;
            obj.PowerTable=tPowerTable;
            obj.Corr=tCorr;
            obj.WordSize=tWordSize;
            obj.LogTable=tLogTable;
            obj.AntiLogTable=tAntiLogTable;

            doubleTCorr=double(tCorr);
            bmLength=2*doubleTCorr+10;
            convLength=(doubleTCorr*2)*(doubleTCorr*2+1)/2;
            chienLength=2.^double(tWordSize);
            delayTotal=bmLength+convLength+chienLength;
            delayWordSize=ceil(log2(delayTotal));
            obj.Latency=uint32(2.^delayWordSize);

            obj.resetStates;


            if isempty(coder.target)||~eml_ambiguous_types
                if~(isa(x,'double')||isa(x,'single'))
                    [inWL,~,~]=dsphdlshared.hdlgetwordsizefromdata(x);
                    coder.internal.errorIf(inWL~=obj.WordSize,...
                    'comm:system:HDLRSDecoder:InputWLMisMatch');

                end
            end

        end

        function num=getNumInputsImpl(obj)%#ok
            num=4;
        end

        function num=getNumOutputsImpl(obj)
            if obj.NumErrorsOutputPort
                num=6;
            else
                num=5;
            end
        end

        function icon=getIconImpl(~)

            icon=sprintf('Integer-Output\nRS Decoder\nHDL Optimized');
        end

        function varargout=getInputNamesImpl(obj)

            varargout=cell(1,getNumInputs(obj));
            varargout{1}='dataIn';
            varargout{2}='startIn';
            varargout{3}='endIn';
            varargout{4}='validIn';
        end

        function varargout=getOutputNamesImpl(obj)

            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='dataOut';
            varargout{2}='startOut';
            varargout{3}='endOut';
            varargout{4}='validOut';
            varargout{5}='errOut';

            if obj.NumErrorsOutputPort
                varargout{6}='numErrors';
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

    methods(Static,Hidden)

        function output=noCastData(data,~,~)
            output=data;
        end

        function output=castDataFixedPoint(data,input,~)


            output=fi(data,input.numerictype,'RoundMode','floor','OverflowMode','wrap');
            output.fimath=[];
        end

        function output=castData(data,input,dType)


            if isfi(input)
                output=fi(data,input.numerictype);
            else
                output=cast(data,dType);
            end
        end


    end

    methods(Static,Access=private)
        function y=dtcast(u,v)
...
...
...
...
...
...
...
            y=cast(u,'like',v);
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

