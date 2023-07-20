classdef(StrictDefaults)SymDemod8PSK<matlab.System



%#codegen
%#ok<*EMCLS>

    properties(Nontunable)

        DecisionType='Approximate log-likelihood ratio';
    end

    properties(Constant,Hidden)
        DecisionTypeSet=matlab.system.StringSet({...
        'Hard','Approximate log-likelihood ratio'});
    end


    properties(Access=private)

        dataIn;
        validIn;
        dataInReal;
        dataInImag;


        sqroot2;
        one;


        angleY;


        dataOut;
        validOut;


        hdlCMA8PSKObj;
        inpDataBGAng;
        piBy8;
        threePiBy8;
        fivePiBy8;
        sevenPiBy8;
        zero;
    end

    methods
        function obj=SymDemod8PSK(varargin)
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
            numInpPorts=3;
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
            obj.dataOut(:)=0;
            obj.sqroot2(:)=sqrt(2);
            obj.one(:)=1;
            obj.angleY(:)=0;
            if(~strcmp(obj.DecisionType,'Approximate log-likelihood ratio'))
                reset(obj.hdlCMA8PSKObj);
                obj.inpDataBGAng(:)=0;
                obj.piBy8(:)=pi/8;
                obj.threePiBy8(:)=3*pi/8;
                obj.fivePiBy8(:)=5*pi/8;
                obj.sevenPiBy8(:)=7*pi/8;
                obj.zero(:)=0;
            end
        end

        function setupImpl(obj,varargin)

            dIn=varargin{1};


            obj.dataIn=cast(0,'like',varargin{1});
            obj.dataInReal=cast(0,'like',real(dIn));
            obj.dataInImag=cast(0,'like',real(dIn));
            obj.validIn=false;

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


                    obj.sqroot2=fi(1.4141845703125,0,bGWLMul,bGFLMul,hdlfimath);
                    obj.one=fi(1,0,bGWLMul,bGFLMul,hdlfimath);

                    obj.dataOut=fi(zeros(5,1),1,inpData.WordLength+bGWLMul+bGWLAdd,inpData.FractionLength+bGFLMul,hdlfimath);
                else

                    obj.sqroot2=cast(sqrt(2),'like',real(dIn));
                    obj.one=cast(1,'like',real(dIn));
                    obj.dataOut=cast(zeros(5,1),'like',real(dIn));
                end
            else

                obj.hdlCMA8PSKObj=dsphdl.ComplexToMagnitudeAngle('NumIterationsSource','Auto',...
                'OutputFormat','Angle','AngleFormat','Radians',...
                'ScaleOutput',1);
                if~isfloat(dIn)
                    if isa(dIn,'int8')
                        inpData=fi(0,1,8,0);
                    elseif(isa(dIn,'int16'))
                        inpData=fi(0,1,16,0);
                    elseif(isa(dIn,'int32'))
                        inpData=fi(0,1,32,0);
                    else
                        inpData=dIn;
                    end
                    bgAng=7;
                    obj.inpDataBGAng=fi(complex(0),1,inpData.WordLength+bgAng,inpData.FractionLength+bgAng,hdlfimath);
                    obj.angleY=fi(0,1,inpData.WordLength+3+bgAng,inpData.WordLength+bgAng,hdlfimath);
                    obj.piBy8=fi(0.39269908168353140354156494140625,1,35,32,hdlfimath);
                    obj.threePiBy8=fi(1.17809724505059421062469482421875,1,35,32,hdlfimath);
                    obj.fivePiBy8=fi(1.96349540841765701770782470703125,1,35,32,hdlfimath);
                    obj.sevenPiBy8=fi(2.74889357178471982479095458984375,1,35,32,hdlfimath);
                    obj.zero=fi(0,1,2,0,hdlfimath);
                else
                    obj.inpDataBGAng=cast(0,'like',varargin{1});
                    obj.angleY=cast(0,'like',real(dIn));
                    obj.piBy8=cast(pi/8,'like',real(dIn));
                    obj.threePiBy8=cast(3*pi/8,'like',real(dIn));
                    obj.fivePiBy8=cast(5*pi/8,'like',real(dIn));
                    obj.sevenPiBy8=cast(7*pi/8,'like',real(dIn));
                    obj.zero=cast(0,'like',real(dIn));
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
            if obj.validIn&&(varargin{3}==3)
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

            m1=obj.one*obj.dataInReal;
            m2=obj.one*obj.dataInImag;
            m3=obj.sqroot2*obj.dataInReal;
            m4=obj.sqroot2*obj.dataInImag;

            D1=-m1-m1;
            D2=-m3-m4;
            D3=-m2-m2;
            D4=m3-m4;
            D5=m1+m1;
            D6=m3+m4;
            D7=m2+m2;
            D8=-m3+m4;

            d0B2=min([D1,D2,D5,D6]);
            d1B2=min([D3,D4,D7,D8]);

            d0B1=min([D1,D2,D3,D8]);
            d1B1=min([D4,D5,D6,D7]);

            d0B0=min([D2,D3,D4,D5]);
            d1B0=min([D1,D6,D7,D8]);

            obj.dataOut(1)=d1B2-d0B2;
            obj.dataOut(2)=d1B1-d0B1;
            obj.dataOut(3)=d1B0-d0B0;
        end

        function obj=symDemodBits(obj)

            if~isfloat(obj.inpDataBGAng(:))
                cmplxDataIn=obj.inpDataBGAng(:);
                logicValidIn=obj.validIn(:);
                for virtLat=1:47
                    [angleOutput,validAngleOut]=obj.hdlCMA8PSKObj(cmplxDataIn,logicValidIn);
                    if validAngleOut==1
                        obj.angleY(:)=angleOutput;
                        obj.validOut(:)=validAngleOut;
                    end
                end
                angY=obj.angleY(:);
            else
                obj.angleY(:)=angle(obj.inpDataBGAng(:));
                angY=obj.angleY(:);
            end


            minusPiBy8=obj.zero-obj.piBy8;
            minus3PiBy8=obj.zero-obj.threePiBy8;
            minus5PiBy8=obj.zero-obj.fivePiBy8;
            minus7PiBy8=obj.zero-obj.sevenPiBy8;

            if(angY>=minusPiBy8&&angY<obj.piBy8)
                obj.dataOut(1)=0;
                obj.dataOut(2)=0;
                obj.dataOut(3)=1;
            elseif(angY>=obj.piBy8&&angY<obj.threePiBy8)
                obj.dataOut(1)=0;
                obj.dataOut(2)=0;
                obj.dataOut(3)=0;
            elseif(angY>=obj.threePiBy8&&angY<obj.fivePiBy8)
                obj.dataOut(1)=1;
                obj.dataOut(2)=0;
                obj.dataOut(3)=0;
            elseif(angY>=obj.fivePiBy8&&angY<obj.sevenPiBy8)
                obj.dataOut(1)=1;
                obj.dataOut(2)=1;
                obj.dataOut(3)=0;
            elseif(angY>=obj.sevenPiBy8||angY<minus7PiBy8)
                obj.dataOut(1)=0;
                obj.dataOut(2)=1;
                obj.dataOut(3)=0;
            elseif(angY>=minus7PiBy8&&angY<minus5PiBy8)
                obj.dataOut(1)=0;
                obj.dataOut(2)=1;
                obj.dataOut(3)=1;
            elseif(angY>=minus5PiBy8&&angY<minus3PiBy8)
                obj.dataOut(1)=1;
                obj.dataOut(2)=1;
                obj.dataOut(3)=1;
            elseif(angY>=minus3PiBy8&&angY<minusPiBy8)
                obj.dataOut(1)=1;
                obj.dataOut(2)=0;
                obj.dataOut(3)=1;
            end
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.dataIn=obj.dataIn;
                s.validIn=obj.validIn;
                s.dataInReal=obj.dataInReal;
                s.dataInImag=obj.dataInImag;
                s.dataOut=obj.dataOut;
                s.validOut=obj.validOut;
                s.sqroot2=obj.sqroot2;
                s.one=obj.one;
                s.angleY=obj.angleY;
                s.hdlCMA8PSKObj=obj.hdlCMA8PSKObj;
                s.inpDataBGAng=obj.inpDataBGAng;
                s.piBy8=obj.piBy8;
                s.threePiBy8=obj.threePiBy8;
                s.fivePiBy8=obj.fivePiBy8;
                s.sevenPiBy8=obj.sevenPiBy8;
                s.zero=obj.zero;
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
