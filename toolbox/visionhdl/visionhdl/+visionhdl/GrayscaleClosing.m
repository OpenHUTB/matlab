classdef GrayscaleClosing<visionhdl.internal.abstractLineMemoryKernel













































































%#codegen
%#ok<*EMCLS>

    properties(Nontunable)





        Neighborhood=ones(3,3);





        LineBufferSize=2048;
    end

    properties(Access=private)
        herosion;
        hdilation;

    end

    properties(Nontunable,Access=private)
        kHeight=3;
        kWidth=3;
        linebufferDelay=1;
        hdlDelay=1;

        ctrlregDelay=2;
    end



    methods(Static,Access=protected)
        function header=getHeaderImpl


            header=matlab.system.display.Header('visionhdl.GrayscaleClosing',...
            'ShowSourceLink',false,...
            'Title','Grayscale Closing');
        end












    end

    methods
        function obj=GrayscaleClosing(varargin)
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


            validateattributes(val,{'logical','double','single'},{'2d','binary'},'','Neighborhood');
            [height,width]=size(val);
            validateattributes(height,{'numeric'},{'scalar','<=',32},'','first dimension of Neighborhood');
            validateattributes(width,{'numeric'},{'scalar','<=',32},'','second dimension of Neighborhood');

            if isempty(coder.target)||~eml_ambiguous_types
                if~(any(val(:)))
                    coder.internal.error('visionhdl:GrayscaleMorphology:NeighborhoodZeros');
                end




                if height==1

                    if sum(double(val(:)))~=width
                        coder.internal.error('visionhdl:GrayscaleMorphology:RowVector');
                    end

                    if width<8
                        coder.internal.error('visionhdl:GrayscaleMorphology:RowVectorMin');
                    end



                end

            end


            obj.Neighborhood=val;

        end

        function set.LineBufferSize(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'','MinLineSize');
            obj.LineBufferSize=val;
        end

    end

    methods(Access=protected)


        function[pixelOut,ctrlOut]=outputImpl(obj,pixelIn,ctrlIn)



            [pixelOutd,ctrlOutd]=output(obj.hdilation,pixelIn,ctrlIn);

            [pixelOut,ctrlOut]=output(obj.herosion,pixelOutd,ctrlOutd);



        end

        function updateImpl(obj,pixelIn,ctrlIn)



            [pixelOutd,ctrlOutd]=step(obj.hdilation,pixelIn,ctrlIn);

            update(obj.herosion,pixelOutd,ctrlOutd);



        end

        function resetImpl(obj)


            reset(obj.hdilation);
            reset(obj.herosion);

        end

        function setupImpl(obj,pixelIn,ctrlIn)


            if isempty(coder.target)||~eml_ambiguous_types


                validateattributes(pixelIn,{'double','single','uint8','uint16','uint32','uint64','embedded.fi'},{'scalar','integer'},'','pixelIn');
                if isfi(pixelIn)
                    coder.internal.errorIf(strcmpi(pixelIn.Signedness,'Signed'),...
                    'visionhdl:GrayscaleMorphology:signedType');
                    coder.internal.errorIf(pixelIn.FractionLength>0,...
                    'visionhdl:GrayscaleMorphology:FractionalBits');
                end
                validatecontrolsignals(ctrlIn);
            end

            hdilate=visionhdl.GrayscaleDilation;
            hdilate.Neighborhood=obj.Neighborhood;
            hdilate.LineBufferSize=obj.LineBufferSize;
            obj.hdilation=hdilate;

            herode=visionhdl.GrayscaleErosion;
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

            icon='Grayscale Closing';
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



        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.herosion=obj.herosion;
                s.hdilation=obj.hdilation;
                s.kHeight=obj.kHeight;
                s.kWidth=obj.kWidth;
                s.linebufferDelay=obj.linebufferDelay;
                s.hdlDelay=obj.hdlDelay;
                s.ctrlregDelay=obj.ctrlregDelay;

            end
        end




        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
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

