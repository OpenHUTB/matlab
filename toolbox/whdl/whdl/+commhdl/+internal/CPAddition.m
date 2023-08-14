classdef(StrictDefaults)CPAddition<matlab.System




%#codegen
%#ok<*EMCLS>



    properties(Nontunable)
        OFDMParametersSource='Property';
        MaxFFTLength=1024;
        FFTLength=64;
        CPLength=16;
        WinLength=4;
        MaxWinLength=8;
    end

    properties(Constant,Hidden)
        OFDMParametersSourceSet=matlab.system.StringSet({'Property','Input port'});
    end

    properties(Nontunable)
        ResetInputPort(1,1)logical=false;
        Windowing(1,1)logical=false;
    end

    properties(Nontunable,Access=private)
        vecLength;
        vecLen;
        VLBits;
        addrBitWidth;
    end

    properties(Access=private)

dataOut
validOut
FFTLenOut
CPLenOut
WinLenOut

dataOutReg
validOutReg
FFTLenOutReg
CPLenOutReg
WinLenOutReg

prevVecData
currVecData
dataVec
dataVecReg
prevSymb
idx1
idx2
index1
index2
startOutput
startOutputReg
hasPrevSymbData
prevSymbIndex
numPrevVecSamples
numCurrVecSamples
numCurrVecSamplesReg
numCurrVecSamplesReg2
numSamp
sumCurrPrevSamples
sumCurrPrevSamplesReg
sumCurrPrevSamplesReg2
idxpos
idxposReg
idxposReg2
idxpos1Reg
idxpos2Reg
idxpos1Reg2
idxpos2Reg2
diff
storeInitReadAddrRAM1
storeInitReadAddrRAM2


hRAM1
hRAM2
dataOutRAM1
dataOutRAM2
RAM2WriteSelect
writeEnbRAM1
writeEnbRAM2
writeAddrRAM1
writeAddrRAM2
readAddrRAM1Reg
readAddrRAM2Reg
sym1Done
sym2Done
readAddrRAM1
readAddrRAM2
startRead1
startRead2
startRead1Reg
startRead2Reg
startRead1Reg2
startRead2Reg2


inCount
inCountReg
FFTSampledAtIn
CPSampledAtIn
WinSampledAtIn
FFTLenMinusVecLen
FFTLenMinusVecLenMinusCPLen
outCount
outCountReg
outCountReg2
outCountReg3
outCountReg4
FFTSampledAtOut
FFTSampledAtOutReg
FFTSampledAtOutReg2
FFTSampledAtOutReg3
FFTSampledAtOutReg4
CPSampledAtOut
CPSampledAtOutReg
CPSampledAtOutReg2
CPSampledAtOutReg3
CPSampledAtOutReg4
WinSampledAtOut
WinSampledAtOutReg
WinSampledAtOutReg2
WinSampledAtOutReg3
WinSampledAtOutReg4
FFTLengthAtOutMinusVecLen
FFTLenPlusCPLen
FFTLenPlusCPLenReg
FFTLenPlusCPLenMinusVecLen
FFTLenPlusCPLenMinusVecLenReg


dataInReg
validInReg
dataInReg1
FFTLenInReg
CPLenInReg
WinLenInReg
resetReg


