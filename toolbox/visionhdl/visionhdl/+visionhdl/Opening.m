classdef(StrictDefaults)Opening<visionhdl.internal.abstractLineMemoryKernel













































































%#codegen
%#ok<*EMCLS>

    properties(Nontunable)




        Neighborhood=[0,1,0;1,1,1;0,1,0];





        LineBufferSize=2048;




        PaddingMethod='Constant';
    end

    properties(Access=private)

        herosion;
        hdilation;

    end

    properties(Constant,Hidden)

        PaddingMethodSet=matlab.system.StringSet({...
        'Constant',...
        'None'});

    end

    methods(Static,Access=protected)
        function header=getHeaderImpl


            header=matlab.system.display.Header('visionhdl.Opening',...
            'ShowSourceLink',false,...
            'Title','Opening');
        end

    end

    methods
        function obj=Opening(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','Vision_HDL_Toolbox'))
                    error(message('visionhdl:visionhdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','Vision_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:},'Neighborhood');
        end

        function set.Neighborhood(obj,val)

            validateattributes(val,{'logical','double','single'},{'2d','binary'},'Opening','Neighborhood');
            [height,width]=size(val);
            validateattributes(height,{'numeric'},{'scalar','<=',32,'>',0},'Opening','first dimension of Neighborhood');
            validateattributes(width,{'numeric'},{'scalar','<=',32},'Opening','second dimension of Neighborhood');


            if isempty(coder.target)||~eml_ambiguous_types
                if~(any(val(:)))
                    coder.internal.error('visionhdl:GrayscaleMorphology:NeighborhoodZeros');
                end
            end

            obj.Neighborhood=val;

        end

        function set.LineBufferSize(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'Opening','MaxLineSize');
            obj.LineBufferSize=val;
        end

    end

    methods(Access=protected)
        function validateInputsImpl(~,pixelIn,ctrlIn)

            if isempty(coder.target)||~eml_ambiguous_types



                validateattributes(pixelIn,{'double','single','logical'},{'binary'},'Opening','pixel input');

                if~ismember(size(pixelIn,1),[1,4,8])
                    coder.internal.error('visionhdl:Morphology:InputDimensions');
                end

                if~ismember(size(pixelIn,2),[1])%#ok<NBRAK2>
                    coder.internal.error('visionhdl:Morphology:InputDimensions');
                end

                validatecontrolsignals(ctrlIn);
            end

        end


        function[pixelOut,ctrlOut]=outputImpl(obj,pixelIn,ctrlIn)


            [pixelOute,ctrlOute]=output(obj.herosion,pixelIn,ctrlIn);

            [pixelOut,ctrlOut]=output(obj.hdilation,pixelOute,ctrlOute);
        end


        function updateImpl(obj,pixelIn,ctrlIn)


            [pixelOute,ctrlOute]=step(obj.herosion,pixelIn,ctrlIn);

            update(obj.hdilation,pixelOute,ctrlOute);
        end


        function resetImpl(obj)



            reset(obj.herosion);

            reset(obj.hdilation);
        end


        function setupImpl(obj,pixelIn,~)

            NumberOfPixels=length(pixelIn);

            [kHeight,kWidth]=size(obj.Neighborhood);

            if strcmpi(obj.PaddingMethod,'None')
                if kWidth==2||kHeight==2
                    coder.internal.error('visionhdl:Morphology:PadNoneKernel');
                end
            end

            if NumberOfPixels>1
                if kWidth==2||kHeight==2||kWidth==1||kHeight==1
                    coder.internal.error('visionhdl:Morphology:MultiPixelKernel');
                end
            end

            hdilate=visionhdl.Dilation;
            hdilate.PaddingMethod=obj.PaddingMethod;
            hdilate.Neighborhood=obj.Neighborhood;
            hdilate.LineBufferSize=obj.LineBufferSize;
            obj.hdilation=hdilate;

            herode=visionhdl.Erosion;
            herode.PaddingMethod=obj.PaddingMethod;
            herode.Neighborhood=obj.Neighborhood;
            herode.LineBufferSize=obj.LineBufferSize;
            obj.herosion=herode;
        end


        function num=getNumInputsImpl(~)
            num=2;
        end


        function num=getNumOutputsImpl(~)
            num=2;
        end


        function icon=getIconImpl(~)
            icon='Opening';
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
        end


        function[sz1,sz2]=getOutputSizeImpl(obj)
            sz1=propagatedInputSize(obj,1);
            sz2=propagatedInputSize(obj,2);
        end


        function[cp1,cp2]=isOutputComplexImpl(obj)
            cp1=propagatedInputComplexity(obj,1);
            cp2=propagatedInputComplexity(obj,2);
        end


        function[dt1,dt2]=getOutputDataTypeImpl(obj)
            dt1=propagatedInputDataType(obj,1);
            dt2=pixelcontrolbustype;
        end


        function[sz1,sz2]=isOutputFixedSizeImpl(obj)
            sz1=propagatedInputFixedSize(obj,1);
            sz2=propagatedInputFixedSize(obj,2);
        end


        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end


        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.herosion=matlab.System.saveObject(obj.herosion);
                s.hdilation=matlab.System.saveObject(obj.hdilation);
            end
        end


        function loadObjectImpl(obj,s,wasLocked)
            obj.Neighborhood=s.Neighborhood;
            obj.PaddingMethod=s.PaddingMethod;
            obj.LineBufferSize=s.LineBufferSize;
            if wasLocked
                obj.herosion=matlab.System.loadObject(s.herosion);
                obj.hdilation=matlab.System.loadObject(s.hdilation);
            end
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
