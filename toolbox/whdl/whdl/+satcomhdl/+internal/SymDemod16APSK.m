classdef(StrictDefaults)SymDemod16APSK<matlab.System




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
        sqrt3Plus1BySqrt2;
        sqrt3Minus1BySqrt2;


        lut16;
        lut16N;
        circBound;


        angleY;
        magnitudeY;


        dataOut;
        validOut;


        hdlCMA16APSKObj;
        inpDataBGAng;
        piBy2;
        piValue;
        piBy6;
        twoPiBy6;
        fourPiBy6;
        fivePiBy6;
    end

    methods
        function obj=SymDemod16APSK(varargin)
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
            obj.sqrt3Plus1BySqrt2(:)=(sqrt(3)+1)/sqrt(2);
            obj.sqrt3Minus1BySqrt2(:)=(sqrt(3)-1)/sqrt(2);

            gamma=[3.15,2.85,2.75,2.7,2.6,2.57];
            constellation16APSK=cell(1,6);
            for countg=1:length(gamma)
                constellation16APSK{countg}=[(1/gamma(countg))*((1/sqrt(2))+j*(1/sqrt(2))),(1/gamma(countg))*((-1/sqrt(2))+j*(1/sqrt(2)))...
                ,(1/gamma(countg))*((-1/sqrt(2))-j*(1/sqrt(2))),(1/gamma(countg))*((1/sqrt(2))-j*(1/sqrt(2)))...
                ,((sqrt(3)+1)+j*(sqrt(3)-1))/(2*sqrt(2)),(1/sqrt(2))+j*(1/sqrt(2))...
                ,((sqrt(3)-1)+j*(sqrt(3)+1))/(2*sqrt(2)),(-(sqrt(3)-1)+j*(sqrt(3)+1))/(2*sqrt(2))...
                ,-(1/sqrt(2))+j*(1/sqrt(2)),(-(sqrt(3)+1)+j*(sqrt(3)-1))/(2*sqrt(2))...
                ,(-(sqrt(3)+1)-j*(sqrt(3)-1))/(2*sqrt(2)),-(1/sqrt(2))-j*(1/sqrt(2))...
                ,(-(sqrt(3)-1)-j*(sqrt(3)+1))/(2*sqrt(2)),((sqrt(3)-1)-j*(sqrt(3)+1))/(2*sqrt(2))...
                ,(1/sqrt(2))-j*(1/sqrt(2)),((sqrt(3)+1)-j*(sqrt(3)-1))/(2*sqrt(2))];
            end
            power16=zeros(1,length(gamma));
            for countg=1:length(gamma)
                power16(countg)=sqrt(mean(abs(constellation16APSK{countg}).^2));
            end
            if(strcmp(obj.DecisionType,'Approximate log-likelihood ratio'))
                obj.lut16(:)=[sqrt(2)./gamma,1./((gamma).^2)];
                obj.lut16N(:)=[power16,1./(power16).^2];
            else
                obj.circBound(:)=(gamma+1)./(2*gamma);
                obj.magnitudeY(:)=1;
                obj.angleY(:)=0;
                reset(obj.hdlCMA16APSKObj);
                obj.inpDataBGAng(:)=0;
                obj.piBy2(:)=pi/2;
                obj.piValue(:)=pi;
                obj.piBy6(:)=pi/6;
                obj.twoPiBy6(:)=2*pi/6;
                obj.fourPiBy6(:)=4*pi/6;
                obj.fivePiBy6(:)=5*pi/6;
            end
        end

        function setupImpl(obj,varargin)

            dIn=varargin{1};


            obj.dataIn=cast(0,'like',varargin{1});
            obj.dataInReal=cast(0,'like',real(dIn));
            obj.dataInImag=cast(0,'like',real(dIn));
            obj.lutIdx=fi(2,0,3,0,hdlfimath);
            obj.validIn=false;



            gamma=[3.15,2.85,2.75,2.7,2.6,2.57];
            constellation16APSK=cell(1,6);
            for countg=1:length(gamma)
                constellation16APSK{countg}=[(1/gamma(countg))*((1/sqrt(2))+j*(1/sqrt(2)))...
                ,(1/gamma(countg))*((-1/sqrt(2))+j*(1/sqrt(2)))...
                ,(1/gamma(countg))*((-1/sqrt(2))-j*(1/sqrt(2))),(1/gamma(countg))*((1/sqrt(2))-j*(1/sqrt(2)))...
                ,((sqrt(3)+1)+j*(sqrt(3)-1))/(2*sqrt(2)),(1/sqrt(2))+j*(1/sqrt(2))...
                ,((sqrt(3)-1)+j*(sqrt(3)+1))/(2*sqrt(2)),(-(sqrt(3)-1)+j*(sqrt(3)+1))/(2*sqrt(2))...
                ,-(1/sqrt(2))+j*(1/sqrt(2)),(-(sqrt(3)+1)+j*(sqrt(3)-1))/(2*sqrt(2))...
                ,(-(sqrt(3)+1)-j*(sqrt(3)-1))/(2*sqrt(2)),-(1/sqrt(2))-j*(1/sqrt(2))...
                ,(-(sqrt(3)-1)-j*(sqrt(3)+1))/(2*sqrt(2)),((sqrt(3)-1)-j*(sqrt(3)+1))/(2*sqrt(2))...
                ,(1/sqrt(2))-j*(1/sqrt(2)),((sqrt(3)+1)-j*(sqrt(3)-1))/(2*sqrt(2))];
            end
            power16=zeros(1,length(gamma));
            for countg=1:length(gamma)
                power16(countg)=sqrt(mean(abs(constellation16APSK{countg}).^2));
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
                    obj.sqrt3Plus1BySqrt2=fi((sqrt(3)+1)/sqrt(2),0,bGWLMul,bGFLMul,hdlfimath);
                    obj.sqrt3Minus1BySqrt2=fi((sqrt(3)-1)/sqrt(2),0,bGWLMul,bGFLMul,hdlfimath);


                    obj.lut16=fi([sqrt(2)./gamma,1./((gamma).^2)],0,bGWLMul,bGFLMul,hdlfimath);
                    obj.lut16N=fi([power16,1./(power16).^2],0,bGWLMul,bGFLMul,hdlfimath);


                    obj.dataOut=fi(zeros(5,1),1,inpData.WordLength+bGWLMul+bGWLAdd,inpData.FractionLength+bGFLMul,hdlfimath);
                else

                    obj.sqroot2=cast(sqrt(2),'like',real(dIn));
                    obj.one=cast(1,'like',real(dIn));
                    obj.sqrt3Plus1BySqrt2=cast((sqrt(3)+1)/sqrt(2),'like',real(dIn));
                    obj.sqrt3Minus1BySqrt2=cast((sqrt(3)-1)/sqrt(2),'like',real(dIn));


                    obj.lut16=cast([sqrt(2)./gamma,1./((gamma).^2)],'like',real(dIn));
                    obj.lut16N=cast([power16,1./(power16).^2],'like',real(dIn));


                    obj.dataOut=cast(zeros(5,1),'like',real(dIn));
                end
            else


                obj.hdlCMA16APSKObj=dsphdl.ComplexToMagnitudeAngle('NumIterationsSource','Auto',...
                'OutputFormat','Magnitude and angle','AngleFormat','Radians',...
                'ScaleOutput',1);
                if~isfloat(dIn)
                    bGWLMul=15;
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


                    obj.lut16N=fi([power16,1./(power16).^2],0,bGWLMul,bGFLMul,hdlfimath);
                    obj.circBound=fi((gamma+1)./(2*gamma),0,33,32,hdlfimath);
                    obj.inpDataBGAng=fi(complex(0),1,inpData.WordLength+bgAng,inpData.FractionLength+bgAng,hdlfimath);
                    obj.angleY=fi(0,1,UAPWLDelay+3+bgAng,UAPWLDelay+bgAng,hdlfimath);

                    obj.piBy2=fi(1.570796326734125614166259765625,1,35,32,hdlfimath);
                    obj.piValue=fi(3.14159265370108187198638916015625,1,35,32,hdlfimath);
                    obj.piBy6=fi(0.52359877550043165683746337890625,1,35,32,hdlfimath);
                    obj.twoPiBy6=fi(1.04719755123369395732879638671875,1,35,32,hdlfimath);
                    obj.fourPiBy6=fi(2.0943951024673879146575927734375,1,35,32,hdlfimath);
                    obj.fivePiBy6=fi(2.61799387796781957149505615234375,1,35,32,hdlfimath);
                else
                    obj.inpDataBGAng=cast(0,'like',varargin{1});
                    obj.piBy2=cast(pi/2,'like',real(dIn));
                    obj.piValue=cast(pi,'like',real(dIn));
                    obj.piBy6=cast(pi/6,'like',real(dIn));
                    obj.twoPiBy6=cast(2*pi/6,'like',real(dIn));
                    obj.fourPiBy6=cast(4*pi/6,'like',real(dIn));
                    obj.fivePiBy6=cast(5*pi/6,'like',real(dIn));


                    obj.sqroot2=cast(sqrt(2),'like',real(dIn));
                    obj.one=cast(1,'like',real(dIn));
                    obj.sqrt3Plus1BySqrt2=cast((sqrt(3)+1)/sqrt(2),'like',real(dIn));
                    obj.sqrt3Minus1BySqrt2=cast((sqrt(3)-1)/sqrt(2),'like',real(dIn));

                    obj.lut16N=cast([power16,1./(power16).^2],'like',real(dIn));
                    obj.circBound=cast((gamma+1)./(2*gamma),'like',real(dIn));
                    obj.angleY=cast(0,'like',real(dIn));
                    obj.magnitudeY=cast(1,'like',real(dIn));
                end

                obj.dataOut=boolean(zeros(5,1));
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
            if obj.validIn&&(varargin{3}==4)
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
                dataInRe=obj.dataInReal*obj.lut16N(ind);
                dataInIm=obj.dataInImag*obj.lut16N(ind);
            else
                dataInRe=obj.dataInReal;
                dataInIm=obj.dataInImag;
            end

            m1=obj.lut16(ind)*dataInRe;
            m2=obj.lut16(ind)*dataInIm;
            m3=obj.sqroot2*dataInRe;
            m4=obj.sqroot2*dataInIm;
            m5=obj.sqrt3Plus1BySqrt2*dataInRe;
            m6=obj.sqrt3Plus1BySqrt2*dataInIm;
            m7=obj.sqrt3Minus1BySqrt2*dataInRe;
            m8=obj.sqrt3Minus1BySqrt2*dataInIm;

            summ1m2=m1+m2;
            diffm1m2=m1-m2;
            summ3m4=m3+m4;
            diffm3m4=m3-m4;

            c1=obj.lut16(6+ind);
            c2=obj.one;

            D1=-summ1m2+c1;
            D2=diffm1m2+c1;
            D3=summ1m2+c1;
            D4=-diffm1m2+c1;
            D5=c2-m5-m8;
            D6=c2-summ3m4;
            D7=c2-m7-m6;
            D8=c2+m7-m6;
            D9=c2+diffm3m4;
            D10=c2+m5-m8;
            D11=c2+m5+m8;
            D12=c2+summ3m4;
            D13=c2+m7+m6;
            D14=c2-m7+m6;
            D15=c2-diffm3m4;
            D16=c2-m5+m8;

            d0B3=min([D5,D6,D9,D10,D11,D12,D15,D16]);
            d1B3=min([D1,D2,D3,D4,D7,D8,D13,D14]);

            d0B2=min([D6,D7,D8,D9,D12,D13,D14,D15]);
            d1B2=min([D1,D2,D3,D4,D5,D10,D11,D16]);

            d0B1=min([D1,D4,D5,D6,D7,D14,D15,D16]);
            d1B1=min([D2,D3,D8,D9,D10,D11,D12,D13]);

            d0B0=min([D1,D2,D5,D6,D7,D8,D9,D10]);
            d1B0=min([D3,D4,D11,D12,D13,D14,D15,D16]);

            if obj.UnitAvgPower
                obj.dataOut(1)=(d1B3-d0B3)*obj.lut16N(6+ind);
                obj.dataOut(2)=(d1B2-d0B2)*obj.lut16N(6+ind);
                obj.dataOut(3)=(d1B1-d0B1)*obj.lut16N(6+ind);
                obj.dataOut(4)=(d1B0-d0B0)*obj.lut16N(6+ind);
            else
                obj.dataOut(1)=d1B3-d0B3;
                obj.dataOut(2)=d1B2-d0B2;
                obj.dataOut(3)=d1B1-d0B1;
                obj.dataOut(4)=d1B0-d0B0;
            end
        end

        function obj=symDemodBits(obj)
            ind=obj.lutIdx(:);

            realInBg=real(obj.inpDataBGAng(:));
            imagInBg=imag(obj.inpDataBGAng(:));

            if obj.UnitAvgPower
                dataInRe=realInBg*obj.lut16N(ind);
                dataInIm=imagInBg*obj.lut16N(ind);
            else
                dataInRe=realInBg;
                dataInIm=imagInBg;
            end

            if~isfloat(obj.inpDataBGAng(:))
                cmplxDataIn=fi(complex(dataInRe,dataInIm),1,obj.inpDataBGAng.WordLength+15,obj.inpDataBGAng.FractionLength+14,hdlfimath);
                logicValidIn=obj.validIn(:);
                for virtLat=1:62
                    [magOutput,angleOutput,validAngleOut]=obj.hdlCMA16APSKObj(cmplxDataIn,logicValidIn);
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

            if(magY<obj.circBound(ind))&&(angY>=0&&angY<obj.piBy2)
                obj.dataOut(1)=1;
                obj.dataOut(2)=1;
                obj.dataOut(3)=0;
                obj.dataOut(4)=0;
            elseif(magY<obj.circBound(ind))&&(angY>=obj.piBy2&&angY<=obj.piValue)
                obj.dataOut(1)=1;
                obj.dataOut(2)=1;
                obj.dataOut(3)=1;
                obj.dataOut(4)=0;
            elseif(magY<obj.circBound(ind))&&(angY>=-obj.piValue&&angY<-obj.piBy2)
                obj.dataOut(1)=1;
                obj.dataOut(2)=1;
                obj.dataOut(3)=1;
                obj.dataOut(4)=1;
            elseif(magY<obj.circBound(ind))&&(angY>=-obj.piBy2&&angY<0)
                obj.dataOut(1)=1;
                obj.dataOut(2)=1;
                obj.dataOut(3)=0;
                obj.dataOut(4)=1;
            elseif(magY>=obj.circBound(ind))&&(angY>=0&&angY<obj.piBy6)
                obj.dataOut(1)=0;
                obj.dataOut(2)=1;
                obj.dataOut(3)=0;
                obj.dataOut(4)=0;
            elseif(magY>=obj.circBound(ind))&&(angY>=obj.piBy6&&angY<obj.twoPiBy6)
                obj.dataOut(1)=0;
                obj.dataOut(2)=0;
                obj.dataOut(3)=0;
                obj.dataOut(4)=0;
            elseif(magY>=obj.circBound(ind))&&(angY>=obj.twoPiBy6&&angY<obj.piBy2)
                obj.dataOut(1)=1;
                obj.dataOut(2)=0;
                obj.dataOut(3)=0;
                obj.dataOut(4)=0;
            elseif(magY>=obj.circBound(ind))&&(angY>=obj.piBy2&&angY<obj.fourPiBy6)
                obj.dataOut(1)=1;
                obj.dataOut(2)=0;
                obj.dataOut(3)=1;
                obj.dataOut(4)=0;
            elseif(magY>=obj.circBound(ind))&&(angY>=obj.fourPiBy6&&angY<obj.fivePiBy6)
                obj.dataOut(1)=0;
                obj.dataOut(2)=0;
                obj.dataOut(3)=1;
                obj.dataOut(4)=0;
            elseif(magY>=obj.circBound(ind))&&(angY>=obj.fivePiBy6&&angY<=obj.piValue)
                obj.dataOut(1)=0;
                obj.dataOut(2)=1;
                obj.dataOut(3)=1;
                obj.dataOut(4)=0;
            elseif(magY>=obj.circBound(ind))&&(angY>=-obj.piValue&&angY<-obj.fivePiBy6)
                obj.dataOut(1)=0;
                obj.dataOut(2)=1;
                obj.dataOut(3)=1;
                obj.dataOut(4)=1;
            elseif(magY>=obj.circBound(ind))&&(angY>=-obj.fivePiBy6&&angY<-obj.fourPiBy6)
                obj.dataOut(1)=0;
                obj.dataOut(2)=0;
                obj.dataOut(3)=1;
                obj.dataOut(4)=1;
            elseif(magY>=obj.circBound(ind))&&(angY>=-obj.fourPiBy6&&angY<-obj.piBy2)
                obj.dataOut(1)=1;
                obj.dataOut(2)=0;
                obj.dataOut(3)=1;
                obj.dataOut(4)=1;
            elseif(magY>=obj.circBound(ind))&&(angY>=-obj.piBy2&&angY<-obj.twoPiBy6)
                obj.dataOut(1)=1;
                obj.dataOut(2)=0;
                obj.dataOut(3)=0;
                obj.dataOut(4)=1;
            elseif(magY>=obj.circBound(ind))&&(angY>=-obj.twoPiBy6&&angY<-obj.piBy6)
                obj.dataOut(1)=0;
                obj.dataOut(2)=0;
                obj.dataOut(3)=0;
                obj.dataOut(4)=1;
            elseif(magY>=obj.circBound(ind))&&(angY>=-obj.piBy6&&angY<0)
                obj.dataOut(1)=0;
                obj.dataOut(2)=1;
                obj.dataOut(3)=0;
                obj.dataOut(4)=1;
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
                s.circBound=obj.circBound;
                s.dataOut=obj.dataOut;
                s.validOut=obj.validOut;
                s.sqroot2=obj.sqroot2;
                s.one=obj.one;
                s.sqrt3Plus1BySqrt2=obj.sqrt3Plus1BySqrt2;
                s.sqrt3Minus1BySqrt2=obj.sqrt3Minus1BySqrt2;
                s.lut16=obj.lut16;
                s.lut16N=obj.lut16N;
                s.angleY=obj.angleY;
                s.magnitudeY=obj.magnitudeY;
                s.hdlCMA16APSKObj=obj.hdlCMA16APSKObj;
                s.inpDataBGAng=obj.inpDataBGAng;
                s.piBy2=obj.piBy2;
                s.piValue=obj.piValue;
                s.piBy6=obj.piBy6;
                s.twoPiBy6=obj.twoPiBy6;
                s.fourPiBy6=obj.fourPiBy6;
                s.fivePiBy6=obj.fivePiBy6;
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
