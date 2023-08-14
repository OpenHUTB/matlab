classdef(StrictDefaults)CPRemoval_stage1<matlab.System




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
        vecLength;
        CPFraction1;
    end

    properties(Access=private)
        dataIn;
        validIn;
        dataOut;
        validOut;
        resetSig;
        FFTLength1;
        CPLength1;
        LGaurdSub1;
        RGaurdSub1;
        FFTLengthReg;
        CPLengthReg;
        LGaurdSubReg;
        RGaurdSubReg;
        FFTLengthRegOut;
        CPLengthRegOut;
        LGaurdSubRegOut;
        RGaurdSubRegOut;
        FFTLengthDelay1;
        FFTLengthDelay2;
        FFTLengthDelay3;
        CPLengthDelay1;
        CPLengthDelay2;
        CPLengthDelay3;
        LGaurdDelay1;
        LGaurdDelay2;
        LGaurdDelay3;
        RGaurdDelay1;
        RGaurdDelay2;
        RGaurdDelay3;
        loopIdx;
idx1
idx2
nextSymSamples
nextSymSamplesF
idxpos
idxposReg
idxposF
CPPlusVec
FCPPlusVec
sampCnt
sampCntReg
CPLenSampled
CPLenSmpld
CPShiftSmpl
CPReg
FFTPlusCP
FFTPlusCPF
FFTLenSampled
FFTPlusCPMinVec
FFTPlusCPFMinVec
FFTReg
dataOutReg
dataOutReg1
dataOutReg2
dataInReg
dataInReg2
dataInReg1
dataReg
validOutReg
validOutReg1
validOutReg2
validOutReg3
validOutReg4
validInReg
validInReg1
validInReg2
validInReg3
        validInReg4;
        ctrlSig;
    end


    methods


        function obj=CPRemoval_stage1(varargin)
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
            rPort=0;
            oPort=0;
            if obj.resetPort
                rPort=1;
            end
            if strcmpi(obj.OFDMSrc,'Input port')
                oPort=4;
            end
            num=2+rPort+oPort;

        end



        function num=getNumOutputsImpl(obj)
            if strcmpi(obj.OFDMSrc,'Input port')
                num=6;
            else
                num=3;
            end
        end



        function setupImpl(obj,varargin)
            vecLen=length(varargin{1});
            if log2(obj.MaxFFTLength)<6
                maxBits=8;
            else
                maxBits=log2(obj.MaxFFTLength)+2;
            end
            obj.vecLength=fi(length(varargin{1}),0,maxBits,0);
            obj.loopIdx=fi(0:(vecLen-1),0,maxBits,0,hdlfimath);
            obj.idx1=fi(0,0,maxBits,0,hdlfimath);
            obj.idx2=fi(0,0,maxBits,0,hdlfimath);
            obj.nextSymSamples=fi(obj.vecLength,0,maxBits,0,hdlfimath);
            obj.nextSymSamplesF=fi(obj.vecLength,0,maxBits,0,hdlfimath);
            obj.idxpos=fi(0,0,maxBits,0,hdlfimath);
            obj.idxposReg=fi(0,0,maxBits,0,hdlfimath);
            obj.idxposF=fi(0,0,maxBits,0,hdlfimath);
            obj.CPPlusVec=fi(vecLen,0,maxBits,0,hdlfimath);
            obj.FCPPlusVec=fi(vecLen,0,maxBits,0,hdlfimath);
            obj.sampCnt=fi(0,0,maxBits,0,hdlfimath);
            obj.sampCntReg=fi(0,0,maxBits,0,hdlfimath);
            if obj.CPFractionVal==0
                obj.CPLenSampled=fi(0,0,maxBits,0,hdlfimath);
            else
                obj.CPLenSampled=fi(vecLen,0,maxBits,0,hdlfimath);
            end
            obj.CPLenSmpld=fi(16,0,maxBits,0,hdlfimath);
            obj.CPShiftSmpl=fi(16,0,maxBits,0,hdlfimath);
            obj.CPReg=fi(16,0,maxBits,0,hdlfimath);
            obj.FFTPlusCP=fi(64,0,maxBits,0,hdlfimath);
            obj.FFTPlusCPF=fi(64,0,maxBits,0,hdlfimath);
            obj.FFTLenSampled=fi(obj.MaxFFTLength,0,maxBits,0,hdlfimath);
            obj.FFTPlusCPMinVec=fi(64,0,maxBits,0,hdlfimath);
            obj.FFTPlusCPFMinVec=fi(64,0,maxBits,0,hdlfimath);
            obj.FFTReg=fi(64,0,maxBits,0,hdlfimath);
            obj.dataOutReg=cast(zeros(vecLen,1),'like',varargin{1});
            obj.dataOutReg1=cast(zeros(vecLen,1),'like',varargin{1});
            obj.dataOutReg2=cast(zeros(vecLen,1),'like',varargin{1});
            obj.dataInReg=cast(zeros(vecLen,1),'like',varargin{1});
            obj.dataInReg2=cast(zeros(vecLen,1),'like',varargin{1});
            obj.dataInReg1=cast(zeros(vecLen,1),'like',varargin{1});
            obj.dataReg=cast(zeros(vecLen,1),'like',varargin{1});
            obj.validOutReg=false;
            obj.validOutReg1=false;
            obj.validOutReg2=false;
            obj.validOutReg3=false;
            obj.validOutReg4=false;
            obj.validInReg=false;
            obj.validInReg1=false;
            obj.validInReg2=false;
            obj.validInReg3=false;
            obj.validInReg4=false;
            obj.dataIn=cast(zeros(vecLen,1),'like',varargin{1});
            obj.validIn=false;
            obj.dataOut=cast(zeros(vecLen,1),'like',varargin{1});
            obj.validOut=false;
            obj.ctrlSig=false;
            obj.LGaurdSub1=fi(6,0,maxBits,0,hdlfimath);
            obj.RGaurdSub1=fi(5,0,maxBits,0,hdlfimath);
            obj.FFTLength1=fi(64,0,maxBits,0,hdlfimath);
            obj.CPLength1=fi(16,0,maxBits,0,hdlfimath);
            obj.LGaurdSubReg=fi(6,0,maxBits,0,hdlfimath);
            obj.RGaurdSubReg=fi(5,0,maxBits,0,hdlfimath);
            obj.FFTLengthReg=fi(64,0,maxBits,0,hdlfimath);
            obj.CPLengthReg=fi(16,0,maxBits,0,hdlfimath);
            obj.LGaurdSubRegOut=fi(6,0,maxBits,0,hdlfimath);
            obj.RGaurdSubRegOut=fi(5,0,maxBits,0,hdlfimath);
            obj.FFTLengthRegOut=fi(64,0,maxBits,0,hdlfimath);
            obj.CPLengthRegOut=fi(16,0,maxBits,0,hdlfimath);
            obj.FFTLengthDelay1=fi(64,0,maxBits,0,hdlfimath);
            obj.FFTLengthDelay2=fi(64,0,maxBits,0,hdlfimath);
            obj.FFTLengthDelay3=fi(64,0,maxBits,0,hdlfimath);
            obj.CPLengthDelay1=fi(16,0,maxBits,0,hdlfimath);
            obj.CPLengthDelay2=fi(16,0,maxBits,0,hdlfimath);
            obj.CPLengthDelay3=fi(16,0,maxBits,0,hdlfimath);
            obj.LGaurdDelay1=fi(6,0,maxBits,0,hdlfimath);
            obj.LGaurdDelay2=fi(6,0,maxBits,0,hdlfimath);
            obj.LGaurdDelay3=fi(6,0,maxBits,0,hdlfimath);
            obj.RGaurdDelay1=fi(5,0,maxBits,0,hdlfimath);
            obj.RGaurdDelay2=fi(5,0,maxBits,0,hdlfimath);
            obj.RGaurdDelay3=fi(5,0,maxBits,0,hdlfimath);
            obj.CPFraction1=fi(obj.CPFractionVal,0,16,14,hdlfimath);
            obj.resetSig=false;
        end


        function resetImpl(obj)
            vecLen=length(obj.dataIn);
            if log2(obj.MaxFFTLength)<6
                maxBits=8;
            else
                maxBits=log2(obj.MaxFFTLength)+2;
            end
            obj.dataIn(:)=(zeros(vecLen,1));
            obj.validIn=false;
            obj.dataOut(:)=(zeros(vecLen,1));
            obj.validOut=false;
            obj.resetSig=false;
            obj.LGaurdSub1(:)=6;
            obj.RGaurdSub1(:)=5;
            obj.FFTLength1(:)=64;
            obj.CPLength1(:)=16;
            obj.LGaurdSubReg(:)=6;
            obj.RGaurdSubReg(:)=5;
            obj.FFTLengthReg(:)=64;
            obj.CPLengthReg(:)=16;
            obj.FFTLengthDelay1(:)=64;
            obj.FFTLengthDelay2(:)=64;
            obj.FFTLengthDelay3(:)=64;
            obj.CPLengthDelay1(:)=16;
            obj.CPLengthDelay2(:)=16;
            obj.CPLengthDelay3(:)=16;
            obj.LGaurdDelay1(:)=6;
            obj.LGaurdDelay2(:)=6;
            obj.LGaurdDelay3(:)=6;
            obj.RGaurdDelay1(:)=5;
            obj.RGaurdDelay2(:)=5;
            obj.RGaurdDelay3(:)=5;
            obj.vecLength=fi(vecLen,0,maxBits,0);
            obj.loopIdx=fi(0:(vecLen-1),0,maxBits,0,hdlfimath);
            obj.idx1=fi(0,0,maxBits,0,hdlfimath);
            obj.idx2=fi(0,0,maxBits,0,hdlfimath);
            obj.nextSymSamples=fi(obj.vecLength,0,maxBits,0,hdlfimath);
            obj.nextSymSamplesF=fi(obj.vecLength,0,maxBits,0,hdlfimath);
            obj.idxpos=fi(0,0,maxBits,0,hdlfimath);
            obj.idxposReg=fi(0,0,maxBits,0,hdlfimath);
            obj.idxposF=fi(0,0,maxBits,0,hdlfimath);
            obj.CPPlusVec=fi(vecLen,0,maxBits,0,hdlfimath);
            obj.FCPPlusVec=fi(vecLen,0,maxBits,0,hdlfimath);
            obj.sampCnt=fi(0,0,maxBits,0,hdlfimath);
            obj.sampCntReg=fi(0,0,maxBits,0,hdlfimath);
            if obj.CPFractionVal==0
                obj.CPLenSampled=fi(0,0,maxBits,0,hdlfimath);
            else
                obj.CPLenSampled=fi(vecLen,0,maxBits,0,hdlfimath);
            end
            obj.CPLenSmpld=fi(16,0,maxBits,0,hdlfimath);
            obj.CPShiftSmpl=fi(16,0,maxBits,0,hdlfimath);
            obj.CPReg=fi(16,0,maxBits,0,hdlfimath);
            obj.FFTPlusCP=fi(64,0,maxBits,0,hdlfimath);
            obj.FFTPlusCPF=fi(64,0,maxBits,0,hdlfimath);
            obj.FFTLenSampled=fi(obj.MaxFFTLength,0,maxBits,0,hdlfimath);
            obj.FFTPlusCPMinVec=fi(64,0,maxBits,0,hdlfimath);
            obj.FFTPlusCPFMinVec=fi(64,0,maxBits,0,hdlfimath);
            obj.FFTReg=fi(64,0,maxBits,0,hdlfimath);
            obj.dataOutReg(:)=zeros(vecLen,1);
            obj.dataOutReg1(:)=zeros(vecLen,1);
            obj.dataOutReg2(:)=zeros(vecLen,1);
            obj.dataInReg(:)=zeros(vecLen,1);
            obj.dataInReg2(:)=zeros(vecLen,1);
            obj.dataInReg1(:)=zeros(vecLen,1);
            obj.dataReg(:)=zeros(vecLen,1);
            obj.validOutReg=false;
            obj.validOutReg1=false;
            obj.validOutReg2=false;
            obj.validOutReg3=false;
            obj.validOutReg4=false;
            obj.validInReg=false;
            obj.validInReg1=false;
            obj.validInReg2=false;
            obj.validInReg3=false;
            obj.validInReg4=false;
            obj.dataIn(:)=zeros(vecLen,1);
            obj.validIn=false;
            obj.dataOut(:)=zeros(vecLen,1);
            obj.validOut=false;
            obj.ctrlSig=false;
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
                varargout{3}=obj.FFTLengthReg;
                varargout{4}=obj.CPLengthReg;
                varargout{5}=obj.LGaurdSubRegOut;
                varargout{6}=obj.RGaurdSubRegOut;
            else
                varargout{3}=obj.CPLengthReg;
            end
        end


        function updateImpl(obj,varargin)

            obj.dataOut(:)=obj.dataOutReg2;
            obj.validOut=obj.validOutReg4;








            if obj.vecLength==1
                obj.validOutReg4=obj.validOutReg3;
                obj.dataOutReg2(:)=obj.dataOutReg1;
            else
                if obj.idxposReg==0
                    obj.dataOutReg2(:)=obj.dataOutReg;
                    obj.validOutReg4=obj.validOutReg2;
                else
                    obj.dataOutReg2(:)=obj.dataOutReg1;
                    obj.validOutReg4=obj.validOutReg2;
                end
            end
            obj.dataOutReg1(:)=obj.dataOutReg;


            if~obj.ctrlSig||obj.validInReg2
                for ii=(obj.loopIdx)

                    obj.idx1(:)=obj.idxpos+ii;
                    obj.idx2(:)=obj.idx1-obj.vecLength;
                    if(obj.idx1<(obj.vecLength))
                        obj.dataOutReg(ii+1)=obj.dataInReg2(obj.idx1+1);
                    else
                        obj.dataOutReg(ii+1)=obj.dataInReg1(obj.idx2+1);
                    end
                end
            end







            obj.idxposReg(:)=obj.idxpos;
            if obj.nextSymSamples<obj.vecLength
                obj.idxpos(:)=obj.nextSymSamples;
            end
            if obj.sampCntReg==0&&obj.idxpos~=0
                obj.idxpos(:)=obj.vecLength;
            end



            obj.dataInReg2(:)=obj.dataInReg1;
            obj.dataInReg1(:)=obj.dataInReg;


            obj.validOutReg3=obj.validOutReg2;
            obj.validOutReg2=obj.validOutReg1;
            obj.validOutReg1=obj.validOutReg&&obj.validInReg2;
            obj.validOutReg=(obj.sampCntReg>=obj.CPLenSampled)&&(obj.sampCntReg<obj.FFTPlusCPF);


            obj.FFTLengthReg(:)=obj.FFTLengthDelay3;
            obj.FFTLengthDelay3=obj.FFTLengthDelay2;
            obj.FFTLengthDelay2=obj.FFTLengthDelay1;
            obj.FFTLengthDelay1=obj.FFTLenSampled;


            obj.CPLengthReg(:)=obj.CPLengthDelay3;
            obj.CPLengthDelay3=obj.CPLengthDelay2;
            obj.CPLengthDelay2=obj.CPLengthDelay1;
            obj.CPLengthDelay1=obj.CPShiftSmpl;


            obj.LGaurdSubRegOut(:)=obj.LGaurdDelay3;
            obj.LGaurdDelay3=obj.LGaurdDelay2;
            obj.LGaurdDelay2=obj.LGaurdDelay1;
            obj.LGaurdDelay1=obj.LGaurdSubReg;


            obj.RGaurdSubRegOut(:)=obj.RGaurdDelay3;
            obj.RGaurdDelay3=obj.RGaurdDelay2;
            obj.RGaurdDelay2=obj.RGaurdDelay1;
            obj.RGaurdDelay1=obj.RGaurdSubReg;

            obj.CPShiftSmpl(:)=obj.CPLenSmpld-obj.CPLenSampled;
            obj.FFTPlusCPF(:)=obj.CPLenSampled+obj.FFTLenSampled;

            obj.FFTPlusCP(:)=obj.CPLenSmpld+obj.FFTLenSampled;
            obj.FFTPlusCPMinVec(:)=obj.FFTPlusCP-obj.vecLength;
            obj.FCPPlusVec(:)=obj.vecLength+obj.CPLenSmpld;
            obj.CPPlusVec(:)=obj.vecLength+obj.CPLenSampled;



            if(obj.sampCnt<obj.vecLength)&&(obj.validInReg)
                obj.CPLenSmpld(:)=obj.CPReg;
                obj.CPLenSampled(:)=obj.CPReg*obj.CPFraction1;
                obj.FFTLenSampled(:)=obj.FFTReg;
                obj.LGaurdSubReg(:)=obj.LGaurdSub1;
                obj.RGaurdSubReg(:)=obj.RGaurdSub1;
            end


            obj.nextSymSamples(:)=obj.CPPlusVec-obj.sampCnt;





            obj.nextSymSamplesF(:)=obj.FCPPlusVec-obj.sampCnt;
            if obj.nextSymSamplesF<obj.vecLength
                obj.idxposF(:)=obj.nextSymSamplesF;
            end


            if(obj.validInReg)
                obj.dataInReg(:)=obj.dataReg;
                if obj.idxpos~=0
                    obj.ctrlSig=~obj.ctrlSig;
                end
            end


            obj.sampCntReg(:)=obj.sampCnt;







            if(obj.validInReg)
                if obj.sampCnt>=obj.FFTPlusCPMinVec
                    if obj.sampCnt==obj.FFTPlusCPMinVec
                        obj.sampCnt(:)=0;
                    else
                        if obj.idxposF==0
                            obj.sampCnt(:)=0;
                        else
                            obj.sampCnt(:)=(obj.vecLength-obj.idxposF);

                        end
                    end
                    obj.ctrlSig=false;
                else
                    obj.sampCnt(:)=obj.sampCnt+obj.vecLength;
                end
            end


            obj.FFTPlusCPFMinVec(:)=obj.FFTPlusCPF-obj.vecLength;



            obj.validInReg4=obj.validInReg3;
            obj.validInReg3=obj.validInReg2;
            obj.validInReg2=obj.validInReg1;
            obj.validInReg1=obj.validInReg;


            obj.dataReg(:)=varargin{1};
            obj.validInReg=varargin{2};



            if strcmpi(obj.OFDMSrc,'Input port')
                obj.FFTReg(:)=varargin{3};
                obj.CPReg(:)=varargin{4};
                obj.LGaurdSub1(:)=varargin{5};
                obj.RGaurdSub1(:)=varargin{6};
            else
                obj.FFTReg(:)=obj.FFTLength;
                obj.CPReg(:)=obj.CPLength;
                obj.LGaurdSub1(:)=obj.LGaurdSub;
                obj.RGaurdSub1(:)=obj.RGaurdSub;
            end


            if obj.resetPort
                if strcmp(obj.OFDMSrc,'Input port')
                    obj.resetSig=varargin{7};
                else
                    obj.resetSig=varargin{3};
                end
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
                s.dataIn=obj.dataIn;
                s.validIn=obj.validIn;
                s.dataOut=obj.dataOut;
                s.validOut=obj.validOut;
                s.resetSig=obj.resetSig;
                s.FFTLength1=obj.FFTLength1;
                s.CPLength1=obj.CPLength1;
                s.LGaurdSub1=obj.LGaurdSub1;
                s.RGaurdSub1=obj.RGaurdSub1;
                s.FFTLengthReg=obj.FFTLengthReg;
                s.CPLengthReg=obj.CPLengthReg;
                s.LGaurdSubReg=obj.LGaurdSubReg;
                s.RGaurdSubReg=obj.RGaurdSubReg;
                s.FFTLengthRegOut=obj.FFTLengthRegOut;
                s.CPLengthRegOut=obj.CPLengthRegOut;
                s.LGaurdSubRegOut=obj.LGaurdSubRegOut;
                s.RGaurdSubRegOut=obj.RGaurdSubRegOut;
                s.FFTLengthDelay1=obj.FFTLengthDelay1;
                s.FFTLengthDelay2=obj.FFTLengthDelay2;
                s.FFTLengthDelay3=obj.FFTLengthDelay3;
                s.CPLengthDelay1=obj.CPLengthDelay1;
                s.CPLengthDelay2=obj.CPLengthDelay2;
                s.CPLengthDelay3=obj.CPLengthDelay3;
                s.LGaurdDelay1=obj.LGaurdDelay1;
                s.LGaurdDelay2=obj.LGaurdDelay2;
                s.LGaurdDelay3=obj.LGaurdDelay3;
                s.RGaurdDelay1=obj.RGaurdDelay1;
                s.RGaurdDelay2=obj.RGaurdDelay2;
                s.RGaurdDelay3=obj.RGaurdDelay3;
                s.loopIdx=obj.loopIdx;
                s.idx1=obj.idx1;
                s.idx2=obj.idx2;
                s.nextSymSamples=obj.nextSymSamples;
                s.idxpos=obj.idxpos;
                s.CPPlusVec=obj.CPPlusVec;
                s.sampCnt=obj.sampCnt;
                s.sampCntReg=obj.sampCntReg;
                s.CPLenSampled=obj.CPLenSampled;
                s.CPLenSmpld=obj.CPLenSmpld;
                s.CPShiftSmpl=obj.CPShiftSmpl;
                s.CPReg=obj.CPReg;
                s.FFTPlusCP=obj.FFTPlusCP;
                s.FFTPlusCPF=obj.FFTPlusCPF;
                s.FFTLenSampled=obj.FFTLenSampled;
                s.FFTPlusCPMinVec=obj.FFTPlusCPMinVec;
                s.FFTPlusCPFMinVec=obj.FFTPlusCPFMinVec;
                s.FFTReg=obj.FFTReg;
                s.dataOutReg=obj.dataOutReg;
                s.dataOutReg1=obj.dataOutReg1;
                s.dataOutReg2=obj.dataOutReg2;
                s.dataInReg=obj.dataInReg;
                s.dataInReg2=obj.dataInReg2;
                s.dataInReg1=obj.dataInReg1;
                s.dataReg=obj.dataReg;
                s.validOutReg=obj.validOutReg;
                s.validOutReg1=obj.validOutReg1;
                s.validOutReg2=obj.validOutReg2;
                s.validOutReg3=obj.validOutReg3;
                s.validOutReg4=obj.validOutReg4;
                s.validInReg=obj.validInReg;
                s.validInReg1=obj.validInReg1;
                s.validInReg2=obj.validInReg2;
                s.validInReg3=obj.validInReg3;
                s.validInReg4=obj.validInReg4;
                s.ctrlSig=obj.ctrlSig;
                s.vecLength=obj.vecLength;
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

