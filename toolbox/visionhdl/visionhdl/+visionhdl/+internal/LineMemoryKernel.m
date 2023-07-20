classdef(Hidden)LineMemoryKernel<visionhdl.internal.abstractLineMemoryKernel


%#codegen
%#ok<*EMCLS>

    properties(Nontunable)
        KernelSize=[5,5];
        MaxLineSize=1024;
        PaddingMethod='Constant';
        PaddingValue=0;
        BiasUp=true;
    end

    properties(Constant,Hidden)
        PaddingMethodSet=matlab.system.StringSet({...
        'Constant',...
        'Replicate',...
        'Symmetric',...
        'None'});

    end

    methods
        function obj=LineMemoryKernel(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','Vision_HDL_Toolbox'))
                    error(message('visionhdl:visionhdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','Vision_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:});
        end
    end


    methods(Access=protected)

        function validateInputsImpl(obj,pixelIn,~)

            validateKernelMemoryConfiguration(obj,pixelIn,obj.KernelSize);
        end

        function[dataVector,hStartOut,hEndOut,vStartOut,vEndOut,validOut,processDataOut]=stepImpl...
            (obj,dataIn,hStartIn,hEndIn,vStartIn,vEndIn,validIn)

            hstartOut=false;
            hendOut=false;
            vstartOut=false;
            vendOut=false;
            validOut=false;
            processDataOut=false;
            dataVector=cast(zeros(obj.KernelSize(1),1),'like',dataIn);%#ok

            assert(isa(hstartOut,'logical'));
            assert(isa(hendOut,'logical'));
            assert(isa(vstartOut,'logical'));
            assert(isa(vendOut,'logical'));
            assert(isa(validOut,'logical'));
            assert(isa(processDataOut,'logical'));

            [tmpdataVector,hStartOut,hEndOut,vStartOut,vEndOut,validOut,processDataOut]=stepKernelMemory...
            (obj,dataIn,hStartIn,hEndIn,vStartIn,vEndIn,validIn);
            dataVector(:)=tmpdataVector;
        end

        function setupImpl(obj,dataIn,hStartIn,hEndIn,vStartIn,vEndIn,validIn)
            obj.KernelMemoryKernelHeight=obj.KernelSize(1);
            obj.KernelMemoryKernelWidth=obj.KernelSize(2);
            obj.KernelMemoryMaxLineSize=obj.MaxLineSize;
            obj.KernelMemoryPaddingMethod=obj.PaddingMethod;
            obj.KernelMemoryPaddingValue=obj.PaddingValue;
            obj.KernelMemoryBiasUp=obj.BiasUp;

            setupKernelMemory(obj,dataIn,hStartIn,hEndIn,vStartIn,vEndIn,validIn);
        end


        function[sz1,sz2,sz3,sz4,sz5,sz6,sz7]=getOutputSizeImpl(obj)
            height=obj.KernelSize(1);
            if isempty(height)
                height=5;
            end
            sz1=[height,1];
            sz2=propagatedInputSize(obj,2);
            sz3=propagatedInputSize(obj,3);
            sz4=propagatedInputSize(obj,4);
            sz5=propagatedInputSize(obj,5);
            sz6=propagatedInputSize(obj,6);
            sz7=propagatedInputSize(obj,6);
        end

        function[cp1,cp2,cp3,cp4,cp5,cp6,cp7]=isOutputComplexImpl(obj)
            cp1=propagatedInputComplexity(obj,1);
            cp2=propagatedInputComplexity(obj,2);
            cp3=propagatedInputComplexity(obj,2);
            cp4=propagatedInputComplexity(obj,2);
            cp5=propagatedInputComplexity(obj,2);
            cp6=propagatedInputComplexity(obj,2);
            cp7=propagatedInputComplexity(obj,2);
        end

        function[dt1,dt2,dt3,dt4,dt5,dt6,dt7]=getOutputDataTypeImpl(obj)
            dt1=propagatedInputDataType(obj,1);
            dt2=propagatedInputDataType(obj,2);
            dt3=propagatedInputDataType(obj,2);
            dt4=propagatedInputDataType(obj,2);
            dt5=propagatedInputDataType(obj,2);
            dt6=propagatedInputDataType(obj,2);
            dt7=propagatedInputDataType(obj,2);
        end

        function[sz1,sz2,sz3,sz4,sz5,sz6,sz7]=isOutputFixedSizeImpl(obj)
            sz1=propagatedInputFixedSize(obj,1);
            sz2=propagatedInputFixedSize(obj,2);
            sz3=propagatedInputFixedSize(obj,2);
            sz4=propagatedInputFixedSize(obj,2);
            sz5=propagatedInputFixedSize(obj,2);
            sz6=propagatedInputFixedSize(obj,2);
            sz7=propagatedInputFixedSize(obj,2);
        end


        function loadObjectImpl(obj,s,~)
            loadObjectKernelMemory(obj,s);
            fn=fieldnames(s);
            for ii=1:numel(fn)
                if~isempty(findprop(obj,fn{ii}))%#ok
                    obj.(fn{ii})=s.(fn{ii});%#ok
                end
            end
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);
            s=saveObjectKernelMemory(obj,s);
        end

    end

end
