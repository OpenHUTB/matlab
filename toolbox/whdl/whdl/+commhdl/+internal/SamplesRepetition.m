classdef(StrictDefaults)SamplesRepetition<matlab.System




%#codegen
%#ok<*EMCLS>



    properties(Nontunable)

        MaxFFTLength=2048;


        resetPort(1,1)logical=false;
    end
    properties(Nontunable,Access=private)
        wordLength;
vecLength
    end

    properties(Access=private)
dataOut
        dataOutReg;
dataOutReg1
validOut
        validOutReg;
validOutReg1
validOutReg2
validOutReg3
wrEn1
wrEn2
inCount
validInReg
validInReg1
prevFFTLength
currFFTLength
currFFTLenReg
        FFTLenReg;
        FFTLenReg1;
        FFTLenReg2;
        FFTLenReg3;
        FFTLenReg4;
        LGaurdReg;
        RGaurdReg;
outCount
rdAddr1
rdAddr2
wrAddr1
wrAddr2
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
LGaurdSubReg
RGaurdSubReg
FFTLengthRegOut
LGaurdSubRegOut
RGaurdSubRegOut
FFTLengthReg1
LGaurdSubReg1
RGaurdSubReg1
FFTLengthReg2
LGaurdSubReg2
RGaurdSubReg2
FFTLengthReg3
LGaurdSubReg3
RGaurdSubReg3
resetSig
    end


    methods


        function obj=SamplesRepetition(varargin)
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
            if obj.resetPort
                rPort=1;
            end
            oPort=3;
            num=2+rPort+oPort;
        end



        function num=getNumOutputsImpl(~)
            num=5;
        end



        function setupImpl(obj,varargin)
            maxFFT=obj.MaxFFTLength;
            vecLen=length(varargin{1});
            bitWidth=log2(obj.MaxFFTLength)+1;
            addrWidth=log2(obj.MaxFFTLength);
            obj.vecLength=fi(vecLen,0,bitWidth,0,hdlfimath);
            obj.dataOut=cast(zeros(vecLen,1),'like',varargin{1});
            obj.dataOutReg=cast(zeros(vecLen,1),'like',varargin{1});
            obj.dataOutReg1=cast(zeros(vecLen,1),'like',varargin{1});
            obj.validOut=false;
            obj.validOutReg=false;
            obj.validOutReg1=false;
            obj.validOutReg2=false;
            obj.validOutReg3=false;
            obj.inCount=fi(0,0,bitWidth,0,hdlfimath);
            obj.wrEn1=false;
            obj.wrEn2=false;
            obj.validInReg=false;
            obj.validInReg1=false;
            obj.prevFFTLength=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.currFFTLength=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.currFFTLenReg=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.FFTLenReg=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.FFTLenReg1=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.FFTLenReg2=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.FFTLenReg3=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.FFTLenReg4=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.outCount=fi(0,0,bitWidth,0,hdlfimath);
            obj.rdAddr1=fi(0,0,addrWidth,0,hdlfimath);
            obj.rdAddr2=fi(0,0,addrWidth,0,hdlfimath);
            obj.wrAddr1=fi(0,0,addrWidth,0,hdlfimath);
            obj.wrAddr2=fi(0,0,addrWidth,0,hdlfimath);
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
            obj.LGaurdSubReg=fi(6,0,bitWidth,0,hdlfimath);
            obj.RGaurdSubReg=fi(5,0,bitWidth,0,hdlfimath);
            obj.RGaurdReg=fi(5,0,bitWidth,0,hdlfimath);
            obj.LGaurdReg=fi(6,0,bitWidth,0,hdlfimath);
            obj.FFTLengthRegOut=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.LGaurdSubRegOut=fi(6,0,bitWidth,0,hdlfimath);
            obj.RGaurdSubRegOut=fi(5,0,bitWidth,0,hdlfimath);
            obj.FFTLengthReg1=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.LGaurdSubReg1=fi(6,0,bitWidth,0,hdlfimath);
            obj.RGaurdSubReg1=fi(5,0,bitWidth,0,hdlfimath);
            obj.FFTLengthReg2=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.LGaurdSubReg2=fi(6,0,bitWidth,0,hdlfimath);
            obj.RGaurdSubReg2=fi(5,0,bitWidth,0,hdlfimath);
            obj.FFTLengthReg3=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.LGaurdSubReg3=fi(6,0,bitWidth,0,hdlfimath);
            obj.RGaurdSubReg3=fi(5,0,bitWidth,0,hdlfimath);
            obj.resetSig=false;
        end


        function resetImpl(obj)
            maxFFT=obj.MaxFFTLength;
            vecLen=length(obj.dataInReg);
            bitWidth=log2(obj.MaxFFTLength)+1;
            addrWidth=log2(obj.MaxFFTLength);
            obj.vecLength=fi(vecLen,0,bitWidth,0,hdlfimath);
            obj.dataOut(:)=0;
            obj.dataOutReg(:)=0;
            obj.dataOutReg1(:)=0;
            obj.validOut=false;
            obj.validOutReg=false;
            obj.validOutReg1=false;
            obj.validOutReg2=false;
            obj.validOutReg3=false;
            obj.inCount=fi(0,0,bitWidth,0,hdlfimath);
            obj.wrEn1=false;
            obj.wrEn2=false;
            obj.validInReg=false;
            obj.validInReg1=false;
            obj.prevFFTLength=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.currFFTLength=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.currFFTLenReg=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.FFTLenReg=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.FFTLenReg1=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.FFTLenReg2=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.FFTLenReg3=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.FFTLenReg4=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.outCount=fi(0,0,bitWidth,0,hdlfimath);
            obj.rdAddr1=fi(0,0,addrWidth,0,hdlfimath);
            obj.rdAddr2=fi(0,0,addrWidth,0,hdlfimath);
            obj.wrAddr1=fi(0,0,addrWidth,0,hdlfimath);
            obj.wrAddr2=fi(0,0,addrWidth,0,hdlfimath);
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
            obj.dataOutRAM1(:)=0;
            obj.dataOutRAM2(:)=0;
            obj.dataInReg(:)=0;
            obj.dataInReg1(:)=0;
            obj.FFTLengthReg=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.LGaurdSubReg=fi(6,0,bitWidth,0,hdlfimath);
            obj.RGaurdReg=fi(5,0,bitWidth,0,hdlfimath);
            obj.LGaurdReg=fi(6,0,bitWidth,0,hdlfimath);
            obj.RGaurdSubReg=fi(5,0,bitWidth,0,hdlfimath);
            obj.FFTLengthRegOut=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.LGaurdSubRegOut=fi(6,0,bitWidth,0,hdlfimath);
            obj.RGaurdSubRegOut=fi(5,0,bitWidth,0,hdlfimath);
            obj.FFTLengthReg1=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.LGaurdSubReg1=fi(6,0,bitWidth,0,hdlfimath);
            obj.RGaurdSubReg1=fi(5,0,bitWidth,0,hdlfimath);
            obj.FFTLengthReg2=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.LGaurdSubReg2=fi(6,0,bitWidth,0,hdlfimath);
            obj.RGaurdSubReg2=fi(5,0,bitWidth,0,hdlfimath);
            obj.FFTLengthReg3=fi(maxFFT,0,bitWidth,0,hdlfimath);
            obj.LGaurdSubReg3=fi(6,0,bitWidth,0,hdlfimath);
            obj.RGaurdSubReg3=fi(5,0,bitWidth,0,hdlfimath);
            obj.resetSig=false;
        end


        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.dataOut;
            varargout{2}=obj.validOut;
            varargout{3}=obj.FFTLengthRegOut;
            varargout{4}=obj.LGaurdSubRegOut;
            varargout{5}=obj.RGaurdSubRegOut;
        end


        function ifResetTrue(obj)
            if obj.resetSig
                resetImpl(obj);
            end
        end

        function updateImpl(obj,varargin)








            obj.dataOut(:)=obj.dataOutReg1;
            obj.validOut(:)=obj.validOutReg3;

            obj.dataOutReg1(:)=obj.dataOutReg;



            obj.validOutReg3=obj.validOutReg2;
            obj.validOutReg2=obj.validOutReg1;
            obj.validOutReg1=obj.validOutReg;









            obj.dataOutRAM1(:)=obj.hRAM1(obj.dataInReg1,obj.wrAddr1,obj.wrEn1,obj.rdAddr1);
            obj.dataOutRAM2(:)=obj.hRAM2(obj.dataInReg1,obj.wrAddr2,obj.wrEn2,obj.rdAddr2);




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
                if obj.rdAddr1==obj.prevFFTLength
                    obj.rdAddr1(:)=0;
                else
                    obj.rdAddr1(:)=obj.rdAddr1+obj.vecLength;
                end
                if obj.outCount==obj.MaxFFTLength-obj.vecLength
                    obj.outCount(:)=0;
                    obj.startRead1=false;
                else
                    obj.outCount(:)=obj.outCount+obj.vecLength;
                end
                obj.validOutReg(:)=true;
            elseif obj.startRead2&&~obj.startRead1
                if obj.rdAddr2==obj.prevFFTLength
                    obj.rdAddr2(:)=0;
                else
                    obj.rdAddr2(:)=obj.rdAddr2+obj.vecLength;
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

            obj.FFTLengthRegOut(:)=obj.FFTLengthReg3;
            obj.LGaurdSubRegOut(:)=obj.LGaurdSubReg3;
            obj.RGaurdSubRegOut(:)=obj.RGaurdSubReg3;

            obj.FFTLengthReg3(:)=obj.FFTLengthReg2;
            obj.LGaurdSubReg3(:)=obj.LGaurdSubReg2;
            obj.RGaurdSubReg3(:)=obj.RGaurdSubReg2;

            obj.FFTLengthReg2(:)=obj.FFTLengthReg1;
            obj.LGaurdSubReg2(:)=obj.LGaurdSubReg1;
            obj.RGaurdSubReg2(:)=obj.RGaurdSubReg1;




            obj.FFTLenReg4(:)=obj.FFTLenReg3;
            obj.FFTLenReg3(:)=obj.FFTLenReg2;
            obj.FFTLenReg2(:)=obj.FFTLenReg1;
            obj.FFTLenReg1(:)=obj.FFTLengthRegOut;
            if obj.inCount==0&&obj.outCount==0
                obj.rdAddr1(:)=0;
                obj.rdAddr2(:)=0;
                obj.prevFFTLength(:)=obj.currFFTLength;
                obj.FFTLengthReg1(:)=obj.FFTLengthReg;
                obj.LGaurdSubReg1(:)=obj.LGaurdSubReg;
                obj.RGaurdSubReg1(:)=obj.RGaurdSubReg;
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






            obj.ctrl=obj.validInReg;
            obj.wrEn1=obj.validInReg&&~obj.flag;
            obj.wrEn2=obj.validInReg&&obj.flag;









            if obj.inCount==0&&obj.validInReg
                obj.currFFTLength(:)=obj.FFTLenReg-obj.vecLength;
                obj.FFTLengthReg(:)=obj.FFTLenReg;
                obj.LGaurdSubReg(:)=obj.LGaurdReg;
                obj.RGaurdSubReg(:)=obj.RGaurdReg;
            end
            obj.currFFTLenReg(:)=obj.currFFTLength;







            if obj.flag
                if obj.ctrl
                    if obj.inCount==obj.currFFTLenReg
                        obj.wrAddr2(:)=0;
                        obj.flag=false;
                        obj.sym2Done=true;
                    else
                        obj.wrAddr2(:)=obj.wrAddr2+obj.vecLength;
                    end
                end
            else
                if obj.ctrl
                    if obj.inCount==obj.currFFTLenReg
                        obj.wrAddr1(:)=0;
                        obj.flag=true;
                        obj.sym1Done=true;
                    else
                        obj.wrAddr1(:)=obj.wrAddr1+obj.vecLength;
                    end
                end
            end




            if obj.validInReg
                if obj.inCount==obj.currFFTLenReg
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
            obj.LGaurdReg(:)=varargin{4};
            obj.RGaurdReg(:)=varargin{5};



            if obj.resetPort
                obj.resetSig=varargin{6};
            end
            ifResetTrue(obj);
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
                s.validOutReg3=obj.validOutReg3;
                s.wrEn1=obj.wrEn1;
                s.wrEn2=obj.wrEn2;
                s.inCount=obj.inCount;
                s.validInReg=obj.validInReg;
                s.validInReg1=obj.validInReg1;
                s.prevFFTLength=obj.prevFFTLength;
                s.currFFTLength=obj.currFFTLength;
                s.currFFTLenReg=obj.currFFTLenReg;
                s.FFTLenReg=obj.FFTLenReg;
                s.FFTLenReg1=obj.FFTLenReg1;
                s.FFTLenReg2=obj.FFTLenReg2;
                s.FFTLenReg3=obj.FFTLenReg3;
                s.FFTLenReg4=obj.FFTLenReg4;
                s.outCount=obj.outCount;
                s.rdAddr1=obj.rdAddr1;
                s.rdAddr2=obj.rdAddr2;
                s.wrAddr1=obj.wrAddr1;
                s.wrAddr2=obj.wrAddr2;
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
                s.LGaurdSubReg=obj.LGaurdSubReg;
                s.RGaurdSubReg=obj.RGaurdSubReg;
                s.resetSig=obj.resetSig;
                s.vecLength=obj.vecLength;
                s.ctrl=obj.ctrl;
                s.dataOutReg1=obj.dataOutReg1;
                s.FFTLengthRegOut=obj.FFTLengthRegOut;
                s.LGaurdSubRegOut=obj.LGaurdSubRegOut;
                s.RGaurdSubRegOut=obj.RGaurdSubRegOut;
                s.RGaurdReg=obj.RGaurdReg;
                s.LGaurdReg=obj.LGaurdReg;
                s.FFTLengthReg1=obj.FFTLengthReg1;
                s.LGaurdSubReg1=obj.LGaurdSubReg1;
                s.RGaurdSubReg1=obj.RGaurdSubReg1;
                s.FFTLengthReg2=obj.FFTLengthReg2;
                s.LGaurdSubReg2=obj.LGaurdSubReg2;
                s.RGaurdSubReg2=obj.RGaurdSubReg2;
                s.FFTLengthReg3=obj.FFTLengthReg3;
                s.LGaurdSubReg3=obj.LGaurdSubReg3;
                s.RGaurdSubReg3=obj.RGaurdSubReg3;
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

