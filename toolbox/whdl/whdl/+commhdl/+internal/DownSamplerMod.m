classdef(StrictDefaults)DownSamplerMod<matlab.System




%#codegen
%#ok<*EMCLS>

    properties(Nontunable)



        MaxFFTLength=64;
        MaxWinLength=8;

        Normalize(1,1)logical=false;
        resetPort(1,1)logical=false;
        Windowing(1,1)logical=false;
    end


    properties(DiscreteState)

    end


    properties(Nontunable,Access=private)
        vecLen;
        VLBits;
        addrBitWidth;
    end


    properties(Access=private)
        dataIn;
        validIn;
        dataOut;
        validOut;
        FFTLengthOut;
        CPLengthOut;
        cpLen;

CPLenSampled
CPLenSampled1
CPLenSampled2

        resetSig;
buffer
inCount
        outCount;
count
countReg
countReg1
sampCount
upCount

CPPlusVec
CPReg
FFTLenSampled
FFTReg
FFTReg1
FFTReg2
FFTReg3
FFTPlusCP
dataOutReg
dataInReg
dataInReg2
dataReg
dataInReg1
validOutReg
validOutReg1
validOutReg2
validOutReg3
validInReg
validInReg1
validInReg2
validInReg3
maxFFT
maxFFTPlusCP
upFac
upFacReg
upFacMinVec
idx2
FFTArr
diffBits
storedIdx
filledVecCnt

