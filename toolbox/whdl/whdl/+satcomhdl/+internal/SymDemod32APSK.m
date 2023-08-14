classdef(StrictDefaults)SymDemod32APSK<matlab.System




%#codegen

%#ok<*EMCLS>

    properties(Nontunable)

        DecisionType='Approximate log-likelihood ratio';
    end

    properties(Constant,Hidden)
        DecisionTypeSet=matlab.system.StringSet({...
        'Hard','Approximate log-likelihood ratio'});
    end

    properties(Nontunable)

        UnitAvgPower(1,1)logical=false;
    end


    properties(Access=private)

        dataIn;
        validIn;
        dataInReal;
        dataInImag;
        lutIdx;


        sqroot2;
        one;
        twoCosPiBy8;
        twoCos3PiBy8;


        lut32;
        lut32N;
        circBound1;
        circBound2;


        angleY;
        magnitudeY;


        dataOut;
        validOut;


        hdlCMA32APSKObj;
        inpDataBGAng;

        piBy2;
        piValue;
        piBy6;
        twoPiBy6;
        fourPiBy6;
        fivePiBy6;

        piBy16;
        threePiBy16;
        fivePiBy16;
        sevenPiBy16;
        ninePiBy16;
        elevenPiBy16;
        thirteenPiBy16;
        fifteenPiBy16;
    end

    methods
        function obj=SymDemod32APSK(varargin)
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

        function numInpPorts=getNumInputsImpl(~)
            numInpPorts=4;
        end

        function numOutPorts=getNumOutputsImpl(~)
            numOutPorts=2;
        end

        function resetImpl(obj)

            obj.dataIn(:)=0;
            obj.validIn(:)=false;
            obj.validOut(:)=false;
            obj.dataInReal(:)=0;
            obj.dataInImag(:)=0;
            obj.lutIdx(:)=2;
            obj.dataOut(:)=0;
            obj.sqroot2(:)=sqrt(2);
            obj.one(:)=1;
            obj.twoCosPiBy8(:)=2*cos(pi/8);
            obj.twoCos3PiBy8(:)=2*cos(3*pi/8);

            g1=[2.84,2.72,2.64,2.54,2.53];
            g2=[5.27,4.87,4.64,4.33,4.30];
            constellation32APSK=cell(1,5);
            for countg=1:length(g1)
                constellation32APSK{countg}=[(1/g2(countg))*((1/sqrt(2))+1i*(1/sqrt(2))),...
                (1/g2(countg))*((-1/sqrt(2))+j*(1/sqrt(2))),...
                (1/g2(countg))*((-1/sqrt(2))-j*(1/sqrt(2))),...
                (1/g2(countg))*((1/sqrt(2))-j*(1/sqrt(2))),...
                (g1(countg)/g2(countg))*((sqrt(3)+1)+j*(sqrt(3)-1))/(2*sqrt(2)),...
                (g1(countg)/g2(countg))*((1/sqrt(2))+j*(1/sqrt(2))),...
                (g1(countg)/g2(countg))*((sqrt(3)-1)+j*(sqrt(3)+1))/(2*sqrt(2)),...
                (g1(countg)/g2(countg))*(-(sqrt(3)-1)+j*(sqrt(3)+1))/(2*sqrt(2)),...
                (g1(countg)/g2(countg))*(-(1/sqrt(2))+j*(1/sqrt(2))),...
                (g1(countg)/g2(countg))*(-(sqrt(3)+1)+j*(sqrt(3)-1))/(2*sqrt(2)),...
                (g1(countg)/g2(countg))*(-(sqrt(3)+1)-j*(sqrt(3)-1))/(2*sqrt(2)),...
                (g1(countg)/g2(countg))*(-(1/sqrt(2))-j*(1/sqrt(2))),...
                (g1(countg)/g2(countg))*(-(sqrt(3)-1)-j*(sqrt(3)+1))/(2*sqrt(2)),...
                (g1(countg)/g2(countg))*((sqrt(3)-1)-j*(sqrt(3)+1))/(2*sqrt(2)),...
                (g1(countg)/g2(countg))*((1/sqrt(2))-j*(1/sqrt(2))),...
                (g1(countg)/g2(countg))*((sqrt(3)+1)-j*(sqrt(3)-1))/(2*sqrt(2)),...
                1,...
                cos(pi/8)+j*sin(pi/8),...
                ((1/sqrt(2))+j*(1/sqrt(2))),...
                cos(3*pi/8)+j*sin(3*pi/8),...
                j,...
                -cos(3*pi/8)+j*sin(3*pi/8),...
                (-(1/sqrt(2))+j*(1/sqrt(2))),...
                -cos(pi/8)+j*sin(pi/8),...
                -1,...
                -cos(pi/8)-j*sin(pi/8),...
                (-(1/sqrt(2))-j*(1/sqrt(2))),...
                -cos(3*pi/8)-j*sin(3*pi/8),...
                -j,...
                cos(3*pi/8)-j*sin(3*pi/8),...
                ((1/sqrt(2))-j*(1/sqrt(2))),...
                cos(pi/8)-j*sin(pi/8)];
            end
            power32=zeros(1,length(g1));
            for countg=1:length(g1)
                power32(countg)=sqrt(mean(abs(constellation32APSK{countg}).^2));
            end
            if(strcmp(obj.DecisionType,'Approximate log-likelihood ratio'))
                obj.lut32(:)=[1./(g2).^2,sqrt(2)./g2,(g1./g2).^2,((sqrt(3)+1)*g1)./(sqrt(2)*g2),...
                ((sqrt(3)-1)*g1)./(sqrt(2)*g2),sqrt(2)*(g1./g2)];
                obj.lut32N(:)=[power32,1./(power32).^2];
            else
                obj.circBound1(:)=(1+g1)./(2*g2);
                obj.circBound2(:)=(g1+g2)./(2*g2);
                obj.magnitudeY(:)=0;
                obj.angleY(:)=0;
                reset(obj.hdlCMA32APSKObj);
                obj.inpDataBGAng(:)=0;
                obj.piBy2(:)=pi/2;
                obj.piValue(:)=pi;
                obj.piBy6(:)=pi/6;
                obj.twoPiBy6(:)=2*pi/6;
                obj.fourPiBy6(:)=4*pi/6;
                obj.fivePiBy6(:)=5*pi/6;

                obj.piBy16(:)=pi/16;
                obj.threePiBy16(:)=3*pi/16;
                obj.fivePiBy16(:)=5*pi/16;
                obj.sevenPiBy16(:)=7*pi/16;
                obj.ninePiBy16(:)=9*pi/16;
                obj.elevenPiBy16(:)=11*pi/16;
                obj.thirteenPiBy16(:)=13*pi/16;
                obj.fifteenPiBy16(:)=15*pi/16;
            end
        end

        function setupImpl(obj,varargin)

            dIn=varargin{1};


            obj.dataIn=cast(0,'like',varargin{1});
            obj.dataInReal=cast(0,'like',real(dIn));
            obj.dataInImag=cast(0,'like',real(dIn));
            obj.lutIdx=fi(2,0,3,0,hdlfimath);
            obj.validIn=false;


            g1=[2.84,2.72,2.64,2.54,2.53];
            g2=[5.27,4.87,4.64,4.33,4.30];
            constellation32APSK=cell(1,5);
            for countg=1:length(g1)
                constellation32APSK{countg}=[(1/g2(countg))*((1/sqrt(2))+1i*(1/sqrt(2))),...
                (1/g2(countg))*((-1/sqrt(2))+j*(1/sqrt(2))),...
                (1/g2(countg))*((-1/sqrt(2))-j*(1/sqrt(2))),...
                (1/g2(countg))*((1/sqrt(2))-j*(1/sqrt(2))),...
                (g1(countg)/g2(countg))*((sqrt(3)+1)+j*(sqrt(3)-1))/(2*sqrt(2)),...
                (g1(countg)/g2(countg))*((1/sqrt(2))+j*(1/sqrt(2))),...
                (g1(countg)/g2(countg))*((sqrt(3)-1)+j*(sqrt(3)+1))/(2*sqrt(2)),...
                (g1(countg)/g2(countg))*(-(sqrt(3)-1)+j*(sqrt(3)+1))/(2*sqrt(2)),...
                (g1(countg)/g2(countg))*(-(1/sqrt(2))+j*(1/sqrt(2))),...
                (g1(countg)/g2(countg))*(-(sqrt(3)+1)+j*(sqrt(3)-1))/(2*sqrt(2)),...
                (g1(countg)/g2(countg))*(-(sqrt(3)+1)-j*(sqrt(3)-1))/(2*sqrt(2)),...
                (g1(countg)/g2(countg))*(-(1/sqrt(2))-j*(1/sqrt(2))),...
                (g1(countg)/g2(countg))*(-(sqrt(3)-1)-j*(sqrt(3)+1))/(2*sqrt(2)),...
                (g1(countg)/g2(countg))*((sqrt(3)-1)-j*(sqrt(3)+1))/(2*sqrt(2)),...
                (g1(countg)/g2(countg))*((1/sqrt(2))-j*(1/sqrt(2))),...
                (g1(countg)/g2(countg))*((sqrt(3)+1)-j*(sqrt(3)-1))/(2*sqrt(2)),...
                1,...
                cos(pi/8)+j*sin(pi/8),...
                ((1/sqrt(2))+j*(1/sqrt(2))),...
                cos(3*pi/8)+j*sin(3*pi/8),...
                j,...
                -cos(3*pi/8)+j*sin(3*pi/8),...
                (-(1/sqrt(2))+j*(1/sqrt(2))),...
                -cos(pi/8)+j*sin(pi/8),...
                -1,...
                -cos(pi/8)-j*sin(pi/8),...
                (-(1/sqrt(2))-j*(1/sqrt(2))),...
                -cos(3*pi/8)-j*sin(3*pi/8),...
                -j,...
                cos(3*pi/8)-j*sin(3*pi/8),...
                ((1/sqrt(2))-j*(1/sqrt(2))),...
                cos(pi/8)-j*sin(pi/8)];
            end
            power32=zeros(1,length(g1));
            for countg=1:length(g1)
                power32(countg)=sqrt(mean(abs(constellation32APSK{countg}).^2));
            end

            if(strcmp(obj.DecisionType,'Approximate log-likelihood ratio'))
                if~isfloat(dIn)
                    bGWLMul=15;
                    bGWLAdd=4;
                    bGFLMul=14;
                    if isa(dIn,'int8')
                        inpData=fi(0,1,8,0);
                    elseif(isa(dIn,'int16'))
                        inpData=fi(0,1,16,0);
                    elseif(isa(dIn,'int32'))
                        inpData=fi(0,1,32,0);
                    else
                        inpData=dIn;
                    end

                    obj.sqroot2=fi(sqrt(2),0,bGWLMul,bGFLMul,hdlfimath);
                    obj.one=fi(1,0,bGWLMul,bGFLMul,hdlfimath);
                    obj.twoCosPiBy8=fi(2*cos(pi/8),0,bGWLMul,bGFLMul,hdlfimath);
                    obj.twoCos3PiBy8=fi(2*cos(3*pi/8),0,bGWLMul,bGFLMul,hdlfimath);


                    obj.lut32=fi([1./(g2).^2,sqrt(2)./g2,(g1./g2).^2,((sqrt(3)+1)*g1)./(sqrt(2)*g2),...
                    ((sqrt(3)-1)*g1)./(sqrt(2)*g2),sqrt(2)*(g1./g2)],0,bGWLMul,bGFLMul,hdlfimath);
                    obj.lut32N=fi([power32,1./(power32).^2],0,bGWLMul,bGFLMul,hdlfimath);

                    obj.dataOut=fi(zeros(5,1),1,inpData.WordLength+bGWLMul+bGWLAdd,inpData.FractionLength+bGFLMul,hdlfimath);
                else

                    obj.sqroot2=cast(sqrt(2),'like',real(dIn));
                    obj.one=cast(1,'like',real(dIn));
                    obj.twoCosPiBy8=cast(2*cos(pi/8),'like',real(dIn));
                    obj.twoCos3PiBy8=cast(2*cos(3*pi/8),'like',real(dIn));

                    obj.lut32=cast([1./(g2).^2,sqrt(2)./g2,(g1./g2).^2,((sqrt(3)+1)*g1)./(sqrt(2)*g2),...
                    ((sqrt(3)-1)*g1)./(sqrt(2)*g2),sqrt(2)*(g1./g2)],'like',real(dIn));
                    obj.lut32N=cast([power32,1./(power32).^2],'like',real(dIn));

                    obj.dataOut=cast(zeros(5,1),'like',real(dIn));
                end
            else

                obj.hdlCMA32APSKObj=dsphdl.ComplexToMagnitudeAngle('NumIterationsSource','Auto',...
                'OutputFormat','Magnitude and angle','AngleFormat','Radians',...
                'ScaleOutput',1);
                if~isfloat(dIn)
                    bGWLMul=15;
                    bGWLAdd=4;
                    bGFLMul=14;
                    if isa(dIn,'int8')
                        inpData=fi(0,1,8,0);
                    elseif(isa(dIn,'int16'))
                        inpData=fi(0,1,16,0);
                    elseif(isa(dIn,'int32'))
                        inpData=fi(0,1,32,0);
                    else
                        inpData=dIn;
                    end
                    LutNAPSKWL=15;
                    LutNAPSKFL=14;
                    UAPWLDelay=inpData.WordLength+LutNAPSKWL;
                    UAPFLDelay=inpData.FractionLength+LutNAPSKFL;
                    bgAng=7;
                    obj.magnitudeY=fi(1,0,UAPWLDelay+1+bgAng,UAPFLDelay+bgAng,hdlfimath);


                    obj.lut32N=fi([power32,1./(power32).^2],0,bGWLMul,bGFLMul,hdlfimath);
                    obj.circBound1=fi((1+g1)./(2*g2),0,33,32,hdlfimath);
                    obj.circBound2=fi((g1+g2)./(2*g2),0,33,32,hdlfimath);
                    obj.inpDataBGAng=fi(complex(0),1,inpData.WordLength+bgAng,inpData.FractionLength+bgAng,hdlfimath);
                    obj.angleY=fi(0,1,UAPWLDelay+3+bgAng,UAPWLDelay+bgAng,hdlfimath);

                    obj.piBy2=fi(1.570796326734125614166259765625,1,35,32,hdlfimath);
                    obj.piValue=fi(3.14159265370108187198638916015625,1,35,32,hdlfimath);
                    obj.piBy6=fi(0.52359877550043165683746337890625,1,35,32,hdlfimath);
                    obj.twoPiBy6=fi(1.04719755123369395732879638671875,1,35,32,hdlfimath);
                    obj.fourPiBy6=fi(2.0943951024673879146575927734375,1,35,32,hdlfimath);
                    obj.fivePiBy6=fi(2.61799387796781957149505615234375,1,35,32,hdlfimath);

                    obj.piBy16=fi(0.19634954095818102359771728515625,1,35,32,hdlfimath);
                    obj.threePiBy16=fi(0.5890486226417124271392822265625,1,35,32,hdlfimath);
                    obj.fivePiBy16=fi(0.98174770432524383068084716796875,1,35,32,hdlfimath);
                    obj.sevenPiBy16=fi(1.374446786008775234222412109375,1,35,32,hdlfimath);
                    obj.ninePiBy16=fi(1.76714586769230663776397705078125,1,35,32,hdlfimath);
                    obj.elevenPiBy16=fi(2.1598449493758380413055419921875,1,35,32,hdlfimath);
                    obj.thirteenPiBy16=fi(2.55254403105936944484710693359375,1,35,32,hdlfimath);
                    obj.fifteenPiBy16=fi(2.945243112742900848388671875,1,35,32,hdlfimath);
                else
                    obj.inpDataBGAng=cast(0,'like',varargin{1});

                    obj.piBy2=cast(pi/2,'like',real(dIn));
                    obj.piValue=cast(pi,'like',real(dIn));
                    obj.piBy6=cast(pi/6,'like',real(dIn));
                    obj.twoPiBy6=cast(2*pi/6,'like',real(dIn));
                    obj.fourPiBy6=cast(4*pi/6,'like',real(dIn));
                    obj.fivePiBy6=cast(5*pi/6,'like',real(dIn));

                    obj.piBy16=cast(pi/16,'like',real(dIn));
                    obj.threePiBy16=cast(3*pi/16,'like',real(dIn));
                    obj.fivePiBy16=cast(5*pi/16,'like',real(dIn));
                    obj.sevenPiBy16=cast(7*pi/16,'like',real(dIn));
                    obj.ninePiBy16=cast(9*pi/16,'like',real(dIn));
                    obj.elevenPiBy16=cast(11*pi/16,'like',real(dIn));
                    obj.thirteenPiBy16=cast(13*pi/16,'like',real(dIn));
                    obj.fifteenPiBy16=cast(15*pi/16,'like',real(dIn));


                    obj.sqroot2=cast(sqrt(2),'like',real(dIn));
                    obj.one=cast(1,'like',real(dIn));
                    obj.twoCosPiBy8=cast(2*cos(pi/8),'like',real(dIn));
                    obj.twoCos3PiBy8=cast(2*cos(3*pi/8),'like',real(dIn));

                    obj.lut32N=cast([power32,1./(power32).^2],'like',real(dIn));
                    obj.circBound1=cast((1+g1)./(2*g2),'like',real(dIn));
                    obj.circBound2=cast((g1+g2)./(2*g2),'like',real(dIn));
                    obj.angleY=cast(0,'like',real(dIn));
                    obj.magnitudeY=cast(0,'like',real(dIn));
                end

                obj.dataOut=cast(zeros(5,1),'like',real(dIn));
            end
            obj.validOut=false;
        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.dataOut;
            varargout{2}=obj.validOut;
        end

        function updateImpl(obj,varargin)
            obj.dataIn(:)=varargin{1};
            obj.validIn(:)=varargin{2};
            obj.dataInReal(:)=real(varargin{1});
            obj.dataInImag(:)=imag(varargin{1});
            if obj.validIn&&(varargin{3}==5)
                obj.lutIdx(:)=varargin{4};
                if strcmpi(obj.DecisionType,'Approximate log-likelihood ratio')
                    calculateApproxLLR(obj);
                else
                    obj.inpDataBGAng(:)=obj.dataIn(:);
                    symDemodBits(obj);
                end
                obj.validOut(:)=obj.validIn(:);
            else
                obj.dataOut(:)=0;
                obj.validOut(:)=false;
            end
        end

        function obj=calculateApproxLLR(obj)

            ind=obj.lutIdx(:);

            if obj.UnitAvgPower
                dataInRe=obj.dataInReal*obj.lut32N(ind);
                dataInIm=obj.dataInImag*obj.lut32N(ind);
            else
                dataInRe=obj.dataInReal;
                dataInIm=obj.dataInImag;
            end

            m1=obj.lut32(fi(5,0,5,0)+ind)*dataInRe;
            m2=obj.lut32(fi(5,0,5,0)+ind)*dataInIm;
            m3=obj.lut32(fi(15,0,5,0)+ind)*dataInRe;
            m4=obj.lut32(fi(15,0,5,0)+ind)*dataInIm;
            m5=obj.lut32(fi(20,0,5,0)+ind)*dataInRe;
            m6=obj.lut32(fi(20,0,5,0)+ind)*dataInIm;
            m7=obj.lut32(fi(25,0,5,0)+ind)*dataInRe;
            m8=obj.lut32(fi(25,0,5,0)+ind)*dataInIm;
            m9=obj.twoCosPiBy8*dataInRe;
            m10=obj.twoCosPiBy8*dataInIm;
            m11=obj.twoCos3PiBy8*dataInRe;
            m12=obj.twoCos3PiBy8*dataInIm;
            m13=obj.sqroot2*dataInRe;
            m14=obj.sqroot2*dataInIm;
            m15=obj.one*dataInRe;
            m16=obj.one*dataInIm;

            summ1m2=m1+m2;
            diffm1m2=m1-m2;
            summ3m6=m3+m6;
            diffm3m6=m3-m6;
            summ5m4=m5+m4;
            diffm5m4=m5-m4;
            summ7m8=m7+m8;
            diffm7m8=m7-m8;
            summ9m12=m9+m12;
            diffm9m12=m9-m12;
            summ11m10=m11+m10;
            diffm11m10=m11-m10;
            summ13m14=m13+m14;
            diffm13m14=m13-m14;
            summ15m15=m15+m15;
            summ16m16=m16+m16;

            c1=obj.lut32(ind);
            c2=obj.lut32(fi(10,0,5,0)+ind);
            c3=obj.one;

            D1=-summ1m2+c1;
            D2=diffm1m2+c1;
            D3=summ1m2+c1;
            D4=-diffm1m2+c1;
            D5=c2-summ3m6;
            D6=c2-summ7m8;
            D7=c2-summ5m4;
            D8=c2+diffm5m4;
            D9=c2+diffm7m8;
            D10=c2+diffm3m6;
            D11=c2+summ3m6;
            D12=c2+summ7m8;
            D13=c2+summ5m4;
            D14=c2-diffm5m4;
            D15=c2-diffm7m8;
            D16=c2-diffm3m6;

            D17=c3-summ15m15;
            D18=c3-summ9m12;
            D19=c3-summ13m14;
            D20=c3-summ11m10;
            D21=c3-summ16m16;
            D22=c3+diffm11m10;
            D23=c3+diffm13m14;
            D24=c3+diffm9m12;
            D25=c3+summ15m15;
            D26=c3+summ9m12;
            D27=c3+summ13m14;
            D28=c3+summ11m10;
            D29=c3+summ16m16;
            D30=c3-diffm11m10;
            D31=c3-diffm13m14;
            D32=c3-diffm9m12;

            d0B4=min([D6,D7,D8,D9,D12,D13,D14,D15,D18,D20,D21,D23,D26,D28,D29,D31]);
            d1B4=min([D1,D2,D3,D4,D5,D10,D11,D16,D17,D19,D22,D24,D25,D27,D30,D32]);

            d0B3=min([D1,D2,D3,D4,D5,D6,D7,D8,D9,D10,D11,D12,D13,D14,D15,D16]);
            d1B3=min([D17,D18,D19,D20,D21,D22,D23,D24,D25,D26,D27,D28,D29,D30,D31,D32]);

            d0B2=min([D1,D4,D5,D6,D7,D14,D15,D16,D17,D18,D19,D20,D29,D30,D31,D32]);
            d1B2=min([D2,D3,D8,D9,D10,D11,D12,D13,D21,D22,D23,D24,D25,D26,D27,D28]);

            d0B1=min([D1,D2,D5,D6,D7,D8,D9,D10,D17,D18,D19,D20,D21,D22,D23,D24]);
            d1B1=min([D3,D4,D11,D12,D13,D14,D15,D16,D25,D26,D27,D28,D29,D30,D31,D32]);

            d0B0=min([D5,D6,D9,D10,D11,D12,D15,D16,D17,D18,D23,D24,D25,D26,D31,D32]);
            d1B0=min([D1,D2,D3,D4,D7,D8,D13,D14,D19,D20,D21,D22,D27,D28,D29,D30]);

            if obj.UnitAvgPower
                obj.dataOut(1)=(d1B4-d0B4)*obj.lut32N(5+ind);
                obj.dataOut(2)=(d1B3-d0B3)*obj.lut32N(5+ind);
                obj.dataOut(3)=(d1B2-d0B2)*obj.lut32N(5+ind);
                obj.dataOut(4)=(d1B1-d0B1)*obj.lut32N(5+ind);
                obj.dataOut(5)=(d1B0-d0B0)*obj.lut32N(5+ind);
            else
                obj.dataOut(1)=d1B4-d0B4;
                obj.dataOut(2)=d1B3-d0B3;
                obj.dataOut(3)=d1B2-d0B2;
                obj.dataOut(4)=d1B1-d0B1;
                obj.dataOut(5)=d1B0-d0B0;
            end
        end

        function obj=symDemodBits(obj)
            ind=obj.lutIdx(:);

            realInBg=real(obj.inpDataBGAng(:));
            imagInBg=imag(obj.inpDataBGAng(:));

            if obj.UnitAvgPower
                dataInRe=realInBg*obj.lut32N(ind);
                dataInIm=imagInBg*obj.lut32N(ind);
            else
                dataInRe=realInBg;
                dataInIm=imagInBg;
            end

            if~isfloat(obj.inpDataBGAng(:))
                cmplxDataIn=fi(complex(dataInRe,dataInIm),1,obj.inpDataBGAng.WordLength+15,obj.inpDataBGAng.FractionLength+14,hdlfimath);
                logicValidIn=obj.validIn(:);
                for virtLat=1:62
                    [magOutput,angleOutput,validAngleOut]=obj.hdlCMA32APSKObj(cmplxDataIn,logicValidIn);
                    if validAngleOut==1
                        obj.magnitudeY(:)=magOutput;
                        obj.angleY(:)=angleOutput;
                        obj.validOut(:)=validAngleOut;
                    end
                end
                angY=obj.angleY(:);
                obj.magnitudeY(:)=abs(cmplxDataIn);
                magY=obj.magnitudeY(:);
            else
                obj.magnitudeY(:)=abs(complex(dataInRe,dataInIm));
                magY=obj.magnitudeY(:);
                obj.angleY(:)=angle(complex(dataInRe,dataInIm));
                angY=obj.angleY(:);
            end

            if(magY<obj.circBound1(ind))&&(angY>=0&&angY<obj.piBy2)
                obj.dataOut(1)=1;
                obj.dataOut(2)=0;
                obj.dataOut(3)=0;
                obj.dataOut(4)=0;
                obj.dataOut(5)=1;
            elseif(magY<obj.circBound1(ind))&&(angY>=obj.piBy2&&angY<=obj.piValue)
                obj.dataOut(1)=1;
                obj.dataOut(2)=0;
                obj.dataOut(3)=1;
                obj.dataOut(4)=0;
                obj.dataOut(5)=1;
            elseif(magY<obj.circBound1(ind))&&(angY>=-obj.piValue&&angY<-obj.piBy2)
                obj.dataOut(1)=1;
                obj.dataOut(2)=0;
                obj.dataOut(3)=1;
                obj.dataOut(4)=1;
                obj.dataOut(5)=1;
            elseif(magY<obj.circBound1(ind))&&(angY>=-obj.piBy2&&angY<0)
                obj.dataOut(1)=1;
                obj.dataOut(2)=0;
                obj.dataOut(3)=0;
                obj.dataOut(4)=1;
                obj.dataOut(5)=1;
            elseif(magY>=obj.circBound1(ind)&&magY<obj.circBound2(ind))&&(angY>=0&&angY<obj.piBy6)
                obj.dataOut(1)=1;
                obj.dataOut(2)=0;
                obj.dataOut(3)=0;
                obj.dataOut(4)=0;
                obj.dataOut(5)=0;
            elseif(magY>=obj.circBound1(ind)&&magY<obj.circBound2(ind))&&(angY>=obj.piBy6&&angY<obj.twoPiBy6)
                obj.dataOut(1)=0;
                obj.dataOut(2)=0;
                obj.dataOut(3)=0;
                obj.dataOut(4)=0;
                obj.dataOut(5)=0;
            elseif(magY>=obj.circBound1(ind)&&magY<obj.circBound2(ind))&&(angY>=obj.twoPiBy6&&angY<obj.piBy2)
                obj.dataOut(1)=0;
                obj.dataOut(2)=0;
                obj.dataOut(3)=0;
                obj.dataOut(4)=0;
                obj.dataOut(5)=1;
            elseif(magY>=obj.circBound1(ind)&&magY<obj.circBound2(ind))&&(angY>=obj.piBy2&&angY<obj.fourPiBy6)
                obj.dataOut(1)=0;
                obj.dataOut(2)=0;
                obj.dataOut(3)=1;
                obj.dataOut(4)=0;
                obj.dataOut(5)=1;
            elseif(magY>=obj.circBound1(ind)&&magY<obj.circBound2(ind))&&(angY>=obj.fourPiBy6&&angY<obj.fivePiBy6)
                obj.dataOut(1)=0;
                obj.dataOut(2)=0;
                obj.dataOut(3)=1;
                obj.dataOut(4)=0;
                obj.dataOut(5)=0;
            elseif(magY>=obj.circBound1(ind)&&magY<obj.circBound2(ind))&&(angY>=obj.fivePiBy6&&angY<=obj.piValue)
                obj.dataOut(1)=1;
                obj.dataOut(2)=0;
                obj.dataOut(3)=1;
                obj.dataOut(4)=0;
                obj.dataOut(5)=0;
            elseif(magY>=obj.circBound1(ind)&&magY<obj.circBound2(ind))&&(angY>=-obj.piValue&&angY<-obj.fivePiBy6)
                obj.dataOut(1)=1;
                obj.dataOut(2)=0;
                obj.dataOut(3)=1;
                obj.dataOut(4)=1;
                obj.dataOut(5)=0;
            elseif(magY>=obj.circBound1(ind)&&magY<obj.circBound2(ind))&&(angY>=-obj.fivePiBy6&&angY<-obj.fourPiBy6)
                obj.dataOut(1)=0;
                obj.dataOut(2)=0;
                obj.dataOut(3)=1;
                obj.dataOut(4)=1;
                obj.dataOut(5)=0;
            elseif(magY>=obj.circBound1(ind)&&magY<obj.circBound2(ind))&&(angY>=-obj.fourPiBy6&&angY<-obj.piBy2)
                obj.dataOut(1)=0;
                obj.dataOut(2)=0;
                obj.dataOut(3)=1;
                obj.dataOut(4)=1;
                obj.dataOut(5)=1;
            elseif(magY>=obj.circBound1(ind)&&magY<obj.circBound2(ind))&&(angY>=-obj.piBy2&&angY<-obj.twoPiBy6)
                obj.dataOut(1)=0;
                obj.dataOut(2)=0;
                obj.dataOut(3)=0;
                obj.dataOut(4)=1;
                obj.dataOut(5)=1;
            elseif(magY>=obj.circBound1(ind)&&magY<obj.circBound2(ind))&&(angY>=-obj.twoPiBy6&&angY<-obj.piBy6)
                obj.dataOut(1)=0;
                obj.dataOut(2)=0;
                obj.dataOut(3)=0;
                obj.dataOut(4)=1;
                obj.dataOut(5)=0;
            elseif(magY>=obj.circBound1(ind)&&magY<obj.circBound2(ind))&&(angY>=-obj.piBy6&&angY<0)
                obj.dataOut(1)=1;
                obj.dataOut(2)=0;
                obj.dataOut(3)=0;
                obj.dataOut(4)=1;
                obj.dataOut(5)=0;
            elseif(magY>=obj.circBound2(ind))&&(angY>=-obj.piBy16&&angY<obj.piBy16)
                obj.dataOut(1)=1;
                obj.dataOut(2)=1;
                obj.dataOut(3)=0;
                obj.dataOut(4)=0;
                obj.dataOut(5)=0;
            elseif(magY>=obj.circBound2(ind))&&(angY>=obj.piBy16&&angY<=obj.threePiBy16)
                obj.dataOut(1)=0;
                obj.dataOut(2)=1;
                obj.dataOut(3)=0;
                obj.dataOut(4)=0;
                obj.dataOut(5)=0;
            elseif(magY>=obj.circBound2(ind))&&(angY>=obj.threePiBy16&&angY<obj.fivePiBy16)
                obj.dataOut(1)=1;
                obj.dataOut(2)=1;
                obj.dataOut(3)=0;
                obj.dataOut(4)=0;
                obj.dataOut(5)=1;
            elseif(magY>=obj.circBound2(ind))&&(angY>=obj.fivePiBy16&&angY<obj.sevenPiBy16)
                obj.dataOut(1)=0;
                obj.dataOut(2)=1;
                obj.dataOut(3)=0;
                obj.dataOut(4)=0;
                obj.dataOut(5)=1;
            elseif(magY>=obj.circBound2(ind))&&(angY>=obj.sevenPiBy16&&angY<obj.ninePiBy16)
                obj.dataOut(1)=0;
                obj.dataOut(2)=1;
                obj.dataOut(3)=1;
                obj.dataOut(4)=0;
                obj.dataOut(5)=1;
            elseif(magY>=obj.circBound2(ind))&&(angY>=obj.ninePiBy16&&angY<obj.elevenPiBy16)
                obj.dataOut(1)=1;
                obj.dataOut(2)=1;
                obj.dataOut(3)=1;
                obj.dataOut(4)=0;
                obj.dataOut(5)=1;
            elseif(magY>=obj.circBound2(ind))&&(angY>=obj.elevenPiBy16&&angY<obj.thirteenPiBy16)
                obj.dataOut(1)=0;
                obj.dataOut(2)=1;
                obj.dataOut(3)=1;
                obj.dataOut(4)=0;
                obj.dataOut(5)=0;
            elseif(magY>=obj.circBound2(ind))&&(angY>=obj.thirteenPiBy16&&angY<obj.fifteenPiBy16)
                obj.dataOut(1)=1;
                obj.dataOut(2)=1;
                obj.dataOut(3)=1;
                obj.dataOut(4)=0;
                obj.dataOut(5)=0;
            elseif(magY>=obj.circBound2(ind))&&(angY>=obj.fifteenPiBy16||angY<-obj.fifteenPiBy16)
                obj.dataOut(1)=1;
                obj.dataOut(2)=1;
                obj.dataOut(3)=1;
                obj.dataOut(4)=1;
                obj.dataOut(5)=0;
            elseif(magY>=obj.circBound2(ind))&&(angY>=-obj.fifteenPiBy16&&angY<-obj.thirteenPiBy16)
                obj.dataOut(1)=0;
                obj.dataOut(2)=1;
                obj.dataOut(3)=1;
                obj.dataOut(4)=1;
                obj.dataOut(5)=0;
            elseif(magY>=obj.circBound2(ind))&&(angY>=-obj.thirteenPiBy16&&angY<-obj.elevenPiBy16)
                obj.dataOut(1)=1;
                obj.dataOut(2)=1;
                obj.dataOut(3)=1;
                obj.dataOut(4)=1;
                obj.dataOut(5)=1;
            elseif(magY>=obj.circBound2(ind))&&(angY>=-obj.elevenPiBy16&&angY<-obj.ninePiBy16)
                obj.dataOut(1)=0;
                obj.dataOut(2)=1;
                obj.dataOut(3)=1;
                obj.dataOut(4)=1;
                obj.dataOut(5)=1;
            elseif(magY>=obj.circBound2(ind))&&(angY>=-obj.ninePiBy16&&angY<-obj.sevenPiBy16)
                obj.dataOut(1)=0;
                obj.dataOut(2)=1;
                obj.dataOut(3)=0;
                obj.dataOut(4)=1;
                obj.dataOut(5)=1;
            elseif(magY>=obj.circBound2(ind))&&(angY>=-obj.sevenPiBy16&&angY<-obj.fivePiBy16)
                obj.dataOut(1)=1;
                obj.dataOut(2)=1;
                obj.dataOut(3)=0;
                obj.dataOut(4)=1;
                obj.dataOut(5)=1;
            elseif(magY>=obj.circBound2(ind))&&(angY>=-obj.fivePiBy16&&angY<-obj.threePiBy16)
                obj.dataOut(1)=0;
                obj.dataOut(2)=1;
                obj.dataOut(3)=0;
                obj.dataOut(4)=1;
                obj.dataOut(5)=0;
            elseif(magY>=obj.circBound2(ind))&&(angY>=-obj.threePiBy16&&angY<-obj.piBy16)
                obj.dataOut(1)=1;
                obj.dataOut(2)=1;
                obj.dataOut(3)=0;
                obj.dataOut(4)=1;
                obj.dataOut(5)=0;
            end
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.dataIn=obj.dataIn;
                s.validIn=obj.validIn;
                s.dataInReal=obj.dataInReal;
                s.dataInImag=obj.dataInImag;
                s.lutIdx=obj.lutIdx;
                s.circBound1=obj.circBound1;
                s.circBound2=obj.circBound2;
                s.dataOut=obj.dataOut;
                s.validOut=obj.validOut;
                s.sqroot2=obj.sqroot2;
                s.one=obj.one;
                s.twoCosPiBy8=obj.twoCosPiBy8;
                s.twoCos3PiBy8=obj.twoCos3PiBy8;
                s.lut32=obj.lut32;
                s.lut32N=obj.lut32N;
                s.magnitudeY=obj.magnitudeY;
                s.angleY=obj.angleY;
                s.hdlCMA32APSKObj=obj.hdlCMA32APSKObj;
                s.inpDataBGAng=obj.inpDataBGAng;
                s.piBy2=obj.piBy2;
                s.piValue=obj.piValue;
                s.piBy6=obj.piBy6;
                s.twoPiBy6=obj.twoPiBy6;
                s.fourPiBy6=obj.fourPiBy6;
                s.fivePiBy6=obj.fivePiBy6;
                s.piBy16=obj.piBy16;
                s.threePiBy16=obj.threePiBy16;
                s.fivePiBy16=obj.fivePiBy16;
                s.sevenPiBy16=obj.sevenPiBy16;
                s.ninePiBy16=obj.ninePiBy16;
                s.elevenPiBy16=obj.elevenPiBy16;
                s.thirteenPiBy16=obj.thirteenPiBy16;
                s.fifteenPiBy16=obj.fifteenPiBy16;
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
