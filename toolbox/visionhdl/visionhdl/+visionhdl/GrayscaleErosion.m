classdef(StrictDefaults)GrayscaleErosion<visionhdl.internal.abstractLineMemoryKernel












































































%#codegen
%#ok<*EMCLS>

    properties(Nontunable)





        Neighborhood=ones(5,5);





        LineBufferSize=2048;
    end

    properties(Access=private)

        vanHerkForwardBuffer;
        vanHerkInputMirror;
        vanHerkOutputMirror;
        vanHerkControlBuffer;
        vanHerkModKCounter;
        vanHerkModKCounterREG;
        vanHerkForwardCurrentMaximum;
        vanHerkBackwardCurrentMaximum;
        vanHerkForwardBufferComplete;
        vanHerkBackwardBufferComplete;
        vanHerkForwardBufferCompleteREG;
        vanHerkForwardFIFOReadCounter;
        vanHerkForwardFIFOWriteCounter;
        vanHerkInputMirrorPingCounter;
        vanHerkInputMirrorPongCounter;
        vanHerkOutputMirrorPingCounter;
        vanHerkOutputMirrorPongCounter;
        vanHerkOutREG;
        vanHerkOutPipe;
        vanHerkMirrorOutput;
        vanHerkLineEndBuffer;
        vanHerkLineEnd;
        vanHerkInitiateFIFO;
        vanHerkValidREG;
        vanHerkOutputControl;
        vanHerkOutputData;
        dataColReg;
        forwardStream;
        backwardStream;
        processfHandle;
        processOutfHandle;
        processDataReg;
        decompositionDataReg;
        decompositionControlReg;
        hVanHerkErosion;
        hLineBuffer;
        pProcessD;
        pEnableControlREG;
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


            header=matlab.system.display.Header('visionhdl.GrayscaleErosion',...
            'ShowSourceLink',false,...
            'Title','Grayscale Erosion');
        end












    end

    methods
        function obj=GrayscaleErosion(varargin)
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
            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'','MaxLineSize');
            obj.LineBufferSize=val;
        end

    end

    methods(Access=protected)

        function[pixelOut,ctrlOut]=outputImpl(obj,pixelIn,ctrlIn)

            [pixelOut,ctrlOut]=obj.processOutfHandle(obj,pixelIn,ctrlIn);
        end

        function updateImpl(obj,pixelIn,ctrlIn)

            obj.processfHandle(obj,pixelIn,ctrlIn);
        end


        function resetImpl(obj)
            obj.vanHerkForwardBuffer(:,:)=0;
            obj.vanHerkInputMirror(:,:)=0;
            obj.vanHerkOutputMirror(:,:)=0;
            obj.vanHerkControlBuffer(:,:)=0;
            obj.vanHerkModKCounter(:)=0;
            obj.vanHerkModKCounterREG(:)=0;
            obj.vanHerkForwardCurrentMaximum(:)=0;
            obj.vanHerkBackwardCurrentMaximum(:)=0;
            obj.vanHerkForwardBufferComplete(:)=0;
            obj.vanHerkBackwardBufferComplete(:)=0;
            obj.vanHerkForwardBufferCompleteREG(:)=0;
            obj.vanHerkForwardFIFOReadCounter(:)=0;
            obj.vanHerkForwardFIFOWriteCounter(:)=0;
            obj.vanHerkInputMirrorPingCounter(:)=0;
            obj.vanHerkInputMirrorPongCounter(:)=0;
            obj.vanHerkOutputMirrorPingCounter(:)=0;
            obj.vanHerkOutputMirrorPongCounter(:)=0;
            obj.vanHerkOutREG(:)=0;
            obj.vanHerkMirrorOutput(:)=0;
            obj.vanHerkLineEndBuffer(:)=0;
            obj.vanHerkLineEnd(:)=0;
            obj.vanHerkInitiateFIFO(:)=0;
            obj.dataColReg(:)=0;
            obj.forwardStream(:)=0;
            obj.backwardStream(:)=0;
            obj.processDataReg(:)=0;
        end


        function setupImpl(obj,pixelIn,ctrlIn)


            if isempty(coder.target)||~eml_ambiguous_types


                validateattributes(pixelIn,{'double','single','uint8','uint16','uint32','uint64','embedded.fi'},{'scalar','integer','real','nonnan','>=',0},'','pixelIn');
                if isfi(pixelIn)
                    coder.internal.errorIf(strcmpi(pixelIn.Signedness,'Signed'),...
                    'visionhdl:GrayscaleMorphology:signedType');
                    coder.internal.errorIf(pixelIn.FractionLength>0,...
                    'visionhdl:GrayscaleMorphology:FractionalBits');
                end
                validatecontrolsignals(ctrlIn);

            end


            [obj.kHeight,obj.kWidth]=size(obj.Neighborhood);







            if obj.kHeight>1&&any(obj.Neighborhood(:)==false)||obj.kWidth<8


                obj.KernelMemoryKernelHeight=obj.kHeight;
                obj.KernelMemoryKernelWidth=(obj.kWidth);
                obj.KernelMemoryMaxLineSize=obj.LineBufferSize;
                obj.KernelMemoryPaddingMethod='Constant';

                obj.KernelMemoryBiasUp=true;

                obj.processfHandle=@fullTreeDilation;
                obj.processOutfHandle=@fullTreeDilationOutput;

            elseif obj.kHeight>1&&obj.kWidth==1


                obj.KernelMemoryKernelHeight=obj.kHeight;
                obj.KernelMemoryKernelWidth=(obj.kWidth);
                obj.KernelMemoryMaxLineSize=obj.LineBufferSize;
                obj.KernelMemoryPaddingMethod='Constant';

                obj.KernelMemoryBiasUp=true;

                obj.processfHandle=@fullTreeDilation;
                obj.processOutfHandle=@fullTreeDilationOutput;


            elseif obj.kHeight>1&&all(obj.Neighborhood(:)==true)



                obj.KernelMemoryKernelHeight=obj.kHeight;
                obj.KernelMemoryKernelWidth=1;
                obj.KernelMemoryMaxLineSize=obj.LineBufferSize;
                obj.KernelMemoryPaddingMethod='Constant';

                obj.KernelMemoryBiasUp=true;
                obj.processfHandle=@decompositionDilation;
                obj.processOutfHandle=@decompositionDilationOutput;


            else

                obj.KernelMemoryKernelHeight=obj.kHeight;
                obj.KernelMemoryKernelWidth=((obj.kWidth)*2)-1;
                obj.KernelMemoryMaxLineSize=obj.LineBufferSize;
                obj.KernelMemoryPaddingMethod='Constant';

                obj.KernelMemoryBiasUp=true;

                obj.processfHandle=@vanHerkDilation;
                obj.processOutfHandle=@vanHerkDilationOutput;

            end

            if isa(pixelIn,'double')
                obj.setupFloat('double',obj.kWidth,obj.kHeight);
            elseif isa(pixelIn,'single')
                obj.setupFloat('single',obj.kWidth,obj.kHeight);
            end


            if isempty(coder.target)||~eml_ambiguous_types
                if isa(pixelIn,'embedded.fi')
                    obj.setupFixed(pixelIn.WordLength,pixelIn.FractionLength,obj.kWidth,obj.kHeight);
                elseif isinteger(pixelIn)
                    if isa(pixelIn,'uint8')
                        obj.setupInteger(8,obj.kWidth,obj.kHeight);
                    elseif isa(pixelIn,'uint16')
                        obj.setupInteger(16,obj.kWidth,obj.kHeight);
                    elseif isa(pixelIn,'uint32')
                        obj.setupInteger(32,obj.kWidth,obj.kHeight);
                    elseif isa(pixelIn,'uint64')
                        obj.setupInteger(64,obj.kWidth,obj.kHeight);
                    end

                end
                a=realmax;
                obj.KernelMemoryPaddingValue=a;
                setupKernelMemory(obj,pixelIn,ctrlIn.hStart,ctrlIn.hEnd,ctrlIn.vStart,ctrlIn.vEnd,ctrlIn.valid);

            end

            obj.pProcessD=false;
            obj.pEnableControlREG=false(5,ceil(obj.kWidth/2));


        end





        function num=getNumInputsImpl(~)
            num=2;
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end


        function icon=getIconImpl(~)

            icon='Grayscale Erosion';
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
            s=saveObjectKernelMemory(obj,s);

            if obj.isLocked
                s.vanHerkForwardBuffer=obj.vanHerkForwardBuffer;
                s.vanHerkInputMirror=obj.vanHerkInputMirror;
                s.vanHerkOutputMirror=obj.vanHerkOutputMirror;
                s.vanHerkControlBuffer=obj.vanHerkControlBuffer;
                s.vanHerkModKCounter=obj.vanHerkModKCounter;
                s.vanHerkModKCounterREG=obj.vanHerkModKCounterREG;
                s.vanHerkForwardCurrentMaximum=obj.vanHerkForwardCurrentMaximum;
                s.vanHerkBackwardCurrentMaximum=obj.vanHerkBackwardCurrentMaximum;
                s.vanHerkForwardBufferComplete=obj.vanHerkForwardBufferComplete;
                s.vanHerkBackwardBufferComplete=obj.vanHerkBackwardBufferComplete;
                s.vanHerkForwardBufferCompleteREG=obj.vanHerkForwardBufferCompleteREG;
                s.vanHerkForwardFIFOReadCounter=obj.vanHerkForwardFIFOReadCounter;
                s.vanHerkForwardFIFOWriteCounter=obj.vanHerkForwardFIFOWriteCounter;
                s.vanHerkInputMirrorPingCounter=obj.vanHerkInputMirrorPingCounter;
                s.vanHerkInputMirrorPongCounter=obj.vanHerkInputMirrorPongCounter;
                s.vanHerkOutputMirrorPingCounter=obj.vanHerkOutputMirrorPingCounter;
                s.vanHerkOutputMirrorPongCounter=obj.vanHerkOutputMirrorPongCounter;
                s.vanHerkOutREG=obj.vanHerkOutREG;
                s.vanHerkOutPipe=obj.vanHerkOutPipe;
                s.vanHerkMirrorOutput=obj.vanHerkMirrorOutput;
                s.vanHerkLineEndBuffer=obj.vanHerkLineEndBuffer;
                s.vanHerkLineEnd=obj.vanHerkLineEnd;
                s.vanHerkInitiateFIFO=obj.vanHerkInitiateFIFO;
                s.vanHerkValidREG=obj.vanHerkValidREG;
                s.vanHerkOutputControl=obj.vanHerkOutputControl;
                s.vanHerkOutputData=obj.vanHerkOutputData;
                s.dataColReg=obj.dataColReg;
                s.forwardStream=obj.forwardStream;
                s.backwardStream=obj.backwardStream;
                s.processfHandle=obj.processfHandle;
                s.processOutfHandle=obj.processOutfHandle;
                s.processDataReg=obj.processDataReg;
                s.decompositionDataReg=obj.decompositionDataReg;
                s.decompositionControlReg=obj.decompositionControlReg;
                s.hVanHerkErosion=obj.hVanHerkErosion;
                s.hLineBuffer=obj.hLineBuffer;
                s.kHeight=obj.kHeight;
                s.kWidth=obj.kWidth;
                s.linebufferDelay=obj.linebufferDelay;
                s.hdlDelay=obj.hdlDelay;
                s.ctrlregDelay=obj.ctrlregDelay;
                s.pProcessD=obj.pProcessD;
                s.pEnableControlREG=obj.pEnableControlREG;

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

    methods(Access=private)















        function vanHerkDilation(obj,pixelIn,controlIn)
            [hStartIn,hEndIn,vStartIn,vEndIn,validIn]=pixelcontrolsignals(controlIn);

            [data,hStart,hEnd,vStart,vEnd,valid,processData]=...
            stepKernelMemory(obj,pixelIn,hStartIn,hEndIn,vStartIn,vEndIn,validIn);


            obj.vanHerkControlBuffer(1,2:end)=obj.vanHerkControlBuffer(1,1:end-1);
            obj.vanHerkControlBuffer(2,2:end)=obj.vanHerkControlBuffer(2,1:end-1);
            obj.vanHerkControlBuffer(3,2:end)=obj.vanHerkControlBuffer(3,1:end-1);
            obj.vanHerkControlBuffer(4,2:end)=obj.vanHerkControlBuffer(4,1:end-1);
            obj.vanHerkControlBuffer(5,2:end)=obj.vanHerkControlBuffer(5,1:end-1);
            obj.vanHerkControlBuffer(6,2:end)=obj.vanHerkControlBuffer(6,1:end-1);


            obj.vanHerkControlBuffer(1,1)=hStart;
            obj.vanHerkControlBuffer(2,1)=hEnd;
            obj.vanHerkControlBuffer(3,1)=vStart;
            obj.vanHerkControlBuffer(4,1)=vEnd;
            obj.vanHerkControlBuffer(5,1)=valid;
            obj.vanHerkControlBuffer(6,1)=processData;



            hStartOutBuffer=obj.vanHerkControlBuffer(1,end);
            hEndOutBuffer=obj.vanHerkControlBuffer(2,end);
            vStartOutBuffer=obj.vanHerkControlBuffer(3,end);
            vEndOutBuffer=obj.vanHerkControlBuffer(4,end);
            validOutBuffer=obj.vanHerkControlBuffer(5,end);
            processOut=obj.vanHerkControlBuffer(6,end);


            obj.vanHerkOutputControl(1,2:end)=obj.vanHerkOutputControl(1,1:end-1);
            obj.vanHerkOutputControl(2,2:end)=obj.vanHerkOutputControl(2,1:end-1);
            obj.vanHerkOutputControl(3,2:end)=obj.vanHerkOutputControl(3,1:end-1);
            obj.vanHerkOutputControl(4,2:end)=obj.vanHerkOutputControl(4,1:end-1);
            obj.vanHerkOutputControl(5,2:end)=obj.vanHerkOutputControl(5,1:end-1);
            obj.vanHerkOutputControl(6,2:end)=obj.vanHerkOutputControl(6,1:end-1);


            obj.vanHerkOutputControl(1,1)=hStartOutBuffer;
            obj.vanHerkOutputControl(2,1)=hEndOutBuffer;
            obj.vanHerkOutputControl(3,1)=vStartOutBuffer;
            obj.vanHerkOutputControl(4,1)=vEndOutBuffer;
            obj.vanHerkOutputControl(5,1)=validOutBuffer;
            obj.vanHerkOutputControl(6,1)=processOut;













            lineBufferControlIn=pixelcontrolstruct(hStart,hEnd,vStart,vEnd,valid);

            obj.vanHerkLineEndBuffer(2:end)=obj.vanHerkLineEndBuffer(1:end-1);
            obj.vanHerkLineEndBuffer(1)=hEnd;
            obj.vanHerkLineEnd=obj.vanHerkLineEndBuffer(end);



            obj.backwardStream(2)=obj.backwardStream(1);

            obj.vanHerkModKCounterREG(:)=obj.vanHerkModKCounter;
            obj.processDataReg(2:end)=obj.processDataReg(1:end-1);
            obj.processDataReg(1)=processData||processOut;
            obj.dataColReg(2:end)=obj.dataColReg(1:end-1);
            obj.dataColReg(1)=data(1);
            obj.vanHerkForwardBufferCompleteREG(2:end)=obj.vanHerkForwardBufferCompleteREG(1:end-1);
            obj.vanHerkForwardBufferCompleteREG(1)=obj.vanHerkForwardBufferComplete;
            if processData||processOut
                obj.vanHerkModKCounter(:)=obj.vanHerkModKCounter+1;
            else

                obj.forwardStream(2:end)=obj.forwardStream(1:end-1);
                obj.forwardStream(1)=realmax;
                obj.vanHerkModKCounter(:)=0;
            end




            obj.forwardStream(1)=obj.vanHerkForwardMax(data(1),lineBufferControlIn,processData||processOut);
            obj.backwardStream(1)=obj.vanHerkBackwardMax(obj.dataColReg(2),lineBufferControlIn,obj.processDataReg(2),obj.vanHerkForwardBufferComplete);
            if processData||processOut
                obj.vanHerkOutPipe(1)=min(obj.forwardStream(4),obj.backwardStream(1));
            else
                obj.vanHerkOutPipe(1)=0;
            end


            if validOutBuffer
                if mod(obj.kWidth,2)==0
                    obj.vanHerkValidREG(:)=obj.vanHerkOutPipe(2);
                else
                    obj.vanHerkValidREG(:)=obj.vanHerkOutPipe(3);
                end
            else
                obj.vanHerkValidREG(:)=0;
            end



            obj.vanHerkOutputData(1)=obj.vanHerkValidREG;
            obj.vanHerkOutPipe(2:end)=obj.vanHerkOutPipe(1:end-1);
            obj.vanHerkOutputData(2:end)=obj.vanHerkOutputData(1:end-1);


            obj.forwardStream(2:end)=obj.forwardStream(1:end-1);
            obj.backwardStream(2:end)=obj.backwardStream(1:end-1);





            if(obj.vanHerkModKCounter>=(length(obj.Neighborhood)))
                obj.vanHerkModKCounter(:)=0;
            elseif obj.vanHerkLineEnd
                obj.vanHerkModKCounter(:)=0;
            end



        end

        function[pixelOut,controlOut]=vanHerkDilationOutput(obj,~,~)



            pixelOut=obj.vanHerkOutputData(end);

            hStartOut=obj.vanHerkOutputControl(1,end);
            hEndOut=obj.vanHerkOutputControl(2,end);
            vStartOut=obj.vanHerkOutputControl(3,end);
            vEndOut=obj.vanHerkOutputControl(4,end);
            validOut=obj.vanHerkOutputControl(5,end);
            controlOut=pixelcontrolstruct(hStartOut,hEndOut,vStartOut,vEndOut,validOut);


        end




        function[pixelOut]=vanHerkForwardMax(obj,pixelIn,~,processDataIn)

            moduloReached=(obj.vanHerkModKCounter==length(obj.Neighborhood));


            if obj.vanHerkForwardFIFOReadCounter>=length(obj.Neighborhood)
                obj.vanHerkForwardFIFOReadCounter(:)=0;
            end

            if obj.vanHerkForwardFIFOWriteCounter>=length(obj.Neighborhood)
                obj.vanHerkForwardFIFOWriteCounter(:)=0;

            else

            end

            if moduloReached&&processDataIn
                obj.vanHerkForwardBufferComplete=true;
            end


            if processDataIn

                if moduloReached
                    obj.vanHerkForwardCurrentMaximum(:)=pixelIn;
                else
                    obj.vanHerkForwardCurrentMaximum(:)=min(pixelIn,obj.vanHerkForwardCurrentMaximum);
                end

                obj.vanHerkForwardBuffer(obj.vanHerkForwardFIFOWriteCounter+1)=obj.vanHerkForwardCurrentMaximum;
                if obj.vanHerkForwardFIFOWriteCounter<length(obj.Neighborhood)
                    obj.vanHerkForwardFIFOWriteCounter(:)=obj.vanHerkForwardFIFOWriteCounter+1;
                end
            end

            if processDataIn&&obj.vanHerkForwardBufferComplete
                obj.vanHerkOutREG(1)=obj.vanHerkForwardBuffer(obj.vanHerkForwardFIFOReadCounter+1);
                if obj.vanHerkForwardFIFOReadCounter<length(obj.Neighborhood)
                    obj.vanHerkForwardFIFOReadCounter(:)=obj.vanHerkForwardFIFOReadCounter+1;
                end
            else
                obj.vanHerkOutREG(:)=realmax;
            end

            pixelOut=obj.vanHerkOutREG(1);

            if obj.vanHerkLineEnd
                obj.vanHerkForwardCurrentMaximum(:)=realmax;
                obj.vanHerkForwardBuffer(:)=realmax;
                obj.vanHerkForwardFIFOReadCounter(:)=0;
                obj.vanHerkForwardFIFOWriteCounter(:)=0;
                obj.vanHerkForwardBufferComplete=false;
            end

        end




        function[pixelOut]=vanHerkBackwardMax(obj,pixelIn,~,processDataIn,forwardBufferFlag)

            if processDataIn
                if obj.vanHerkInputMirrorPingCounter>=(length(obj.Neighborhood))
                    obj.vanHerkBackwardBufferComplete=true;
                    moduloReached=true;
                elseif obj.vanHerkInputMirrorPongCounter>=(length(obj.Neighborhood))
                    obj.vanHerkBackwardBufferComplete=false;
                    moduloReached=true;
                else
                    moduloReached=false;
                end
            else
                moduloReached=false;
            end


            if processDataIn&&~(obj.vanHerkBackwardBufferComplete)&&~(forwardBufferFlag)
                obj.vanHerkInputMirror(1,obj.vanHerkInputMirrorPingCounter+1)=pixelIn;
                obj.vanHerkMirrorOutput(:)=realmax;
                if obj.vanHerkInputMirrorPingCounter<(length(obj.Neighborhood))
                    obj.vanHerkInputMirrorPingCounter(:)=obj.vanHerkInputMirrorPingCounter+1;
                end

            elseif processDataIn&&obj.vanHerkBackwardBufferComplete

                if obj.vanHerkInputMirrorPingCounter>0
                    obj.vanHerkInputMirrorPingCounter(:)=obj.vanHerkInputMirrorPingCounter-1;
                end

                obj.vanHerkMirrorOutput(:)=obj.vanHerkInputMirror(1,obj.vanHerkInputMirrorPingCounter+1);

                obj.vanHerkInputMirror(2,(obj.vanHerkInputMirrorPongCounter+1))=pixelIn;

                if obj.vanHerkInputMirrorPongCounter<(length(obj.Neighborhood))
                    obj.vanHerkInputMirrorPongCounter(:)=obj.vanHerkInputMirrorPongCounter+1;
                end


            elseif processDataIn&&~obj.vanHerkBackwardBufferComplete

                if obj.vanHerkInputMirrorPongCounter>0
                    obj.vanHerkInputMirrorPongCounter(:)=obj.vanHerkInputMirrorPongCounter-1;
                end
                obj.vanHerkMirrorOutput(:)=obj.vanHerkInputMirror(2,obj.vanHerkInputMirrorPongCounter+1);

                obj.vanHerkInputMirror(1,(obj.vanHerkInputMirrorPingCounter+1))=pixelIn;

                if obj.vanHerkInputMirrorPingCounter<(length(obj.Neighborhood))
                    obj.vanHerkInputMirrorPingCounter=obj.vanHerkInputMirrorPingCounter+1;
                end

            end


            if moduloReached
                obj.vanHerkBackwardCurrentMaximum(:)=obj.vanHerkMirrorOutput;
            elseif obj.vanHerkLineEnd
                obj.vanHerkBackwardCurrentMaximum(:)=realmax;
            else
                obj.vanHerkBackwardCurrentMaximum(:)=min(obj.vanHerkBackwardCurrentMaximum,obj.vanHerkMirrorOutput);
            end



            if processDataIn&&~forwardBufferFlag&&(~obj.vanHerkBackwardBufferComplete)
                pixelOut=cast(0,'like',pixelIn);

            elseif processDataIn&&~obj.vanHerkBackwardBufferComplete&&forwardBufferFlag

                if(obj.vanHerkOutputMirrorPingCounter>0)
                    obj.vanHerkOutputMirrorPingCounter=obj.vanHerkOutputMirrorPingCounter-1;
                end

                pixelOut=cast(obj.vanHerkOutputMirror(1,obj.vanHerkOutputMirrorPingCounter+1),'like',pixelIn);

                if(obj.vanHerkOutputMirrorPongCounter<(length(obj.Neighborhood)))
                    obj.vanHerkOutputMirror(2,obj.vanHerkOutputMirrorPongCounter+1)=obj.vanHerkBackwardCurrentMaximum;
                    obj.vanHerkOutputMirrorPongCounter=obj.vanHerkOutputMirrorPongCounter+1;
                end
            elseif processDataIn&&obj.vanHerkBackwardBufferComplete


                if(obj.vanHerkOutputMirrorPongCounter>0)
                    obj.vanHerkOutputMirrorPongCounter=obj.vanHerkOutputMirrorPongCounter-1;
                end

                pixelOut=cast(obj.vanHerkOutputMirror(2,obj.vanHerkOutputMirrorPongCounter+1),'like',pixelIn);


                if(obj.vanHerkOutputMirrorPingCounter<(length(obj.Neighborhood)))
                    obj.vanHerkOutputMirror(1,obj.vanHerkOutputMirrorPingCounter+1)=obj.vanHerkBackwardCurrentMaximum;
                    obj.vanHerkOutputMirrorPingCounter=obj.vanHerkOutputMirrorPingCounter+1;
                end

            else
                pixelOut=cast(0,'like',pixelIn);

            end


            if obj.vanHerkLineEnd
                obj.vanHerkInputMirrorPingCounter(:)=0;
                obj.vanHerkInputMirrorPongCounter(:)=0;
                obj.vanHerkOutputMirrorPingCounter(:)=0;
                obj.vanHerkOutputMirrorPongCounter(:)=0;
                obj.vanHerkBackwardBufferComplete(:)=false;
                obj.vanHerkInputMirror(:,:)=realmax;
                obj.vanHerkOutputMirror(:,:)=realmax;
                obj.vanHerkMirrorOutput(:)=realmax;
                obj.vanHerkBackwardCurrentMaximum(:)=realmax;
            end





        end






        function[pixelOut,controlOut]=decompositionDilationOutput(obj,~,~)

            pixelOut=obj.decompositionDataReg(end);

            hStartOut=obj.decompositionControlReg(1,end);
            hEndOut=obj.decompositionControlReg(2,end);
            vStartOut=obj.decompositionControlReg(3,end);
            vEndOut=obj.decompositionControlReg(4,end);
            validOut=obj.decompositionControlReg(5,end);

            controlOut=pixelcontrolstruct(hStartOut,hEndOut,vStartOut,vEndOut,validOut);

        end


        function decompositionDilation(obj,pixelIn,controlIn)
            [pixelVanHerkOut,controlVanHerkOut]=step(obj.hVanHerkErosion,pixelIn,controlIn);

            [hStartIn,hEndIn,vStartIn,vEndIn,validIn]=pixelcontrolsignals(controlVanHerkOut);

            [dataCol,hStart,hEnd,vStart,vEnd,valid,~]=...
            stepKernelMemory(obj,pixelVanHerkOut,hStartIn,hEndIn,vStartIn,vEndIn,validIn);

            obj.decompositionControlReg(:,2:end)=obj.decompositionControlReg(:,1:end-1);
            obj.decompositionDataReg(2:end)=obj.decompositionDataReg(1:end-1);

            obj.decompositionControlReg(1,1)=hStart;
            obj.decompositionControlReg(2,1)=hEnd;
            obj.decompositionControlReg(3,1)=vStart;
            obj.decompositionControlReg(4,1)=vEnd;
            obj.decompositionControlReg(5,1)=valid;


            obj.decompositionDataReg(1)=min(dataCol(:));





        end




        function[pixelOut,controlOut]=fullTreeDilationOutput(obj,~,~)

            hStartOut=obj.vanHerkControlBuffer(1,end);
            hEndOut=obj.vanHerkControlBuffer(2,end);
            vStartOut=obj.vanHerkControlBuffer(3,end);
            vEndOut=obj.vanHerkControlBuffer(4,end);
            validOut=obj.vanHerkControlBuffer(5,end);

            controlOut=pixelcontrolstruct(hStartOut,hEndOut,vStartOut,vEndOut,validOut);

            if validOut
                pixelOut=obj.vanHerkOutREG(end);
            else
                pixelOut=cast(0,'like',obj.dataColReg(:,1));
            end
        end

        function fullTreeDilation(obj,pixelIn,controlIn)


            [hStartIn,hEndIn,vStartIn,vEndIn,validIn]=pixelcontrolsignals(controlIn);

            [dataCol,hStart,hEnd,vStart,vEnd,valid,processData]=...
            stepKernelMemory(obj,pixelIn,hStartIn,hEndIn,vStartIn,vEndIn,validIn);


            obj.vanHerkControlBuffer(1,2:end)=obj.vanHerkControlBuffer(1,1:end-1);
            obj.vanHerkControlBuffer(2,2:end)=obj.vanHerkControlBuffer(2,1:end-1);
            obj.vanHerkControlBuffer(3,2:end)=obj.vanHerkControlBuffer(3,1:end-1);
            obj.vanHerkControlBuffer(4,2:end)=obj.vanHerkControlBuffer(4,1:end-1);
            obj.vanHerkControlBuffer(5,2:end)=obj.vanHerkControlBuffer(5,1:end-1);
            obj.vanHerkControlBuffer(6,2:end)=obj.vanHerkControlBuffer(6,1:end-1);

            obj.vanHerkControlBuffer(1,1)=obj.pEnableControlREG(1,end)&&obj.pProcessD;
            obj.vanHerkControlBuffer(2,1)=obj.pEnableControlREG(2,end)&&obj.pProcessD;
            obj.vanHerkControlBuffer(3,1)=obj.pEnableControlREG(3,end)&&obj.pProcessD;
            obj.vanHerkControlBuffer(4,1)=obj.pEnableControlREG(4,end)&&obj.pProcessD;
            obj.vanHerkControlBuffer(5,1)=obj.pEnableControlREG(5,end)&&obj.pProcessD;


            if processData
                obj.dataColReg(:,obj.kWidth:-1:2)=obj.dataColReg(:,obj.kWidth-1:-1:1);
                obj.dataColReg(:,1)=dataCol;

                obj.pEnableControlREG(1,2:end)=obj.pEnableControlREG(1,1:end-1);
                obj.pEnableControlREG(2,2:end)=obj.pEnableControlREG(2,1:end-1);
                obj.pEnableControlREG(3,2:end)=obj.pEnableControlREG(3,1:end-1);
                obj.pEnableControlREG(4,2:end)=obj.pEnableControlREG(4,1:end-1);
                obj.pEnableControlREG(5,2:end)=obj.pEnableControlREG(5,1:end-1);


                obj.pEnableControlREG(1,1)=hStart;
                obj.pEnableControlREG(2,1)=hEnd;
                obj.pEnableControlREG(3,1)=vStart;
                obj.pEnableControlREG(4,1)=vEnd;
                obj.pEnableControlREG(5,1)=valid;

            end


            currentPOCI=cast(zeros(obj.kHeight,obj.kWidth),'like',obj.dataColReg);

            neighborRot=rot90(rot90((obj.Neighborhood)));
            for ii=1:obj.kHeight
                for jj=1:obj.kWidth
                    if neighborRot(ii,jj)==0
                        currentPOCI(ii,jj)=realmax;
                    else
                        currentPOCI(ii,jj)=obj.dataColReg(ii,jj);
                    end
                end
            end

            obj.vanHerkOutREG(2:end)=obj.vanHerkOutREG(1:end-1);
            colMax=min(currentPOCI(:,:));
            obj.vanHerkOutREG(1)=min(colMax);




            obj.pProcessD=processData;

        end




        function setupFloat(obj,type,NLength,NHeight)
            obj.vanHerkForwardBuffer=cast(zeros(1,NLength),type);
            obj.vanHerkInputMirror=cast(zeros(2,NLength),type);
            obj.vanHerkOutputMirror=cast(zeros(2,NLength),type);

            if obj.kHeight>1&&any(obj.Neighborhood(:)==false)
                obj.vanHerkControlBuffer=false(6,3+ceil(log2(NHeight))+ceil(log2(NLength)));
                obj.dataColReg=cast(zeros(NHeight,NLength),type);
            elseif obj.kHeight>1&&obj.kWidth==1
                obj.vanHerkControlBuffer=false(6,ceil(NLength/2)+ceil(log2(NHeight))+ceil(log2(NLength))+1);
                obj.dataColReg=cast(zeros(NHeight,NLength),type);

            elseif obj.kHeight>1&&all(obj.Neighborhood(:)==true)
                obj.vanHerkControlBuffer=false(6,(NLength)+ceil(NLength/2)+2);
                obj.vanHerkOutputControl=false(6,7);
                obj.dataColReg=cast((zeros(1,3)),type);
                obj.vanHerkOutputData=cast((zeros(1,7)),type);
                obj.hVanHerkErosion=visionhdl.GrayscaleErosion(ones(1,NLength));
                pipeDelay=ceil(log2(obj.kHeight));

                if mod(obj.kWidth,2)==0
                    obj.decompositionDataReg=cast(zeros(1,pipeDelay+3),type);
                    obj.decompositionControlReg=cast(zeros(6,pipeDelay+3),type);
                else
                    obj.decompositionDataReg=cast(zeros(1,pipeDelay+2),type);
                    obj.decompositionControlReg=cast(zeros(6,pipeDelay+2),type);
                end
            else
                if mod(obj.kWidth,2)==0
                    obj.vanHerkControlBuffer=false(6,(NLength)+ceil(NLength/2)+4);
                    obj.vanHerkOutputControl=false(6,9);
                    obj.dataColReg=cast(zeros(1,4),type);
                    obj.vanHerkOutputData=cast((zeros(1,10)),type);
                else
                    obj.vanHerkControlBuffer=false(6,(NLength)+ceil(NLength/2)+4);
                    obj.vanHerkOutputControl=false(6,9);
                    obj.dataColReg=cast(zeros(1,4),type);
                    obj.vanHerkOutputData=cast(zeros(1,10),type);

                end
            end

            obj.vanHerkLineEndBuffer=false(1,(NLength*3)+1);
            obj.vanHerkLineEnd=false;
            obj.vanHerkModKCounter=uint32(0);
            obj.vanHerkModKCounterREG=uint32(0);
            obj.vanHerkForwardCurrentMaximum=cast(0,type);
            obj.vanHerkBackwardCurrentMaximum=cast(0,type);
            obj.vanHerkForwardBufferComplete=false;
            obj.vanHerkBackwardBufferComplete=false;
            obj.vanHerkForwardFIFOReadCounter=uint32(0);
            obj.vanHerkForwardFIFOWriteCounter=uint32(0);
            obj.vanHerkInputMirrorPingCounter=uint32(0);
            obj.vanHerkInputMirrorPongCounter=uint32(0);
            obj.vanHerkOutputMirrorPingCounter=uint32(0);
            obj.vanHerkOutputMirrorPongCounter=uint32(0);
            if(obj.kHeight>1&&any(obj.Neighborhood(:)==false))

                if mod(obj.kWidth,2)==0
                    obj.vanHerkOutREG=cast(zeros(1,3+ceil(log2(NHeight))+ceil(log2(NLength))),type);
                else
                    obj.vanHerkOutREG=cast(zeros(1,4+ceil(log2(NHeight))+ceil(log2(NLength))),type);
                end
            elseif(obj.kHeight>1&&all(obj.Neighborhood(:)==true))
                obj.vanHerkOutREG=cast(zeros(1,3+ceil(log2(NHeight))+ceil(log2(NLength))),type);
            else
                obj.vanHerkOutREG=cast(0,type);
                obj.vanHerkValidREG=cast(0,type);
                obj.vanHerkOutPipe=cast(zeros(1,5),type);

            end
            obj.vanHerkMirrorOutput=cast(0,type);
            obj.forwardStream=cast(zeros(1,4),type);
            obj.backwardStream=cast(zeros(1,4),type);
            obj.processDataReg=false(1,2);
            obj.vanHerkForwardBufferCompleteREG=false(1,4);

            obj.vanHerkInitiateFIFO=false;


        end






        function setupFixed(obj,WL,FL,NLength,NHeight)
            obj.vanHerkForwardBuffer=(fi(zeros(1,NLength),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            obj.vanHerkInputMirror=(fi(zeros(2,NLength),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            obj.vanHerkOutputMirror=(fi(zeros(2,NLength),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));

            if(obj.kHeight>1&&any(obj.Neighborhood(:)==false)&&obj.kWidth>1)||((obj.kWidth<8)&&(obj.kWidth>1))
                obj.vanHerkControlBuffer=false(6,3+ceil(log2(NHeight))+ceil(log2(NLength)));
                obj.dataColReg=(fi((zeros(NHeight,NLength)),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            elseif obj.kHeight>1&&obj.kWidth==1
                obj.vanHerkControlBuffer=false(6,ceil(NLength/2)+ceil(log2(NHeight))+ceil(log2(NLength))+1);
                obj.dataColReg=(fi((zeros(NHeight,NLength)),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));

            elseif obj.kHeight>1&&all(obj.Neighborhood(:)==true)
                obj.vanHerkControlBuffer=false(6,(NLength)+ceil(NLength/2)+2);
                obj.vanHerkOutputControl=false(6,7);
                obj.dataColReg=(fi((zeros(1,3)),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.vanHerkOutputData=(fi((zeros(1,7)),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.hVanHerkErosion=visionhdl.GrayscaleErosion(ones(1,NLength));
                pipeDelay=ceil(log2(obj.kHeight));

                if mod(obj.kWidth,2)==0
                    obj.decompositionDataReg=(fi(zeros(1,pipeDelay+3),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                    obj.decompositionControlReg=(fi(zeros(6,pipeDelay+3),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                else
                    obj.decompositionDataReg=(fi(zeros(1,pipeDelay+2),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                    obj.decompositionControlReg=(fi(zeros(6,pipeDelay+2),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                end
            else
                if mod(obj.kWidth,2)==0
                    obj.vanHerkControlBuffer=false(6,(NLength)+ceil(NLength/2)+4);
                    obj.vanHerkOutputControl=false(6,9);
                    obj.dataColReg=(fi((zeros(1,4)),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                    obj.vanHerkOutputData=(fi((zeros(1,10)),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                else
                    obj.vanHerkControlBuffer=false(6,(NLength)+ceil(NLength/2)+4);
                    obj.vanHerkOutputControl=false(6,9);
                    obj.dataColReg=(fi((zeros(1,4)),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                    obj.vanHerkOutputData=(fi((zeros(1,10)),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));

                end
            end

            obj.vanHerkLineEndBuffer=false(1,(NLength*3)+1);
            obj.vanHerkLineEnd=false;
            obj.vanHerkModKCounter=uint32(0);
            obj.vanHerkModKCounterREG=uint32(0);
            obj.vanHerkForwardCurrentMaximum=(fi(0,0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            obj.vanHerkBackwardCurrentMaximum=(fi(0,0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            obj.vanHerkForwardBufferComplete=false;
            obj.vanHerkBackwardBufferComplete=false;
            obj.vanHerkForwardFIFOReadCounter=uint32(0);
            obj.vanHerkForwardFIFOWriteCounter=uint32(0);
            obj.vanHerkInputMirrorPingCounter=uint32(0);
            obj.vanHerkInputMirrorPongCounter=uint32(0);
            obj.vanHerkOutputMirrorPingCounter=uint32(0);
            obj.vanHerkOutputMirrorPongCounter=uint32(0);
            if(obj.kHeight>1&&any(obj.Neighborhood(:)==false))
                if obj.kWidth==1
                    obj.vanHerkOutREG=(fi(zeros(1,3+ceil(log2(NHeight))+ceil(log2(NLength))),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                elseif mod(obj.kWidth,2)==0
                    obj.vanHerkOutREG=(fi(zeros(1,3+ceil(log2(NHeight))+ceil(log2(NLength))),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                else
                    obj.vanHerkOutREG=(fi(zeros(1,4+ceil(log2(NHeight))+ceil(log2(NLength))),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                end
            elseif(obj.kHeight>1&&all(obj.Neighborhood(:)==true))
                if obj.kWidth==1
                    obj.vanHerkOutREG=(fi(zeros(1,3+ceil(log2(NHeight))+ceil(log2(NLength))),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                elseif mod(obj.kWidth,2)==0
                    obj.vanHerkOutREG=(fi(zeros(1,3+ceil(log2(NHeight))+ceil(log2(NLength))),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                else
                    obj.vanHerkOutREG=(fi(zeros(1,4+ceil(log2(NHeight))+ceil(log2(NLength))),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                end
            else
                if obj.kWidth==1
                    obj.vanHerkOutREG=(fi(zeros(1,2+ceil(log2(NHeight))+ceil(log2(NLength))),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                elseif mod(obj.kWidth,2)==0
                    obj.vanHerkOutREG=(fi(zeros(1,3+ceil(log2(NHeight))+ceil(log2(NLength))),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                elseif mod(obj.kWidth,2)==1
                    obj.vanHerkOutREG=(fi(zeros(1,4+ceil(log2(NHeight))+ceil(log2(NLength))),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                else
                    obj.vanHerkOutREG=(fi(0,0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                end
                obj.vanHerkValidREG=(fi(0,0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.vanHerkOutPipe=(fi(zeros(1,5),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            end

            obj.vanHerkMirrorOutput=(fi(0,0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            obj.forwardStream=(fi(zeros(1,4),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            obj.backwardStream=(fi(zeros(1,4),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            obj.processDataReg=false(1,2);
            obj.vanHerkForwardBufferCompleteREG=false(1,4);

            obj.vanHerkInitiateFIFO=false;

        end




        function setupInteger(obj,WL,NLength,NHeight)
            obj.vanHerkForwardBuffer=storedInteger(fi(zeros(1,NLength),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            obj.vanHerkInputMirror=storedInteger(fi(zeros(2,NLength),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            obj.vanHerkOutputMirror=storedInteger(fi(zeros(2,NLength),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));

            if(obj.kHeight>1&&any(obj.Neighborhood(:)==false)&&obj.kWidth>1)||((obj.kWidth<8)&&(obj.kWidth>1))
                obj.vanHerkControlBuffer=false(6,3+ceil(log2(NHeight))+ceil(log2(NLength)));
                obj.dataColReg=storedInteger(fi((zeros(NHeight,NLength)),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            elseif obj.kHeight>1&&obj.kWidth==1
                obj.vanHerkControlBuffer=false(6,ceil(NLength/2)+ceil(log2(NHeight))+ceil(log2(NLength))+1);
                obj.dataColReg=storedInteger(fi((zeros(NHeight,NLength)),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));

            elseif obj.kHeight>1&&all(obj.Neighborhood(:)==true)
                obj.vanHerkControlBuffer=false(6,(NLength)+ceil(NLength/2)+2);
                obj.vanHerkOutputControl=false(6,7);
                obj.dataColReg=storedInteger(fi((zeros(1,3)),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.vanHerkOutputData=storedInteger(fi((zeros(1,7)),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.hVanHerkErosion=visionhdl.GrayscaleErosion(ones(1,NLength));
                pipeDelay=ceil(log2(obj.kHeight));

                if mod(obj.kWidth,2)==0
                    obj.decompositionDataReg=storedInteger(fi(zeros(1,pipeDelay+3),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                    obj.decompositionControlReg=storedInteger(fi(zeros(6,pipeDelay+3),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                else
                    obj.decompositionDataReg=storedInteger(fi(zeros(1,pipeDelay+2),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                    obj.decompositionControlReg=storedInteger(fi(zeros(6,pipeDelay+2),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                end
            else
                if mod(obj.kWidth,2)==0
                    obj.vanHerkControlBuffer=false(6,(NLength)+ceil(NLength/2)+4);
                    obj.vanHerkOutputControl=false(6,9);
                    obj.dataColReg=storedInteger(fi((zeros(1,4)),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                    obj.vanHerkOutputData=storedInteger(fi((zeros(1,10)),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                else
                    obj.vanHerkControlBuffer=false(6,(NLength)+ceil(NLength/2)+4);
                    obj.vanHerkOutputControl=false(6,9);
                    obj.dataColReg=storedInteger(fi((zeros(1,4)),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                    obj.vanHerkOutputData=storedInteger(fi((zeros(1,10)),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));

                end
            end

            obj.vanHerkLineEndBuffer=false(1,(NLength*3)+1);
            obj.vanHerkLineEnd=false;
            obj.vanHerkModKCounter=uint32(0);
            obj.vanHerkModKCounterREG=uint32(0);
            obj.vanHerkForwardCurrentMaximum=storedInteger(fi(0,0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            obj.vanHerkBackwardCurrentMaximum=storedInteger(fi(0,0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            obj.vanHerkForwardBufferComplete=false;
            obj.vanHerkBackwardBufferComplete=false;
            obj.vanHerkForwardFIFOReadCounter=uint32(0);
            obj.vanHerkForwardFIFOWriteCounter=uint32(0);
            obj.vanHerkInputMirrorPingCounter=uint32(0);
            obj.vanHerkInputMirrorPongCounter=uint32(0);
            obj.vanHerkOutputMirrorPingCounter=uint32(0);
            obj.vanHerkOutputMirrorPongCounter=uint32(0);
            if(obj.kHeight>1&&any(obj.Neighborhood(:)==false))
                if obj.kWidth==1
                    obj.vanHerkOutREG=storedInteger(fi(zeros(1,3+ceil(log2(NHeight))+ceil(log2(NLength))),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                elseif mod(obj.kWidth,2)==0
                    obj.vanHerkOutREG=storedInteger(fi(zeros(1,3+ceil(log2(NHeight))+ceil(log2(NLength))),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                else
                    obj.vanHerkOutREG=storedInteger(fi(zeros(1,4+ceil(log2(NHeight))+ceil(log2(NLength))),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                end
            elseif(obj.kHeight>1&&all(obj.Neighborhood(:)==true))
                if obj.kWidth==1
                    obj.vanHerkOutREG=storedInteger(fi(zeros(1,3+ceil(log2(NHeight))+ceil(log2(NLength))),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));

                elseif mod(obj.kWidth,2)==0
                    obj.vanHerkOutREG=storedInteger(fi(zeros(1,3+ceil(log2(NHeight))+ceil(log2(NLength))),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                else
                    obj.vanHerkOutREG=storedInteger(fi(zeros(1,4+ceil(log2(NHeight))+ceil(log2(NLength))),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));

                end

            else

                if obj.kWidth==1
                    obj.vanHerkOutREG=storedInteger(fi(zeros(1,2+ceil(log2(NHeight))+ceil(log2(NLength))),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                elseif mod(obj.kWidth,2)==0
                    obj.vanHerkOutREG=storedInteger(fi(zeros(1,3+ceil(log2(NHeight))+ceil(log2(NLength))),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                elseif mod(obj.kWidth,2)==1
                    obj.vanHerkOutREG=storedInteger(fi(zeros(1,4+ceil(log2(NHeight))+ceil(log2(NLength))),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                else
                    obj.vanHerkOutREG=storedInteger(fi(0,0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));

                end
                obj.vanHerkValidREG=storedInteger(fi(0,0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.vanHerkOutPipe=storedInteger(fi(zeros(1,5),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));

            end
            obj.vanHerkMirrorOutput=storedInteger(fi(0,0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            obj.forwardStream=storedInteger(fi(zeros(1,4),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            obj.backwardStream=storedInteger(fi(zeros(1,4),0,WL,0,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            obj.processDataReg=false(1,2);
            obj.vanHerkForwardBufferCompleteREG=false(1,4);

            obj.vanHerkInitiateFIFO=false;
        end







    end

end

