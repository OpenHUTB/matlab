classdef(StrictDefaults)PixelStreamAligner<matlab.System






















































































%#codegen
%#ok<*EMCLS>

    properties(Nontunable)




        LineBufferSize=2048;



        MaximumNumberOfLines=10;
    end


    properties(Access=private)
        InPixelReg;
        InCtrlReg;
        InRefPixelReg;
        InRefCtrlReg;

        RefPixelPipe;
        RefCtrlPipe;

        BufferSize;
        PixelBuffer;
        ReadPointer;
        WritePointer;
        LineStarts;
        LineStartsValid;
        LineWritePointer;
        LineReadPointer;

        FrameStart;
        FrameStartValid;

        PixelInFrame;
        PixelInLine;
        PixelInFramePrev;
        PixelInLinePrev;

        RefInFrame;
        RefInLine;
        RefInFramePrev;
        RefInLinePrev;
        RefFrameValid;

        InputFunHandle;
        OutputFunHandle;

        OutPixelReg;
        OutRefPixelReg;
        OutRefCtrlReg;
    end

    properties(Access=private,Nontunable)
        PrivNRegions;
    end

    methods
        function obj=PixelStreamAligner(varargin)
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

        function set.LineBufferSize(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'PixelStreamAligner','Line buffer size');
            obj.LineBufferSize=val;
        end
        function set.MaximumNumberOfLines(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','>',1},'PixelStreamAligner','Maximum number of lines');
            obj.MaximumNumberOfLines=val;
        end


    end

    methods(Static,Access=protected)
        function header=getHeaderImpl

            header=matlab.system.display.Header('visionhdl.PixelStreamAligner',...
            'ShowSourceLink',false,...
            'Title','Pixel Stream Aligner');
        end

        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end
    end

    methods(Access=protected)

        function validateInputsImpl(~,pixelIn,ctrlIn,refPixelIn,refCtrlIn)

            if isempty(coder.target)||~eml_ambiguous_types



                validateattributes(pixelIn,{'numeric','embedded.fi','logical'},...
                {'real','nonnan','finite'},'PixelStreamAligner','pixel input');
                validateattributes(refPixelIn,{'numeric','embedded.fi','logical'},...
                {'real','nonnan','finite'},'PixelStreamAligner','reference pixel input');

                if~ismember(size(pixelIn,1),[1,2,4,8])||~ismember(size(refPixelIn,1),[1,2,4,8])
                    coder.internal.error('visionhdl:PixelStreamAligner:InputDimensions');
                end

                if size(pixelIn,1)~=size(refPixelIn,1)
                    coder.internal.error('visionhdl:PixelStreamAligner:SizeMismatch');
                end

                if size(pixelIn,1)>1
                    if~ismember(size(pixelIn,2),[1,3,4])||~ismember(size(refPixelIn,2),[1,3,4])
                        coder.internal.error('visionhdl:PixelStreamAligner:UnsupportedComps');
                    end
                end


                validatecontrolsignals(ctrlIn);
                validatecontrolsignals(refCtrlIn);
            end

        end


        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                if~isempty(findprop(obj,fn{ii}))
                    obj.(fn{ii})=s.(fn{ii});
                end
            end
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);
            if obj.isLocked
                s.InPixelReg=obj.InPixelReg;
                s.InCtrlReg=obj.InCtrlReg;
                s.InRefPixelReg=obj.InRefPixelReg;
                s.InRefCtrlReg=obj.InRefCtrlReg;
                s.RefPixelPipe=obj.RefPixelPipe;
                s.RefCtrlPipe=obj.RefCtrlPipe;
                s.BufferSize=obj.BufferSize;
                s.PixelBuffer=obj.PixelBuffer;
                s.ReadPointer=obj.ReadPointer;
                s.WritePointer=obj.WritePointer;
                s.LineStarts=obj.LineStarts;
                s.LineStartsValid=obj.LineStartsValid;
                s.LineWritePointer=obj.LineWritePointer;
                s.LineReadPointer=obj.LineReadPointer;
                s.FrameStart=obj.FrameStart;
                s.FrameStartValid=obj.FrameStartValid;
                s.PixelInFrame=obj.PixelInFrame;
                s.PixelInLine=obj.PixelInLine;
                s.PixelInFramePrev=obj.PixelInFramePrev;
                s.PixelInLinePrev=obj.PixelInLinePrev;

                s.RefInFrame=obj.RefInFrame;
                s.RefInLine=obj.RefInLine;
                s.RefInFramePrev=obj.RefInFramePrev;
                s.RefInLinePrev=obj.RefInLinePrev;
                s.RefFrameValid=obj.RefFrameValid;
                s.InputFunHandle=obj.InputFunHandle;
                s.OutputFunHandle=obj.OutputFunHandle;
                s.OutPixelReg=obj.OutPixelReg;
                s.OutRefPixelReg=obj.OutRefPixelReg;
                s.OutRefCtrlReg=obj.OutRefCtrlReg;
            end
        end

        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end


        function setupImpl(obj,pixel,~,refPixel,~)
            resetImpl(obj);
            obj.InPixelReg=cast(zeros(size(pixel,1),size(pixel,2)),'like',pixel);
            obj.InCtrlReg=pixelcontrolstruct(false,false,false,false,false);
            obj.InRefPixelReg=cast(zeros(size(refPixel,1),size(refPixel,2)),'like',refPixel);
            obj.InRefCtrlReg=pixelcontrolstruct(false,false,false,false,false);



            obj.RefPixelPipe=zeros(8,(size(refPixel,1)*size(refPixel,2)),'like',refPixel);
            obj.RefCtrlPipe=repmat(pixelcontrolstruct(false,false,false,false,false),8,1);

            tmpSize=double(2.^(ceil((log2(obj.LineBufferSize)))))*double(2.^(ceil((log2(obj.MaximumNumberOfLines)))));
            obj.BufferSize=tmpSize;
            obj.PixelBuffer=zeros((size(pixel,1)*size(pixel,2)),tmpSize,'like',pixel);
            obj.ReadPointer=1;
            obj.WritePointer=1;
            obj.LineStarts=zeros(size(pixel,1),obj.MaximumNumberOfLines);
            obj.LineStartsValid=false(size(pixel,1),obj.MaximumNumberOfLines);
            obj.LineWritePointer=1;
            obj.LineReadPointer=1;
            obj.OutPixelReg=cast(zeros(size(pixel,1),size(pixel,2)),'like',pixel);
            obj.OutRefPixelReg=cast(zeros(size(refPixel,1),size(refPixel,2)),'like',refPixel);
            obj.OutRefCtrlReg=pixelcontrolstruct(false,false,false,false,false);

            if size(obj.InRefPixelReg,1)>1
                obj.InputFunHandle=@calcInRefTranspose;
                obj.OutputFunHandle=@calcOutRefTranspose;
            else
                obj.InputFunHandle=@calcInRef;
                obj.OutputFunHandle=@calcOutRef;
            end
        end


        function resetImpl(obj)
            obj.PixelInFrame=false;
            obj.PixelInLine=false;
            obj.RefInFrame=false;
            obj.RefInLine=false;
            obj.FrameStart=0;
            obj.FrameStartValid=false;
            obj.RefFrameValid=false;
        end


        function[pixel,refPixel,refCtrl]=outputImpl(obj,pixel,~,refPixel,~)

            refCtrl=obj.OutRefCtrlReg;
            valid=obj.OutRefCtrlReg.valid;

            if(valid==true)
                pixel(:)=obj.OutPixelReg(:);
                refPixel(:)=obj.OutRefPixelReg(:);
            else
                pixel=cast(zeros(size(pixel,1),size(pixel,2)),'like',pixel);
                refPixel=cast(zeros(size(refPixel,1),size(refPixel,2)),'like',refPixel);
            end

        end


        function updateImpl(obj,pixel,ctrl,refPixel,refCtrl)

            refLineFrameFSM(obj);
            pixelLineFrameFSM(obj);


            obj.OutputFunHandle(obj);
            obj.OutRefCtrlReg=obj.RefCtrlPipe(end);

            for ii=size(obj.RefPixelPipe,1):-1:2
                obj.RefPixelPipe(ii,:)=obj.RefPixelPipe(ii-1,:);
                obj.RefCtrlPipe(ii)=obj.RefCtrlPipe(ii-1);
            end

            obj.InputFunHandle(obj);
            obj.RefCtrlPipe(1)=obj.InRefCtrlReg;

            obj.InRefPixelReg(:)=refPixel(:);
            obj.InRefCtrlReg=refCtrl;


            obj.InPixelReg(:)=pixel(:);
            obj.InCtrlReg=ctrl;

        end


        function readPixelData(obj)
            obj.OutPixelReg(:)=obj.PixelBuffer(:,obj.ReadPointer);
            oldReadPointer=obj.ReadPointer;
            if(obj.ReadPointer~=obj.WritePointer)
                obj.ReadPointer=obj.ReadPointer+1;
                if(obj.ReadPointer==obj.BufferSize+1)
                    obj.ReadPointer=1;
                end
            end

            if(obj.ReadPointer==obj.LineStarts(obj.LineReadPointer))&&obj.LineStartsValid(obj.LineReadPointer)
                obj.ReadPointer=oldReadPointer;
            end
        end


        function writePixelData(obj)
            if obj.PixelInFrame&&obj.PixelInLine
                nextWritePointer=obj.WritePointer+1;
                if(nextWritePointer==obj.BufferSize+1)
                    nextWritePointer=1;
                end
                if obj.RefFrameValid&&(nextWritePointer==obj.ReadPointer)
                    coder.internal.warning('visionhdl:PixelStreamAligner:BufferOverflow');
                end
                obj.PixelBuffer(:,obj.WritePointer)=obj.InPixelReg(:);
                obj.WritePointer=nextWritePointer;
            end
        end


        function writeLineStart(obj)
            if(obj.LineStartsValid(obj.LineWritePointer)==true)
                coder.internal.warning('visionhdl:PixelStreamAligner:MaxLinesOverflow');
            end
            obj.LineStarts(obj.LineWritePointer)=obj.WritePointer;
            obj.LineStartsValid(obj.LineWritePointer)=true;
            obj.LineWritePointer=obj.LineWritePointer+1;
            if(obj.LineWritePointer==obj.MaximumNumberOfLines+1)
                obj.LineWritePointer=1;
            end
        end


        function advanceLineStarts(obj)
            if(obj.LineStartsValid(obj.LineReadPointer)&&obj.FrameStartValid&&obj.RefFrameValid)
                obj.ReadPointer=obj.LineStarts(obj.LineReadPointer);
                obj.LineStartsValid(obj.LineReadPointer)=false;
                obj.LineReadPointer=obj.LineReadPointer+1;
                if(obj.LineReadPointer==obj.MaximumNumberOfLines+1)
                    obj.LineReadPointer=1;
                end
            end
        end


        function writeFrameStart(obj)
            obj.FrameStart=obj.WritePointer;
            obj.FrameStartValid=true;
        end


        function pixelLineFrameFSM(obj,varargin)


            obj.PixelInFramePrev=obj.PixelInFrame;
            obj.PixelInLinePrev=obj.PixelInLine;

            if obj.InCtrlReg.valid

                writePixelData(obj);

                if obj.InCtrlReg.vStart
                    obj.PixelInFrame=true;
                    writeFrameStart(obj);
                    if obj.InCtrlReg.hStart
                        obj.PixelInLine=true;
                        writeLineStart(obj);
                        writePixelData(obj);
                    else

                    end
                elseif obj.PixelInFrame&&obj.InCtrlReg.vEnd
                    obj.PixelInFrame=false;
                    if obj.InCtrlReg.hEnd
                        obj.PixelInLine=false;
                    else

                    end
                elseif obj.PixelInFrame&&obj.PixelInLine&&obj.InCtrlReg.hEnd
                    obj.PixelInLine=false;
                elseif obj.PixelInFrame&&obj.InCtrlReg.hStart
                    obj.PixelInLine=true;
                    writeLineStart(obj);
                    writePixelData(obj);
                elseif obj.PixelInFrame&&~obj.PixelInLine&&obj.InCtrlReg.hEnd
                    obj.PixelInLine=false;

                elseif~obj.PixelInFrame&&(obj.InCtrlReg.hStart||obj.InCtrlReg.hEnd)

                end
            end
        end


        function refLineFrameFSM(obj,varargin)


            obj.RefInFramePrev=obj.RefInFrame;
            obj.RefInLinePrev=obj.RefInLine;

            if obj.RefCtrlPipe(end).valid
                if obj.RefCtrlPipe(end).vStart
                    obj.RefInFrame=true;
                    if(obj.FrameStartValid)
                        obj.RefFrameValid=true;
                    end
                    if obj.RefCtrlPipe(end).hStart
                        obj.RefInLine=true;
                        if(obj.FrameStartValid&&obj.RefFrameValid)
                            advanceLineStarts(obj);
                            obj.ReadPointer=obj.FrameStart;
                        end
                    else

                    end
                elseif obj.RefInFrame&&obj.RefCtrlPipe(end).vEnd
                    obj.RefInFrame=false;
                    if(obj.FrameStartValid&&obj.RefFrameValid)
                        readPixelData(obj);
                    end
                    if obj.RefCtrlPipe(end).hEnd
                        obj.RefInLine=false;
                    else

                    end
                elseif obj.RefInFrame&&obj.RefInLine&&obj.RefCtrlPipe(end).hEnd
                    obj.RefInLine=false;
                    if(obj.FrameStartValid&&obj.RefFrameValid)
                        readPixelData(obj);
                    end
                elseif obj.RefInFrame&&obj.RefCtrlPipe(end).hStart
                    obj.RefInLine=true;
                    advanceLineStarts(obj);
                elseif obj.RefInFrame&&~obj.RefInLine&&obj.RefCtrlPipe(end).hEnd
                    obj.RefInLine=false;

                elseif~obj.RefInFrame&&(obj.RefCtrlPipe(end).hStart||obj.RefCtrlPipe(end).hEnd)

                end

                if obj.RefInFrame&&obj.RefInLine
                    if(obj.FrameStartValid&&obj.RefFrameValid)
                        readPixelData(obj);
                    end
                end

            end
        end




        function calcOutRefTranspose(obj)
            obj.OutRefPixelReg(:)=obj.RefPixelPipe(end,:)';
        end




        function calcOutRef(obj)
            obj.OutRefPixelReg(:)=obj.RefPixelPipe(end,:);
        end




        function calcInRefTranspose(obj)
            obj.RefPixelPipe(1,:)=obj.InRefPixelReg(:)';
        end




        function calcInRef(obj)
            obj.RefPixelPipe(1,:)=obj.InRefPixelReg(:);
        end


        function icon=getIconImpl(~)
            icon=sprintf('Pixel Stream\nAligner');
        end


        function varargout=getOutputSizeImpl(obj)
            varargout{1}=propagatedInputSize(obj,1);
            varargout{2}=propagatedInputSize(obj,3);
            varargout{3}=propagatedInputSize(obj,4);
        end


        function varargout=isOutputComplexImpl(obj)
            varargout{1}=propagatedInputComplexity(obj,1);
            varargout{2}=propagatedInputComplexity(obj,3);
            varargout{3}=propagatedInputComplexity(obj,4);
        end


        function varargout=getOutputDataTypeImpl(obj)
            intype=propagatedInputDataType(obj,1);
            intyperef=propagatedInputDataType(obj,3);
            varargout{1}=intype;
            varargout{2}=intyperef;
            varargout{3}=pixelcontrolbustype;
        end


        function varargout=isOutputFixedSizeImpl(obj)
            varargout{1}=propagatedInputFixedSize(obj,1);
            varargout{2}=propagatedInputFixedSize(obj,3);
            varargout{3}=propagatedInputFixedSize(obj,4);
        end


    end

end