winLenIn
WinLenSampled
WinLenSampled1
WinLenSampled2
winLenOut
    end



    methods
        function obj=DownSamplerMod(varargin)
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

        function numInpPorts=getNumInputsImpl(obj)
            numInpPorts=4;
            if obj.Windowing
                if obj.resetPort
                    numInpPorts=6;
                else
                    numInpPorts=5;
                end
            else
                if obj.resetPort
                    numInpPorts=5;
                end
            end
        end

        function numOutPorts=getNumOutputsImpl(obj)
            if obj.Windowing
                numOutPorts=5;
            else
                numOutPorts=4;
            end
        end

        function setupImpl(obj,varargin)

            maxBits=log2(obj.MaxFFTLength);


            dIn=varargin{1};
            if maxBits<6
                bitWidth=8;
            else
                bitWidth=maxBits+1;
            end
            obj.diffBits=fi(maxBits-1:-1:0,0,bitWidth,0,hdlfimath);
            obj.FFTArr=fi(2.^(1:maxBits),0,bitWidth,0,hdlfimath);
            obj.buffer=cast(zeros(length(dIn),1),'like',dIn);
            obj.vecLen=fi(length(dIn),0,bitWidth,0,hdlfimath);
            obj.inCount=fi(0,0,bitWidth,0,hdlfimath);
            obj.outCount=fi(0,0,bitWidth,0,hdlfimath);
            obj.count=fi(0,0,bitWidth,0,hdlfimath);
            obj.countReg=fi(0,0,bitWidth,0,hdlfimath);
            obj.countReg1=fi(0,0,bitWidth,0,hdlfimath);
            obj.sampCount=fi(0,0,bitWidth,0,hdlfimath);
            obj.upCount=fi(0,0,bitWidth,0,hdlfimath);
            obj.CPLenSampled=fi(8,0,bitWidth,0,hdlfimath);
            obj.CPLenSampled1=fi(8,0,bitWidth,0,hdlfimath);
            obj.CPLenSampled2=fi(8,0,bitWidth,0,hdlfimath);
            obj.CPPlusVec=fi(8,0,bitWidth,0,hdlfimath);
            obj.CPReg=fi(8,0,bitWidth,0,hdlfimath);
            obj.FFTLenSampled=fi(64,0,bitWidth,0,hdlfimath);
            obj.FFTReg=fi(64,0,bitWidth,0,hdlfimath);
            obj.FFTReg1=fi(64,0,bitWidth,0,hdlfimath);
            obj.FFTReg2=fi(64,0,bitWidth,0,hdlfimath);
            obj.FFTReg3=fi(64,0,bitWidth,0,hdlfimath);
            obj.FFTPlusCP=fi(obj.MaxFFTLength,0,bitWidth,0,hdlfimath);
            obj.dataOutReg=cast(zeros(length(dIn),1),'like',dIn);
            obj.dataOut=cast(zeros(length(dIn),1),'like',dIn);
            obj.dataInReg=cast(zeros(length(dIn),1),'like',dIn);
            obj.dataInReg2=cast(zeros(length(dIn),1),'like',dIn);
            obj.dataReg=cast(zeros(length(dIn),1),'like',dIn);
            obj.dataInReg1=cast(zeros(length(dIn),1),'like',dIn);
            obj.validOut=false;
            obj.validOutReg=false;
            obj.validOutReg1=false;
            obj.validOutReg2=false;
            obj.validOutReg3=false;
            obj.validInReg=false;
            obj.validInReg1=false;
            obj.validInReg2=false;
            obj.validInReg3=false;
            obj.maxFFT=fi(64,0,bitWidth,0,hdlfimath);
            obj.upFac=fi(0,0,bitWidth,0,hdlfimath);
            obj.upFacMinVec=fi(1,0,bitWidth,0,hdlfimath);
            obj.upFacReg=fi(0,0,bitWidth,0,hdlfimath);
            obj.idx2=fi(0,0,bitWidth,0);

            obj.storedIdx=fi(1:length(dIn),0,bitWidth,0,hdlfimath);
            obj.FFTLengthOut=cast(64,'like',varargin{3});
            obj.CPLengthOut=cast(6,'like',varargin{4});
            obj.cpLen=cast(6,'like',varargin{4});

            obj.resetSig=false;
            obj.filledVecCnt=fi(0,0,bitWidth,0,hdlfimath);

            if obj.Windowing
                obj.winLenIn=fi(1,0,bitWidth,0,hdlfimath);
                obj.WinLenSampled=fi(1,0,bitWidth,0,hdlfimath);
                obj.WinLenSampled1=fi(1,0,bitWidth,0,hdlfimath);
                obj.WinLenSampled2=fi(1,0,bitWidth,0,hdlfimath);
                obj.winLenOut=fi(1,0,bitWidth,0,hdlfimath);
            end
        end

        function resetImpl(obj)

            maxBits=log2(obj.MaxFFTLength);
            dIn=zeros(length(obj.dataInReg),1);
            if maxBits<6
                bitWidth=8;
            else
                bitWidth=maxBits+1;
            end
            obj.buffer(:)=zeros(length(dIn),1);
            obj.inCount=fi(0,0,bitWidth,0,hdlfimath);
            obj.outCount=fi(0,0,bitWidth,0,hdlfimath);
            obj.count=fi(0,0,bitWidth,0,hdlfimath);
            obj.countReg=fi(0,0,bitWidth,0,hdlfimath);
            obj.countReg1=fi(0,0,bitWidth,0,hdlfimath);
            obj.sampCount=fi(0,0,bitWidth,0,hdlfimath);
            obj.upCount=fi(0,0,bitWidth,0,hdlfimath);
            obj.CPLenSampled=fi(8,0,bitWidth,0,hdlfimath);
            obj.CPLenSampled1=fi(8,0,bitWidth,0,hdlfimath);
            obj.CPLenSampled2=fi(8,0,bitWidth,0,hdlfimath);
            obj.CPPlusVec=fi(8,0,bitWidth,0,hdlfimath);
            obj.CPReg=fi(8,0,bitWidth,0,hdlfimath);
            obj.FFTLenSampled=fi(16,0,bitWidth,0,hdlfimath);
            obj.FFTReg=fi(16,0,bitWidth,0,hdlfimath);
            obj.FFTReg1=fi(16,0,bitWidth,0,hdlfimath);
            obj.FFTReg2=fi(16,0,bitWidth,0,hdlfimath);
            obj.FFTReg3=fi(16,0,bitWidth,0,hdlfimath);
            obj.FFTPlusCP=fi(obj.MaxFFTLength,0,bitWidth,0,hdlfimath);
            obj.dataOutReg(:)=zeros(length(dIn),1);
            obj.dataOut(:)=zeros(length(dIn),1);
            obj.dataInReg(:)=zeros(length(dIn),1);
            obj.dataInReg2(:)=zeros(length(dIn),1);
            obj.dataReg(:)=zeros(length(dIn),1);
            obj.dataInReg1(:)=zeros(length(dIn),1);
            obj.validOut=false;
            obj.validOutReg=false;
            obj.validOutReg1=false;
            obj.validOutReg2=false;
            obj.validOutReg3=false;
            obj.validInReg=false;
            obj.validInReg1=false;
            obj.validInReg2=false;
            obj.validInReg3=false;
            obj.maxFFT=fi(64,0,bitWidth,0,hdlfimath);
            obj.upFac=fi(0,0,bitWidth,0,hdlfimath);
            obj.upFacReg=fi(0,0,bitWidth,0,hdlfimath);
            obj.upFacMinVec=fi(1,0,bitWidth,0,hdlfimath);
            obj.idx2=fi(0,0,bitWidth,0);
            obj.FFTLengthOut(:)=64;
            obj.CPLengthOut(:)=6;
            obj.cpLen(:)=6;
            obj.resetSig=false;
            if obj.Windowing
                obj.winLenIn(:)=1;
                obj.WinLenSampled(:)=1;
                obj.WinLenSampled1(:)=1;
                obj.WinLenSampled2(:)=1;
                obj.winLenOut(:)=1;
            end
        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=cast(obj.dataOut,'like',varargin{1});
            varargout{2}=obj.validOut;
            varargout{3}=obj.FFTLengthOut;
            varargout{4}=obj.CPLengthOut;
            if obj.Windowing
                varargout{5}=obj.winLenOut;
            end
        end

        function updateImpl(obj,varargin)







            if~obj.Normalize
                if obj.FFTReg3==obj.MaxFFTLength
                    obj.dataOut(:)=obj.buffer;
                else
                    for ind=1:obj.vecLen
                        obj.dataOut(ind)=bitsra(obj.buffer(ind),obj.countReg1);
                    end
                end
            else
                obj.dataOut(:)=obj.buffer;
            end
            obj.validOut=obj.validOutReg;

            obj.validOutReg1=obj.validOutReg;






            obj.upFacMinVec(:)=obj.upFac-obj.vecLen;
            const1=fi(1,0,log2(obj.MaxFFTLength)+1,0,hdlfimath);
            obj.upFacReg(:)=obj.upFac;
            obj.FFTReg2(:)=obj.FFTReg1;
            obj.CPLenSampled1(:)=obj.CPLenSampled;
            if obj.Windowing
                obj.WinLenSampled1(:)=obj.WinLenSampled;
            end
            if(obj.sampCount==0)&&obj.validInReg
                obj.CPLenSampled(:)=obj.cpLen;
                if obj.Windowing
                    obj.WinLenSampled(:)=obj.winLenIn;
                end
                obj.FFTReg1(:)=obj.FFTReg;
                obj.upFac(:)=bitshift(const1,obj.count);
            end



            if obj.upCount==0
                obj.idx2(:)=0;
            end

            if obj.validInReg1

                if obj.upFacReg<obj.vecLen



                    for idx1=0:(obj.vecLen-1)



                        temp=bitsll(idx1,obj.countReg);
                        if temp<obj.vecLen
                            obj.buffer(obj.storedIdx(idx1+1))=obj.dataInReg(temp+1);
                            obj.filledVecCnt(:)=obj.storedIdx(idx1+1);
                        end

                    end

                    if obj.filledVecCnt==obj.vecLen
                        obj.filledVecCnt(:)=0;
                        obj.validOutReg=true;
                    else
                        obj.validOutReg=false;
                    end
                else

                    if obj.upCount==0




                        obj.buffer(obj.inCount+1)=obj.dataInReg(1);
                        if obj.inCount==obj.vecLen-1
                            obj.inCount(:)=0;
                            obj.validOutReg=true;
                        else
                            obj.inCount(:)=obj.inCount+1;
                            obj.validOutReg=false;
                        end
                        obj.idx2(:)=obj.idx2+obj.upFacReg;
                    else
                        obj.validOutReg=false;
                    end
                end
            else
                obj.validOutReg=false;
            end

            obj.storedIdx(:)=(1:(obj.vecLen))+obj.filledVecCnt;



            if obj.validInReg
                if obj.sampCount==obj.MaxFFTLength-obj.vecLen
                    obj.sampCount(:)=0;
                else
                    obj.sampCount(:)=obj.sampCount+obj.vecLen;
                end
            end

            if obj.validInReg1



                if obj.upFacReg>=obj.vecLen
                    if obj.upCount==(obj.upFacMinVec)||obj.upFacReg==1
                        obj.upCount(:)=0;
                    else
                        obj.upCount(:)=obj.upCount+obj.vecLen;
                    end
                else
                    obj.upCount(:)=0;
                end
            end




            obj.FFTLengthOut(:)=obj.FFTReg3;
            obj.CPLengthOut(:)=obj.CPLenSampled2;
            if obj.Windowing
                obj.winLenOut(:)=obj.WinLenSampled2;
            end
            if obj.validOutReg
                if obj.outCount==0
                    obj.FFTReg3(:)=obj.FFTReg2;
                    obj.CPLenSampled2(:)=obj.CPLenSampled1;
                    if obj.Windowing
                        obj.WinLenSampled2(:)=obj.WinLenSampled1;
                    end
                end
            end
            obj.FFTLenSampled(:)=obj.FFTReg2-obj.vecLen;
            if obj.validOutReg
                if obj.outCount==obj.FFTLenSampled
                    obj.outCount(:)=0;
                else
                    obj.outCount(:)=obj.outCount+obj.vecLen;
                end
            end




            obj.validInReg2=obj.validInReg1;
            obj.validInReg1=obj.validInReg;


            obj.dataInReg(:)=obj.dataReg;
            obj.dataReg(:)=varargin{1};
            obj.validInReg=varargin{2};
            obj.FFTReg(:)=varargin{3};
            obj.cpLen(:)=varargin{4};

            obj.countReg1(:)=obj.countReg;
            obj.countReg(:)=obj.count;
            for ind=1:log2(obj.MaxFFTLength)
                if obj.FFTArr(ind)==obj.FFTReg
                    obj.count(:)=obj.diffBits(ind);
                end
            end

            if obj.Windowing
                obj.winLenIn(:)=varargin{5};

                if obj.resetPort
                    obj.resetSig=varargin{6};
                end
            else

                if obj.resetPort
                    obj.resetSig=varargin{5};
                end
            end
            ifResetTrue(obj);
        end


        function ifResetTrue(obj)
            if obj.resetSig
                resetImpl(obj);
            end
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.dataIn=obj.dataIn;
                s.validIn=obj.validIn;
                s.dataOut=obj.dataOut;
                s.validOut=obj.validOut;
                s.FFTLengthOut=obj.FFTLengthOut;
                s.CPLengthOut=obj.CPLengthOut;
                s.winLenOut=obj.winLenOut;
                s.cpLen=obj.cpLen;
                s.winLenIn=obj.winLenIn;
                s.CPLenSampled=obj.CPLenSampled;
                s.CPLenSampled1=obj.CPLenSampled1;
                s.CPLenSampled2=obj.CPLenSampled2;
                s.WinLenSampled=obj.WinLenSampled;
                s.WinLenSampled1=obj.WinLenSampled1;
                s.WinLenSampled2=obj.WinLenSampled2;
                s.resetSig=obj.resetSig;
                s.buffer=obj.buffer;
                s.inCount=obj.inCount;
                s.outCount=obj.outCount;
                s.count=obj.count;
                s.countReg=obj.countReg;
                s.countReg1=obj.countReg1;
                s.sampCount=obj.sampCount;
                s.upCount=obj.upCount;
                s.CPPlusVec=obj.CPPlusVec;
                s.CPReg=obj.CPReg;
                s.FFTLenSampled=obj.FFTLenSampled;
                s.FFTReg=obj.FFTReg;
                s.FFTReg1=obj.FFTReg1;
                s.FFTReg2=obj.FFTReg2;
                s.FFTReg3=obj.FFTReg3;
                s.FFTPlusCP=obj.FFTPlusCP;
                s.dataOutReg=obj.dataOutReg;
                s.dataInReg=obj.dataInReg;
                s.dataInReg2=obj.dataInReg2;
                s.dataReg=obj.dataReg;
                s.dataInReg1=obj.dataInReg1;
                s.validOutReg=obj.validOutReg;
                s.validOutReg1=obj.validOutReg1;
                s.validOutReg2=obj.validOutReg2;
                s.validOutReg3=obj.validOutReg3;
                s.validInReg=obj.validInReg;
                s.validInReg1=obj.validInReg1;
                s.validInReg2=obj.validInReg2;
                s.validInReg3=obj.validInReg3;
                s.maxFFT=obj.maxFFT;
                s.maxFFTPlusCP=obj.maxFFTPlusCP;
                s.upFac=obj.upFac;
                s.upFacMinVec=obj.upFacMinVec;
                s.upFacReg=obj.upFacReg;
                s.idx2=obj.idx2;
                s.vecLen=obj.vecLen;
                s.FFTArr=obj.FFTArr;
                s.diffBits=obj.diffBits;
                s.storedIdx=obj.storedIdx;
                s.filledVecCnt=obj.filledVecCnt;
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
