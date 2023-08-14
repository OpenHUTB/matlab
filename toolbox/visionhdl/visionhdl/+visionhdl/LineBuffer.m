classdef(StrictDefaults)LineBuffer<visionhdl.internal.abstractLineMemoryKernel


























































































%#codegen

    properties(Nontunable)




        NeighborhoodSize=[3,3];




        PaddingMethod='Symmetric';





        PaddingValue=0;





        LineBufferSize=2048;
    end

    properties(Nontunable,Access=private)
        pKernelHeight=5;
        pKernelWidth=5;
    end

    properties(Constant,Hidden)
        PaddingMethodSet=matlab.system.StringSet({...
        'Constant',...
        'Replicate',...
        'Symmetric',...
        'Reflection',...
        'None'});
    end

    properties(Access=private)
        dataVectorREG;
        controlVectorREG;
        processDataREG;
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl

            header=matlab.system.display.Header('visionhdl.LineBuffer',...
            'ShowSourceLink',false,...
            'Title','Line Buffer');
        end
    end

    methods
        function obj=LineBuffer(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','Vision_HDL_Toolbox'))
                    error(message('visionhdl:visionhdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','Vision_HDL_Toolbox');
            end
            setProperties(obj,nargin,varargin{:},'NeighborhoodSize');
        end


        function set.NeighborhoodSize(obj,val)
            validateattributes(val,{'numeric'},{'integer','>',0},'LineBuffer','NeighborhoodSize');
            [height,width]=size(val);
            if height>1||height==0||width==0
                coder.internal.error('visionhdl:LineBuffer:NeighborhoodLength');
            end

            if width>2
                coder.internal.error('visionhdl:LineBuffer:NeighborhoodLength');
            end

            if val(1)==1&&val(2)==1
                coder.internal.error('visionhdl:LineBuffer:KernelSize');
            end

            obj.NeighborhoodSize=val;
        end


        function set.LineBufferSize(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'LineBuffer','LineBufferSize');
            obj.LineBufferSize=val;
        end


        function set.PaddingValue(obj,val)
            validateattributes(val,{'numeric','logical','integer','real'},{'scalar'},'LineBuffer','PaddingValue');

            if isnan(val)
                coder.internal.error('visionhdl:LineBuffer:PaddingInvalid');
            end

            obj.PaddingValue=val;
        end

    end

    methods(Access=protected)
        function validateInputsImpl(obj,pixelIn,~)

            validateattributes(pixelIn,{'numeric','embedded.fi','logical'},{'real'},'LineBuffer','pixelIn');

            validateKernelMemoryConfiguration(obj,pixelIn,obj.NeighborhoodSize);
        end

        function[dataVectorOut,ctrlOut,shiftEnable]=outputImpl(obj,~,~)
            dataVectorOut=obj.dataVectorREG;
            ctrlOut=obj.controlVectorREG;
            shiftEnable=obj.processDataREG;
        end

        function updateImpl(obj,dataIn,ctrlIn)
            [dataVector,hStartOut,hEndOut,vStartOut,vEndOut,validOut,processDataOut]=...
            stepKernelMemory(obj,dataIn,ctrlIn.hStart,ctrlIn.hEnd,ctrlIn.vStart,ctrlIn.vEnd,ctrlIn.valid);

            obj.dataVectorREG(:)=dataVector;
            obj.controlVectorREG.hStart=hStartOut;
            obj.controlVectorREG.hEnd=hEndOut;
            obj.controlVectorREG.vStart=vStartOut;
            obj.controlVectorREG.vEnd=vEndOut;
            obj.controlVectorREG.valid=validOut;
            obj.processDataREG=processDataOut;
        end


        function resetImpl(obj)
            resetKernelMemoryStates(obj);
            obj.dataVectorREG(:)=0;
            obj.controlVectorREG=pixelcontrolstruct(false,false,false,false,false);
            obj.processDataREG=false;
        end

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case{'PaddingValue'}
                if~strcmp(obj.PaddingMethod,'Constant')
                    flag=true;
                end
            end
        end


        function setupImpl(obj,pixelIn,ctrlIn)
            if length(obj.NeighborhoodSize)==2
                obj.pKernelHeight=obj.NeighborhoodSize(1);
                obj.pKernelWidth=obj.NeighborhoodSize(2);
            else
                obj.pKernelHeight=obj.NeighborhoodSize(1);
                obj.pKernelWidth=obj.NeighborhoodSize(1);
            end


            obj.KernelMemoryKernelHeight=obj.pKernelHeight;
            obj.KernelMemoryKernelWidth=obj.pKernelWidth;
            obj.KernelMemoryMaxLineSize=obj.LineBufferSize;
            obj.KernelMemoryPaddingMethod=obj.PaddingMethod;
            obj.KernelMemoryPaddingValue=obj.PaddingValue;
            obj.KernelMemoryBiasUp=true;

            setupKernelMemory(obj,pixelIn,ctrlIn.hStart,ctrlIn.hEnd,ctrlIn.vStart,ctrlIn.vEnd,ctrlIn.valid);

            obj.dataVectorREG=cast(zeros(obj.pKernelHeight,length(pixelIn)),'like',pixelIn);
            obj.controlVectorREG=pixelcontrolstruct(false,false,false,false,false);
            obj.processDataREG=false;
        end


        function num=getNumInputsImpl(~)
            num=2;
        end


        function num=getNumOutputsImpl(~)
            num=3;
        end


        function icon=getIconImpl(~)
            icon='Line Buffer';
        end


        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='pixel';
            varargout{2}='ctrl';
        end


        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='pixel';
            varargout{2}='ctrl';
            varargout{3}='shiftEnable';
        end


        function[sz1,sz2,sz3]=getOutputSizeImpl(obj,varargin)
            sz1=[obj.NeighborhoodSize(1),propagatedInputSize(obj,1)];
            sz2=propagatedInputSize(obj,2);
            sz3=1;
        end

        function[cp1,cp2,cp3]=isOutputComplexImpl(obj)
            cp1=propagatedInputComplexity(obj,1);
            cp2=propagatedInputComplexity(obj,2);
            cp3=propagatedInputComplexity(obj,2);

        end

        function[dt1,dt2,dt3]=getOutputDataTypeImpl(obj)
            dt1=propagatedInputDataType(obj,1);
            dt2=pixelcontrolbustype;
            dt3='logical';
        end

        function[sz1,sz2,sz3]=isOutputFixedSizeImpl(obj)
            sz1=propagatedInputFixedSize(obj,1);
            sz2=propagatedInputFixedSize(obj,2);
            sz3=propagatedInputFixedSize(obj,2);
        end


        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);
            s=saveObjectKernelMemory(obj,s);

            if obj.isLocked
                s.dataVectorREG=obj.dataVectorREG;
                s.controlVectorREG=obj.controlVectorREG;
                s.processDataREG=obj.processDataREG;
                s.pKernelHeight=obj.pKernelHeight;
                s.pKernelWidth=obj.pKernelWidth;


            end
        end


        function loadObjectImpl(obj,s,~)
            loadObjectKernelMemory(obj,s);
            fn=fieldnames(s);
            for ii=1:numel(fn)
                if~isempty(findprop(obj,fn{ii}))
                    obj.(fn{ii})=s.(fn{ii});
                end
            end
        end


        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end

    end

    methods(Static,Access=protected)
        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end
    end

    methods(Access=protected)
        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end
    end

end
