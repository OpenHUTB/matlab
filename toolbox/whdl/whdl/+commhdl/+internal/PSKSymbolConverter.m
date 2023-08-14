classdef PSKSymbolConverter<matlab.System


%#codegen


    properties(Access=private)
inpReg
inpmReg
outMappedReg
Mapped0Reg
outValidReg
RealReg
ImagReg
CompReg
runMapper
const1
const2
const3
const4
const5
const6
constMul1
constMul2
    end

    methods

        function obj=PSKSymbolConverter(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','LTE_HDL_Toolbox'))
                    error(message('whdl:whdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','LTE_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:})
        end
    end

    methods(Access=protected)

        function setupImpl(obj,varargin)
            dIn=varargin{1};
            if(~isfloat(dIn))
                inpData=dIn;

                obj.inpReg=fi(complex(0),1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                obj.RealReg=fi(0,1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                obj.ImagReg=fi(0,1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                obj.CompReg=fi(complex(0),1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                obj.inpmReg=fi(0,0,4,0,hdlfimath);
                obj.outMappedReg=fi(complex(zeros(4,1)),1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                obj.Mapped0Reg=fi(complex(0),1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                obj.const1=fi(1/2^(0.5),1,16,14,hdlfimath);
                obj.const2=fi((1-sin(pi/8)*tan(pi/16)),1,16,14,hdlfimath);
                obj.const3=fi(sin(pi/8),1,16,14,hdlfimath);
                obj.const4=fi(((1+cos(pi/8))*tan(pi/16)),1,16,14,hdlfimath);
                obj.const5=fi(cos(pi/8),1,16,14,hdlfimath);
                obj.const6=fi([tan(pi/8),tan(pi/16)],1,16,14,hdlfimath);
                obj.constMul1=fi(0,1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                obj.constMul2=fi(0,1,inpData.WordLength,inpData.FractionLength,hdlfimath);
            else
                obj.inpReg=cast(complex(0),'like',dIn);
                obj.RealReg=cast(0,'like',real(dIn));
                obj.ImagReg=cast(0,'like',real(dIn));
                obj.CompReg=cast(complex(0),'like',dIn);
                obj.inpmReg=cast(0,'like',real(dIn));
                obj.outMappedReg=cast(complex(zeros(4,1)),'like',dIn);
                obj.Mapped0Reg=cast(complex(0),'like',dIn);
                obj.const1=cast(1/2^(0.5),'like',real(dIn));
                obj.const2=cast((1-sin(pi/8)*tan(pi/16)),'like',real(dIn));
                obj.const3=cast(sin(pi/8),'like',real(dIn));
                obj.const4=cast(((1+cos(pi/8))*tan(pi/16)),'like',real(dIn));
                obj.const5=cast(cos(pi/8),'like',real(dIn));
                obj.const6=cast([tan(pi/8),tan(pi/16)],'like',real(dIn));
                obj.constMul1=cast(0,'like',real(dIn));
                obj.constMul2=cast(0,'like',real(dIn));
            end
            obj.outValidReg=false;
            obj.runMapper=false;
        end

        function resetImpl(obj)

            obj.inpReg(:)=0;
            obj.inpmReg(:)=0;
            obj.ImagReg(:)=0;
            obj.RealReg(:)=0;
            obj.CompReg(:)=0;

            obj.Mapped0Reg(:)=0;
            obj.constMul1(:)=0;
            obj.constMul2(:)=0;
            obj.outValidReg=false;
            obj.runMapper=false;
        end


        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.inpReg=obj.inpReg;
                s.RealReg=obj.RealReg;
                s.ImagReg=obj.ImagReg;
                s.CompReg=obj.CompReg;
                s.inpmReg=obj.inpmReg;
                s.outMappedReg=obj.outMappedReg;
                s.Mapped0Reg=obj.Mapped0Reg;
                s.outValidReg=obj.outValidReg;
                s.runMapper=obj.runMapper;
                s.const1=obj.const1;
                s.const2=obj.const2;
                s.const3=obj.const3;
                s.const4=obj.const4;
                s.const5=obj.const5;
                s.const6=obj.const6;
                s.constMul1=obj.constMul1;
                s.constMul2=obj.constMul2;
            end
        end

        function updateImpl(obj,varargin)

            if(varargin{3}==true)
                obj.inpReg(:)=varargin{1};
                obj.inpmReg(:)=varargin{2};
                obj.runMapper=true;

                obj.RealReg(:)=abs(real(obj.inpReg));
                obj.ImagReg(:)=abs(imag(obj.inpReg));
                obj.CompReg(:)=complex(obj.RealReg,obj.ImagReg);
            else
                obj.inpmReg(:)=0;
                obj.runMapper=false;
            end

            if(obj.runMapper)
                if(obj.inpmReg(:)==1)
                    obj.outMappedReg(1,:)=obj.inpReg;
                    obj.outValidReg=true;
                    obj.runMapper=false;
                elseif(obj.inpmReg(:)==2)
                    obj.outMappedReg(1,:)=obj.CompReg;
                    obj.outValidReg=true;
                    obj.runMapper=false;
                elseif(obj.inpmReg(:)==3)
                    obj.outMappedReg(1,:)=obj.CompReg(:);
                    if(imag(obj.outMappedReg(1))<real(obj.outMappedReg(1)))
                        obj.outMappedReg(2,:)=obj.outMappedReg(1);
                    else
                        obj.outMappedReg(2,:)=complex(imag(obj.outMappedReg(1)),(real(obj.outMappedReg(1))));
                    end
                    obj.outValidReg=true;
                    obj.runMapper=false;
                elseif(obj.inpmReg(:)==4)
                    obj.outMappedReg(1,:)=obj.CompReg(:);
                    if(imag(obj.outMappedReg(1))<real(obj.outMappedReg(1)))
                        obj.outMappedReg(2,:)=obj.outMappedReg(1);
                    else
                        obj.outMappedReg(2,:)=complex(imag(obj.outMappedReg(1)),(real(obj.outMappedReg(1))));
                    end
                    if(imag(obj.outMappedReg(2,:))<obj.const6(1)*real(obj.outMappedReg(2)))
                        obj.outMappedReg(3,:)=obj.outMappedReg(2);
                    else
                        obj.outMappedReg(3,:)=complex(obj.const1*(real(obj.outMappedReg(2))+imag(obj.outMappedReg(2))),...
                        (obj.const1*(real(obj.outMappedReg(2))-imag(obj.outMappedReg(2)))));
                    end
                    obj.outValidReg=true;
                    obj.runMapper=false;
                elseif(obj.inpmReg(:)==5)
                    obj.outMappedReg(1,:)=obj.CompReg(:);
                    if(imag(obj.outMappedReg(1))<real(obj.outMappedReg(1)))
                        obj.outMappedReg(2,:)=obj.outMappedReg(1);
                    else
                        obj.outMappedReg(2,:)=complex(imag(obj.outMappedReg(1)),(real(obj.outMappedReg(1))));
                    end
                    obj.constMul1(:)=obj.const6(1)*real(obj.outMappedReg(2));
                    if(imag(obj.outMappedReg(2,:))<obj.const6(1)*real(obj.outMappedReg(2)))
                        obj.outMappedReg(3,:)=obj.outMappedReg(2);
                    else
                        obj.outMappedReg(3,:)=complex(obj.const1*(real(obj.outMappedReg(2))+imag(obj.outMappedReg(2))),...
                        (obj.const1*(real(obj.outMappedReg(2))-imag(obj.outMappedReg(2)))));
                    end
                    obj.constMul2(:)=obj.const6(2)*real(obj.outMappedReg(3));
                    if(imag(obj.outMappedReg(3))<obj.const6(2)*real(obj.outMappedReg(3)))
                        obj.outMappedReg(4,:)=obj.outMappedReg(3);
                    else
                        obj.outMappedReg(4,:)=complex(real(obj.outMappedReg(3))*obj.const2+imag(obj.outMappedReg(3))*obj.const3,...
                        (real(obj.outMappedReg(3))*obj.const4-imag(obj.outMappedReg(3))*obj.const5));
                    end
                    obj.outValidReg=true;
                    obj.runMapper=false;
                else
                    obj.outValidReg=false;
                    obj.outMappedReg(:)=0;
                end
            else
                obj.outValidReg=false;
                obj.outMappedReg(:)=0;
            end
        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.outMappedReg;
            varargout{2}=obj.outValidReg;
        end

        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end

        function num=getNumInputsImpl(~)

            num=3;
        end

        function num=getNumOutputsImpl(~)


            num=2;
        end

        function flag=isInputComplexityMutableImpl(~,~)

            flag=true;
        end
    end

end
