classdef QAMSymbolConverter<matlab.System


%#codegen


    properties(Access=private)
inpReg
inpmReg
inpValid
outQPhase
outInPhase
IPhaseoutReg
QPhaseoutReg
outValidReg
RealReg
ImagReg
runMapper
validI
validQ
scaleFactor
        CurrValue;
        outReg;
        LValues;
        LValues02;
        LValues04;
        LValues08;
        LValues16;
        tempOutReg;
        CurrLValue;
inpValidReg
    end

    methods

        function obj=QAMSymbolConverter(varargin)
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
            if~isfloat(dIn)
                inpData=dIn;

                obj.inpReg=fi(0+0*1i,1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                obj.RealReg=fi(0,1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                obj.ImagReg=fi(0,1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                obj.inpmReg=fi(0,0,4,0,hdlfimath);
                obj.scaleFactor=fi(1,0,16,11,hdlfimath);
                obj.outQPhase=fi(zeros(9,1),1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                obj.outInPhase=fi(zeros(9,1),1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                obj.IPhaseoutReg=fi(zeros(9,1),1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                obj.QPhaseoutReg=fi(zeros(9,1),1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                obj.tempOutReg=fi(zeros(9,1),1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                obj.outReg=fi(zeros(9,1),1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                obj.LValues=fi([2,4,8,16],1,16,11,hdlfimath);
                obj.CurrLValue=fi(zeros(7,1),1,16,11,hdlfimath);
                obj.CurrValue=fi(0,1,16,11,hdlfimath);
                obj.LValues02=fi(2./(2.^[1,2,3,4,5,6,7]),1,16,11,hdlfimath);
                obj.LValues04=fi(4./(2.^[1,2,3,4,5,6,7]),1,16,11,hdlfimath);
                obj.LValues08=fi(8./(2.^[1,2,3,4,5,6,7]),1,16,11,hdlfimath);
                obj.LValues16=fi(16./(2.^[1,2,3,4,5,6,7]),1,16,11,hdlfimath);
            else
                obj.inpReg=cast(0+0*1i,'like',dIn);
                obj.RealReg=cast(0,'like',real(dIn));
                obj.ImagReg=cast(0,'like',real(dIn));
                obj.inpmReg=cast(0,'like',real(dIn));
                obj.scaleFactor=cast(1,'like',real(dIn));
                obj.outQPhase=cast(zeros(9,1),'like',real(dIn));
                obj.outInPhase=cast(zeros(9,1),'like',real(dIn));

                obj.IPhaseoutReg=cast(zeros(9,1),'like',real(dIn));
                obj.QPhaseoutReg=cast(zeros(9,1),'like',real(dIn));

                obj.CurrValue=cast(0,'like',real(dIn));
                obj.CurrLValue=cast(zeros(7,1),'like',real(dIn));
                obj.tempOutReg=cast(zeros(9,1),'like',real(dIn));
                obj.outReg=cast(zeros(9,1),'like',real(dIn));
                obj.LValues=cast([2,4,8,16],'like',real(dIn));
                obj.LValues02=cast(2./(2.^[1,2,3,4,5,6,7]),'like',real(dIn));
                obj.LValues04=cast(4./(2.^[1,2,3,4,5,6,7]),'like',real(dIn));
                obj.LValues08=cast(8./(2.^[1,2,3,4,5,6,7]),'like',real(dIn));
                obj.LValues16=cast(16./(2.^[1,2,3,4,5,6,7]),'like',real(dIn));
            end

            obj.inpValid=false;
            obj.validI=false;
            obj.validQ=false;
            obj.outValidReg=false;
            obj.runMapper=false;
            obj.inpValidReg=false;
        end

        function resetImpl(obj)

            obj.inpReg(:)=0;
            obj.RealReg(:)=0;
            obj.ImagReg(:)=0;
            obj.inpmReg(:)=0;
            obj.scaleFactor(:)=1;
            obj.outQPhase(:)=0;
            obj.outInPhase(:)=0;
            obj.IPhaseoutReg(:)=0;
            obj.QPhaseoutReg(:)=0;
            obj.outValidReg=false;
            obj.runMapper=false;
            obj.validI=false;
            obj.validQ=false;
            obj.inpValid=false;
            obj.CurrValue(:)=0;
            obj.CurrLValue(:)=0;
            obj.tempOutReg(:)=0;
            obj.outReg(:)=0;
            obj.scaleFactor(:)=1;
            obj.inpValidReg=false;
        end


        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.inpReg=obj.inpReg;
                s.RealReg=obj.RealReg;
                s.ImagReg=obj.ImagReg;
                s.inpmReg=obj.inpmReg;
                s.scaleFactor=obj.scaleFactor;
                s.outQPhase=obj.outQPhase;
                s.outInPhase=obj.outInPhase;
                s.IPhaseoutReg=obj.IPhaseoutReg;
                s.QPhaseoutReg=obj.QPhaseoutReg;
                s.outValidReg=obj.outValidReg;
                s.runMapper=obj.runMapper;
                s.validI=obj.validI;
                s.validQ=obj.validQ;
                s.inpValid=obj.inpValid;
                s.CurrValue=obj.CurrValue;
                s.CurrLValue=obj.CurrLValue;
                s.tempOutReg=obj.tempOutReg;
                s.outReg=obj.outReg;
                s.LValues=obj.LValues;
                s.scaleFactor=obj.scaleFactor;
                s.LValues02=obj.LValues02;
                s.LValues04=obj.LValues04;
                s.LValues08=obj.LValues08;
                s.LValues16=obj.LValues16;
                s.outValidReg=obj.outValidReg;
                s.inpValidReg=obj.inpValidReg;
            end
        end

        function updateImpl(obj,varargin)


            obj.inpValid=varargin{4};
            if(obj.inpValid==true)
                obj.inpReg(:)=varargin{1};
                obj.inpmReg(:)=varargin{2};
                obj.scaleFactor(:)=varargin{3};
                obj.runMapper=true;

                obj.RealReg(:)=abs(real(obj.inpReg));
                obj.ImagReg(:)=abs(imag(obj.inpReg));
            else
                obj.RealReg(:)=0;
                obj.ImagReg(:)=0;
                obj.inpmReg(:)=0;
                obj.runMapper=false;
            end

            [obj.IPhaseoutReg(:),obj.validI]=obj.QAMrecMapper(obj.RealReg,obj.inpmReg,obj.scaleFactor,obj.inpValid);
            [obj.QPhaseoutReg(:),obj.validQ]=obj.QAMrecMapper(obj.ImagReg,obj.inpmReg,obj.scaleFactor,obj.inpValid);
            obj.outValidReg=obj.validI&&obj.validQ;

            if(~obj.outValidReg)
                obj.IPhaseoutReg(:)=0;
                obj.QPhaseoutReg(:)=0;
            end
        end


        function[data,valid]=QAMrecMapper(obj,RealReg,inpmReg,scaleFactor,inpValid)

            obj.inpValidReg=inpValid;
            if(obj.inpValidReg==true)
                obj.inpReg(:)=RealReg;
                obj.inpmReg(:)=inpmReg;
                obj.scaleFactor(:)=scaleFactor;

                if(obj.inpmReg==4)
                    obj.CurrLValue(:)=obj.LValues02*obj.scaleFactor;
                    obj.CurrValue(:)=obj.LValues(1)*obj.scaleFactor;
                elseif(obj.inpmReg==6)
                    obj.CurrLValue(:)=obj.LValues04*obj.scaleFactor;
                    obj.CurrValue(:)=obj.LValues(2)*obj.scaleFactor;
                elseif(obj.inpmReg==8)
                    obj.CurrLValue(:)=obj.LValues08*obj.scaleFactor;
                    obj.CurrValue(:)=obj.LValues(3)*obj.scaleFactor;
                end

                obj.tempOutReg(1,:)=abs(obj.inpReg);
                obj.tempOutReg(2,:)=obj.CurrValue(1)-abs(obj.CurrValue(1)-obj.tempOutReg(1));
                obj.tempOutReg(3,:)=obj.CurrLValue(1)-abs(obj.CurrLValue(1)-obj.tempOutReg(2));
                obj.tempOutReg(4,:)=obj.CurrLValue(2)-abs(obj.CurrLValue(2)-obj.tempOutReg(3));
                obj.tempOutReg(5,:)=obj.CurrLValue(3)-abs(obj.CurrLValue(3)-obj.tempOutReg(4));
                obj.tempOutReg(6,:)=obj.CurrLValue(4)-abs(obj.CurrLValue(4)-obj.tempOutReg(5));
                obj.tempOutReg(7,:)=obj.CurrLValue(5)-abs(obj.CurrLValue(5)-obj.tempOutReg(6));

                if(obj.inpmReg==4)
                    obj.outReg(1,:)=obj.tempOutReg(1);
                    obj.outReg(2,:)=obj.tempOutReg(2);
                    obj.outReg(3,:)=obj.tempOutReg(3);
                elseif(obj.inpmReg==6)
                    obj.outReg(1,:)=obj.tempOutReg(1);
                    obj.outReg(2,:)=obj.tempOutReg(2);
                    obj.outReg(3,:)=obj.tempOutReg(3);
                    obj.outReg(4,:)=obj.tempOutReg(4);
                    obj.outReg(5,:)=obj.tempOutReg(5);
                elseif(obj.inpmReg==8)
                    obj.outReg(1,:)=obj.tempOutReg(1);
                    obj.outReg(2,:)=obj.tempOutReg(2);
                    obj.outReg(3,:)=obj.tempOutReg(3);
                    obj.outReg(4,:)=obj.tempOutReg(4);
                    obj.outReg(5,:)=obj.tempOutReg(5);
                    obj.outReg(6,:)=obj.tempOutReg(6);
                    obj.outReg(7,:)=obj.tempOutReg(7);
                else
                    obj.outReg(:)=0;
                end

                obj.outValidReg=true;
            else
                obj.outValidReg=false;
                obj.outReg(:)=0;
            end
            data=obj.outReg;
            valid=obj.outValidReg;
        end


        function varargout=outputImpl(obj,varargin)


            varargout{1}=obj.IPhaseoutReg;
            varargout{2}=obj.QPhaseoutReg;
            varargout{3}=obj.outValidReg;
        end

        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end

        function num=getNumInputsImpl(~)

            num=4;
        end

        function num=getNumOutputsImpl(~)


            num=3;
        end

        function flag=isInputComplexityMutableImpl(~,~)

            flag=true;
        end
    end

end
