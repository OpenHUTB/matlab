classdef(StrictDefaults)APPDecoder<matlab.System





%#codegen






    properties(Nontunable)

        CodeGenerator=[171,133];

        TermMode='Truncated';

        Algorithm='Max Log MAP (max)'

        WindowLength=64;


        DisableAprOut(1,1)logical=false;
    end

    properties(Access=private)

        gamma;
        gamma0Prev;
        gamma1Prev;
        beta0Reg;
        beta1Reg;
        beta0Prev;
        beta1Prev;
        alpha0Reg;
        alpha1Reg;
        alpha0Prev;
        alpha1Prev;
        branchMetrics;
        count;
        countReg;
        outCount;
        revCount;
        alphaDone;
        dataOut;
        codedRAM;
        uncodedRAM;
        gamma0RAM;
        gamma1RAM;
        alpha0RAM;
        alpha1RAM;
        outputRAM;
        outputCodedRAM;
        wrAddr;
        rdAddr;
        wrAddrReg;
        rdAddrReg;
        wrAddrReg1;
        rdAddrReg1;
        writeReverse;
        writeReverseReg;

        prevOut;
        prevOutCoded;
        validIn;
        validInReg;
        validInReg1;
        writeOutInRAM;
        wrAddOut;
        wrRevOutRAM;
        rdAddrOut;
        outValid;
        countOut;
        validOutReg;
        validOutReg1;
        uncodedData;
        codedData;
        dataOutCoded;
        lastWindLen;
        lastWindLen1;
        lastWindLenReg;
        lastWind;
        lastWindReg;
        endOut;
        endOutReg;
        endInReg;
        endInReg1;
        startOut;
        startOutReg;
        startOutReg1;
        maxVal;
        nextFrame;
        nextFrameCount;
        nextFrameReg;
        startCounting;
        startInp;
        validInp;
        endInp;
        symbolPulse;
        startReg;
        windDone;
        windComplete;
        FrameGap;
        minMetric;
        startOutBuffer;
        endOutBuffer;
        enbFramEndOp;
        enbReg;
        firstWind;
        firstWindReg;
        firstWindReg1;
        firstWindReg2;
        delayLuOut;
        delayLcOut;
        delayStrtOut;
        delayEndOut;
        delayValidOut;
        endFlag;
        startOutDelBal;
        endOutDelBal;
        validOutDelBal;
        dataOutUncodedDelBal;
        dataOutCodedDelBal;
    end

    properties(Access=private,Nontunable)
        numRows;
        numCols;
        statesBPSK;
        bit0indices;
        bit1indices;
        bitIndicesCoded;
        logMAPLUT;
        bitGrowth;
        winLenMinus1;
        inDisp;
    end

    properties(Constant,Hidden)
        TermModeSet=matlab.system.StringSet({...
        'Truncated','Terminated'});
        AlgorithmSet=matlab.system.StringSet({...
        'Max Log MAP (max)','Log MAP (max*)'});
    end





    methods


        function obj=APPDecoder(varargin)
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

        function set.CodeGenerator(obj,val)
            coder.extrinsic('commprivate');
            coder.extrinsic('boolean');
            CGLength=numel(val);
            validateattributes(val,{'numeric'},{'integer',...
            'row'},'APPDecoder','Code Generator');
            coder.internal.errorIf(~boolean(commprivate('isoctal',val)),...
            'whdl:APPDecoder:InvalidCGType');
            coder.internal.errorIf(~(CGLength>=2&&CGLength<=7),...
            'whdl:APPDecoder:InvalidRate');
            CodeGenMatrixSize=size(dec2bin(oct2dec(val)),2);
            if(CodeGenMatrixSize<3||CodeGenMatrixSize>9)
                coder.internal.error('whdl:APPDecoder:InvalidCodeGenerator');
            end
            obj.CodeGenerator=val;
        end

        function set.WindowLength(obj,val)
            coder.extrinsic('commprivate');
            coder.extrinsic('boolean');
            winLength=val;
            validateattributes(val,{'numeric'},{'integer',...
            'scalar'},'APPDecoder','Window length');
            coder.internal.errorIf(~(winLength>=3&&winLength<=128),...
            'whdl:APPDecoder:InvalidWindowlength');
            obj.WindowLength=val;
        end

    end

    methods(Static,Access=protected)

        function header=getHeaderImpl
            text=['Decode coded LLR input using maximum a-posteriori probability (MAP) algorithm.',newline,newline...
            ,'The block generates the constraint length internally based on the code generator polynomial. '...
            ,'For better performance, the recommended window length is at least five times the constraint length.'];

            header=matlab.system.display.Header(mfilename('class'),...
            'Title','APP Decoder',...
            'Text',text,...
            'ShowSourceLink',false);
        end



        function groups=getPropertyGroupsImpl

            struc=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'CodeGenerator','TermMode','Algorithm','WindowLength','DisableAprOut'});

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
        function latency=getLatency(obj)
            K=size(dec2bin(oct2dec(obj.CodeGenerator)),2);
            latency=2*obj.WindowLength+3+2+(2^(K-1)-1);
        end
    end


    methods(Access=protected)



        function icon=getIconImpl(obj)
            if isempty(obj.inDisp)
                icon=sprintf('APP Decoder\nLatency = --');
            else
                icon=sprintf('APP Decoder\nLatency = %d',getLatency(obj));
            end
        end

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end



        function resetImpl(obj)

            obj.dataOut(:)=0;
            obj.uncodedData(:)=0;
            obj.prevOut(:)=0;
            obj.dataOutCoded(:)=0;
            obj.codedData(:)=0;
            obj.prevOutCoded(:)=0;
            obj.gamma0Prev(:)=0;
            obj.gamma1Prev(:)=0;
            obj.alpha0Reg(:)=-1e30;
            obj.alpha1Reg(:)=-1e30;
            obj.alpha0Prev(:)=-1e30;
            obj.alpha1Prev(:)=-1e30;
            obj.beta0Reg(:)=-1e30;
            obj.beta1Reg(:)=-1e30;
            obj.beta0Prev(:)=-1e30;
            obj.beta1Prev(:)=-1e30;
            obj.branchMetrics(:)=0;
            obj.FrameGap(:)=0;
            obj.count(:)=0;
            obj.countReg(:)=0;
            obj.outCount(:)=0;
            obj.revCount(:)=0;
            obj.wrAddr(:)=0;
            obj.rdAddr(:)=0;
            obj.wrAddrReg(:)=0;
            obj.rdAddrReg(:)=0;
            obj.wrAddrReg1(:)=0;
            obj.rdAddrReg1(:)=0;
            obj.countOut(:)=0;
            obj.rdAddrOut(:)=0;
            obj.wrAddOut(:)=0;

            obj.lastWindLen(:)=0;
            obj.lastWindLen1(:)=0;
            obj.lastWindLenReg(:)=0;



            obj.alpha0Reg(1)=0;
            obj.alpha1Reg(1)=0;
            obj.alpha0Prev(1)=0;
            obj.alpha1Prev(1)=0;

            if strcmpi(obj.TermMode,'Terminated')
                obj.beta0Reg(1:2)=0;
                obj.beta0Prev(1:2)=0;
            else
                obj.beta0Reg(:)=0;
                obj.beta1Reg(:)=0;
                obj.beta0Prev(:)=0;
                obj.beta1Prev(:)=0;
            end


            obj.alphaDone=false;
            obj.writeReverse=false;
            obj.writeReverseReg=false;
            obj.validIn=false;
            obj.validInReg=false;
            obj.validInReg1=false;
            obj.writeOutInRAM=false;
            obj.wrRevOutRAM=false;
            obj.outValid=false;
            obj.validOutReg=false;
            obj.validOutReg1=false;
            obj.lastWind=false;
            obj.lastWindReg=false;
            obj.endOutReg=false;
            obj.endOut=false;
            obj.endInReg=false;
            obj.endInReg1=false;
            obj.startOut=false;
            obj.startOutReg=false;
            obj.startOutReg1=false;
            obj.nextFrame=true;
            obj.nextFrameReg=true;
            obj.symbolPulse=false;
            obj.nextFrameCount(:)=0;
            obj.startCounting=false;
            obj.startInp=false;
            obj.validInp=false;
            obj.endInp=false;
            obj.startReg=false;
            obj.windDone=false;
            obj.windComplete=false;
            bufferDepth=2*obj.WindowLength+2;
            obj.startOutBuffer=false(1,bufferDepth);
            obj.endOutBuffer=false(1,bufferDepth);
            obj.enbFramEndOp=false;
            obj.enbReg=false;
            obj.firstWind=false;
            obj.firstWindReg=false;
            obj.firstWindReg1=false;
            obj.firstWindReg2=false;
            obj.endFlag=false;
            obj.startOutDelBal(:)=false;
            obj.endOutDelBal(:)=false;
            obj.validOutDelBal(:)=false;
            obj.dataOutUncodedDelBal(:)=0;
            obj.dataOutCodedDelBal(:)=0;

            reset(obj.delayLuOut);
            reset(obj.delayLcOut);
            reset(obj.delayStrtOut);
            reset(obj.delayEndOut);
            reset(obj.delayValidOut);
        end



        function setupImpl(obj,varargin)

            dIn=varargin{1};
            K=size(dec2bin(oct2dec(obj.CodeGenerator)),2);
            trellis=poly2trellis(K,obj.CodeGenerator);
            obj.bit0indices=oct2dec(trellis.outputs(:,1))+1;
            obj.bit1indices=oct2dec(trellis.outputs(:,2))+1;
            n=size(dec2bin(oct2dec(trellis.outputs)),2);
            obj.bitIndicesCoded=coder.const(logical(reshape(feval('int2bit',oct2dec(trellis.outputs),(n)),n,[])'));

            obj.numRows=2^(K-1);
            obj.numCols=obj.WindowLength;
            obj.bitGrowth=floor(log2(length(dIn)))+floor(log2(K-1))+2;
            outBitGrowth=obj.bitGrowth;
            if~isfloat(dIn)
                if isa(dIn,'int8')
                    inpData=fi(0,1,8,0);
                elseif(isa(dIn,'int16'))
                    inpData=fi(0,1,16,0);
                else
                    inpData=dIn;
                end
                obj.dataOutUncodedDelBal=fi(0,1,inpData.WordLength+outBitGrowth,inpData.FractionLength,hdlfimath);
                obj.dataOutCodedDelBal=fi(zeros(length(obj.CodeGenerator),1),1,inpData.WordLength+outBitGrowth,inpData.FractionLength,hdlfimath);
                obj.dataOut=fi(0,1,inpData.WordLength+outBitGrowth,inpData.FractionLength,hdlfimath);
                obj.uncodedData=fi(0,1,inpData.WordLength+outBitGrowth,inpData.FractionLength,hdlfimath);
                obj.prevOut=fi(0,1,inpData.WordLength+outBitGrowth,inpData.FractionLength,hdlfimath);
                obj.dataOutCoded=fi(zeros(length(obj.CodeGenerator),1),1,inpData.WordLength+outBitGrowth,inpData.FractionLength,hdlfimath);
                obj.codedData=fi(zeros(length(obj.CodeGenerator),1),1,inpData.WordLength+outBitGrowth,inpData.FractionLength,hdlfimath);
                obj.prevOutCoded=fi(zeros(length(obj.CodeGenerator),1),1,inpData.WordLength+outBitGrowth,inpData.FractionLength,hdlfimath);
                obj.gamma0Prev=fi(zeros(2^length(dIn),1),1,inpData.WordLength+obj.bitGrowth,inpData.FractionLength,hdlfimath);
                obj.gamma1Prev=fi(zeros(2^length(dIn),1),1,inpData.WordLength+obj.bitGrowth,inpData.FractionLength,hdlfimath);
                obj.alpha0Reg=fi(-2^(inpData.WordLength-inpData.FractionLength-2+obj.bitGrowth-floor(log2(length(dIn))))*ones(obj.numRows,1),1,inpData.WordLength+obj.bitGrowth,inpData.FractionLength,hdlfimath);
                obj.alpha1Reg=fi(-2^(inpData.WordLength-inpData.FractionLength-2+obj.bitGrowth-floor(log2(length(dIn))))*ones(obj.numRows,1),1,inpData.WordLength+obj.bitGrowth,inpData.FractionLength,hdlfimath);
                obj.alpha0Prev=fi(-2^(inpData.WordLength-inpData.FractionLength-2+obj.bitGrowth-floor(log2(length(dIn))))*ones(obj.numRows,1),1,inpData.WordLength+obj.bitGrowth,inpData.FractionLength,hdlfimath);
                obj.alpha1Prev=fi(-2^(inpData.WordLength-inpData.FractionLength-2+obj.bitGrowth-floor(log2(length(dIn))))*ones(obj.numRows,1),1,inpData.WordLength+obj.bitGrowth,inpData.FractionLength,hdlfimath);
                obj.beta0Reg=fi(-2^(inpData.WordLength-inpData.FractionLength-2+obj.bitGrowth)*ones(obj.numRows,1),1,inpData.WordLength+obj.bitGrowth,inpData.FractionLength,hdlfimath);
                obj.beta1Reg=fi(-2^(inpData.WordLength-inpData.FractionLength-2+obj.bitGrowth)*ones(obj.numRows,1),1,inpData.WordLength+obj.bitGrowth,inpData.FractionLength,hdlfimath);
                obj.beta0Prev=fi(-2^(inpData.WordLength-inpData.FractionLength-2+obj.bitGrowth)*ones(obj.numRows,1),1,inpData.WordLength+obj.bitGrowth,inpData.FractionLength,hdlfimath);
                obj.beta1Prev=fi(-2^(inpData.WordLength-inpData.FractionLength-2+obj.bitGrowth)*ones(obj.numRows,1),1,inpData.WordLength+obj.bitGrowth,inpData.FractionLength,hdlfimath);
                obj.branchMetrics=fi(zeros(2^length(dIn),1),1,inpData.WordLength+obj.bitGrowth,inpData.FractionLength,hdlfimath);
                obj.maxVal=fi(-2^(inpData.WordLength-inpData.FractionLength-2+obj.bitGrowth),1,inpData.WordLength+obj.bitGrowth,inpData.FractionLength,hdlfimath);
                obj.FrameGap=fi(0,0,8,0,hdlfimath);
                obj.count=fi(0,0,8,0,hdlfimath);
                obj.nextFrameCount=fi(0,0,8,0,hdlfimath);
                obj.countReg=fi(0,0,8,0,hdlfimath);
                obj.outCount=fi(0,0,8,0,hdlfimath);
                obj.revCount=fi(0,0,8,0,hdlfimath);
                obj.wrAddr=fi(0,0,8,0,hdlfimath);
                obj.rdAddr=fi(0,0,8,0,hdlfimath);
                obj.wrAddrReg=fi(0,0,8,0,hdlfimath);
                obj.rdAddrReg=fi(0,0,8,0,hdlfimath);
                obj.wrAddrReg1=fi(0,0,8,0,hdlfimath);
                obj.rdAddrReg1=fi(0,0,8,0,hdlfimath);
                obj.countOut=fi(0,0,8,0,hdlfimath);
                obj.rdAddrOut=fi(0,0,8,0,hdlfimath);
                obj.wrAddOut=fi(0,0,8,0,hdlfimath);
                obj.winLenMinus1=fi((obj.WindowLength-1),0,8,0,hdlfimath);
                obj.lastWindLen=fi(0,0,8,0,hdlfimath);
                obj.lastWindLen1=fi(0,0,8,0,hdlfimath);
                obj.lastWindLenReg=fi(0,0,8,0,hdlfimath);
                obj.minMetric=fi(-2^(inpData.WordLength-inpData.FractionLength-2+obj.bitGrowth),1,inpData.WordLength+obj.bitGrowth,inpData.FractionLength,hdlfimath);
            else
                obj.dataOutUncodedDelBal=cast(0,'like',dIn);
                obj.dataOutCodedDelBal=cast(zeros(length(obj.CodeGenerator),1),'like',dIn);
                obj.dataOut=cast(0,'like',dIn);
                obj.uncodedData=cast(0,'like',dIn);
                obj.prevOut=cast(0,'like',dIn);
                obj.dataOutCoded=cast(zeros(length(obj.CodeGenerator),1),'like',dIn);
                obj.codedData=cast(zeros(length(obj.CodeGenerator),1),'like',dIn);
                obj.prevOutCoded=cast(zeros(length(obj.CodeGenerator),1),'like',dIn);
                obj.gamma0Prev=cast(zeros(2^length(dIn),1),'like',dIn);
                obj.gamma1Prev=cast(zeros(2^length(dIn),1),'like',dIn);
                obj.alpha0Reg=cast(-1e30*ones(obj.numRows,1),'like',dIn);
                obj.alpha1Reg=cast(-1e30*ones(obj.numRows,1),'like',dIn);
                obj.alpha0Prev=cast(-1e30*ones(obj.numRows,1),'like',dIn);
                obj.alpha1Prev=cast(-1e30*ones(obj.numRows,1),'like',dIn);
                obj.beta0Reg=cast(-1e30*ones(obj.numRows,1),'like',dIn);
                obj.beta1Reg=cast(-1e30*ones(obj.numRows,1),'like',dIn);
                obj.beta0Prev=cast(-1e30*ones(obj.numRows,1),'like',dIn);
                obj.beta1Prev=cast(-1e30*ones(obj.numRows,1),'like',dIn);
                obj.branchMetrics=cast(zeros(2^length(dIn),1),'like',dIn);
                obj.FrameGap=cast(0,'like',dIn);
                obj.count=cast(0,'like',dIn);
                obj.countReg=cast(0,'like',dIn);
                obj.outCount=cast(0,'like',dIn);
                obj.revCount=cast(0,'like',dIn);
                obj.wrAddr=cast(0,'like',dIn);
                obj.rdAddr=cast(0,'like',dIn);
                obj.wrAddrReg=cast(0,'like',dIn);
                obj.rdAddrReg=cast(0,'like',dIn);
                obj.wrAddrReg1=cast(0,'like',dIn);
                obj.rdAddrReg1=cast(0,'like',dIn);
                obj.countOut=cast(0,'like',dIn);
                obj.rdAddrOut=cast(0,'like',dIn);
                obj.nextFrameCount=cast(0,'like',dIn);
                obj.wrAddOut=cast(0,'like',dIn);
                obj.winLenMinus1=cast(obj.WindowLength-1,'like',dIn);
                obj.lastWindLen=cast(0,'like',dIn);
                obj.lastWindLen1=cast(0,'like',dIn);
                obj.lastWindLenReg=cast(0,'like',dIn);
                obj.maxVal=cast(-1e30,'like',dIn);
                obj.minMetric=cast(-1e30,'like',dIn);
            end

            obj.alpha0Reg(1)=0;
            obj.alpha1Reg(1)=0;
            obj.alpha0Prev(1)=0;
            obj.alpha1Prev(1)=0;

            if strcmpi(obj.TermMode,'Terminated')
                obj.beta0Reg(1:2)=0;
                obj.beta0Prev(1:2)=0;
            else
                obj.beta0Reg(:)=0;
                obj.beta1Reg(:)=0;
                obj.beta0Prev(:)=0;
                obj.beta1Prev(:)=0;
            end

            obj.codedRAM=hdl.RAM('Simple Dual port');
            obj.uncodedRAM=hdl.RAM('Simple Dual port');
            obj.gamma0RAM=hdl.RAM('Simple Dual port');
            obj.gamma1RAM=hdl.RAM('Simple Dual port');
            obj.alpha0RAM=hdl.RAM('Simple Dual port');
            obj.alpha1RAM=hdl.RAM('Simple Dual port');
            obj.outputRAM=hdl.RAM('Simple Dual port');
            obj.outputCodedRAM=hdl.RAM('Simple Dual port');

            statesDecimal=0:(2^length(dIn)-1);
            n=size(dec2bin(statesDecimal),2);
            statesBinary=coder.const(logical(reshape(feval('int2bit',statesDecimal,(n)),n,[])'));

            obj.statesBPSK=2.*statesBinary-1;

            LUT=fi((log(1+exp(-[0:(1/16):8]))),0,16,16,hdlfimath);
            obj.logMAPLUT=LUT(1:end-1);




            obj.alphaDone=false;
            obj.writeReverse=false;
            obj.writeReverseReg=false;
            obj.validIn=false;
            obj.validInReg=false;
            obj.validInReg1=false;
            obj.writeOutInRAM=false;
            obj.wrRevOutRAM=false;
            obj.outValid=false;
            obj.validOutReg=false;
            obj.validOutReg1=false;
            obj.lastWind=false;
            obj.lastWindReg=false;
            obj.endOutReg=false;
            obj.endOut=false;
            obj.endInReg=false;
            obj.endInReg1=false;
            obj.startOut=false;
            obj.startOutReg=false;
            obj.startOutReg1=false;
            obj.nextFrame=true;
            obj.nextFrameReg=true;
            obj.symbolPulse=false;
            obj.startCounting=false;
            obj.startInp=false;
            obj.validInp=false;
            obj.endInp=false;
            obj.startReg=false;
            obj.windDone=false;
            obj.windComplete=false;
            bufferDepth=2*obj.WindowLength+2;
            obj.startOutBuffer=false(1,bufferDepth);
            obj.endOutBuffer=false(1,bufferDepth);
            obj.enbFramEndOp=false;
            obj.enbReg=false;
            obj.firstWind=false;
            obj.firstWindReg=false;
            obj.firstWindReg1=false;
            obj.firstWindReg2=false;
            obj.endFlag=false;
            obj.startOutDelBal=false;
            obj.endOutDelBal=false;
            obj.validOutDelBal=false;

            pipelines=obj.numRows+1;
            obj.delayLuOut=dsp.Delay(pipelines);
            obj.delayLcOut=dsp.Delay(pipelines);
            obj.delayStrtOut=dsp.Delay(pipelines);
            obj.delayEndOut=dsp.Delay(pipelines);
            obj.delayValidOut=dsp.Delay(pipelines);
        end



        function flag=getExecutionSemanticsImpl(~)

            flag={'Classic','Synchronous'};
        end



        function varargout=outputImpl(obj,varargin)
            ctrlOut.start=obj.startOutDelBal;
            ctrlOut.end=obj.endOutDelBal;
            ctrlOut.valid=obj.validOutDelBal;
            dOutDel=obj.dataOutUncodedDelBal;
            dOutCodedDel=obj.dataOutCodedDelBal;
            if ctrlOut.valid
                dOut=dOutDel;
                dOutCoded=dOutCodedDel;
            else
                dOut=cast(0,'like',obj.dataOut);
                dOutCoded=cast(zeros(length(obj.dataOutCoded),1),'like',obj.dataOut);
            end

            if obj.DisableAprOut
                varargout{1}=dOut;
                varargout{2}=ctrlOut;
                varargout{3}=obj.nextFrame;
            else
                varargout{1}=dOut;
                varargout{2}=dOutCoded;
                varargout{3}=ctrlOut;
                varargout{4}=obj.nextFrame;
            end
        end



        function updateImpl(obj,varargin)


            dataIn=varargin{1};
            dataUncoded=varargin{2};

            obj.sampleBusController(varargin{3});

            startIn=obj.startInp;
            endIn=obj.endInp;
            obj.validIn=obj.validInp;

            if~isfloat(dataIn)
                if isfi(dataIn)||isnumerictype(dataIn)
                    dIn=dataIn;
                elseif isa(dataIn,'int8')
                    dIn=fi(dataIn,1,8,0,hdlfimath);
                else
                    dIn=fi(dataIn,1,16,0,hdlfimath);
                end
            else
                dIn=dataIn;
            end

            if startIn&&obj.validIn
                obj.count(:)=0;
                if~isfloat(dataIn)
                    if isfi(dataIn)||isnumerictype(dataIn)
                        obj.alpha0Reg(:)=-2^(dataIn.WordLength-dataIn.FractionLength-2+obj.bitGrowth)*ones(obj.numRows,1);
                        obj.alpha1Reg(:)=-2^(dataIn.WordLength-dataIn.FractionLength-2+obj.bitGrowth)*ones(obj.numRows,1);
                        obj.alpha0Prev(:)=fi(-2^(dataIn.WordLength-dataIn.FractionLength-2+obj.bitGrowth)*ones(obj.numRows,1));
                        obj.alpha1Prev(:)=fi(-2^(dataIn.WordLength-dataIn.FractionLength-2+obj.bitGrowth)*ones(obj.numRows,1));
                    elseif isa(dataIn,'int8')
                        obj.alpha0Reg(:)=-2^(6+obj.bitGrowth)*ones(obj.numRows,1);
                        obj.alpha1Reg(:)=-2^(6+obj.bitGrowth)*ones(obj.numRows,1);
                        obj.alpha0Prev(:)=-2^(6+obj.bitGrowth)*ones(obj.numRows,1);
                        obj.alpha1Prev(:)=-2^(6+obj.bitGrowth)*ones(obj.numRows,1);
                    else
                        obj.alpha0Reg(:)=-2^(14+obj.bitGrowth)*ones(obj.numRows,1);
                        obj.alpha1Reg(:)=-2^(14+obj.bitGrowth)*ones(obj.numRows,1);
                        obj.alpha0Prev(:)=-2^(14+obj.bitGrowth)*ones(obj.numRows,1);
                        obj.alpha1Prev(:)=-2^(14+obj.bitGrowth)*ones(obj.numRows,1);
                    end
                else
                    obj.alpha0Reg(:)=-1e30*ones(obj.numRows,1);
                    obj.alpha1Reg(:)=-1e30*ones(obj.numRows,1);
                    obj.alpha0Prev(:)=-1e30*ones(obj.numRows,1);
                    obj.alpha1Prev(:)=-1e30*ones(obj.numRows,1);
                end
                obj.alpha0Reg(1)=0;
                obj.alpha1Reg(1)=0;
                obj.alpha0Prev(1)=0;
                obj.alpha1Prev(1)=0;

                if~obj.nextFrame
                    obj.endFlag=false;
                end

                obj.firstWind=true;
            end


            obj.wrAddrReg1(:)=obj.wrAddrReg;
            obj.wrAddrReg(:)=obj.wrAddr;
            obj.rdAddrReg1(:)=obj.rdAddrReg;
            obj.rdAddrReg(:)=obj.rdAddr;




            obj.revCount(:)=obj.winLenMinus1-obj.count;
            if~obj.writeReverse
                obj.wrAddr(:)=obj.count;
            else
                obj.wrAddr(:)=obj.revCount;
            end


            if~obj.wrRevOutRAM
                obj.wrAddOut(:)=obj.outCount;
            else
                obj.wrAddOut(:)=obj.winLenMinus1-obj.outCount;
            end




            obj.uncodedData(:)=obj.uncodedRAM(dataUncoded,obj.wrAddr,obj.validIn,obj.rdAddr);

            obj.codedData(:)=obj.codedRAM(dataIn,obj.wrAddr,obj.validIn,obj.rdAddr);





            obj.branchMetrics(:)=obj.statesBPSK*dIn;




            if~isfloat(dataIn)
                gamma0=bitshift(obj.branchMetrics-dataUncoded,-1);
                gamma1=bitshift(obj.branchMetrics+dataUncoded,-1);
            else
                gamma0=(obj.branchMetrics-dataUncoded)/2;
                gamma1=(obj.branchMetrics+dataUncoded)/2;
            end



            obj.gamma0Prev(:)=obj.gamma0RAM(gamma0,obj.wrAddr,obj.validIn,obj.rdAddr);
            obj.gamma1Prev(:)=obj.gamma1RAM(gamma1,obj.wrAddr,obj.validIn,obj.rdAddr);


            alpha0=obj.alpha0Reg+gamma0(obj.bit0indices);
            alpha1=obj.alpha1Reg+gamma1(obj.bit1indices);



            obj.alpha0Prev(:)=obj.alpha0RAM(alpha0,obj.wrAddr,obj.validIn,obj.rdAddr);
            obj.alpha1Prev(:)=obj.alpha1RAM(alpha1,obj.wrAddr,obj.validIn,obj.rdAddr);


            if obj.validIn
                totalAlpha=[alpha0;alpha1];
                totAlphShifted=totalAlpha;
                alphTemp=alpha0;
                for ind=uint16(1:2:2*obj.numRows)
                    if strcmpi(obj.Algorithm,'Max Log MAP (max)')
                        alphTemp(bitshift(ind,-1)+1)=max(totalAlpha(ind:ind+1));
                    else



                        alphTemp(bitshift(ind,-1)+1)=(max(totAlphShifted(ind:ind+1)))+cast(obj.quantizeIndex(abs((totAlphShifted(ind))-(totAlphShifted(ind+1)))),'like',totalAlpha);

                    end
                end


                if obj.count<=(log2(obj.numRows)-1)
                    obj.alpha0Reg(:)=alphTemp;
                    obj.alpha1Reg(:)=alphTemp;
                else


                    obj.alpha0Reg(:)=alphTemp-alphTemp(1);
                    obj.alpha1Reg(:)=alphTemp-alphTemp(1);
                end

            end



            metric0=obj.alpha0Prev+obj.beta0Prev;
            metric1=obj.alpha1Prev+obj.beta1Prev;
            if strcmpi(obj.Algorithm,'Max Log MAP (max)')
                LLRrev=max(metric1-obj.uncodedData)-max(metric0);
            else


                in1=metric1(1);
                in2=metric0(1);
                for ii=1:obj.numRows-1



                    shiftIn1=in1;
                    shiftMetric1=metric1(ii+1);
                    in1(:)=max(shiftIn1,shiftMetric1)+cast(obj.quantizeIndex(abs(shiftIn1-shiftMetric1)),'like',metric1);




                    shiftIn2=in2;
                    shiftMetric0=metric0(ii+1);
                    in2(:)=max(shiftMetric0,shiftIn2)+cast(obj.quantizeIndex(abs((shiftMetric0-shiftIn2))),'like',metric0);

                end
                LLRrev=in1-in2-obj.uncodedData;
            end




            LLRrevCoded=cast(zeros(length(dataIn),1),'like',LLRrev);

            totalmetrics=[metric0;metric1];
            t1=cast(zeros(obj.numRows,1),'like',totalmetrics);
            t2=cast(zeros(obj.numRows,1),'like',totalmetrics);

            for ind=1:length(dataIn)
                ind1=uint16(0);
                ind2=uint16(0);
                for ii=1:2*obj.numRows
                    if obj.bitIndicesCoded(ii,ind)
                        if ind1<obj.numRows
                            t1(ind1+1)=totalmetrics(ii);
                            ind1(:)=ind1+1;
                        end
                    else
                        if ind2<obj.numRows
                            t2(ind2+1)=totalmetrics(ii);
                            ind2(:)=ind2+1;
                        end
                    end
                end
                if strcmpi(obj.Algorithm,'Max Log MAP (max)')
                    LLRrevCoded(ind)=max(t1)-max(t2)-obj.codedData(ind);
                else
                    in1=t1(1);
                    in2=t2(1);
                    for ii=1:obj.numRows-1



                        in1(:)=max(t1(ii+1),in1)+cast(obj.quantizeIndex(abs((t1(ii+1))-(in1))),'like',metric1);




                        in2(:)=max(t2(ii+1),in2)+cast(obj.quantizeIndex(abs((t2(ii+1))-(in2))),'like',metric0);

                    end
                    LLRrevCoded(ind)=in1-in2-obj.codedData(ind);
                end
            end





            obj.prevOut(:)=obj.outputRAM(LLRrev,obj.wrAddOut,obj.writeOutInRAM,obj.rdAddrOut);
            obj.prevOutCoded(:)=obj.outputCodedRAM(LLRrevCoded,obj.wrAddOut,obj.writeOutInRAM,obj.rdAddrOut);


            obj.dataOut(:)=obj.prevOut;
            obj.dataOutUncodedDelBal(:)=obj.delayLuOut(obj.dataOut);

            obj.dataOutCoded(:)=obj.prevOutCoded;
            obj.dataOutCodedDelBal(:)=obj.delayLcOut(obj.dataOutCoded.').';


            if~obj.wrRevOutRAM
                if obj.rdAddrOut==obj.winLenMinus1
                    obj.rdAddrOut(:)=0;
                else
                    obj.rdAddrOut(:)=obj.rdAddrOut+1;
                end
            else
                if obj.rdAddrOut==0
                    obj.rdAddrOut(:)=obj.winLenMinus1;
                else
                    obj.rdAddrOut(:)=obj.rdAddrOut-1;
                end
            end


            obj.validOutReg1=obj.validOutReg;
            obj.validOutReg=obj.outValid;
            obj.validOutDelBal(:)=obj.delayValidOut(obj.validOutReg1);

            obj.endOut=obj.endOutReg;
            obj.endOutDelBal(:)=obj.delayEndOut(obj.endOut);

            obj.startOut=obj.startOutReg1;
            obj.startOutDelBal(:)=obj.delayStrtOut(obj.startOut);

            obj.startOutReg1(:)=((obj.countOut==0)&&obj.outValid)&&obj.firstWindReg2;

            if obj.outValid
                if obj.lastWindReg&&obj.windComplete
                    if obj.countOut==obj.lastWindLenReg
                        obj.countOut(:)=0;
                        obj.outValid=false;
                        obj.lastWindReg=false;
                        obj.endOutReg=true;

                        obj.windComplete=false;
                        if obj.firstWindReg2
                            obj.firstWindReg2=false;
                        end
                    else
                        obj.countOut(:)=obj.countOut+1;
                        obj.endOutReg=false;

                    end
                else
                    if obj.countOut==obj.winLenMinus1
                        obj.countOut(:)=0;
                        obj.outValid=false;
                        obj.windComplete=true;
                        if obj.lastWindReg
                            obj.outValid=true;
                        end
                        if obj.firstWindReg2
                            obj.firstWindReg2=false;
                        end
                    else
                        obj.countOut(:)=obj.countOut+1;
                        obj.windComplete=false;
                    end
                    obj.endOutReg=false;

                end
            else
                obj.endOutReg=false;
            end


            if obj.writeOutInRAM
                if obj.lastWind&&obj.windDone
                    if obj.outCount==obj.winLenMinus1
                        obj.outCount(:)=0;
                        obj.writeOutInRAM=false;
                        if obj.wrRevOutRAM
                            obj.rdAddrOut(:)=obj.winLenMinus1-obj.lastWindLen1;
                        else
                            obj.rdAddrOut(:)=obj.lastWindLen1;
                        end

                        obj.wrRevOutRAM=~obj.wrRevOutRAM;

                        obj.outValid=true;
                        obj.lastWindLenReg(:)=obj.lastWindLen1;
                        if obj.firstWindReg1
                            obj.windComplete=true;
                        end
                        obj.lastWind=false;
                        obj.lastWindReg=true;
                        obj.windDone=false;
                        if obj.firstWindReg1
                            obj.firstWindReg2=true;
                        end
                        obj.firstWindReg1=false;
                    else
                        obj.outCount(:)=obj.outCount+1;
                    end
                else
                    if obj.outCount==obj.winLenMinus1
                        obj.outCount(:)=0;
                        if obj.lastWind
                            obj.writeOutInRAM=true;
                        else
                            obj.writeOutInRAM=false;
                        end
                        if obj.wrRevOutRAM
                            obj.rdAddrOut(:)=0;
                        else
                            obj.rdAddrOut(:)=obj.winLenMinus1;
                        end
                        obj.wrRevOutRAM=~obj.wrRevOutRAM;
                        obj.outValid=true;
                        obj.windDone=true;
                        if obj.firstWindReg1
                            obj.firstWindReg2=true;
                        end
                        obj.firstWindReg1=false;
                    else
                        obj.outCount(:)=obj.outCount+1;
                        obj.windDone=false;
                    end
                end
            end


            beta0=obj.beta0Prev+obj.gamma0Prev(obj.bit0indices);
            beta1=obj.beta1Prev+obj.gamma1Prev(obj.bit1indices);

            totalBeta=[beta0,beta1].';
            totalBeta=totalBeta(:);
            shiftTotalBeta=totalBeta;
            betaTemp=cast(zeros(obj.numRows,1),'like',totalBeta);
            for ind=uint16(1:2:2*obj.numRows)
                if strcmpi(obj.Algorithm,'Max Log MAP (max)')
                    betaTemp(bitshift(ind,-1)+1)=max(totalBeta(ind:ind+1));
                else





                    betaTemp(bitshift(ind,-1)+1)=max(shiftTotalBeta(ind:ind+1))+cast(obj.quantizeIndex(abs((shiftTotalBeta(ind))-shiftTotalBeta(ind+1))),'like',totalBeta);

                end
            end

            betaTempBuff=repmat(betaTemp,1,2).';
            betaTempBuff=betaTempBuff(:);


            if min(betaTempBuff)==obj.minMetric
                obj.beta0Prev(:)=betaTempBuff(1:obj.numRows);
                obj.beta1Prev(:)=betaTempBuff(obj.numRows+(1:obj.numRows));
            else


                obj.beta0Prev(:)=betaTempBuff(1:obj.numRows)-betaTempBuff(1);
                obj.beta1Prev(:)=betaTempBuff(obj.numRows+(1:obj.numRows))-betaTempBuff(1);
            end


            if~obj.writeReverse
                if obj.rdAddr==obj.winLenMinus1
                    obj.rdAddr(:)=0;
                else
                    obj.rdAddr(:)=obj.rdAddr+1;
                end
            else
                if obj.rdAddr==0
                    obj.rdAddr(:)=obj.winLenMinus1;
                else
                    obj.rdAddr(:)=obj.rdAddr-1;
                end
            end

            if obj.endInReg
                obj.lastWindLen(:)=obj.countReg;
            end



            if xor(obj.writeReverseReg,obj.writeReverse)
                if obj.endFlag
                    if~isfloat(dataIn)
                        if isfi(dataIn)||isnumerictype(dataIn)
                            obj.beta0Reg(:)=-2^(dataIn.WordLength-dataIn.FractionLength-2+obj.bitGrowth);
                            obj.beta1Reg(:)=-2^(dataIn.WordLength-dataIn.FractionLength-2+obj.bitGrowth);
                        elseif isa(dataIn,'int8')
                            obj.beta0Reg(:)=-2^(6+obj.bitGrowth);
                            obj.beta1Reg(:)=-2^(6+obj.bitGrowth);
                        else
                            obj.beta0Reg(:)=-2^(14+obj.bitGrowth);
                            obj.beta1Reg(:)=-2^(14+obj.bitGrowth);
                        end
                    else
                        obj.beta0Reg(:)=-1e30*ones(obj.numRows,1);
                        obj.beta1Reg(:)=-1e30*ones(obj.numRows,1);
                    end

                    if strcmpi(obj.TermMode,'Terminated')
                        obj.beta0Reg(1:2)=0;
                    else
                        obj.beta0Reg(:)=0;
                        obj.beta1Reg(:)=0;
                    end
                else
                    obj.beta0Reg(:)=0;
                    obj.beta1Reg(:)=0;
                end

                obj.beta0Prev(:)=obj.beta0Reg;
                obj.beta1Prev(:)=obj.beta1Reg;
                obj.outCount(:)=0;

                obj.writeOutInRAM=true;
                obj.lastWindLen1(:)=obj.lastWindLen;
                obj.firstWindReg1=obj.firstWindReg;
                if obj.endFlag
                    obj.windDone=true;
                    obj.lastWind(:)=true;
                end
            end

            obj.endInReg=endIn&&obj.validIn;

            if endIn&&obj.validIn
                obj.endFlag=true;
                obj.FrameGap(:)=(obj.winLenMinus1-obj.count);
            end



            if obj.nextFrame
                obj.endFlag=false;
            end


            obj.firstWindReg=obj.firstWind;
            obj.writeReverseReg(:)=obj.writeReverse;
            obj.countReg(:)=obj.count;
            if obj.validIn||obj.endFlag
                if obj.count==obj.winLenMinus1
                    obj.count(:)=0;
                    if obj.validIn
                        if obj.writeReverse
                            obj.rdAddr(:)=0;
                        else
                            obj.rdAddr(:)=obj.winLenMinus1;
                        end
                        obj.writeReverse=~obj.writeReverse;
                        obj.firstWind=false;
                    else
                        if obj.writeReverse
                            obj.rdAddr(:)=obj.winLenMinus1-obj.lastWindLen;
                        else
                            obj.rdAddr(:)=obj.lastWindLen;
                        end
                        obj.writeReverse=~obj.writeReverse;
                    end
                else
                    obj.count(:)=obj.count+1;
                end
            end

            obj.nextFrameGenerator(obj.startInp,obj.endInp,obj.FrameGap);

        end

        function LUTval=quantizeIndex(obj,val)

            val1=val;
            idx=(floor(bitsll(double(val1),4)));

            if idx<0
                idx(:)=length(obj.logMAPLUT);
            end
            if idx<length(obj.logMAPLUT)
                LUTval=obj.logMAPLUT(idx+1);
            else
                LUTval=cast(0,'like',obj.logMAPLUT);
            end
        end

        function sampleBusController(obj,ctrlBus)
            startIn=ctrlBus.start;
            endIn=ctrlBus.end;
            validIn1=ctrlBus.valid;

            if startIn&&validIn1
                obj.startReg=true;
                obj.startInp=true;
            else
                obj.startInp=false;
            end

            if validIn1&&obj.startReg
                obj.validInp=true;
            else
                obj.validInp=false;
            end

            if(endIn&&validIn1)&&(obj.startReg&&~startIn)
                obj.endInp=true;
                obj.startReg=false;
            else
                obj.endInp=false;
            end

        end


        function nextFrameGenerator(obj,startIn,endIn,gap)

            if endIn
                obj.startCounting=true;
            end

            if obj.startCounting
                if(obj.nextFrameCount==(gap))
                    obj.nextFrameCount(:)=0;
                    obj.startCounting=false;
                else
                    obj.nextFrameCount(:)=obj.nextFrameCount+1;
                end
            end

            if startIn&&~endIn
                obj.symbolPulse=true;
            end

            if endIn&&~startIn
                obj.symbolPulse=false;
            end

            if obj.startCounting||obj.symbolPulse
                obj.nextFrameReg=false;
            else
                obj.nextFrameReg=true;
            end

            if startIn
                obj.nextFrame=false;
            else
                obj.nextFrame=obj.nextFrameReg;
            end
        end




        function num=getNumInputsImpl(~)
            num=3;
        end



        function num=getNumOutputsImpl(obj)
            if obj.DisableAprOut
                num=3;
            else
                num=4;
            end
        end



        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            inputPortInd=1;
            varargout{inputPortInd}='LLRc';
            inputPortInd=inputPortInd+1;
            varargout{inputPortInd}='LLRu';
            inputPortInd=inputPortInd+1;
            varargout{inputPortInd}='ctrl';
        end



        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            outputPortInd=1;
            varargout{outputPortInd}='LLRu';
            if~obj.DisableAprOut
                outputPortInd=outputPortInd+1;
                varargout{outputPortInd}='LLRc';
            end
            outputPortInd=outputPortInd+1;
            varargout{outputPortInd}='ctrl';
            outputPortInd=outputPortInd+1;
            varargout{outputPortInd}='nextFrame';
        end



        function validateInputsImpl(obj,varargin)
            coder.extrinsic('tostringInternalSlName');

            if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                validateattributes(varargin{1},...
                {'single','double','embedded.fi',...
                'int8','int16'},{'real','size',[length(obj.CodeGenerator),1]},...
                'APPDecoder','LLRc');

                if isa(varargin{1},'embedded.fi')
                    maxWordLength=16;
                    minWordLength=4;
                    coder.internal.errorIf(...
                    (varargin{1}.WordLength>maxWordLength),...
                    'whdl:APPDecoder:MaxInputWordLengthC',...
                    tostringInternalSlName(varargin{1}.numerictype));
                    coder.internal.errorIf(...
                    (varargin{1}.WordLength<minWordLength),...
                    'whdl:APPDecoder:MaxInputWordLengthC',...
                    tostringInternalSlName(varargin{1}.numerictype));
                    if(~issigned(varargin{1}))
                        coder.internal.error('whdl:APPDecoder:InvalidSignedTypeC',...
                        tostringInternalSlName(varargin{1}.numerictype));
                    end
                end

                validateattributes(varargin{2},...
                {'single','double','embedded.fi',...
                'int8','int16'},{'scalar','real'},...
                'APPDecoder','LLRu');

                if isa(varargin{2},'embedded.fi')
                    maxWordLength=16;
                    minWordLength=4;
                    coder.internal.errorIf(...
                    (varargin{2}.WordLength>maxWordLength),...
                    'whdl:APPDecoder:MaxInputWordLengthU',...
                    tostringInternalSlName(varargin{2}.numerictype));
                    coder.internal.errorIf(...
                    (varargin{2}.WordLength<minWordLength),...
                    'whdl:APPDecoder:MaxInputWordLengthU',...
                    tostringInternalSlName(varargin{2}.numerictype));
                    if(~issigned(varargin{2}))
                        coder.internal.error('whdl:APPDecoder:InvalidSignedTypeU',...
                        tostringInternalSlName(varargin{1}.numerictype));
                    end
                end

                if xor((isa(varargin{1},'embedded.fi')),(isa(varargin{2},'embedded.fi')))
                    coder.internal.error('whdl:APPDecoder:dataTypeMismatch');
                else
                    if(isa(varargin{1},'embedded.fi'))
                        if(varargin{1}.WordLength~=varargin{2}.WordLength)||(varargin{1}.FractionLength~=varargin{2}.FractionLength)
                            coder.internal.error('whdl:APPDecoder:dataTypeMismatch');
                        end
                    end
                    if((isa(varargin{1},'int8'))&&~(isa(varargin{2},'int8')))||(~(isa(varargin{1},'int8'))&&(isa(varargin{2},'int8')))...
                        ||((isa(varargin{1},'int16'))&&~(isa(varargin{2},'int16')))||(~(isa(varargin{1},'int16'))&&(isa(varargin{2},'int16')))
                        coder.internal.error('whdl:APPDecoder:dataTypeMismatch');
                    end
                end

                if isstruct(varargin{3})
                    test=fieldnames(varargin{3});
                    ctrlSignals={'start';'end';'valid'};
                    if isequal(test,ctrlSignals)
                        validateattributes(varargin{3}.start,{'logical'},...
                        {'scalar'},'APPDecoder','start');
                        validateattributes(varargin{3}.end,{'logical'},...
                        {'scalar'},'APPDecoder','end');
                        validateattributes(varargin{3}.valid,{'logical'},...
                        {'scalar'},'APPDecoder','valid');
                    else
                        coder.internal.error('whdl:APPDecoder:InvalidControlBusType');
                    end
                else
                    coder.internal.error('whdl:APPDecoder:InvalidControlBusType');
                end
                obj.inDisp=~isempty(varargin{1});
            end
        end





        function varargout=getOutputDataTypeImpl(obj,varargin)

            inputDT=propagatedInputDataType(obj,1);
            K=size(dec2bin(oct2dec(obj.CodeGenerator)),2);
            vecLen=length(obj.CodeGenerator);
            if K==1
                totalBitGrowth=floor(log2(vecLen))+2;
            else
                totalBitGrowth=floor(log2(vecLen))+floor(log2(K-1))+2;
            end
            if isnumerictype(inputDT)||isfi(inputDT)
                outputDT=numerictype(1,inputDT.WordLength+totalBitGrowth,inputDT.FractionLength);
            elseif strcmpi(inputDT,'int8')
                outputDT=numerictype(1,8+totalBitGrowth,0);
            elseif strcmpi(inputDT,'int16')
                outputDT=numerictype(1,16+totalBitGrowth,0);
            else
                outputDT=inputDT;
            end

            if obj.DisableAprOut
                varargout={outputDT,samplecontrolbustype,'logical'};
            else
                varargout={outputDT,outputDT,samplecontrolbustype,'logical'};
            end
        end



        function varargout=isOutputComplexImpl(obj)
            if obj.DisableAprOut
                varargout={false,false,false};
            else
                varargout={false,false,false,false};
            end
        end



        function[varargout]=getOutputSizeImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            if obj.DisableAprOut
                varargout{1}=1;
                varargout{2}=propagatedInputSize(obj,3);
                varargout{3}=1;
            else
                varargout{1}=1;
                varargout{2}=propagatedInputSize(obj,1);
                varargout{3}=propagatedInputSize(obj,3);
                varargout{4}=1;
            end
        end



        function varargout=isOutputFixedSizeImpl(obj)
            if obj.DisableAprOut
                varargout={true,true,true};
            else
                varargout={true,true,true,true};
            end
        end



        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.gamma=obj.gamma;
                s.gamma0Prev=obj.gamma0Prev;
                s.gamma1Prev=obj.gamma1Prev;
                s.beta0Reg=obj.beta0Reg;
                s.beta1Reg=obj.beta1Reg;
                s.beta0Prev=obj.beta0Prev;
                s.beta1Prev=obj.beta1Prev;
                s.alpha0Reg=obj.alpha0Reg;
                s.alpha1Reg=obj.alpha1Reg;
                s.alpha0Prev=obj.alpha0Prev;
                s.alpha1Prev=obj.alpha1Prev;
                s.branchMetrics=obj.branchMetrics;
                s.count=obj.count;
                s.countReg=obj.countReg;
                s.outCount=obj.outCount;
                s.revCount=obj.revCount;
                s.alphaDone=obj.alphaDone;
                s.dataOut=obj.dataOut;
                s.codedRAM=obj.codedRAM;
                s.uncodedRAM=obj.uncodedRAM;
                s.gamma0RAM=obj.gamma0RAM;
                s.gamma1RAM=obj.gamma1RAM;
                s.alpha0RAM=obj.alpha0RAM;
                s.alpha1RAM=obj.alpha1RAM;
                s.outputRAM=obj.outputRAM;
                s.outputCodedRAM=obj.outputCodedRAM;
                s.wrAddr=obj.wrAddr;
                s.rdAddr=obj.rdAddr;
                s.wrAddrReg=obj.wrAddrReg;
                s.rdAddrReg=obj.rdAddrReg;
                s.wrAddrReg1=obj.wrAddrReg1;
                s.rdAddrReg1=obj.rdAddrReg1;
                s.writeReverse=obj.writeReverse;
                s.writeReverseReg=obj.writeReverseReg;
                s.winLenMinus1=obj.winLenMinus1;
                s.prevOut=obj.prevOut;
                s.prevOutCoded=obj.prevOutCoded;
                s.validIn=obj.validIn;
                s.validInReg=obj.validInReg;
                s.validInReg1=obj.validInReg1;
                s.writeOutInRAM=obj.writeOutInRAM;
                s.wrAddOut=obj.wrAddOut;
                s.wrRevOutRAM=obj.wrRevOutRAM;
                s.rdAddrOut=obj.rdAddrOut;
                s.outValid=obj.outValid;
                s.countOut=obj.countOut;
                s.validOutReg=obj.validOutReg;
                s.validOutReg1=obj.validOutReg1;
                s.uncodedData=obj.uncodedData;
                s.codedData=obj.codedData;
                s.dataOutCoded=obj.dataOutCoded;
                s.lastWindLen=obj.lastWindLen;
                s.lastWindLen1=obj.lastWindLen1;
                s.lastWindLenReg=obj.lastWindLenReg;
                s.lastWind=obj.lastWind;
                s.lastWindReg=obj.lastWindReg;
                s.endOut=obj.endOut;
                s.endOutReg=obj.endOutReg;
                s.endInReg=obj.endInReg;
                s.endInReg1=obj.endInReg1;
                s.startOut=obj.startOut;
                s.startOutReg=obj.startOutReg;
                s.startOutReg1=obj.startOutReg1;
                s.numRows=obj.numRows;
                s.numCols=obj.numCols;
                s.statesBPSK=obj.statesBPSK;
                s.bit0indices=obj.bit0indices;
                s.bit1indices=obj.bit1indices;
                s.bitIndicesCoded=obj.bitIndicesCoded;
                s.logMAPLUT=obj.logMAPLUT;
                s.maxVal=obj.maxVal;
                s.bitGrowth=obj.bitGrowth;
                s.nextFrame=obj.nextFrame;
                s.nextFrameReg=obj.nextFrameReg;
                s.startReg=obj.startReg;
                s.startInp=obj.startInp;
                s.validInp=obj.validInp;
                s.endInp=obj.endInp;
                s.startCounting=obj.startCounting;
                s.symbolPulse=obj.symbolPulse;
                s.nextFrameCount=obj.nextFrameCount;
                s.windDone=obj.windDone;
                s.windComplete=obj.windComplete;
                s.FrameGap=obj.FrameGap;
                s.minMetric=obj.minMetric;
                s.startOutBuffer=obj.startOutBuffer;
                s.endOutBuffer=obj.endOutBuffer;
                s.enbFramEndOp=obj.enbFramEndOp;
                s.enbReg=obj.enbReg;
                s.firstWind=obj.firstWind;
                s.firstWindReg=obj.firstWindReg;
                s.firstWindReg1=obj.firstWindReg1;
                s.firstWindReg2=obj.firstWindReg2;
                s.delayLuOut=obj.delayLuOut;
                s.delayLcOut=obj.delayLcOut;
                s.delayStrtOut=obj.delayStrtOut;
                s.delayEndOut=obj.delayEndOut;
                s.delayValidOut=obj.delayValidOut;
                s.endFlag=obj.endFlag;
                s.startOutDelBal=obj.startOutDelBal;
                s.endOutDelBal=obj.endOutDelBal;
                s.validOutDelBal=obj.validOutDelBal;
                s.dataOutUncodedDelBal=obj.dataOutUncodedDelBal;
                s.dataOutCodedDelBal=obj.dataOutCodedDelBal;
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
