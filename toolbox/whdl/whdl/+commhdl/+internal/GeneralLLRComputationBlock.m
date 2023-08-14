classdef GeneralLLRComputationBlock<matlab.System


%#codegen


    properties(Access=private)
inpCompReg1
inpCompReg2
outReg
outValidReg
inp1RealReg
inp1ImagReg
inp2RealReg
inp2ImagReg
mulRealReg1
mulImagReg1
mulRealReg2
mulImagReg2
computeReg1
computeReg2
runLLRComp
    end

    methods

        function obj=GeneralLLRComputationBlock(varargin)
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
            sizeIn=size(dIn);
            maxSizeIn=max(sizeIn);
            if(~isfloat(dIn))
                bitGrowth=0;

                inpData=dIn;
                obj.inpCompReg1=fi(zeros(maxSizeIn,1)+1i*zeros(maxSizeIn,1),1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                obj.inpCompReg2=fi(zeros(maxSizeIn,1)+1i*zeros(maxSizeIn,1),1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                obj.outReg=fi(zeros(maxSizeIn,1),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                obj.inp1RealReg=fi(zeros(maxSizeIn,1),1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                obj.inp1ImagReg=fi(zeros(maxSizeIn,1),1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                obj.inp2RealReg=fi(zeros(maxSizeIn,1),1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                obj.inp2ImagReg=fi(zeros(maxSizeIn,1),1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                obj.mulRealReg1=fi(zeros(maxSizeIn,1),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                obj.mulImagReg1=fi(zeros(maxSizeIn,1),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                obj.mulRealReg2=fi(zeros(maxSizeIn,1),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                obj.mulImagReg2=fi(zeros(maxSizeIn,1),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                obj.computeReg1=fi(zeros(maxSizeIn,1),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);
                obj.computeReg2=fi(zeros(maxSizeIn,1),1,inpData.WordLength+bitGrowth,inpData.FractionLength,hdlfimath);

            else
                obj.inpCompReg1=cast(zeros(maxSizeIn,1)+1i*zeros(maxSizeIn,1),'like',dIn);
                obj.inpCompReg2=cast(zeros(maxSizeIn,1)+1i*zeros(maxSizeIn,1),'like',dIn);
                obj.outReg=cast(zeros(maxSizeIn,1),'like',real(dIn));
                obj.inp1RealReg=cast(zeros(maxSizeIn,1),'like',real(dIn));
                obj.inp1ImagReg=cast(zeros(maxSizeIn,1),'like',real(dIn));
                obj.inp2RealReg=cast(zeros(maxSizeIn,1),'like',real(dIn));
                obj.inp2ImagReg=cast(zeros(maxSizeIn,1),'like',real(dIn));
                obj.mulRealReg1=cast(zeros(maxSizeIn,1),'like',real(dIn));
                obj.mulImagReg1=cast(zeros(maxSizeIn,1),'like',real(dIn));
                obj.mulRealReg2=cast(zeros(maxSizeIn,1),'like',real(dIn));
                obj.mulImagReg2=cast(zeros(maxSizeIn,1),'like',real(dIn));
                obj.computeReg1=cast(zeros(maxSizeIn,1),'like',real(dIn));
                obj.computeReg2=cast(zeros(maxSizeIn,1),'like',real(dIn));

            end
            obj.outValidReg=false;
            obj.runLLRComp=false;
        end

        function resetImpl(obj)

            obj.inpCompReg1(:)=0;
            obj.inpCompReg2(:)=0;
            obj.outReg(:)=0;
            obj.inp1RealReg(:)=0;
            obj.inp1ImagReg(:)=0;
            obj.inp2RealReg(:)=0;
            obj.inp2ImagReg(:)=0;
            obj.mulRealReg1(:)=0;
            obj.mulImagReg1(:)=0;
            obj.mulRealReg2(:)=0;
            obj.mulImagReg2(:)=0;
            obj.computeReg1(:)=0;
            obj.computeReg2(:)=0;
            obj.outValidReg=false;
            obj.runLLRComp=false;
        end


        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.inpCompReg1=obj.inpCompReg1;
                s.inpCompReg2=obj.inpCompReg2;
                s.outReg=obj.outReg;
                s.inp1RealReg=obj.inp1RealReg;
                s.inp1ImagReg=obj.inp1ImagReg;
                s.inp2RealReg=obj.inp2RealReg;
                s.inp2ImagReg=obj.inp2ImagReg;
                s.mulRealReg1=obj.mulRealReg1;
                s.mulImagReg1=obj.mulImagReg1;
                s.mulRealReg2=obj.mulRealReg2;
                s.mulImagReg2=obj.mulImagReg2;
                s.computeReg1=obj.computeReg1;
                s.computeReg2=obj.computeReg2;
                s.outValidReg=obj.outValidReg;
                s.runLLRComp=obj.runLLRComp;
            end
        end

        function updateImpl(obj,varargin)

            if(varargin{3}==true)
                obj.inpCompReg1(:)=varargin{1};
                obj.inpCompReg2(:)=varargin{2};
                obj.inp1RealReg(:)=real(obj.inpCompReg1);
                obj.inp1ImagReg(:)=imag(obj.inpCompReg1);
                obj.inp2RealReg(:)=real(obj.inpCompReg2);
                obj.inp2ImagReg(:)=imag(obj.inpCompReg2);
                obj.runLLRComp=true;
            else
                obj.runLLRComp=false;
            end

            if(obj.runLLRComp)
                obj.mulRealReg1(:)=obj.inp1RealReg.*obj.inp1RealReg;
                obj.mulImagReg1(:)=obj.inp1ImagReg.*obj.inp1ImagReg;
                obj.mulRealReg2(:)=obj.inp2RealReg.*obj.inp2RealReg;
                obj.mulImagReg2(:)=obj.inp2ImagReg.*obj.inp2ImagReg;

                obj.computeReg1(:)=obj.mulRealReg1+obj.mulImagReg1;
                obj.computeReg2(:)=obj.mulRealReg2+obj.mulImagReg2;
                obj.outReg(:)=obj.computeReg1-obj.computeReg2;
                obj.outValidReg=true;
            else
                obj.outReg(:)=0;
                obj.outValidReg(:)=false;
            end
        end

        function varargout=outputImpl(obj,varargin)

            varargout{1}=obj.outReg;
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
