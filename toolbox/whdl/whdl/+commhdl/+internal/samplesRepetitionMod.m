classdef(StrictDefaults)samplesRepetitionMod<matlab.System




%#codegen
%#ok<*EMCLS>



    properties(Nontunable)

        MaxFFTLength=2048;
        MaxWinLength=8;

        ResetInputPort(1,1)logical=false;
        Windowing(1,1)logical=false;
    end
    properties(Nontunable,Access=private)
        wordLength;
        vecLength;
        VLBits;
        addrBitWidth;
    end

    properties(Access=private)
dataOut
        dataOutReg;
dataOutReg1
validOut
        validOutReg;
validOutReg1
validOutReg2

wrEn1
wrEn2
wrEn1Vec
wrEn2Vec
inCount
validInReg
validInReg1
prevFFTLength
currFFTLength
        FFTLenReg;
outCount
rdAddr1
rdAddr2
rdAddr1Vec
rdAddr2Vec
rdAddr1Reg
rdAddr2Reg
wrAddr1
wrAddr2
wrAddr1Vec
wrAddr2Vec
startRead1
startRead2
strtRd1Reg
strtRd2Reg
strtRd1Reg1
strtRd2Reg1
sym1Done
sym2Done
flag
ctrl
dataOutRAM1
dataOutRAM2
hRAM1
hRAM2
dataInReg
dataInReg1
FFTLengthReg
CPLengthReg


FFTLengthRegOut
CPLengthRegOut
resetSig

