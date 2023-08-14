classdef DataRemBlock<matlab.System


%#codegen


    properties(Access=private)
outReg
outValidReg
    end

    methods

        function obj=DataRemBlock(varargin)
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
                inpData=dIn;
                if(isreal(dIn))
                    obj.outReg=fi(zeros(maxSizeIn,1),1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                else
                    obj.outReg=fi(zeros(maxSizeIn,1)+1i*zeros(maxSizeIn,1),1,inpData.WordLength,inpData.FractionLength,hdlfimath);
                end
            else
                if(isreal(dIn))
                    obj.outReg=cast(zeros(maxSizeIn,1),'like',real(dIn));
                else
                    obj.outReg=cast(zeros(maxSizeIn,1)+1i*zeros(maxSizeIn,1),'like',real(dIn));
                end
            end
            obj.outValidReg=false;
        end

        function resetImpl(obj)

            obj.outReg(:)=0;
            obj.outValidReg=false;
        end


        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.outReg=obj.outReg;
                s.outValidReg=obj.outValidReg;
            end
        end

        function updateImpl(obj,varargin)

            if(varargin{2}==true)
                obj.outReg(:)=varargin{1};
                obj.outValidReg=true;
            else
                obj.outReg(:)=0;
                obj.outValidReg=false;
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


        function flag=isInputSizeMutableImpl(~,~)


            flag=false;
        end

        function num=getNumInputsImpl(~)

            num=2;
        end

        function num=getNumOutputsImpl(~)


            num=2;
        end

    end

end
