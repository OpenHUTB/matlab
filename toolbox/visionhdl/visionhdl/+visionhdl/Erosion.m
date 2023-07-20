classdef(StrictDefaults)Erosion<visionhdl.internal.abstractLineMemoryKernel













































































%#codegen
%#ok<*EMCLS>

    properties(Nontunable)




        Neighborhood=ones(3,3);





        LineBufferSize=2048;




        PaddingMethod='Constant';
    end

    properties(Access=private)
        yReg;
        hStartReg;
        hEndReg;
        vStartReg;
        vEndReg;
        validReg;
        hStartKernelReg;
        hEndKernelReg;
        vStartKernelReg;
        vEndKernelReg;
        validKernelReg;
        dataColReg;
        notNhood;
        DelayLine;
        MultiPixelWindow;
        MultiPixelFilterKernel;
        PaddingNoneValid;
    end

    properties(Nontunable,Access=private)
        kHeight;
        kWidth;
        linebufferDelay=1;
        hdlDelay=1;

        ctrlregDelay=2;
    end


    properties(Access=private,Nontunable)
        filterHandle;
        NumberOfPixels;
    end

    properties(Constant,Hidden)

        PaddingMethodSet=matlab.system.StringSet({...
        'Constant',...
        'None'});

    end

    methods(Static,Access=protected)
        function header=getHeaderImpl


            header=matlab.system.display.Header('visionhdl.Erosion',...
            'ShowSourceLink',false,...
            'Title','Erosion');
        end

    end

    methods
        function obj=Erosion(varargin)
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


            validateattributes(val,{'logical','double','single'},{'2d','binary'},'Erosion','Neighborhood');
            [height,width]=size(val);
            validateattributes(height,{'numeric'},{'scalar','<=',32,'>',0},'Erosion','first dimension of Neighborhood');
            validateattributes(width,{'numeric'},{'scalar','<=',32},'Erosion','second dimension of Neighborhood');


            if isempty(coder.target)||~eml_ambiguous_types
                if~(any(val(:)))
                    coder.internal.error('visionhdl:Morphology:NeighborhoodZeros');
                end
            end

            obj.Neighborhood=val;

        end

        function set.LineBufferSize(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'Erosion','MaxLineSize');
            obj.LineBufferSize=val;
        end

    end

    methods(Access=protected)
        function validateInputsImpl(~,pixelIn,ctrlIn)

            if isempty(coder.target)||~eml_ambiguous_types



                validateattributes(pixelIn,{'double','single','logical'},{'binary'},'Erosion','pixel input');

                if~ismember(size(pixelIn,1),[1,4,8])
                    coder.internal.error('visionhdl:Morphology:InputDimensions');
                end

                if~ismember(size(pixelIn,2),[1])%#ok<NBRAK2> 
                    coder.internal.error('visionhdl:Morphology:InputDimensions');
                end

                validatecontrolsignals(ctrlIn);
            end

        end


        function[pixelOut,ctrlOut]=outputImpl(obj,~,~)



            hStartOut=obj.hStartReg(end);
            hEndOut=obj.hEndReg(end);
            vStartOut=obj.vStartReg(end);
            vEndOut=obj.vEndReg(end);
            validOut=obj.validReg(end);
            ctrlOut.hStart=hStartOut;
            ctrlOut.hEnd=hEndOut;
            ctrlOut.vStart=vStartOut;
            ctrlOut.vEnd=vEndOut;
            ctrlOut.valid=validOut;


            if validOut
                pixelOut=obj.yReg;
            else
                pixelOut=cast(zeros(obj.NumberOfPixels,1),'like',obj.yReg);
            end
        end

        function updateImpl(obj,pixelIn,ctrlIn)



            hStartIn=ctrlIn.hStart;
            hEndIn=ctrlIn.hEnd;
            vStartIn=ctrlIn.vStart;
            vEndIn=ctrlIn.vEnd;
            validIn=ctrlIn.valid;

            [dataCol,hStart,hEnd,vStart,vEnd,valid,processData]=...
            stepKernelMemory(obj,pixelIn,hStartIn,hEndIn,vStartIn,vEndIn,validIn);

            ctrlLB=[hStart,hEnd,vStart,vEnd,valid,processData];

            if processData||obj.PaddingNoneValid
                yt=obj.filterHandle(obj,dataCol,ctrlLB);

            else
                yt=false(obj.NumberOfPixels,1);
            end

            obj.yReg=cast(yt,'like',pixelIn);
            obj.hStartReg(2:end)=obj.hStartReg(1:end-1);
            obj.hEndReg(2:end)=obj.hEndReg(1:end-1);
            obj.vStartReg(2:end)=obj.vStartReg(1:end-1);
            obj.vEndReg(2:end)=obj.vEndReg(1:end-1);
            obj.validReg(2:end)=obj.validReg(1:end-1);

            if strcmpi(obj.PaddingMethod,'None')
                if obj.linebufferDelay~=0
                    if processData||obj.PaddingNoneValid
                        obj.hStartReg(1)=obj.hStartKernelReg(end);
                        obj.hEndReg(1)=obj.hEndKernelReg(end);
                        obj.vStartReg(1)=obj.vStartKernelReg(end);
                        obj.vEndReg(1)=obj.vEndKernelReg(end);
                        obj.validReg(1)=obj.validKernelReg(end)||obj.PaddingNoneValid;
                    else
                        obj.hStartReg(1)=false;
                        obj.hEndReg(1)=false;
                        obj.vStartReg(1)=false;
                        obj.vEndReg(1)=false;
                        obj.validReg(1)=false;
                    end

                    if hEnd
                        obj.PaddingNoneValid=true;
                        obj.validKernelReg(1:end)=false;
                    elseif obj.hEndKernelReg(end)
                        obj.PaddingNoneValid=false;
                        obj.validKernelReg(1:end)=false;
                    end

                    if processData
                        obj.hStartKernelReg(2:end)=obj.hStartKernelReg(1:end-1);
                        obj.vStartKernelReg(2:end)=obj.vStartKernelReg(1:end-1);
                        obj.validKernelReg(2:end)=obj.validKernelReg(1:end-1);
                        obj.hStartKernelReg(1)=hStart;
                        obj.vStartKernelReg(1)=vStart;
                        obj.validKernelReg(1)=valid;

                    end
                    obj.hEndKernelReg(2:end)=obj.hEndKernelReg(1:end-1);
                    obj.vEndKernelReg(2:end)=obj.vEndKernelReg(1:end-1);

                    obj.hEndKernelReg(1)=hEnd;
                    obj.vEndKernelReg(1)=vEnd;
                else

                    obj.hStartReg(1)=hStart;
                    obj.hEndReg(1)=hEnd;
                    obj.vStartReg(1)=vStart;
                    obj.vEndReg(1)=vEnd;
                    obj.validReg(1)=valid;

                end

            else



                if processData
                    if obj.linebufferDelay>0
                        obj.hStartReg(1)=obj.hStartKernelReg(end);
                        obj.hEndReg(1)=obj.hEndKernelReg(end);
                        obj.vStartReg(1)=obj.vStartKernelReg(end);
                        obj.vEndReg(1)=obj.vEndKernelReg(end);
                        obj.validReg(1)=obj.validKernelReg(end);

                        obj.hStartKernelReg(2:end)=obj.hStartKernelReg(1:end-1);
                        obj.hEndKernelReg(2:end)=obj.hEndKernelReg(1:end-1);
                        obj.vStartKernelReg(2:end)=obj.vStartKernelReg(1:end-1);
                        obj.vEndKernelReg(2:end)=obj.vEndKernelReg(1:end-1);
                        obj.validKernelReg(2:end)=obj.validKernelReg(1:end-1);
                        obj.hStartKernelReg(1)=hStart;
                        obj.hEndKernelReg(1)=hEnd;
                        obj.vStartKernelReg(1)=vStart;
                        obj.vEndKernelReg(1)=vEnd;
                        obj.validKernelReg(1)=valid;
                    else
                        obj.hStartReg(1)=hStart;
                        obj.hEndReg(1)=hEnd;
                        obj.vStartReg(1)=vStart;
                        obj.vEndReg(1)=vEnd;
                        obj.validReg(1)=valid;
                    end
                else

                    obj.hStartReg(1)=false;
                    obj.hEndReg(1)=false;
                    obj.vStartReg(1)=false;
                    obj.vEndReg(1)=false;
                    obj.validReg(1)=false;
                end

            end
        end


        function setupImpl(obj,pixelIn,ctrlIn)

            obj.NumberOfPixels=length(pixelIn);

            if obj.NumberOfPixels==1
                obj.filterHandle=@ComputeErosion;
            else
                obj.filterHandle=@ComputeErosionMultiPixel;
            end

            [obj.KernelMemoryKernelHeight,obj.KernelMemoryKernelWidth]=size(obj.Neighborhood);

            obj.kHeight=obj.KernelMemoryKernelHeight;
            obj.kWidth=obj.KernelMemoryKernelWidth;


            NhoodRot=obj.Neighborhood(obj.kHeight:-1:1,:);
            obj.notNhood=not(NhoodRot);
            obj.dataColReg=false(obj.kHeight,obj.kWidth);



            obj.KernelMemoryMaxLineSize=obj.LineBufferSize;
            obj.KernelMemoryPaddingMethod=obj.PaddingMethod;
            obj.KernelMemoryPaddingValue=1;
            obj.KernelMemoryBiasUp=true;
            setupKernelMemory(obj,pixelIn,ctrlIn.hStart,ctrlIn.hEnd,ctrlIn.vStart,ctrlIn.vEnd,ctrlIn.valid);

            obj.linebufferDelay=floor(obj.kWidth/2);


            obj.ctrlregDelay=obj.linebufferDelay+obj.hdlDelay;
            obj.yReg=cast(zeros(obj.NumberOfPixels,obj.hdlDelay),'like',pixelIn);
            obj.hStartReg=false(obj.hdlDelay,1);
            obj.hEndReg=false(obj.hdlDelay,1);
            obj.vStartReg=false(obj.hdlDelay,1);
            obj.vEndReg=false(obj.hdlDelay,1);
            obj.validReg=false(obj.hdlDelay,1);

            if strcmpi(obj.PaddingMethod,'None')
                if obj.kWidth==2||obj.kHeight==2
                    coder.internal.error('visionhdl:Morphology:PadNoneKernel');
                end
            end


            if obj.NumberOfPixels>1


                if obj.kWidth==2||obj.kHeight==2||obj.kWidth==1||obj.kHeight==1
                    coder.internal.error('visionhdl:Morphology:MultiPixelKernel');
                end

                halfWidth=floor(obj.kWidth/2);
                numMatrices=(ceil(halfWidth/obj.NumberOfPixels))*2+1;
                obj.DelayLine=cast(zeros(obj.kHeight,obj.NumberOfPixels,numMatrices),'like',pixelIn);
                if numMatrices==3
                    windowLength=((numMatrices-2)*obj.NumberOfPixels)+halfWidth*2;
                else
                    windowLength=((numMatrices-2)*obj.NumberOfPixels)+(halfWidth-((ceil(halfWidth/obj.NumberOfPixels))-1)*obj.NumberOfPixels)*2;
                end
                obj.MultiPixelWindow=cast(zeros(obj.kHeight,windowLength),'like',pixelIn);
                obj.MultiPixelFilterKernel=cast(zeros(obj.kHeight,obj.kWidth,obj.NumberOfPixels),'like',pixelIn);
            end



            if obj.NumberOfPixels>1
                obj.hStartKernelReg=false(floor(numMatrices/2),1);
                obj.hEndKernelReg=false(floor(numMatrices/2),1);
                obj.vStartKernelReg=false(floor(numMatrices/2),1);
                obj.vEndKernelReg=false(floor(numMatrices/2),1);
                obj.validKernelReg=false(floor(numMatrices/2),1);
            else
                obj.hStartKernelReg=false(obj.linebufferDelay,1);
                obj.hEndKernelReg=false(obj.linebufferDelay,1);
                obj.vStartKernelReg=false(obj.linebufferDelay,1);
                obj.vEndKernelReg=false(obj.linebufferDelay,1);
                obj.validKernelReg=false(obj.linebufferDelay,1);
            end

            obj.PaddingNoneValid=false;


        end

        function resetImpl(obj)

            obj.yReg(:)=0;
            obj.hStartReg(:)=false;
            obj.hEndReg(:)=false;
            obj.vStartReg(:)=false;
            obj.vEndReg(:)=false;
            obj.validReg(:)=false;
            obj.hStartKernelReg(:)=false;
            obj.hEndKernelReg(:)=false;
            obj.vStartKernelReg(:)=false;
            obj.vEndKernelReg(:)=false;
            obj.validKernelReg(:)=false;
            obj.dataColReg(:)=false;
            obj.PaddingNoneValid=false;

        end


        function mval=ComputeErosion(obj,dataCol,~)


            if obj.PaddingNoneValid
                padNoneKernel=cast(ones(obj.kHeight,obj.kWidth),'like',obj.dataColReg);
                padNoneKernel(:,1)=dataCol;
                padNoneKernel(:,obj.kWidth:-1:2)=obj.dataColReg(:,obj.kWidth-1:-1:1);

                ordata=false(obj.kHeight,obj.kWidth);
                firstand=true(1,obj.kWidth);
                finaland=true;
                for i=1:obj.kWidth
                    for j=1:obj.kHeight

                        ordata(j,i)=or(padNoneKernel(j,i),obj.notNhood(j,i));
                        firstand(1,i)=and(firstand(1,i),ordata(j,i));
                    end
                    finaland=and(finaland,firstand(1,i));
                end

                mval=finaland;

            else

                if obj.kHeight>1
                    obj.dataColReg(:,1:obj.kWidth-1)=obj.dataColReg(:,2:obj.kWidth);
                    obj.dataColReg(:,obj.kWidth)=dataCol;
                else
                    obj.dataColReg(1:obj.kWidth-1)=obj.dataColReg(2:obj.kWidth);
                    obj.dataColReg(obj.kWidth)=dataCol;
                end

                ordata=false(obj.kHeight,obj.kWidth);
                firstand=true(1,obj.kWidth);
                finaland=true;
                for i=1:obj.kWidth
                    for j=1:obj.kHeight

                        ordata(j,i)=or(obj.dataColReg(j,i),obj.notNhood(j,i));
                        firstand(1,i)=and(firstand(1,i),ordata(j,i));
                    end
                    finaland=and(finaland,firstand(1,i));
                end

                mval=finaland;


            end
        end



        function mval=ComputeErosionMultiPixel(obj,dataVector,ctrlIn)

            processDataOut=ctrlIn(6);

            halfWidth=(floor(obj.kWidth/2))-((ceil((floor(obj.kWidth/2))/obj.NumberOfPixels)-1)*obj.NumberOfPixels);



            if processDataOut
                obj.DelayLine(:,:,end-1:-1:1)=obj.DelayLine(:,:,end:-1:2);
                obj.DelayLine(:,:,end)=dataVector;
            end


            windowCount=uint16(1);
            sizeD=size(obj.DelayLine);

            for ii=1:1:sizeD(3)

                if ii==1
                    if strcmpi(obj.PaddingMethod,'None')&&obj.PaddingNoneValid

                        for jj=1:1:halfWidth
                            obj.MultiPixelWindow(:,windowCount)=obj.DelayLine(:,(obj.NumberOfPixels-halfWidth)+jj,ii+1);
                            windowCount=windowCount+1;
                        end
                    else
                        for jj=1:1:halfWidth
                            obj.MultiPixelWindow(:,windowCount)=obj.DelayLine(:,(obj.NumberOfPixels-halfWidth)+jj,ii);
                            windowCount=windowCount+1;
                        end


                    end
                elseif ii==sizeD(3)
                    if strcmpi(obj.PaddingMethod,'None')&&obj.PaddingNoneValid
                        for jj=1:1:halfWidth
                            obj.MultiPixelWindow(:,windowCount)=dataVector(:,jj);
                            windowCount=windowCount+1;
                        end
                    else
                        for jj=1:1:halfWidth
                            obj.MultiPixelWindow(:,windowCount)=obj.DelayLine(:,jj,ii);
                            windowCount=windowCount+1;
                        end
                    end

                else
                    if strcmpi(obj.PaddingMethod,'None')&&obj.PaddingNoneValid

                        for jj=1:1:obj.NumberOfPixels
                            obj.MultiPixelWindow(:,windowCount)=obj.DelayLine(:,jj,ii+1);
                            windowCount=windowCount+1;
                        end
                    else
                        for jj=1:1:obj.NumberOfPixels
                            obj.MultiPixelWindow(:,windowCount)=obj.DelayLine(:,jj,ii);
                            windowCount=windowCount+1;
                        end


                    end
                end

            end
            evenKernelUp=(mod(obj.kWidth,2)==0)&&obj.KernelMemoryBiasUp;

            mval=false(obj.NumberOfPixels,1);

            for kk=1:1:obj.NumberOfPixels

                obj.MultiPixelFilterKernel(:,:,kk)=obj.MultiPixelWindow(:,kk+evenKernelUp:obj.kWidth+(kk-1+evenKernelUp));
                POCIMat=rot90(obj.MultiPixelFilterKernel(:,:,kk),2);
                obj.dataColReg(:,:)=POCIMat;
                ordata=false(obj.kHeight,obj.kWidth);
                firstand=true(1,obj.kWidth);
                finaland=true;

                for i=1:obj.kWidth
                    for j=1:obj.kHeight

                        ordata(j,i)=or(obj.dataColReg(j,i),obj.notNhood(j,i));
                        firstand(1,i)=and(firstand(1,i),ordata(j,i));
                    end
                    finaland=and(finaland,firstand(1,i));
                end

                mval(kk)=finaland;

            end
        end




        function num=getNumInputsImpl(~)
            num=2;
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end


        function icon=getIconImpl(~)
            icon='Erosion';
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
                s.yReg=obj.yReg;
                s.hStartReg=obj.hStartReg;
                s.hEndReg=obj.hEndReg;
                s.vStartReg=obj.vStartReg;
                s.vEndReg=obj.vEndReg;
                s.validReg=obj.validReg;
                s.hStartKernelReg=obj.hStartKernelReg;
                s.hEndKernelReg=obj.hEndKernelReg;
                s.vStartKernelReg=obj.vStartKernelReg;
                s.vEndKernelReg=obj.vEndKernelReg;
                s.validKernelReg=obj.validKernelReg;
                s.dataColReg=obj.dataColReg;
                s.notNhood=obj.notNhood;
                s.kHeight=obj.kHeight;
                s.kWidth=obj.kWidth;
                s.linebufferDelay=obj.linebufferDelay;
                s.hdlDelay=obj.hdlDelay;
                s.ctrlregDelay=obj.ctrlregDelay;
                s.MultiPixelWindow=obj.MultiPixelWindow;
                s.MultiPixelFilterKernel=obj.MultiPixelFilterKernel;
                s.filterHandle=obj.filterHandle;
                s.NumberOfPixels=obj.NumberOfPixels;
                s.DelayLine=obj.DelayLine;
                s.PaddingNoneValid=obj.PaddingNoneValid;
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