winLenReg
winLengthReg
winLengthRegOut
    end


    methods


        function obj=samplesRepetitionMod(varargin)
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


        function num=getNumInputsImpl(obj)
            rPort=0;
            if obj.ResetInputPort
                rPort=1;
            end
            if obj.Windowing
                oPort=3;
            else
                oPort=2;
            end
            num=2+rPort+oPort;
        end



        function num=getNumOutputsImpl(obj)
            num=4;
            if obj.Windowing
                num=5;
            end
        end




        function setupImpl(obj,varargin)
            maxFFT=obj.MaxFFTLength;
            vecLen=length(varargin{1});
            obj.VLBits=log2(vecLen);
            bitWidth=log2(obj.MaxFFTLength)+1;
            obj.addrBitWidth=bitWidth-obj.VLBits+1;
            obj.vecLength=fi(vecLen,0,bitWidth,0,hdlfimath);
            obj.dataOut=cast(zeros(vecLen,1),'like',varargin{1});
            obj.dataOutReg=cast(zeros(vecLen,1),'like',varargin{1});
            obj.dataOutReg1=cast(zeros(vecLen,1),'like',varargin{1});
            obj.validOut=false;
            obj.validOutReg=false;
            obj.validOutReg1=false;
            obj.validOutReg2=false;
            obj.inCount=fi(0,0,bitWidth,0,hdlfimath);
            obj.wrEn1=false;
            obj.wrEn2=false;
            obj.wrEn1Vec=false(vecLen,1);
            obj.wrEn2Vec=false(vecLen,1);
            obj.validInReg=false;
            obj.validInReg1=false;
            obj.prevFFTLength=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.currFFTLength=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.FFTLenReg=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.outCount=fi(0,0,bitWidth,0,hdlfimath);
            obj.rdAddr1=fi(0,0,obj.addrBitWidth,0,hdlfimath);
            obj.rdAddr2=fi(0,0,obj.addrBitWidth,0,hdlfimath);
            obj.rdAddr1Vec=fi(zeros(vecLen,1),0,obj.addrBitWidth,0,hdlfimath);
            obj.rdAddr2Vec=fi(zeros(vecLen,1),0,obj.addrBitWidth,0,hdlfimath);
            obj.rdAddr1Reg=fi(0,0,obj.addrBitWidth,0,hdlfimath);
            obj.rdAddr2Reg=fi(0,0,obj.addrBitWidth,0,hdlfimath);
            obj.wrAddr1=fi(0,0,obj.addrBitWidth,0,hdlfimath);
            obj.wrAddr2=fi(0,0,obj.addrBitWidth,0,hdlfimath);
            obj.wrAddr1Vec=fi(zeros(vecLen,1),0,obj.addrBitWidth,0,hdlfimath);
            obj.wrAddr2Vec=fi(zeros(vecLen,1),0,obj.addrBitWidth,0,hdlfimath);
            obj.startRead1=false;
            obj.startRead2=false;
            obj.strtRd1Reg=false;
            obj.strtRd2Reg=false;
            obj.strtRd1Reg1=false;
            obj.strtRd2Reg1=false;
            obj.sym1Done=false;
            obj.sym2Done=false;
            obj.flag=false;
            obj.ctrl=false;
            obj.dataOutRAM1=cast(zeros(vecLen,1),'like',varargin{1});
            obj.dataOutRAM2=cast(zeros(vecLen,1),'like',varargin{1});
            obj.hRAM1=hdl.RAM('RAMType','Simple Dual port');
            obj.hRAM2=hdl.RAM('RAMType','Simple Dual port');
            obj.dataInReg=cast(zeros(vecLen,1),'like',varargin{1});
            obj.dataInReg1=cast(zeros(vecLen,1),'like',varargin{1});
            obj.FFTLengthReg=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.CPLengthReg=fi(16,0,bitWidth,0,hdlfimath);

            obj.FFTLengthRegOut=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.CPLengthRegOut=fi(16,0,bitWidth,0,hdlfimath);

            obj.resetSig=false;
            if obj.Windowing
                obj.winLenReg=fi(0,0,bitWidth,0,hdlfimath);
                obj.winLengthReg=fi(0,0,bitWidth,0,hdlfimath);
                obj.winLengthRegOut=fi(0,0,bitWidth,0,hdlfimath);
            end
        end


        function resetImpl(obj)
            maxFFT=obj.MaxFFTLength;
            vecLen=length(obj.dataInReg);
            bitWidth=log2(obj.MaxFFTLength)+1;
            obj.vecLength=fi(vecLen,0,bitWidth,0,hdlfimath);
            obj.dataOut(:)=zeros(vecLen,1);
            obj.dataOutReg(:)=zeros(vecLen,1);
            obj.dataOutReg1(:)=zeros(vecLen,1);
            obj.validOut=false;
            obj.validOutReg=false;
            obj.validOutReg1=false;
            obj.validOutReg2=false;
            obj.inCount=fi(0,0,bitWidth,0,hdlfimath);
            obj.wrEn1=false;
            obj.wrEn2=false;
            obj.wrEn1Vec=false(vecLen,1);
            obj.wrEn2Vec=false(vecLen,1);
            obj.validInReg=false;
            obj.validInReg1=false;
            obj.prevFFTLength=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.currFFTLength=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.FFTLenReg=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.outCount=fi(0,0,bitWidth,0,hdlfimath);
            obj.rdAddr1(:)=0;
            obj.rdAddr2(:)=0;
            obj.rdAddr1Vec(:)=0;
            obj.rdAddr2Vec(:)=0;
            obj.rdAddr1Reg(:)=0;
            obj.rdAddr2Reg(:)=0;
            obj.wrAddr1(:)=0;
            obj.wrAddr2(:)=0;
            obj.wrAddr1Vec(:)=0;
            obj.wrAddr2Vec(:)=0;
            obj.startRead1=false;
            obj.startRead2=false;
            obj.strtRd1Reg=false;
            obj.strtRd2Reg=false;
            obj.strtRd1Reg1=false;
            obj.strtRd2Reg1=false;
            obj.sym1Done=false;
            obj.sym2Done=false;
            obj.flag=false;
            obj.ctrl=false;
            obj.dataOutRAM1(:)=zeros(vecLen,1);
            obj.dataOutRAM2(:)=zeros(vecLen,1);
            obj.dataInReg(:)=zeros(vecLen,1);
            obj.dataInReg1(:)=zeros(vecLen,1);
            obj.FFTLengthReg=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.CPLengthReg=fi(16,0,bitWidth,0,hdlfimath);

            obj.FFTLengthRegOut=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.CPLengthRegOut=fi(16,0,bitWidth,0,hdlfimath);

            obj.resetSig=false;
            if obj.Windowing
                obj.winLenReg(:)=0;
                obj.winLengthReg(:)=0;
                obj.winLengthRegOut(:)=0;
            end
        end


        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.dataOut;
            varargout{2}=obj.validOut;
            varargout{3}=obj.FFTLengthRegOut;
            varargout{4}=obj.CPLengthRegOut;
            if obj.Windowing
                varargout{5}=obj.winLengthRegOut;
            end
        end


        function ifResetTrue(obj)
            if obj.resetSig
                resetImpl(obj);
            end
        end

        function updateImpl(obj,varargin)



            obj.dataOut(:)=obj.dataOutReg;

            obj.dataOutReg1(:)=obj.dataOutReg;



            obj.validOut(:)=obj.validOutReg2;
            obj.validOutReg2=obj.validOutReg1;
            obj.validOutReg1=obj.validOutReg;



            for ind=1:length(varargin{1})
                obj.wrAddr1Vec(ind)=obj.wrAddr1;
                obj.rdAddr1Vec(ind)=obj.rdAddr1;
                obj.wrEn1Vec(ind)=obj.wrEn1;
                obj.wrAddr2Vec(ind)=obj.wrAddr2;
                obj.rdAddr2Vec(ind)=obj.rdAddr2;
                obj.wrEn2Vec(ind)=obj.wrEn2;
            end


            obj.dataOutRAM1(:)=obj.hRAM1(obj.dataInReg1,obj.wrAddr1Vec,obj.wrEn1Vec,obj.rdAddr1Vec);
            obj.dataOutRAM2(:)=obj.hRAM2(obj.dataInReg1,obj.wrAddr2Vec,obj.wrEn2Vec,obj.rdAddr2Vec);







            if obj.strtRd1Reg1&&~obj.strtRd2Reg1
                obj.dataOutReg(:)=obj.dataOutRAM1;
            elseif~obj.strtRd1Reg1&&obj.strtRd2Reg1
                obj.dataOutReg(:)=obj.dataOutRAM2;
            else
                obj.dataOutReg(:)=0;
            end




            obj.strtRd1Reg1(:)=obj.strtRd1Reg;
            obj.strtRd2Reg1(:)=obj.strtRd2Reg;



            obj.strtRd1Reg(:)=obj.startRead1;
            obj.strtRd2Reg(:)=obj.startRead2;









            if obj.startRead1&&~obj.startRead2
                if obj.rdAddr1==bitsra(obj.prevFFTLength,obj.VLBits)
                    obj.rdAddr1(:)=0;
                else
                    obj.rdAddr1(:)=obj.rdAddr1+1;
                end
                if obj.outCount==obj.MaxFFTLength-obj.vecLength
                    obj.outCount(:)=0;
                    obj.startRead1=false;
                else
                    obj.outCount(:)=obj.outCount+obj.vecLength;
                end
                obj.validOutReg(:)=true;
            elseif obj.startRead2&&~obj.startRead1
                if obj.rdAddr2==bitsra(obj.prevFFTLength,obj.VLBits)
                    obj.rdAddr2(:)=0;
                else
                    obj.rdAddr2(:)=obj.rdAddr2+1;
                end
                if obj.outCount==obj.MaxFFTLength-obj.vecLength
                    obj.outCount(:)=0;
                    obj.startRead2=false;
                else
                    obj.outCount(:)=obj.outCount+obj.vecLength;
                end
                obj.validOutReg(:)=true;
            else
                obj.validOutReg(:)=false;
            end


            obj.rdAddr1Reg(:)=obj.rdAddr1;
            obj.rdAddr2Reg(:)=obj.rdAddr2;



            if obj.inCount==0&&obj.outCount==0
                obj.rdAddr1(:)=0;
                obj.rdAddr2(:)=0;
                obj.prevFFTLength(:)=obj.currFFTLength;
                obj.FFTLengthRegOut(:)=obj.FFTLengthReg;
                obj.CPLengthRegOut(:)=obj.CPLengthReg;
                if obj.Windowing
                    obj.winLengthRegOut(:)=obj.winLengthReg;
                end
            end





            if obj.sym1Done
                if obj.startRead2
                    obj.startRead1=false;
                else
                    obj.startRead1=true;
                    obj.sym1Done=false;
                end
            end
            if obj.sym2Done
                if obj.startRead1
                    obj.startRead2=false;
                else
                    obj.startRead2=true;
                    obj.sym2Done=false;
                end
            end










            if obj.FFTLenReg~=obj.vecLength
                obj.ctrl=obj.validInReg;
                obj.wrEn1=obj.validInReg&&~obj.flag;
                obj.wrEn2=obj.validInReg&&obj.flag;
            end








            if obj.flag
                if obj.ctrl
                    if obj.inCount==obj.currFFTLength
                        obj.wrAddr2(:)=0;
                        obj.flag=false;
                        obj.sym2Done=true;
                    else
                        obj.wrAddr2(:)=obj.wrAddr2+1;
                    end
                end
            else
                if obj.ctrl
                    if obj.inCount==obj.currFFTLength
                        obj.wrAddr1(:)=0;
                        obj.flag=true;
                        obj.sym1Done=true;
                    else
                        obj.wrAddr1(:)=obj.wrAddr1+1;
                    end
                end
            end



            if obj.inCount==0&&obj.validInReg
                obj.currFFTLength(:)=obj.FFTLenReg-obj.vecLength;
                obj.FFTLengthReg(:)=obj.FFTLenReg;
                obj.CPLengthReg(:)=varargin{4};
                if obj.Windowing
                    obj.winLengthReg(:)=obj.winLenReg;
                end
            end





            if obj.validInReg
                if obj.inCount==obj.currFFTLength
                    obj.inCount(:)=0;
                else
                    obj.inCount(:)=obj.inCount+obj.vecLength;
                end
            end


            obj.validInReg1(:)=obj.validInReg;
            obj.dataInReg1(:)=obj.dataInReg;
            obj.dataInReg(:)=varargin{1};
            obj.validInReg(:)=varargin{2};
            obj.FFTLenReg(:)=varargin{3};
            if obj.Windowing
                obj.winLenReg(:)=varargin{5};
                if obj.ResetInputPort
                    obj.resetSig=varargin{6};
                end
            else
                if obj.ResetInputPort
                    obj.resetSig=varargin{5};
                end
            end



            ifResetTrue(obj);
        end



        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end


        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.dataOut=obj.dataOut;
                s.dataOutReg=obj.dataOutReg;
                s.validOut=obj.validOut;
                s.validOutReg=obj.validOutReg;
                s.validOutReg1=obj.validOutReg1;
                s.validOutReg2=obj.validOutReg2;
                s.wrEn1=obj.wrEn1;
                s.wrEn2=obj.wrEn2;
                s.wrEn1Vec=obj.wrEn1Vec;
                s.wrEn2Vec=obj.wrEn2Vec;
                s.inCount=obj.inCount;
                s.validInReg=obj.validInReg;
                s.validInReg1=obj.validInReg1;
                s.prevFFTLength=obj.prevFFTLength;
                s.currFFTLength=obj.currFFTLength;
                s.FFTLenReg=obj.FFTLenReg;
                s.outCount=obj.outCount;
                s.rdAddr1=obj.rdAddr1;
                s.rdAddr2=obj.rdAddr2;
                s.rdAddr1Vec=obj.rdAddr1Vec;
                s.rdAddr2Vec=obj.rdAddr2Vec;
                s.rdAddr1Reg=obj.rdAddr1Reg;
                s.rdAddr2Reg=obj.rdAddr2Reg;
                s.wrAddr1=obj.wrAddr1;
                s.wrAddr2=obj.wrAddr2;
                s.wrAddr1Vec=obj.wrAddr1Vec;
                s.wrAddr2Vec=obj.wrAddr2Vec;
                s.startRead1=obj.startRead1;
                s.startRead2=obj.startRead2;
                s.strtRd1Reg=obj.strtRd1Reg;
                s.strtRd2Reg=obj.strtRd2Reg;
                s.strtRd1Reg1=obj.strtRd1Reg1;
                s.strtRd2Reg1=obj.strtRd2Reg1;
                s.sym1Done=obj.sym1Done;
                s.sym2Done=obj.sym2Done;
                s.flag=obj.flag;
                s.dataOutRAM1=obj.dataOutRAM1;
                s.dataOutRAM2=obj.dataOutRAM2;
                s.hRAM1=obj.hRAM1;
                s.hRAM2=obj.hRAM2;
                s.dataInReg=obj.dataInReg;
                s.dataInReg1=obj.dataInReg1;
                s.FFTLengthReg=obj.FFTLengthReg;
                s.CPLengthReg=obj.CPLengthReg;
                s.resetSig=obj.resetSig;
                s.vecLength=obj.vecLength;
                s.wordLength=obj.wordLength;
                s.CPLengthRegOut=obj.CPLengthRegOut;
                s.FFTLengthRegOut=obj.FFTLengthRegOut;
                s.winLenReg=obj.winLenReg;
                s.winLengthReg=obj.winLengthReg;
                s.winLengthRegOut=obj.winLengthRegOut;
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