FFTLenPlusCPLenMinusVecLenReg2
FFTLenPlusCPLenMinusVecLenReg3
dataVec1
dataVec2
sendOutput
prevSymbStartIndex
dataVec1Samples
carryForward
vecStartIndex
dataVecidx1
dataVecidx2
    end


    methods

        function obj=CPAddition(varargin)
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
        function flag=isInactivePropertyImpl(obj,prop)


            props={};
            if~strcmpi(obj.OFDMParametersSource,'Property')
                props=[props,{'FFTLength'},{'CPLength'}];
            else
                props=[props,{'MaxFFTLength'}];
            end
            flag=ismember(prop,props);
        end


        function num=getNumInputsImpl(obj)
            if obj.ResetInputPort
                rPort=1;
            else
                rPort=0;
            end
            if strcmpi(obj.OFDMParametersSource,'Input port')
                if obj.Windowing
                    oPort=3;
                else
                    oPort=2;
                end
            else
                oPort=0;
            end
            num=2+rPort+oPort;
        end


        function num=getNumOutputsImpl(obj)
            num=2;
            if strcmpi(obj.OFDMParametersSource,'Input port')
                num=num+2;
                if obj.Windowing
                    num=num+1;
                end
            end
        end


        function setupImpl(obj,varargin)
            if strcmpi(obj.OFDMParametersSource,'Input port')
                bitWidth=log2(obj.MaxFFTLength)+1;
            else
                bitWidth=log2(obj.FFTLength)+1;
            end
            obj.vecLength=length(varargin{1});
            obj.VLBits=log2(obj.vecLength);
            obj.vecLen=fi(obj.vecLength,0,bitWidth,0,hdlfimath);

            obj.addrBitWidth=bitWidth-obj.VLBits+1;

            obj.dataOut=cast(zeros(obj.vecLength,1),'like',varargin{1});
            obj.validOut=false;
            obj.FFTLenOut=fi(64,0,bitWidth,0,hdlfimath);
            obj.CPLenOut=fi(16,0,bitWidth,0,hdlfimath);
            obj.WinLenOut=fi(1,0,bitWidth,0,hdlfimath);

            obj.dataOutReg=cast(zeros(obj.vecLength,1),'like',varargin{1});
            obj.validOutReg=false;
            obj.FFTLenOutReg=fi(64,0,bitWidth,0,hdlfimath);
            obj.CPLenOutReg=fi(16,0,bitWidth,0,hdlfimath);
            obj.WinLenOutReg=fi(1,0,bitWidth,0,hdlfimath);

            obj.prevVecData=cast(zeros(obj.vecLength,1),'like',varargin{1});
            obj.currVecData=cast(zeros(obj.vecLength,1),'like',varargin{1});
            obj.dataVec=cast(zeros(obj.vecLength,1),'like',varargin{1});
            obj.dataVecReg=cast(zeros(obj.vecLength,1),'like',varargin{1});
            obj.prevSymb=cast(zeros(obj.vecLength,1),'like',varargin{1});
            obj.idx1=fi(0,0,obj.VLBits+1,0,hdlfimath);
            obj.idx2=fi(0,0,obj.VLBits+1,0,hdlfimath);
            obj.index1=fi(0,0,obj.VLBits+1,0,hdlfimath);
            obj.index2=fi(0,0,obj.VLBits+1,0,hdlfimath);
            obj.startOutput=false;
            obj.startOutputReg=false;
            obj.hasPrevSymbData=false;
            obj.prevSymbIndex=fi(0,0,obj.VLBits+1,0,hdlfimath);

            obj.numPrevVecSamples=fi(0,0,bitWidth,0,hdlfimath);
            obj.numCurrVecSamples=fi(0,0,bitWidth,0,hdlfimath);
            obj.numCurrVecSamplesReg=fi(0,0,bitWidth,0,hdlfimath);
            obj.numCurrVecSamplesReg2=fi(0,0,bitWidth,0,hdlfimath);
            obj.numSamp=fi(0,0,bitWidth,0,hdlfimath);
            obj.sumCurrPrevSamples=fi(0,0,bitWidth,0,hdlfimath);
            obj.sumCurrPrevSamplesReg=fi(0,0,bitWidth,0,hdlfimath);
            obj.sumCurrPrevSamplesReg2=fi(0,0,bitWidth,0,hdlfimath);
            obj.idxpos=fi(0,0,obj.VLBits+1,0,hdlfimath);
            obj.idxposReg=fi(0,0,obj.VLBits+1,0,hdlfimath);
            obj.idxposReg2=fi(0,0,obj.VLBits+1,0,hdlfimath);
            obj.idxpos1Reg=fi(0,0,obj.VLBits+1,0,hdlfimath);
            obj.idxpos2Reg=fi(0,0,obj.VLBits+1,0,hdlfimath);
            obj.idxpos1Reg2=fi(0,0,obj.VLBits+1,0,hdlfimath);
            obj.idxpos2Reg2=fi(0,0,obj.VLBits+1,0,hdlfimath);
            obj.diff=fi(0,0,obj.VLBits+1,0,hdlfimath);
            obj.storeInitReadAddrRAM1=false;
            obj.storeInitReadAddrRAM2=false;


            obj.hRAM1=hdl.RAM('RAMType','Simple Dual Port');
            obj.hRAM2=hdl.RAM('RAMType','Simple Dual Port');
            obj.dataOutRAM1=cast(zeros(obj.vecLength,1),'like',varargin{1});
            obj.dataOutRAM2=cast(zeros(obj.vecLength,1),'like',varargin{1});
            obj.RAM2WriteSelect=false;
            obj.writeEnbRAM1=false;
            obj.writeEnbRAM2=false;
            obj.writeAddrRAM1=fi(0,0,obj.addrBitWidth,0,hdlfimath);
            obj.writeAddrRAM2=fi(0,0,obj.addrBitWidth,0,hdlfimath);
            obj.readAddrRAM1Reg=fi(0,0,obj.addrBitWidth,0,hdlfimath);
            obj.readAddrRAM2Reg=fi(0,0,obj.addrBitWidth,0,hdlfimath);
            obj.sym1Done=false;
            obj.sym2Done=false;
            obj.readAddrRAM1=fi(0,0,obj.addrBitWidth,0,hdlfimath);
            obj.readAddrRAM2=fi(0,0,obj.addrBitWidth,0,hdlfimath);
            obj.startRead1=false;
            obj.startRead2=false;
            obj.startRead1Reg=false;
            obj.startRead2Reg=false;
            obj.startRead1Reg2=false;
            obj.startRead2Reg2=false;


            obj.inCount=fi(0,0,bitWidth,0,hdlfimath);
            obj.inCountReg=fi(0,0,bitWidth,0,hdlfimath);
            obj.FFTSampledAtIn=fi(64,0,bitWidth,0,hdlfimath);
            obj.CPSampledAtIn=fi(16,0,bitWidth,0,hdlfimath);
            obj.WinSampledAtIn=fi(1,0,bitWidth,0,hdlfimath);
            obj.FFTLenMinusVecLen=fi(0,0,bitWidth,0,hdlfimath);
            obj.FFTLenMinusVecLenMinusCPLen=fi(0,0,bitWidth,0,hdlfimath);
            obj.outCount=fi(0,0,bitWidth,0,hdlfimath);
            obj.outCountReg=fi(0,0,bitWidth,0,hdlfimath);
            obj.outCountReg2=fi(0,0,bitWidth,0,hdlfimath);
            obj.outCountReg3=fi(0,0,bitWidth,0,hdlfimath);
            obj.outCountReg4=fi(0,0,bitWidth,0,hdlfimath);
            obj.FFTSampledAtOut=fi(64,0,bitWidth,0,hdlfimath);
            obj.FFTSampledAtOutReg=fi(64,0,bitWidth,0,hdlfimath);
            obj.FFTSampledAtOutReg2=fi(64,0,bitWidth,0,hdlfimath);
            obj.FFTSampledAtOutReg3=fi(64,0,bitWidth,0,hdlfimath);
            obj.FFTSampledAtOutReg4=fi(64,0,bitWidth,0,hdlfimath);
            obj.CPSampledAtOut=fi(16,0,bitWidth,0,hdlfimath);
            obj.CPSampledAtOutReg=fi(16,0,bitWidth,0,hdlfimath);
            obj.CPSampledAtOutReg2=fi(16,0,bitWidth,0,hdlfimath);
            obj.CPSampledAtOutReg3=fi(16,0,bitWidth,0,hdlfimath);
            obj.CPSampledAtOutReg4=fi(16,0,bitWidth,0,hdlfimath);
            obj.WinSampledAtOut=fi(1,0,bitWidth,0,hdlfimath);
            obj.WinSampledAtOutReg=fi(1,0,bitWidth,0,hdlfimath);
            obj.WinSampledAtOutReg2=fi(1,0,bitWidth,0,hdlfimath);
            obj.WinSampledAtOutReg3=fi(1,0,bitWidth,0,hdlfimath);
            obj.WinSampledAtOutReg4=fi(1,0,bitWidth,0,hdlfimath);
            obj.FFTLengthAtOutMinusVecLen=fi(0,0,bitWidth,0,hdlfimath);
            obj.FFTLenPlusCPLen=fi(0,0,bitWidth,0,hdlfimath);
            obj.FFTLenPlusCPLenReg=fi(0,0,bitWidth,0,hdlfimath);
            obj.FFTLenPlusCPLenMinusVecLen=fi(0,0,bitWidth,0,hdlfimath);
            obj.FFTLenPlusCPLenMinusVecLenReg=fi(0,0,bitWidth,0,hdlfimath);


            obj.dataInReg=cast(zeros(obj.vecLength,1),'like',varargin{1});
            obj.validInReg=false;
            obj.dataInReg1=cast(zeros(obj.vecLength,1),'like',varargin{1});
            obj.FFTLenInReg=fi(64,0,bitWidth,0,hdlfimath);
            obj.CPLenInReg=fi(16,0,bitWidth,0,hdlfimath);
            obj.WinLenInReg=fi(16,0,bitWidth,0,hdlfimath);
            obj.resetReg=false;


            obj.FFTLenPlusCPLenMinusVecLenReg2=fi(0,0,bitWidth,0,hdlfimath);
            obj.FFTLenPlusCPLenMinusVecLenReg3=fi(0,0,bitWidth,0,hdlfimath);
            obj.dataVec1=cast(zeros(obj.vecLength,1),'like',varargin{1});
            obj.index1=fi(0,0,obj.VLBits+1,0,hdlfimath);
            obj.dataVec2=cast(zeros(obj.vecLength,1),'like',varargin{1});
            obj.index2=fi(0,0,obj.VLBits+1,0,hdlfimath);
            obj.sendOutput=false;
            obj.prevSymbStartIndex=fi(0,0,obj.VLBits+1,0,hdlfimath);
            obj.dataVec1Samples=fi(0,0,obj.VLBits+1,0,hdlfimath);
            obj.carryForward=false;
            obj.vecStartIndex=fi(0,0,obj.VLBits+1,0,hdlfimath);
            obj.dataVecidx1=fi(0,0,obj.VLBits+1,0,hdlfimath);
            obj.dataVecidx2=fi(0,0,obj.VLBits+1,0,hdlfimath);
        end


        function resetImpl(obj)

            obj.dataOut(:)=0;
            obj.validOut=false;
            obj.FFTLenOut(:)=64;
            obj.CPLenOut(:)=16;
            obj.WinLenOut(:)=1;
            obj.dataOutReg(:)=0;
            obj.validOutReg=false;
            obj.FFTLenOutReg(:)=64;
            obj.CPLenOutReg(:)=16;
            obj.WinLenOutReg(:)=1;

            obj.prevVecData(:)=0;
            obj.currVecData(:)=0;
            obj.dataVec(:)=0;
            obj.dataVecReg(:)=0;
            obj.prevSymb(:)=0;
            obj.idx1(:)=0;
            obj.idx2(:)=0;
            obj.index1(:)=0;
            obj.index2(:)=0;
            obj.startOutput=false;
            obj.startOutputReg=false;
            obj.hasPrevSymbData=false;

            obj.numPrevVecSamples(:)=0;
            obj.numCurrVecSamples(:)=0;
            obj.numCurrVecSamplesReg(:)=0;
            obj.numCurrVecSamplesReg2(:)=0;
            obj.numSamp(:)=0;
            obj.sumCurrPrevSamples(:)=0;
            obj.sumCurrPrevSamplesReg(:)=0;
            obj.sumCurrPrevSamplesReg2(:)=0;
            obj.idxpos(:)=0;
            obj.idxposReg(:)=0;
            obj.idxposReg2(:)=0;
            obj.idxpos1Reg(:)=0;
            obj.idxpos2Reg2(:)=0;
            obj.idxpos1Reg2(:)=0;
            obj.idxpos2Reg(:)=0;
            obj.diff(:)=0;
            obj.storeInitReadAddrRAM1=false;
            obj.storeInitReadAddrRAM2=false;


            obj.dataOutRAM1(:)=0;
            obj.dataOutRAM2(:)=0;
            obj.RAM2WriteSelect=false;
            obj.writeEnbRAM1=false;
            obj.writeEnbRAM2=false;
            obj.writeAddrRAM1(:)=0;
            obj.writeAddrRAM2(:)=0;
            obj.readAddrRAM1Reg(:)=0;
            obj.readAddrRAM2Reg(:)=0;
            obj.sym1Done=false;
            obj.sym2Done=false;
            obj.readAddrRAM1(:)=0;
            obj.readAddrRAM2(:)=0;
            obj.startRead1=false;
            obj.startRead2=false;
            obj.startRead1Reg=false;
            obj.startRead2Reg=false;
            obj.startRead1Reg2=false;
            obj.startRead2Reg2=false;


            obj.inCount(:)=0;
            obj.inCountReg(:)=0;
            obj.FFTSampledAtIn(:)=64;
            obj.CPSampledAtIn(:)=16;
            obj.WinSampledAtIn(:)=1;
            obj.FFTLenMinusVecLen(:)=0;
            obj.FFTLenMinusVecLenMinusCPLen(:)=0;
            obj.outCount(:)=0;
            obj.outCountReg(:)=0;
            obj.outCountReg2(:)=0;
            obj.outCountReg3(:)=0;
            obj.outCountReg4(:)=0;
            obj.FFTSampledAtOut(:)=64;
            obj.FFTSampledAtOutReg(:)=64;
            obj.FFTSampledAtOutReg2(:)=64;
            obj.FFTSampledAtOutReg3(:)=64;
            obj.FFTSampledAtOutReg4(:)=64;
            obj.CPSampledAtOut(:)=16;
            obj.CPSampledAtOutReg(:)=16;
            obj.CPSampledAtOutReg2(:)=16;
            obj.CPSampledAtOutReg3(:)=16;
            obj.CPSampledAtOutReg4(:)=16;
            obj.WinSampledAtOut(:)=1;
            obj.WinSampledAtOutReg(:)=1;
            obj.WinSampledAtOutReg2(:)=1;
            obj.WinSampledAtOutReg3(:)=1;
            obj.WinSampledAtOutReg4(:)=1;
            obj.FFTLengthAtOutMinusVecLen(:)=0;
            obj.FFTLenPlusCPLen(:)=0;
            obj.FFTLenPlusCPLenReg(:)=0;
            obj.FFTLenPlusCPLenMinusVecLen(:)=0;
            obj.FFTLenPlusCPLenMinusVecLenReg(:)=0;


            obj.dataInReg(:)=0;
            obj.validInReg=false;
            obj.dataInReg1(:)=0;
            obj.FFTLenInReg(:)=64;
            obj.CPLenInReg(:)=16;
            obj.WinLenInReg(:)=1;
            obj.resetReg=false;


            obj.FFTLenPlusCPLenMinusVecLenReg2(:)=0;
            obj.FFTLenPlusCPLenMinusVecLenReg3(:)=0;
            obj.dataVec1(:)=0;
            obj.index1(:)=0;
            obj.dataVec2(:)=0;
            obj.index2(:)=0;
            obj.sendOutput=false;
            obj.prevSymbStartIndex(:)=0;
            obj.dataVec1Samples(:)=0;
            obj.carryForward=false;
            obj.vecStartIndex(:)=0;
            obj.dataVecidx1(:)=0;
            obj.dataVecidx2(:)=0;
        end



        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.dataOut;
            varargout{2}=obj.validOut;
            if strcmpi(obj.OFDMParametersSource,'Input port')
                varargout{3}=cast(obj.FFTLenOut,'like',varargin{3});
                varargout{4}=cast(obj.CPLenOut,'like',varargin{4});
                if obj.Windowing
                    varargout{5}=cast(obj.WinLenOut,'like',varargin{5});
                end
            end

        end


        function updateImpl(obj,varargin)

            obj.dataOut(:)=obj.dataOutReg;
            obj.validOut(:)=obj.validOutReg;

            if obj.outCountReg4==0
                obj.FFTLenOut(:)=obj.FFTLenOutReg;
                obj.CPLenOut(:)=obj.CPLenOutReg;
                if obj.Windowing
                    obj.WinLenOut(:)=obj.WinLenOutReg;
                end
            end


            obj.dataOutRAM1(:)=obj.hRAM1(obj.dataInReg1,obj.writeAddrRAM1,obj.writeEnbRAM1,obj.readAddrRAM1);
            obj.dataOutRAM2(:)=obj.hRAM2(obj.dataInReg1,obj.writeAddrRAM2,obj.writeEnbRAM2,obj.readAddrRAM2);


            if obj.outCount==0
                obj.FFTSampledAtOut(:)=obj.FFTSampledAtIn;
                obj.CPSampledAtOut(:)=obj.CPSampledAtIn;
                if obj.Windowing
                    obj.WinSampledAtOut(:)=obj.WinSampledAtIn;
                end
                obj.FFTLengthAtOutMinusVecLen(:)=obj.FFTLenMinusVecLen;
                obj.FFTLenPlusCPLen(:)=obj.FFTSampledAtIn+obj.CPSampledAtIn;
                obj.FFTLenPlusCPLenMinusVecLen(:)=obj.FFTLenPlusCPLen-obj.vecLen;
            end

            if obj.sendOutput
                obj.dataVecidx1(:)=obj.index1;
                obj.dataVecidx2(:)=obj.index2;
                for ii=0:(obj.vecLen-1)
                    obj.dataVecidx1(:)=obj.index1+cast(ii,'like',obj.dataVecidx1);
                    if ii<obj.dataVec1Samples
                        obj.dataOutReg(ii+1)=obj.dataVec1(obj.dataVecidx1+1);
                    else
                        obj.dataOutReg(ii+1)=obj.dataVec2(obj.dataVecidx2+1);
                        obj.dataVecidx2(:)=obj.dataVecidx2+1;
                    end
                end
                obj.validOutReg=true;
            else
                obj.dataOutReg(:)=0;
                obj.validOutReg=false;
            end


            if obj.startOutputReg
                if obj.outCountReg3>=obj.FFTLenPlusCPLenMinusVecLenReg3
                    if obj.carryForward
                        obj.dataVec1(:)=obj.prevVecData;
                        obj.dataVec2(:)=obj.dataVecReg;
                        obj.index1(:)=obj.idxpos;
                        obj.dataVec1Samples(:)=obj.vecLen-obj.idxpos;
                        obj.index2(:)=0;
                        obj.hasPrevSymbData=true;
                        obj.prevSymb(:)=obj.dataVecReg;
                        obj.prevSymbStartIndex(:)=obj.idxpos;
                        obj.numPrevVecSamples(:)=obj.dataVec1Samples;
                        obj.sendOutput=true;
                    else
                        obj.dataVec1(:)=obj.dataVecReg;
                        obj.dataVec2(:)=obj.dataVec;
                        obj.index1(:)=obj.idxpos;
                        obj.dataVec1Samples(:)=obj.vecLen-obj.idxpos;
                        obj.index2(:)=0;
                        if obj.idxpos==0
                            obj.hasPrevSymbData=false;
                            obj.sendOutput=true;
                        else
                            obj.hasPrevSymbData=true;
                            obj.prevSymb(:)=obj.dataVecReg;
                            obj.prevSymbStartIndex(:)=obj.idxpos;
                            obj.numPrevVecSamples(:)=obj.dataVec1Samples;
                            obj.sendOutput=false;
                        end
                    end
                    obj.carryForward=false;
                else
                    if obj.hasPrevSymbData
                        obj.sumCurrPrevSamples(:)=obj.numCurrVecSamples+obj.numPrevVecSamples;
                        if obj.sumCurrPrevSamples>=obj.vecLen


                            obj.index1(:)=obj.prevSymbStartIndex;
                            obj.index2(:)=obj.idxpos;
                            obj.dataVec1(:)=obj.prevSymb;
                            obj.dataVec2(:)=obj.dataVecReg;
                            obj.dataVec1Samples(:)=obj.vecLen-obj.prevSymbStartIndex;
                            obj.idxpos(:)=obj.idxpos+obj.prevSymbStartIndex;
                            if obj.idxpos==obj.vecLen
                                obj.idxpos(:)=0;
                                obj.carryForward=false;
                            else
                                obj.prevVecData(:)=obj.dataVecReg;
                                obj.carryForward=true;
                            end
                            obj.sendOutput=true;
                        else



                            obj.idx1(:)=obj.prevSymbStartIndex;
                            obj.idx2(:)=obj.idxpos;
                            obj.vecStartIndex(:)=obj.prevSymbStartIndex-obj.numCurrVecSamples;
                            for ii=0:(obj.vecLen-1)
                                ii_2=cast(ii+obj.numCurrVecSamples,'like',obj.vecLen);
                                if ii>=obj.idx2
                                    obj.prevVecData(ii+1)=obj.dataVecReg(ii+1);
                                elseif ii>=obj.vecStartIndex
                                    obj.prevVecData(ii+1)=obj.prevSymb(ii_2+1);
                                end
                            end
                            obj.index1(:)=obj.vecLen-obj.sumCurrPrevSamples;
                            obj.index2(:)=0;
                            obj.idxpos(:)=obj.index1;
                            obj.dataVec1Samples(:)=obj.sumCurrPrevSamples;
                            obj.dataVec1(:)=obj.prevVecData;
                            obj.dataVec2(:)=obj.dataVec;
                            obj.sendOutput=true;
                            obj.carryForward=false;
                        end
                    else
                        if obj.carryForward
                            obj.dataVec1(:)=obj.prevVecData;
                            obj.dataVec2(:)=obj.dataVecReg;
                        else
                            obj.dataVec1(:)=obj.dataVecReg;
                            obj.dataVec2(:)=obj.dataVec;
                        end
                        obj.index1(:)=obj.idxpos;
                        obj.index2(:)=0;
                        obj.dataVec1Samples(:)=obj.vecLen-obj.idxpos;
                        obj.sendOutput=true;
                        obj.prevVecData(:)=obj.dataVecReg;
                    end
                    obj.hasPrevSymbData=false;
                end
            else
                obj.sendOutput=false;
            end

            if obj.startRead1Reg2&&~obj.startRead2Reg2
                if obj.outCountReg2==0
                    obj.idxpos(:)=obj.idxpos1Reg2;
                    obj.numCurrVecSamples(:)=obj.numSamp;
                    obj.sumCurrPrevSamples(:)=0;
                end
            elseif~obj.startRead1Reg2&&obj.startRead2Reg2
                if obj.outCountReg2==0
                    obj.idxpos(:)=obj.idxpos2Reg2;
                    obj.numCurrVecSamples(:)=obj.numSamp;
                    obj.sumCurrPrevSamples(:)=0;
                end
            end
            obj.idxpos1Reg2(:)=obj.idxpos1Reg;
            obj.idxpos2Reg2(:)=obj.idxpos2Reg;

            if obj.startRead1Reg&&~obj.startRead2Reg
                obj.currVecData(:)=obj.dataOutRAM1;
            elseif~obj.startRead1Reg&&obj.startRead2Reg
                obj.currVecData(:)=obj.dataOutRAM2;
            end
            obj.dataVecReg(:)=obj.dataVec;
            obj.dataVec(:)=obj.currVecData;

            obj.startOutputReg(:)=obj.startOutput;
            obj.startOutput(:)=xor(obj.startRead1Reg,obj.startRead2Reg);

            obj.outCountReg4(:)=obj.outCountReg3;
            obj.outCountReg3(:)=obj.outCountReg2;
            obj.outCountReg2(:)=obj.outCountReg;

            obj.outCountReg(:)=obj.outCount;
            obj.FFTLenPlusCPLenMinusVecLenReg3(:)=obj.FFTLenPlusCPLenMinusVecLenReg2;
            obj.FFTLenPlusCPLenMinusVecLenReg2(:)=obj.FFTLenPlusCPLenMinusVecLenReg;
            obj.FFTLenPlusCPLenMinusVecLenReg(:)=obj.FFTLenPlusCPLenMinusVecLen;


            obj.FFTLenOutReg(:)=obj.FFTSampledAtOutReg3;
            obj.CPLenOutReg(:)=obj.CPSampledAtOutReg3;

            obj.FFTSampledAtOutReg3(:)=obj.FFTSampledAtOutReg2;
            obj.CPSampledAtOutReg3(:)=obj.CPSampledAtOutReg2;

            obj.FFTSampledAtOutReg2(:)=obj.FFTSampledAtOutReg;
            obj.CPSampledAtOutReg2(:)=obj.CPSampledAtOutReg;

            obj.FFTSampledAtOutReg(:)=obj.FFTSampledAtOut;
            obj.CPSampledAtOutReg(:)=obj.CPSampledAtOut;

            if obj.Windowing
                obj.WinLenOutReg(:)=obj.WinSampledAtOutReg3;
                obj.WinSampledAtOutReg3(:)=obj.WinSampledAtOutReg2;
                obj.WinSampledAtOutReg2(:)=obj.WinSampledAtOutReg;
                obj.WinSampledAtOutReg(:)=obj.WinSampledAtOut;
            end


            obj.startRead1Reg2(:)=obj.startRead1Reg;
            obj.startRead2Reg2(:)=obj.startRead2Reg;

            obj.startRead1Reg(:)=obj.startRead1;
            obj.startRead2Reg(:)=obj.startRead2;


            if obj.startRead1&&~obj.startRead2

                if obj.readAddrRAM1==bitsra(obj.FFTLengthAtOutMinusVecLen,obj.VLBits)
                    obj.readAddrRAM1(:)=0;
                else

                    obj.readAddrRAM1(:)=obj.readAddrRAM1+1;
                end
                if obj.outCount>=obj.FFTLenPlusCPLenMinusVecLen
                    obj.outCount(:)=0;
                    obj.startRead1(:)=false;
                else
                    obj.outCount(:)=obj.outCount+obj.vecLen;
                end
            elseif obj.startRead2&&~obj.startRead1
                if obj.readAddrRAM2==bitsra(obj.FFTLengthAtOutMinusVecLen,obj.VLBits)
                    obj.readAddrRAM2(:)=0;
                else

                    obj.readAddrRAM2(:)=obj.readAddrRAM2+1;
                end
                if obj.outCount>=obj.FFTLenPlusCPLenMinusVecLen
                    obj.outCount(:)=0;
                    obj.startRead2(:)=false;
                else
                    obj.outCount(:)=obj.outCount+obj.vecLen;
                end
            end



            if obj.sym1Done
                if obj.startRead2
                    obj.startRead1=false;
                else
                    obj.startRead1=true;
                    obj.readAddrRAM1(:)=obj.readAddrRAM1Reg;
                    obj.sym1Done=false;
                end
            end
            if obj.sym2Done
                if obj.startRead1
                    obj.startRead2=false;
                else
                    obj.startRead2=true;
                    obj.readAddrRAM2(:)=obj.readAddrRAM2Reg;
                    obj.sym2Done=false;
                end
            end


            if obj.writeEnbRAM1&&~obj.storeInitReadAddrRAM1
                if obj.CPSampledAtIn<=obj.vecLen
                    if obj.CPSampledAtIn~=0
                        if obj.inCountReg==obj.FFTLenMinusVecLen
                            obj.readAddrRAM1Reg(:)=obj.writeAddrRAM1;
                            obj.idxpos1Reg(:)=obj.vecLen-obj.CPSampledAtIn;
                            obj.storeInitReadAddrRAM1=true;
                            obj.numSamp(:)=obj.CPSampledAtIn;
                        end
                    else
                        if obj.inCountReg==obj.FFTLenMinusVecLen
                            obj.readAddrRAM1Reg(:)=0;
                            obj.idxpos1Reg(:)=0;
                            obj.storeInitReadAddrRAM1=true;
                            obj.numSamp(:)=0;
                        end
                    end
                elseif obj.CPSampledAtIn>=obj.FFTLenMinusVecLen
                    if obj.inCountReg==0
                        obj.readAddrRAM1Reg(:)=0;
                        obj.diff(:)=obj.CPSampledAtIn-obj.FFTLenMinusVecLen;
                        obj.numSamp(:)=obj.diff;
                        obj.idxpos1Reg(:)=obj.vecLen-obj.diff;
                        obj.storeInitReadAddrRAM1=true;
                    end
                else
                    if obj.inCountReg>obj.FFTLenMinusVecLenMinusCPLen
                        obj.readAddrRAM1Reg(:)=obj.writeAddrRAM1;
                        obj.storeInitReadAddrRAM1=true;
                        obj.diff(:)=obj.inCountReg-obj.FFTLenMinusVecLenMinusCPLen;
                        obj.numSamp(:)=obj.diff;
                        obj.idxpos1Reg(:)=obj.vecLen-obj.diff;
                    end
                end
            elseif obj.writeEnbRAM2&&~obj.storeInitReadAddrRAM2
                if obj.CPSampledAtIn<=obj.vecLen
                    if obj.CPSampledAtIn~=0
                        if obj.inCountReg==obj.FFTLenMinusVecLen
                            obj.readAddrRAM2Reg(:)=obj.writeAddrRAM2;
                            obj.idxpos2Reg(:)=obj.vecLen-obj.CPSampledAtIn;
                            obj.storeInitReadAddrRAM2=true;
                            obj.numSamp(:)=obj.CPSampledAtIn;
                        end
                    else
                        if obj.inCountReg==obj.FFTLenMinusVecLen
                            obj.readAddrRAM2Reg(:)=0;
                            obj.idxpos2Reg(:)=0;
                            obj.storeInitReadAddrRAM2=true;
                            obj.numSamp(:)=0;
                        end
                    end
                elseif obj.CPSampledAtIn>=obj.FFTLenMinusVecLen
                    if obj.inCountReg==0
                        obj.readAddrRAM2Reg(:)=0;
                        obj.diff(:)=obj.CPSampledAtIn-obj.FFTLenMinusVecLen;
                        obj.numSamp(:)=obj.diff;
                        obj.idxpos2Reg(:)=obj.vecLen-obj.diff;
                        obj.storeInitReadAddrRAM2=true;
                    end
                else
                    if obj.inCountReg>obj.FFTLenMinusVecLenMinusCPLen
                        obj.readAddrRAM2Reg(:)=obj.writeAddrRAM2;
                        obj.storeInitReadAddrRAM2=true;
                        obj.diff(:)=obj.inCountReg-obj.FFTLenMinusVecLenMinusCPLen;
                        obj.numSamp(:)=obj.diff;
                        obj.idxpos2Reg(:)=obj.vecLen-obj.diff;
                    end
                end
            end


            if obj.writeEnbRAM1
                if obj.inCountReg==obj.FFTLenMinusVecLen
                    obj.writeAddrRAM1(:)=0;
                    obj.sym1Done=true;
                    obj.storeInitReadAddrRAM1=false;
                else

                    obj.writeAddrRAM1(:)=obj.writeAddrRAM1+1;
                end
            elseif obj.writeEnbRAM2
                if obj.inCountReg==obj.FFTLenMinusVecLen
                    obj.writeAddrRAM2(:)=0;
                    obj.sym2Done=true;
                    obj.storeInitReadAddrRAM2=false;
                else

                    obj.writeAddrRAM2(:)=obj.writeAddrRAM2+1;
                end
            end


            obj.writeEnbRAM1=obj.validInReg&&~obj.RAM2WriteSelect;
            obj.writeEnbRAM2=obj.validInReg&&obj.RAM2WriteSelect;


            if obj.validInReg
                if obj.inCount==0
                    obj.FFTLenMinusVecLen(:)=obj.FFTLenInReg-obj.vecLen;
                    obj.FFTLenMinusVecLenMinusCPLen(:)=obj.FFTLenMinusVecLen-obj.CPLenInReg;
                    obj.FFTSampledAtIn(:)=obj.FFTLenInReg;
                    obj.CPSampledAtIn(:)=obj.CPLenInReg;
                    if obj.Windowing
                        obj.WinSampledAtIn(:)=obj.WinLenInReg;
                    end
                end
            end


            obj.inCountReg(:)=obj.inCount;


            if obj.validInReg
                if obj.inCount==obj.FFTLenMinusVecLen
                    obj.inCount(:)=0;
                    obj.RAM2WriteSelect=~obj.RAM2WriteSelect;
                else
                    obj.inCount(:)=obj.inCount+obj.vecLen;
                end
            end


            obj.dataInReg1(:)=obj.dataInReg;


            obj.dataInReg(:)=varargin{1};
            obj.validInReg(:)=varargin{2};
            if strcmp(obj.OFDMParametersSource,'Input port')
                obj.FFTLenInReg(:)=varargin{3};
                obj.CPLenInReg(:)=varargin{4};
                if obj.Windowing
                    obj.WinLenInReg(:)=varargin{5};
                    if obj.ResetInputPort
                        obj.resetReg=varargin{6};
                    end
                else
                    if obj.ResetInputPort
                        obj.resetReg=varargin{5};
                    end
                end
            else
                obj.FFTLenInReg(:)=obj.FFTLength;
                obj.CPLenInReg(:)=obj.CPLength;
                if obj.Windowing
                    obj.WinLenInReg(:)=obj.WinLength;
                end
                if obj.ResetInputPort
                    obj.resetReg=varargin{3};
                end
            end

            if obj.ResetInputPort
                ifResetTrue(obj);
            end
        end


        function ifResetTrue(obj)
            if obj.resetReg
                resetImpl(obj);
            end
        end


        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end


        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.dataOut=obj.dataOut;
                s.validOut=obj.validOut;
                s.FFTLenOut=obj.FFTLenOut;
                s.CPLenOut=obj.CPLenOut;
                s.dataOutReg=obj.dataOutReg;
                s.validOutReg=obj.validOutReg;
                s.FFTLenOutReg=obj.FFTLenOutReg;
                s.CPLenOutReg=obj.CPLenOutReg;
                s.prevVecData=obj.prevVecData;
                s.currVecData=obj.currVecData;
                s.dataVec=obj.dataVec;
                s.dataVecReg=obj.dataVecReg;
                s.prevSymb=obj.prevSymb;
                s.idx1=obj.idx1;
                s.idx2=obj.idx2;
                s.index1=obj.index1;
                s.index2=obj.index2;
                s.startOutput=obj.startOutput;
                s.startOutputReg=obj.startOutputReg;
                s.hasPrevSymbData=obj.hasPrevSymbData;
                s.prevSymbIndex=obj.prevSymbIndex;
                s.numPrevVecSamples=obj.numPrevVecSamples;
                s.numCurrVecSamples=obj.numCurrVecSamples;
                s.numCurrVecSamplesReg=obj.numCurrVecSamplesReg;
                s.numCurrVecSamplesReg2=obj.numCurrVecSamplesReg2;
                s.numSamp=obj.numSamp;
                s.sumCurrPrevSamples=obj.sumCurrPrevSamples;
                s.sumCurrPrevSamplesReg=obj.sumCurrPrevSamplesReg;
                s.sumCurrPrevSamplesReg2=obj.sumCurrPrevSamplesReg2;
                s.idxpos=obj.idxpos;
                s.idxposReg=obj.idxposReg;
                s.idxposReg2=obj.idxposReg2;
                s.idxpos1Reg=obj.idxpos1Reg;
                s.idxpos2Reg=obj.idxpos2Reg;
                s.idxpos1Reg2=obj.idxpos1Reg2;
                s.idxpos2Reg2=obj.idxpos2Reg2;
                s.diff=obj.diff;
                s.storeInitReadAddrRAM1=obj.storeInitReadAddrRAM1;
                s.storeInitReadAddrRAM2=obj.storeInitReadAddrRAM2;
                s.hRAM1=obj.hRAM1;
                s.hRAM2=obj.hRAM2;
                s.dataOutRAM1=obj.dataOutRAM1;
                s.dataOutRAM2=obj.dataOutRAM2;
                s.RAM2WriteSelect=obj.RAM2WriteSelect;
                s.writeEnbRAM1=obj.writeEnbRAM1;
                s.writeEnbRAM2=obj.writeEnbRAM2;
                s.writeAddrRAM1=obj.writeAddrRAM1;
                s.writeAddrRAM2=obj.writeAddrRAM2;
                s.readAddrRAM1Reg=obj.readAddrRAM1Reg;
                s.readAddrRAM2Reg=obj.readAddrRAM2Reg;
                s.sym1Done=obj.sym1Done;
                s.sym2Done=obj.sym2Done;
                s.readAddrRAM1=obj.readAddrRAM1;
                s.readAddrRAM2=obj.readAddrRAM2;
                s.startRead1=obj.startRead1;
                s.startRead2=obj.startRead2;
                s.startRead1Reg=obj.startRead1Reg;
                s.startRead2Reg=obj.startRead2Reg;
                s.startRead1Reg2=obj.startRead1Reg2;
                s.startRead2Reg2=obj.startRead2Reg2;
                s.inCount=obj.inCount;
                s.inCountReg=obj.inCountReg;
                s.FFTSampledAtIn=obj.FFTSampledAtIn;
                s.CPSampledAtIn=obj.CPSampledAtIn;
                s.FFTLenMinusVecLen=obj.FFTLenMinusVecLen;
                s.FFTLenMinusVecLenMinusCPLen=obj.FFTLenMinusVecLenMinusCPLen;
                s.outCount=obj.outCount;
                s.outCountReg=obj.outCountReg;
                s.outCountReg2=obj.outCountReg2;
                s.outCountReg3=obj.outCountReg3;
                s.FFTSampledAtOut=obj.FFTSampledAtOut;
                s.FFTSampledAtOutReg=obj.FFTSampledAtOutReg;
                s.CPSampledAtOut=obj.CPSampledAtOut;
                s.CPSampledAtOutReg=obj.CPSampledAtOutReg;
                s.FFTLengthAtOutMinusVecLen=obj.FFTLengthAtOutMinusVecLen;
                s.FFTLenPlusCPLen=obj.FFTLenPlusCPLen;
                s.FFTLenPlusCPLenReg=obj.FFTLenPlusCPLenReg;
                s.FFTLenPlusCPLenMinusVecLen=obj.FFTLenPlusCPLenMinusVecLen;
                s.FFTLenPlusCPLenMinusVecLenReg=obj.FFTLenPlusCPLenMinusVecLenReg;
                s.dataInReg=obj.dataInReg;
                s.validInReg=obj.validInReg;
                s.dataInReg1=obj.dataInReg1;
                s.FFTLenInReg=obj.FFTLenInReg;
                s.CPLenInReg=obj.CPLenInReg;
                s.resetReg=obj.resetReg;
                s.FFTLenPlusCPLenMinusVecLenReg2=obj.FFTLenPlusCPLenMinusVecLenReg2;
                s.FFTLenPlusCPLenMinusVecLenReg3=obj.FFTLenPlusCPLenMinusVecLenReg3;
                s.dataVec1=obj.dataVec1;
                s.dataVec2=obj.dataVec2;
                s.sendOutput=obj.sendOutput;
                s.prevSymbStartIndex=obj.prevSymbStartIndex;
                s.dataVec1Samples=obj.dataVec1Samples;
                s.carryForward=obj.carryForward;
                s.vecStartIndex=obj.vecStartIndex;
                s.dataVecidx1=obj.dataVecidx1;
                s.dataVecidx2=obj.dataVecidx2;
                s.WinLenOut=obj.WinLenOut;
                s.WinLenOutReg=obj.WinLenOutReg;
                s.WinSampledAtIn=obj.WinSampledAtIn;
                s.outCountReg4=obj.outCountReg4;
                s.FFTSampledAtOutReg2=obj.FFTSampledAtOutReg2;
                s.FFTSampledAtOutReg3=obj.FFTSampledAtOutReg3;
                s.FFTSampledAtOutReg4=obj.FFTSampledAtOutReg4;
                s.CPSampledAtOutReg2=obj.CPSampledAtOutReg2;
                s.CPSampledAtOutReg3=obj.CPSampledAtOutReg3;
                s.CPSampledAtOutReg4=obj.CPSampledAtOutReg4;
                s.WinSampledAtOut=obj.WinSampledAtOut;
                s.WinSampledAtOutReg=obj.WinSampledAtOutReg;
                s.WinSampledAtOutReg2=obj.WinSampledAtOutReg2;
                s.WinSampledAtOutReg3=obj.WinSampledAtOutReg3;
                s.WinSampledAtOutReg4=obj.WinSampledAtOutReg4;
                s.WinLenInReg=obj.WinLenInReg;



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

