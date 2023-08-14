classdef(StrictDefaults)CPRemoval_stage2<matlab.System




%#codegen
%#ok<*EMCLS>



    properties(Nontunable)
        OFDMSrc='Property';
        MaxFFTLength=64;
        FFTLength=64;
        CPLength=16;
        LGaurdSub=6;
        RGaurdSub=5;
        CPFractionVal=0.55;
    end

    properties(Constant,Hidden)
        OFDMSrcSet=matlab.system.StringSet({...
        'Property','Input port'});
    end

    properties(Nontunable)
        resetPort(1,1)logical=false;
    end

    properties(Nontunable,Access=private)
vecLen
    end

    properties(Access=private)

        idx1;
        idx2;
        flag;
        flag1;
        validInReg;
        validInReg1;
        diff;
        idxpos;
        inCount;
        count;
        inCountReg;
        outCount;
        actOutCount;
        rdAddr;
        FFTLenReg;
        CPLenReg;
        FFTSampled;
        CPSampled;
        CPSampled1;
        LGSampled;
        RGSampled;
FFTSampledOut
CPSampledOut
        FFTLenMVecLen;
        FFTLenMVecLen1;
        hRAM1;
        hRAM2;
        dataOutReg;
        dataOutCrs;
        dataInReg;
        dataInReg1;
        dataInReg2;
        dataRAM1;
        dataRAM2;
        dataRead;
        firstDataEnd1;
        firstDataEnd2;
        switchRAM;
        switchRAMReg;
        readRAM1;
        readRAM1Reg;
        validOutReg;
        validOutReg1;
        validOutReg2;
        validOutCrs;
        storedValid;
        ctrl;
        resetSig;
        FFTLengthOutReg;
        LGaurdOutReg;
        RGaurdOutReg;
        LGaurdSubReg;
        RGaurdSubReg;
        FFTLengthReg;
        CPLengthReg;
        dataOut;
        validOut;
        wrEn1;
        wrEn2;
        readFirstVec;
    end


    methods


        function obj=CPRemoval_stage2(varargin)
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
            if~strcmpi(obj.OFDMSrc,'Property')
                props=[props,{'FFTLength'},{'CPLength'},{'LGaurdSub'},{'RGaurdSub'}];
            end
            flag=ismember(prop,props);
        end


        function num=getNumInputsImpl(obj)

            if obj.resetPort
                rPort=1;
            else
                rPort=0;
            end
            if strcmpi(obj.OFDMSrc,'Input port')
                oPort=4;
            else
                oPort=1;
            end
            num=2+rPort+oPort;

        end



        function num=getNumOutputsImpl(obj)
            if strcmpi(obj.OFDMSrc,'Input port')
                num=5;
            else
                num=2;
            end
        end


        function setupImpl(obj,varargin)

            bitWidth=log2(obj.MaxFFTLength)+1;
            obj.vecLen=fi(length(varargin{1}),0,bitWidth,0,hdlfimath);
            VL=length(varargin{1});
            obj.dataInReg=cast(zeros(VL,1),'like',varargin{1});
            obj.dataInReg1=cast(zeros(VL,1),'like',varargin{1});
            obj.dataInReg2=cast(zeros(VL,1),'like',varargin{1});
            obj.dataOutCrs=cast(zeros(VL,1),'like',varargin{1});
            obj.dataRAM1=cast(zeros(VL,1),'like',varargin{1});
            obj.dataRAM2=cast(zeros(VL,1),'like',varargin{1});
            obj.firstDataEnd1=cast(zeros(VL,1),'like',varargin{1});
            obj.firstDataEnd2=cast(zeros(VL,1),'like',varargin{1});
            obj.dataRead=cast(zeros(VL,1),'like',varargin{1});
            obj.dataOutReg=cast(zeros(VL,1),'like',varargin{1});
            obj.hRAM1=hdl.RAM('RAMType','Simple Dual port');
            obj.hRAM2=hdl.RAM('RAMType','Simple Dual port');
            obj.validInReg=false;
            obj.validInReg1=false;
            obj.FFTLenReg=fi(obj.MaxFFTLength,0,bitWidth,0,hdlfimath);
            obj.FFTSampled=fi(obj.MaxFFTLength,0,bitWidth,0,hdlfimath);
            obj.FFTSampledOut=fi(obj.MaxFFTLength,0,bitWidth,0,hdlfimath);
            obj.FFTLenMVecLen=fi(obj.MaxFFTLength,0,bitWidth,0,hdlfimath);
            obj.FFTLenMVecLen1=fi(obj.MaxFFTLength,0,bitWidth,0,hdlfimath);
            obj.CPLenReg=fi(4,0,bitWidth,0,hdlfimath);
            obj.CPSampled=fi(4,0,bitWidth,0,hdlfimath);
            obj.CPSampled1=fi(4,0,bitWidth,0,hdlfimath);
            obj.CPSampledOut=fi(4,0,bitWidth,0,hdlfimath);
            obj.LGSampled=fi(6,0,bitWidth,0,hdlfimath);
            obj.RGSampled=fi(5,0,bitWidth,0,hdlfimath);
            obj.inCount=fi(0,0,log2(obj.MaxFFTLength),0,hdlfimath);
            obj.inCountReg=fi(0,0,log2(obj.MaxFFTLength),0,hdlfimath);
            obj.outCount=fi(0,0,bitWidth,0,hdlfimath);
            obj.actOutCount=fi(0,0,bitWidth,0,hdlfimath);
            obj.count=fi(0,0,bitWidth,0,hdlfimath);
            obj.validOutReg=false;
            obj.validOutReg1=false;
            obj.validOutReg2=false;
            obj.idxpos=fi(VL,0,bitWidth,0,hdlfimath);
            obj.idx1=fi(0,0,bitWidth,0,hdlfimath);
            obj.idx2=fi(0,0,bitWidth,0,hdlfimath);
            obj.rdAddr=fi(0,0,log2(obj.MaxFFTLength),0,hdlfimath);
            obj.diff=fi(0,0,bitWidth,0,hdlfimath);
            obj.flag=false;
            obj.flag1=false;
            obj.dataOut=cast(zeros(VL,1),'like',varargin{1});
            obj.validOut=false;
            obj.resetSig=false;
            obj.switchRAM=false;
            obj.switchRAMReg=false;
            obj.readRAM1=false;
            obj.readRAM1Reg=false;
            obj.storedValid=false;
            obj.ctrl=false;
            obj.wrEn1=false;
            obj.wrEn2=false;
            obj.LGaurdSubReg=fi(6,0,bitWidth,0);
            obj.RGaurdSubReg=fi(5,0,bitWidth,0);
            obj.validOutCrs=false;
            obj.readFirstVec=false;
            if strcmp(obj.OFDMSrc,'Input port')
                obj.FFTLengthReg=fi(64,0,bitWidth,0);
                obj.CPLengthReg=fi(16,0,bitWidth,0);
                obj.LGaurdOutReg=fi(6,0,bitWidth,0);
                obj.RGaurdOutReg=fi(6,0,bitWidth,0);
                obj.FFTLengthOutReg=fi(64,0,bitWidth,0);
            end
        end


        function resetImpl(obj)

            obj.dataInReg(:)=0;
            obj.dataInReg1(:)=0;
            obj.dataInReg2(:)=0;
            obj.dataRead(:)=0;
            obj.dataRAM1(:)=0;
            obj.dataRAM2(:)=0;
            obj.dataRead(:)=0;
            obj.firstDataEnd1(:)=0;
            obj.firstDataEnd2(:)=0;
            obj.validInReg=false;
            obj.validInReg1=false;
            obj.FFTLenReg(:)=obj.MaxFFTLength;
            obj.FFTSampled(:)=obj.MaxFFTLength;
            obj.FFTSampledOut(:)=obj.MaxFFTLength;
            obj.FFTLenMVecLen(:)=obj.MaxFFTLength;
            obj.FFTLenMVecLen1(:)=obj.MaxFFTLength;
            obj.CPLenReg(:)=4;
            obj.CPSampled(:)=4;
            obj.CPSampled1(:)=4;
            obj.LGSampled(:)=6;
            obj.RGSampled(:)=5;
            obj.CPSampledOut(:)=4;
            obj.inCount(:)=0;
            obj.inCountReg(:)=0;
            obj.outCount(:)=0;
            obj.count(:)=0;
            obj.actOutCount(:)=0;
            obj.rdAddr(:)=0;
            obj.dataOutReg(:)=0;
            obj.dataOutCrs(:)=0;
            obj.validOutReg=false;
            obj.validOutReg1=false;
            obj.validOutReg2=false;
            obj.idxpos(:)=0;
            obj.idx1(:)=0;
            obj.idx2(:)=0;
            obj.diff(:)=obj.vecLen;
            obj.flag=false;
            obj.flag1=false;
            obj.dataOut(:)=0;
            obj.validOut=false;
            obj.resetSig=false;
            obj.switchRAM=false;
            obj.switchRAMReg=false;
            obj.readRAM1=false;
            obj.readRAM1Reg=false;
            obj.storedValid=false;
            obj.ctrl=false;
            obj.wrEn1=false;
            obj.wrEn2=false;
            obj.LGaurdSubReg(:)=6;
            obj.RGaurdSubReg(:)=5;
            obj.validOutCrs=false;
            obj.readFirstVec=false;
            if strcmp(obj.OFDMSrc,'Input port')
                obj.FFTLengthReg(:)=64;
                obj.CPLengthReg(:)=16;
                obj.LGaurdOutReg(:)=6;
                obj.RGaurdOutReg(:)=6;
                obj.FFTLengthOutReg(:)=64;
            end
        end

        function varargout=isInputDirectFeedthroughImpl(~,varargin)

            varargout{1}=false;
            varargout{2}=true;
            varargout{3}=true;
            varargout{4}=true;
            varargout{5}=true;
            varargout{6}=true;
            varargout{7}=true;
        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.dataOut;
            varargout{2}=obj.validOut;
            if strcmp(obj.OFDMSrc,'Input port')
                varargout{3}=obj.FFTLengthOutReg;
                varargout{4}=obj.LGaurdOutReg;
                varargout{5}=obj.RGaurdOutReg;
            end
        end


        function updateImpl(obj,varargin)

            if obj.diff<obj.vecLen
                obj.idxpos(:)=obj.vecLen-obj.diff;
            end

            if obj.CPSampled<=obj.FFTLenMVecLen1
                if obj.validInReg1
                    if obj.inCount>=obj.CPSampled
                        obj.flag=true;
                        obj.rdAddr(:)=obj.inCountReg;
                    end
                else
                    obj.flag=false;
                end
                if obj.inCount>=obj.CPSampled
                    obj.diff(:)=obj.inCount-obj.CPSampled;



                end
            else
                if obj.validInReg1
                    if obj.inCountReg==obj.FFTLenMVecLen
                        obj.flag=true;
                        obj.rdAddr(:)=obj.inCountReg;
                    end
                else
                    obj.flag=false;
                end

                obj.diff(:)=obj.FFTSampled-obj.CPSampled;
            end

            if~obj.switchRAM
                obj.wrEn1=obj.validInReg;
                obj.wrEn2=false;
            else
                obj.wrEn1=false;
                obj.wrEn2=obj.validInReg;
            end

            if obj.FFTSampled==obj.vecLen
                obj.idxpos(:)=obj.CPSampled;
            end

            if obj.CPSampledOut==0
                obj.idxpos(:)=0;
            end

            if xor(obj.switchRAMReg,obj.switchRAM)
                obj.flag1=true;
            end

            obj.dataRAM1(:)=obj.hRAM1(obj.dataInReg,obj.inCount,obj.wrEn1,obj.rdAddr);
            obj.dataRAM2(:)=obj.hRAM2(obj.dataInReg,obj.inCount,obj.wrEn2,obj.rdAddr);

            if obj.readRAM1Reg
                obj.dataRead(:)=obj.dataRAM2;
            else
                obj.dataRead(:)=obj.dataRAM1;
            end

            obj.switchRAMReg=obj.switchRAM;


            if obj.validInReg
                if obj.inCount==0
                    obj.FFTSampled(:)=obj.FFTLenReg;
                    obj.CPSampled(:)=obj.CPLenReg;
                    obj.LGSampled(:)=obj.LGaurdSubReg;
                    obj.RGSampled(:)=obj.RGaurdSubReg;
                end
            end

            obj.FFTLenMVecLen1(:)=obj.FFTSampled-obj.vecLen;

            obj.inCountReg(:)=obj.inCount;
            if obj.validInReg
                if obj.inCount==obj.FFTLenMVecLen1
                    obj.inCount(:)=0;
                    obj.switchRAM=~obj.switchRAM;
                else
                    obj.inCount(:)=obj.inCount+obj.vecLen;
                end
            end

            obj.validOutReg1=obj.validOutReg;
            obj.validOutReg=obj.flag||obj.flag1;

            obj.readRAM1Reg=obj.readRAM1;
            if obj.flag||obj.flag1
                if obj.outCount==obj.FFTLenMVecLen
                    obj.outCount(:)=0;
                    obj.readRAM1=~obj.readRAM1;
                    obj.flag=false;
                    obj.flag1=false;
                    obj.rdAddr(:)=0;
                else
                    obj.outCount(:)=obj.outCount+obj.vecLen;
                end
            end
            if obj.flag||obj.flag1
                if obj.rdAddr==obj.FFTLenMVecLen
                    obj.rdAddr(:)=0;
                else
                    obj.rdAddr(:)=obj.rdAddr+obj.vecLen;
                end
            end

            if obj.FFTSampledOut==obj.vecLen
                obj.validOutReg2=obj.validOutCrs;
            else
                obj.validOutReg2=obj.storedValid&&obj.validOutReg1;
                if obj.validOutReg1
                    obj.storedValid=true;
                end
            end


            obj.dataOutCrs=obj.dataRead;
            obj.validOutCrs=obj.validOutReg1;

            if obj.FFTSampledOut~=obj.vecLen
                if(obj.actOutCount)==obj.FFTLenMVecLen
                    obj.validOutReg2=true;
                end
            end

            if obj.validOutReg2
                if obj.actOutCount==obj.FFTLenMVecLen
                    obj.actOutCount(:)=0;
                    obj.readFirstVec=~obj.readFirstVec;
                else
                    obj.actOutCount(:)=obj.actOutCount+obj.vecLen;
                end
            end

            if obj.validOutCrs&&obj.count==0
                if obj.readRAM1Reg
                    obj.firstDataEnd2(:)=obj.dataOutCrs;
                else
                    obj.firstDataEnd1(:)=obj.dataOutCrs;
                end
            end

            if obj.validOutCrs
                if obj.count==obj.FFTLenMVecLen
                    obj.count(:)=0;
                    obj.storedValid=false;
                else
                    obj.count(:)=obj.count+obj.vecLen;
                end
            end

            obj.dataInReg2(:)=obj.dataInReg1;
            if obj.validOutCrs
                obj.dataInReg1(:)=obj.dataOutCrs;
            end

            if obj.FFTSampledOut~=obj.vecLen
                if(obj.actOutCount==0&&obj.validOutReg2)
                    if obj.readFirstVec
                        obj.dataInReg1(:)=obj.firstDataEnd1;
                    else
                        obj.dataInReg1(:)=obj.firstDataEnd2;
                    end
                end
            end


            for ii=0:(obj.vecLen-1)
                obj.idx1(:)=obj.idxpos+ii;
                obj.idx2(:)=obj.idx1-obj.vecLen;
                if(obj.idx1<(obj.vecLen))
                    obj.dataOutReg(ii+1)=obj.dataInReg2(obj.idx1+1);
                else
                    obj.dataOutReg(ii+1)=obj.dataInReg1(obj.idx2+1);
                end
            end

            if(obj.actOutCount==0&&obj.validOutReg2)
                obj.dataInReg1(:)=obj.dataOutCrs;
            end


            if obj.actOutCount==0
                obj.FFTSampledOut(:)=obj.FFTSampled;
                obj.CPSampledOut(:)=obj.CPSampled;

                obj.FFTLengthOutReg(:)=obj.FFTSampledOut;
                obj.LGaurdOutReg(:)=obj.LGSampled;
                obj.RGaurdOutReg(:)=obj.RGSampled;
            end
            obj.FFTLenMVecLen(:)=obj.FFTSampledOut-obj.vecLen;


            obj.dataOut(:)=obj.dataOutReg;
            obj.validOut=obj.validOutReg2;

            obj.validInReg1=obj.validInReg;
            obj.validInReg=varargin{2};
            obj.dataInReg(:)=varargin{1};


            if strcmp(obj.OFDMSrc,'Input port')
                obj.FFTLenReg(:)=varargin{3};
                obj.CPLenReg(:)=varargin{4};
                obj.LGaurdSubReg(:)=varargin{5};
                obj.RGaurdSubReg(:)=varargin{6};
            else
                obj.CPLenReg(:)=varargin{3};
            end


            if obj.resetPort
                if strcmp(obj.OFDMSrc,'Input port')
                    obj.resetSig=varargin{7};
                else
                    obj.resetSig=varargin{4};
                end
            end
            if obj.resetPort
                ifResetTrue(obj);
            end
        end

        function ifResetTrue(obj)
            if obj.resetSig
                resetImpl(obj);
            end
        end


        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.idx1=obj.idx1;
                s.idx2=obj.idx2;
                s.flag=obj.flag;
                s.flag1=obj.flag1;
                s.validInReg=obj.validInReg;
                s.validInReg1=obj.validInReg1;
                s.diff=obj.diff;
                s.idxpos=obj.idxpos;
                s.inCount=obj.inCount;
                s.count=obj.count;
                s.inCountReg=obj.inCountReg;
                s.outCount=obj.outCount;
                s.actOutCount=obj.actOutCount;
                s.rdAddr=obj.rdAddr;
                s.vecLen=obj.vecLen;
                s.FFTLenReg=obj.FFTLenReg;
                s.CPLenReg=obj.CPLenReg;
                s.FFTSampled=obj.FFTSampled;
                s.FFTSampledOut=obj.FFTSampledOut;
                s.CPSampledOut=obj.CPSampledOut;
                s.CPSampled=obj.CPSampled;
                s.CPSampled1=obj.CPSampled1;
                s.FFTLenMVecLen=obj.FFTLenMVecLen;
                s.hRAM1=obj.hRAM1;
                s.hRAM2=obj.hRAM2;
                s.dataOutReg=obj.dataOutReg;
                s.dataOutCrs=obj.dataOutCrs;
                s.dataInReg=obj.dataInReg;
                s.dataInReg1=obj.dataInReg1;
                s.dataInReg2=obj.dataInReg2;
                s.dataRAM1=obj.dataRAM1;
                s.dataRAM2=obj.dataRAM2;
                s.dataRead=obj.dataRead;
                s.firstDataEnd1=obj.firstDataEnd1;
                s.firstDataEnd2=obj.firstDataEnd2;
                s.switchRAM=obj.switchRAM;
                s.switchRAMReg=obj.switchRAMReg;
                s.readRAM1=obj.readRAM1;
                s.readRAM1Reg=obj.readRAM1Reg;
                s.validOutReg=obj.validOutReg;
                s.validOutReg1=obj.validOutReg1;
                s.validOutReg2=obj.validOutReg2;
                s.validOutCrs=obj.validOutCrs;
                s.storedValid=obj.storedValid;
                s.ctrl=obj.ctrl;
                s.resetSig=obj.resetSig;
                s.FFTLengthOutReg=obj.FFTLengthOutReg;
                s.LGaurdOutReg=obj.LGaurdOutReg;
                s.RGaurdOutReg=obj.RGaurdOutReg;
                s.LGaurdSubReg=obj.LGaurdSubReg;
                s.RGaurdSubReg=obj.RGaurdSubReg;
                s.FFTLengthReg=obj.FFTLengthReg;
                s.CPLengthReg=obj.CPLengthReg;
                s.dataOut=obj.dataOut;
                s.validOut=obj.validOut;
                s.wrEn1=obj.wrEn1;
                s.wrEn2=obj.wrEn2;
                s.readFirstVec=obj.readFirstVec;
                s.LGSampled=obj.LGSampled;
                s.RGSampled=obj.RGSampled;
                s.FFTLenMVecLen1=obj.FFTLenMVecLen1;
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

