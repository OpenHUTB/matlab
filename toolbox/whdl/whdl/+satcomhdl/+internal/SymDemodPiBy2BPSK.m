classdef(StrictDefaults)SymDemodPiBy2BPSK<matlab.System



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


        evenSymFlag;


        twoRootTwo;


        piBy4;
        threePiby4;
        zero;
        one;


        angleY;


        dataOut;
        validOut;


        hdlCMABPSKObj;
        inpDataBGAng;
    end

    methods
        function obj=SymDemodPiBy2BPSK(varargin)
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
            obj.dataOut(:)=0;
            obj.twoRootTwo(:)=2*sqrt(2);
            obj.zero(:)=0;
            obj.one(:)=1;
            obj.piBy4(:)=pi/4;
            obj.threePiby4(:)=3*pi/4;
            obj.angleY(:)=0;
            obj.evenSymFlag(:)=false;
            if(~strcmp(obj.DecisionType,'Approximate log-likelihood ratio'))
                reset(obj.hdlCMABPSKObj);
                obj.inpDataBGAng(:)=0;
            end
        end

        function setupImpl(obj,varargin)

            dIn=varargin{1};


            obj.dataIn=cast(0,'like',varargin{1});
            obj.dataInReal=cast(0,'like',real(dIn));
            obj.dataInImag=cast(0,'like',real(dIn));
            obj.validIn=false;


            obj.evenSymFlag=false;

            if(strcmp(obj.DecisionType,'Approximate log-likelihood ratio'))
                if~isfloat(dIn)
                    bGWLMul=16;
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


                    obj.twoRootTwo=fi(2.828369140625000,1,bGWLMul,13,hdlfimath);


                    obj.dataOut=fi(zeros(5,1),1,inpData.WordLength+bGWLMul+bGWLAdd,inpData.FractionLength+bGFLMul,hdlfimath);
                else

                    obj.twoRootTwo=cast(2*sqrt(2),'like',real(dIn));


                    obj.dataOut=cast(zeros(5,1),'like',real(dIn));
                end
            else

                obj.hdlCMABPSKObj=dsphdl.ComplexToMagnitudeAngle('NumIterationsSource','Auto',...
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

                    obj.zero=fi(0,1,2,0,hdlfimath);
                    obj.one=fi(1,1,2,0,hdlfimath);
                    obj.piBy4=fi(pi/4,1,35,32,hdlfimath);
                    obj.threePiby4=fi(3*pi/4,1,35,32,hdlfimath);

                    bgAng=7;
                    obj.inpDataBGAng=fi(complex(0),1,inpData.WordLength+bgAng,inpData.FractionLength+bgAng,hdlfimath);
                    obj.angleY=fi(0,1,inpData.WordLength+3+bgAng,inpData.WordLength+bgAng,hdlfimath);
                else
                    obj.inpDataBGAng=cast(0,'like',varargin{1});

                    obj.piBy4=cast(pi/4,'like',real(dIn));
                    obj.threePiby4=cast(3*pi/4,'like',real(dIn));
                    obj.zero=cast(0,'like',real(dIn));
                    obj.one=cast(1,'like',real(dIn));
                    obj.angleY=cast(0,'like',real(dIn));
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
            obj.evenSymFlag(:)=varargin{3};
            if obj.validIn&&(varargin{4}==1)
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
            m1=obj.dataInReal*obj.twoRootTwo;
            m2=obj.dataInImag*obj.twoRootTwo;

            if obj.evenSymFlag
                obj.dataOut(1)=m1+m2;
            else
                obj.dataOut(1)=m2-m1;
            end
        end

        function obj=symDemodBits(obj)

            if~isfloat(obj.inpDataBGAng(:))
                cmplxDataIn=obj.inpDataBGAng(:);
                logicValidIn=obj.validIn(:);
                for virtLat=1:47
                    [angleOutput,validAngleOut]=obj.hdlCMABPSKObj(cmplxDataIn,logicValidIn);
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

            m1=obj.zero*obj.piBy4;
            m2=obj.one*obj.piBy4;
            m3=obj.zero*obj.threePiby4;
            m4=obj.one*obj.threePiby4;

            d1=m1-m2;
            d2=m3-m4;

            if obj.evenSymFlag
                if(angY>=d1&&angY<-d2)
                    obj.dataOut(1)=0;
                else
                    obj.dataOut(1)=1;
                end
            else
                if(angY>=-d1||angY<d2)
                    obj.dataOut(1)=0;
                else
                    obj.dataOut(1)=1;
                end
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
                s.twoRootTwo=obj.twoRootTwo;
                s.zero=obj.zero;
                s.one=obj.one;
                s.piBy4=obj.piBy4;
                s.threePiby4=obj.threePiby4;
                s.angleY=obj.angleY;
                s.evenSymFlag=obj.evenSymFlag;
                s.hdlCMABPSKObj=obj.hdlCMABPSKObj;
                s.inpDataBGAng=obj.inpDataBGAng;
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
