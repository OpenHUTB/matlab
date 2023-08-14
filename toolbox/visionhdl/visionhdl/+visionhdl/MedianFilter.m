classdef(StrictDefaults)MedianFilter<visionhdl.internal.abstractLineMemoryKernel















































































%#codegen
%#ok<*EMCLS>
    properties(Nontunable)



        NeighborhoodSize='3x3';



        PaddingMethod='Symmetric';




        PaddingValue=0;




        LineBufferSize=2048;
    end

    properties(Access=private)

        imreg;
        corner;
        lcorner;
        rcorner;


        yReg;
        dataOutReg;
        hStartOutKernelReg;
        hEndOutKernelReg;
        vStartOutKernelReg;
        vEndOutKernelReg;
        validOutKernelReg;
        hStartOutReg;
        hEndOutReg;
        vStartOutReg;
        vEndOutReg;
        validOutReg;
        DelayLine;
        MultiPixelWindow;
        MultiPixelFilterKernel;
        PaddingNoneValid;
    end

    properties(Nontunable,Access=private)
        bSize=1;
        NSize=3;

        hdldelay=6;
        linebufferDelay=1;
        yzero;
    end


    properties(Constant,Hidden)

        NeighborhoodSizeSet=matlab.system.StringSet({...
        '3x3',...
        '5x5',...
        '7x7'});

        PaddingMethodSet=matlab.system.StringSet({...
        'Constant',...
        'Replicate',...
        'Symmetric',...
        'Reflection',...
        'None'});

    end


    properties(Access=private,Nontunable)
        filterHandle;
        NumberOfPixels;
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl

            header=matlab.system.display.Header('visionhdl.MedianFilter',...
            'ShowSourceLink',false,...
            'Title','Median Filter');
        end

    end

    methods
        function obj=MedianFilter(varargin)
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


        function set.PaddingValue(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','>=',0},'','PaddingValue');
            obj.PaddingValue=val;
        end

        function set.LineBufferSize(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'','LineBufferSize');
            obj.LineBufferSize=val;
        end

    end

    methods(Access=protected)

        function[y,CtrlOut]=outputImpl(obj,~,~)


            CtrlOut.hStart=obj.hStartOutReg(1);
            CtrlOut.hEnd=obj.hEndOutReg(1);
            CtrlOut.vStart=obj.vStartOutReg(1);
            CtrlOut.vEnd=obj.vEndOutReg(1);
            CtrlOut.valid=obj.validOutReg(1);

            if CtrlOut.valid
                y=obj.yReg(:,1);
            else
                y=obj.yzero;
            end
        end

        function updateImpl(obj,dataIn,ctrlIn)


            hStartIn=ctrlIn.hStart;
            hEndIn=ctrlIn.hEnd;
            vStartIn=ctrlIn.vStart;
            vEndIn=ctrlIn.vEnd;
            validIn=ctrlIn.valid;


            [dataCol,hStart,hEnd,vStart,vEnd,valid,processData]=...
            stepKernelMemory(obj,dataIn,hStartIn,hEndIn,vStartIn,vEndIn,validIn);



            if processData||obj.PaddingNoneValid
                yt=obj.filterHandle(obj,dataCol,processData);

            else
                yt=obj.yzero;
            end






            obj.validOutReg(1:end-1)=obj.validOutReg(2:end);
            obj.hStartOutReg(1:end-1)=obj.hStartOutReg(2:end);
            obj.hEndOutReg(1:end-1)=obj.hEndOutReg(2:end);
            obj.vStartOutReg(1:end-1)=obj.vStartOutReg(2:end);
            obj.vEndOutReg(1:end-1)=obj.vEndOutReg(2:end);
            obj.yReg(:,1:end-1)=obj.yReg(:,2:end);
            if strcmpi(obj.PaddingMethod,'None')

                if processData||(obj.PaddingNoneValid)

                    obj.validOutReg(end)=obj.validOutKernelReg(1)||obj.PaddingNoneValid;
                    obj.hStartOutReg(end)=obj.hStartOutKernelReg(1);
                    obj.hEndOutReg(end)=obj.hEndOutKernelReg(1);
                    obj.vStartOutReg(end)=obj.vStartOutKernelReg(1);
                    obj.vEndOutReg(end)=obj.vEndOutKernelReg(1);

                    obj.validOutKernelReg(1:end-1)=obj.validOutKernelReg(2:end);
                    obj.hStartOutKernelReg(1:end-1)=obj.hStartOutKernelReg(2:end);
                    obj.vStartOutKernelReg(1:end-1)=obj.vStartOutKernelReg(2:end);

                    obj.validOutKernelReg(end)=valid;
                    obj.hStartOutKernelReg(end)=hStart;
                    obj.vStartOutKernelReg(end)=vStart;

                else

                    obj.validOutReg(end)=false;
                    obj.hStartOutReg(end)=false;
                    obj.hEndOutReg(end)=false;
                    obj.vStartOutReg(end)=false;
                    obj.vEndOutReg(end)=false;
                end

                if hEnd
                    obj.PaddingNoneValid=true;

                    obj.validOutKernelReg(1:end)=false;
                elseif obj.hEndOutKernelReg(1)
                    obj.PaddingNoneValid=false;

                    obj.validOutKernelReg(1:end)=false;
                end

                obj.hEndOutKernelReg(1:end-1)=obj.hEndOutKernelReg(2:end);
                obj.hEndOutKernelReg(end)=hEnd;
                obj.vEndOutKernelReg(1:end-1)=obj.vEndOutKernelReg(2:end);
                obj.vEndOutKernelReg(end)=vEnd;


            else

                if processData

                    obj.validOutReg(end)=obj.validOutKernelReg(1);
                    obj.hStartOutReg(end)=obj.hStartOutKernelReg(1);
                    obj.hEndOutReg(end)=obj.hEndOutKernelReg(1);
                    obj.vStartOutReg(end)=obj.vStartOutKernelReg(1);
                    obj.vEndOutReg(end)=obj.vEndOutKernelReg(1);

                    obj.validOutKernelReg(1:end-1)=obj.validOutKernelReg(2:end);
                    obj.hStartOutKernelReg(1:end-1)=obj.hStartOutKernelReg(2:end);
                    obj.hEndOutKernelReg(1:end-1)=obj.hEndOutKernelReg(2:end);
                    obj.vStartOutKernelReg(1:end-1)=obj.vStartOutKernelReg(2:end);
                    obj.vEndOutKernelReg(1:end-1)=obj.vEndOutKernelReg(2:end);

                    obj.validOutKernelReg(end)=valid;
                    obj.hStartOutKernelReg(end)=hStart;
                    obj.hEndOutKernelReg(end)=hEnd;
                    obj.vStartOutKernelReg(end)=vStart;
                    obj.vEndOutKernelReg(end)=vEnd;

                else
                    obj.validOutReg(end)=false;
                    obj.hStartOutReg(end)=false;
                    obj.hEndOutReg(end)=false;
                    obj.vStartOutReg(end)=false;
                    obj.vEndOutReg(end)=false;
                end

            end





            obj.yReg(:,end)=yt;







        end

        function setupImpl(obj,dataIn,ctrlIn)
            if isempty(coder.target)||~eml_ambiguous_types

                validatecontrolsignals(ctrlIn);

                if isa(dataIn,'embedded.fi')
                    FL=dataIn.FractionLength;
                    coder.internal.errorIf(FL~=0,'visionhdl:MedianFilter:NonZeroFractionLength');
                end
            end

            if~ismember(size(dataIn,1),[1,4,8])
                coder.internal.error('visionhdl:MedianFilter:InputDimensions');
            end

            switch obj.NeighborhoodSize
            case '3x3'
                obj.NSize=3;
            case '5x5'
                obj.NSize=5;
            case '7x7'
                obj.NSize=7;
            otherwise
                obj.NSize=3;
            end

            obj.NumberOfPixels=length(dataIn);



            obj.KernelMemoryKernelHeight=obj.NSize;
            obj.KernelMemoryKernelWidth=obj.NSize;
            obj.KernelMemoryMaxLineSize=obj.LineBufferSize;
            obj.KernelMemoryPaddingMethod=obj.PaddingMethod;
            obj.KernelMemoryPaddingValue=obj.PaddingValue;
            obj.KernelMemoryBiasUp=true;
            setupKernelMemory(obj,dataIn,ctrlIn.hStart,ctrlIn.hEnd,ctrlIn.vStart,ctrlIn.vEnd,ctrlIn.valid);


            if obj.NumberOfPixels==1
                obj.bSize=floor(obj.NSize/2);
                obj.linebufferDelay=floor(obj.NSize/2);
            else
                obj.bSize=floor(obj.NSize/2);
                halfWidth=floor(obj.NSize/2);
                numMatrices=(ceil(halfWidth/double(obj.NumberOfPixels)))*2+1;
                obj.linebufferDelay=floor(numMatrices/2);
            end
            refdata=dataIn;


            switch obj.NSize
            case 3
                mcdelay=4;
            case 5
                mcdelay=11;
            case 7
                mcdelay=14;
            otherwise
                mcdelay=4;
            end





            obj.hdldelay=mcdelay+1;

            if obj.NumberOfPixels==1
                obj.yReg=createParamWithDatatype(obj,refdata,obj.NumberOfPixels,mcdelay+1);
            else
                obj.yReg=createParamWithDatatype(obj,refdata,obj.NumberOfPixels,mcdelay+obj.linebufferDelay);
            end

            obj.hStartOutReg=false(obj.hdldelay,1);
            obj.hEndOutReg=false(obj.hdldelay,1);
            obj.vStartOutReg=false(obj.hdldelay,1);
            obj.vEndOutReg=false(obj.hdldelay,1);
            obj.validOutReg=false(obj.hdldelay,1);











            obj.hStartOutKernelReg=false(obj.linebufferDelay,1);
            obj.hEndOutKernelReg=false(obj.linebufferDelay,1);
            obj.vStartOutKernelReg=false(obj.linebufferDelay,1);
            obj.vEndOutKernelReg=false(obj.linebufferDelay,1);
            obj.validOutKernelReg=false(obj.linebufferDelay,1);

            if obj.NumberOfPixels==1
                obj.imreg=createParamWithDatatype(obj,refdata,obj.NSize,obj.NSize);
            else
                obj.imreg=createParamWithDatatype(obj,refdata,obj.NSize,obj.NumberOfPixels);
            end

            s=obj.bSize*(obj.bSize+2);
            obj.corner=createParamWithDatatype(obj,refdata,1,s);
            sl=(obj.NSize-obj.bSize-1)^2;
            obj.lcorner=createParamWithDatatype(obj,refdata,sl,1);
            obj.rcorner=createParamWithDatatype(obj,refdata,sl,1);
            obj.yzero=cast(zeros(obj.NumberOfPixels,1),'like',refdata);

            startFrameCleanup(obj);


            if obj.NumberOfPixels==1
                obj.filterHandle=@medianCoreSinglePixel;
            else
                obj.filterHandle=@medianCoreMultiPixel;
            end


            if obj.NumberOfPixels==1
                obj.DelayLine=cast(zeros(obj.KernelMemoryKernelHeight,obj.KernelMemoryKernelWidth),'like',dataIn);
            else
                halfWidth=floor(obj.KernelMemoryKernelWidth/2);
                numMatrices=(ceil(halfWidth/obj.NumberOfPixels))*2+1;
                obj.DelayLine=cast(zeros(obj.KernelMemoryKernelHeight,obj.NumberOfPixels,numMatrices),'like',dataIn);
                if numMatrices==3
                    windowLength=((numMatrices-2)*obj.NumberOfPixels)+halfWidth*2;
                else
                    windowLength=((numMatrices-2)*obj.NumberOfPixels)+(halfWidth-((ceil(halfWidth/obj.NumberOfPixels))-1)*obj.NumberOfPixels)*2;
                end
                obj.MultiPixelWindow=cast(zeros(obj.KernelMemoryKernelHeight,windowLength),'like',dataIn);
                obj.MultiPixelFilterKernel=cast(zeros(obj.KernelMemoryKernelHeight,obj.KernelMemoryKernelWidth,obj.NumberOfPixels),'like',dataIn);
            end

            obj.PaddingNoneValid=false;


            if obj.NumberOfPixels>1&&obj.NSize==7&&strcmpi(obj.PaddingMethod,'None')
                coder.internal.error('visionhdl:MedianFilter:PadNone');
            end



        end


        function startFrameCleanup(obj)

            obj.imreg(:,:,:)=0;
            obj.corner(:,:,:)=0;
            obj.lcorner(:,:,:)=0;
            obj.rcorner(:,:,:)=0;








        end

        function startFrameCleanupOutputs(obj)
            obj.yReg(:,:)=0;
            obj.dataReg(:,:)=0;
            obj.hStartOutReg(:,:)=0;
            obj.hEndOutReg(:,:)=0;
            obj.vStartOutReg(:,:)=0;
            obj.vEndOutReg(:,:)=0;
            obj.validOutReg(:,:)=0;
            obj.hStartOutKernelReg(:,:)=0;
            obj.hEndOutKernelReg(:,:)=0;
            obj.vStartOutKernelReg(:,:)=0;
            obj.vEndOutKernelReg(:,:)=0;
            obj.validOutKernelReg(:,:)=0;
        end


        function num=getNumInputsImpl(~)
            num=2;
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end


        function icon=getIconImpl(~)

            icon=sprintf('Median Filter');
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


        function flag=isInactivePropertyImpl(obj,prop)


            if strcmp(prop,'PaddingValue')&&~strcmp(obj.PaddingMethod,'Constant')
                flag=true;
            else
                flag=false;
            end


        end





















        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);
            s=saveObjectKernelMemory(obj,s);

            if obj.isLocked

                s.imreg=obj.imreg;
                s.corner=obj.corner;
                s.lcorner=obj.lcorner;
                s.rcorner=obj.rcorner;

                s.bSize=obj.bSize;

                s.NSize=obj.NSize;
                s.linebufferDelay=obj.linebufferDelay;
                s.hdldelay=obj.hdldelay;
                s.yzero=obj.yzero;

                s.yReg=obj.yReg;
                s.dataOutReg=obj.dataOutReg;
                s.hStartOutReg=obj.hStartOutReg;
                s.hEndOutReg=obj.hEndOutReg;
                s.vStartOutReg=obj.vStartOutReg;
                s.vEndOutReg=obj.vEndOutReg;
                s.validOutReg=obj.validOutReg;
                s.hStartOutKernelReg=obj.hStartOutKernelReg;
                s.hEndOutKernelReg=obj.hEndOutKernelReg;
                s.vStartOutKernelReg=obj.vStartOutKernelReg;
                s.vEndOutKernelReg=obj.vEndOutKernelReg;
                s.validOutKernelReg=obj.validOutKernelReg;
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


        function resetImpl(obj)



            startFrameCleanup(obj)

        end



        function yy=createParamWithDatatype(~,refdata,r,c)

            if~islogical(refdata)
                yy=zeros([r,c],'like',refdata);
            else
                yy=false(r,c);
            end

        end




        function mresult=medianCoreSinglePixel(obj,newCol,processData)
            n=obj.NSize;
            mp=ceil(n/2);








            if processData
                obj.imreg(:,1:end-1)=obj.imreg(:,2:end);
            end




            if processData
                obj.imreg(:,end)=basicsort(obj,newCol);
            end




            if~obj.PaddingNoneValid
                y=obj.imreg;
            else


                y=cast((obj.imreg.*0),'like',obj.imreg);





            end



            idx=basicsort(obj,y(mp,:),1);


            yload=y(:,idx);





            obj.lcorner(:,:)=0;
            obj.lcorner(1:obj.bSize,1)=yload(mp+1:end,1);
            for i=coder.unroll(2:mp-1)
                obj.lcorner(1:i*obj.bSize,1)=visionhdl.MedianFilter.OddEvenMerge(obj.lcorner(1:(i-1)*obj.bSize,1),yload(mp+1:end,i));
            end


            obj.rcorner(:,:)=0;
            obj.rcorner(1:obj.bSize,1)=yload(1:mp-1,mp+1);

            for i=coder.unroll(mp+2:n)
                k=obj.bSize-(n-i);

                obj.rcorner(1:k*obj.bSize,1)=visionhdl.MedianFilter.OddEvenMerge(obj.rcorner(1:(k-1)*obj.bSize,1),yload(1:mp-1,i));
            end


            uncovered=visionhdl.MedianFilter.OddEvenMerge(obj.lcorner,obj.rcorner);
            mm=yload(mp,mp);
            marea=visionhdl.MedianFilter.OddEvenMerge(uncovered,mm);

            mrefpos=length(uncovered)/2;
            obj.corner(:,:)=0;
            if mm<uncovered(mrefpos)


                obj.corner(1:mp-1)=yload(mp+1:n,mp);
                for jj=coder.unroll(1:mp-1)

                    obj.corner(1:mp-1+jj*mp)=visionhdl.MedianFilter.OddEvenMerge(obj.corner(1:mp-1+(jj-1)*mp),yload(mp:n,mp+jj));
                end

                fops=ceil(n*n/2)-length(obj.corner);
            else


                obj.corner(1:mp-1)=yload(1:mp-1,mp);
                for jj=coder.unroll(1:mp-1)

                    obj.corner(1:mp-1+jj*mp)=visionhdl.MedianFilter.OddEvenMerge(obj.corner(1:mp-1+(jj-1)*mp),yload(1:mp,mp-jj));
                end



                fops=ceil(n*n/2);
            end

            yfinal=visionhdl.MedianFilter.OddEvenMerge(marea,obj.corner);

            if mm==uncovered(mrefpos)
                mresult=mm;
            else
                mresult=yfinal(fops);
            end

        end



        function mresult=medianCoreMultiPixel(obj,newCol,processDataOut)
            n=obj.NSize;
            mp=ceil(n/2);













            for ii=1:1:obj.NumberOfPixels
                obj.imreg(:,ii)=basicsort(obj,newCol(:,ii));
            end



            halfWidth=(floor(obj.KernelMemoryKernelWidth/2))-((ceil((floor(obj.KernelMemoryKernelWidth/2))/obj.NumberOfPixels)-1)*obj.NumberOfPixels);



            if processDataOut
                obj.DelayLine(:,:,end-1:-1:1)=obj.DelayLine(:,:,end:-1:2);
                obj.DelayLine(:,:,end)=obj.imreg;
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
                            obj.MultiPixelWindow(:,windowCount)=newCol(:,jj);
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

            evenKernelUp=(mod(obj.KernelMemoryKernelWidth,2)==0)&&obj.KernelMemoryBiasUp;

            for kk=1:1:obj.NumberOfPixels

                obj.MultiPixelFilterKernel(:,:,kk)=obj.MultiPixelWindow(:,kk+evenKernelUp:obj.KernelMemoryKernelWidth+(kk-1+evenKernelUp));
            end


            mresult=cast(zeros(obj.NumberOfPixels,1),'like',newCol);

            for ii=1:1:obj.NumberOfPixels

                y=(obj.MultiPixelFilterKernel(:,:,ii));

                idx=basicsort(obj,y(mp,:),1);


                yload=y(:,idx);





                obj.lcorner(:,:)=0;
                obj.lcorner(1:obj.bSize,1)=yload(mp+1:end,1);
                for i=coder.unroll(2:mp-1)
                    obj.lcorner(1:i*obj.bSize,1)=visionhdl.MedianFilter.OddEvenMerge(obj.lcorner(1:(i-1)*obj.bSize,1),yload(mp+1:end,i));
                end


                obj.rcorner(:,:)=0;
                obj.rcorner(1:obj.bSize,1)=yload(1:mp-1,mp+1);

                for i=coder.unroll(mp+2:n)
                    k=obj.bSize-(n-i);

                    obj.rcorner(1:k*obj.bSize,1)=visionhdl.MedianFilter.OddEvenMerge(obj.rcorner(1:(k-1)*obj.bSize,1),yload(1:mp-1,i));
                end


                uncovered=visionhdl.MedianFilter.OddEvenMerge(obj.lcorner,obj.rcorner);
                mm=yload(mp,mp);
                marea=visionhdl.MedianFilter.OddEvenMerge(uncovered,mm);

                mrefpos=length(uncovered)/2;
                obj.corner(:,:)=0;
                if mm<uncovered(mrefpos)


                    obj.corner(1:mp-1)=yload(mp+1:n,mp);
                    for jj=coder.unroll(1:mp-1)

                        obj.corner(1:mp-1+jj*mp)=visionhdl.MedianFilter.OddEvenMerge(obj.corner(1:mp-1+(jj-1)*mp),yload(mp:n,mp+jj));
                    end

                    fops=ceil(n*n/2)-length(obj.corner);
                else


                    obj.corner(1:mp-1)=yload(1:mp-1,mp);
                    for jj=coder.unroll(1:mp-1)

                        obj.corner(1:mp-1+jj*mp)=visionhdl.MedianFilter.OddEvenMerge(obj.corner(1:mp-1+(jj-1)*mp),yload(1:mp,mp-jj));
                    end



                    fops=ceil(n*n/2);
                end

                yfinal=visionhdl.MedianFilter.OddEvenMerge(marea,obj.corner);
                if mm==uncovered(mrefpos)
                    mresult(ii)=mm;
                else
                    mresult(ii)=yfinal(fops);
                end
            end

        end




        function y=basicsort(obj,x,varargin)




            t3=[1,2;2,3;1,2];
            t5=[1,2,3,4;2,4,3,5;1,3,2,5;2,3,4,5;3,4,0,0];
            t7=[1,2,3,4,5,6;1,3,2,4,5,7;1,5,2,6,3,7;2,5,4,7,0,0;3,5,4,6,0,0;2,3,4,5,6,7];
            t9=[1,8,2,7,3,6,4,5;1,4,5,8,2,3,7,9;1,2,3,7,4,5,6,9;2,3,4,6,5,7,8,9;2,4,3,5,6,8,0,0;1,2,3,4,5,6,7,8;4,5,6,7,0,0,0,0];
            t11=[2,11,3,10,4,9,5,8,6,7;1,7,2,5,8,11,3,4,9,10;1,2,3,6,8,9,10,11,4,5;1,3,2,6,5,7,9,10,0,0;3,4,7,11,6,10,2,9,5,8;...
            4,6,7,10,2,5,8,9,0,0;2,3,4,5,6,8,7,9,0,0;3,4,5,6,7,8,0,0,0,0];
            len=length(x);

            switch len
            case 3
                t=t3;
            case 5
                t=t5;
            case 7
                t=t7;
            case 9
                t=t9;
            case 11
                t=t11;
            otherwise
                y=x;
                return;
            end



            rx=x;
            yidx=(1:len);
            [stages,pcoms]=size(t);

            for i=1:stages
                for j=1:2:pcoms
                    [rx,yidx]=compare_exchange(obj,rx,yidx,t(i,j),t(i,j+1));
                end
            end

            if nargin>2

                y=yidx;
            else
                y=rx;
            end

        end


        function[y,yidx]=compare_exchange(~,x,xidx,lo,hi)

            y=x;
            yidx=xidx;
            if and(lo,hi)~=0
                if x(lo)>x(hi)

                    y(hi)=x(lo);
                    y(lo)=x(hi);
                    yidx(hi)=xidx(lo);
                    yidx(lo)=xidx(hi);
                end
            end
        end


    end


    methods(Static,Access=protected)
        function y=OddEvenMerge(s1,s2)

            n1=length(s1);
            n2=length(s2);


            if n2==0
                y=s1;
                return;
            elseif n1==0
                y=s2;
                return;
            else
                n=max(n1,n2);


            end



            if n>1
                odds1=s1(1:2:end);
                evens1=s1(2:2:end);
                odds2=s2(1:2:end);
                evens2=s2(2:2:end);

                c1=visionhdl.MedianFilter.OddEvenMerge(odds1,evens2);
                c2=visionhdl.MedianFilter.OddEvenMerge(odds2,evens1);
                y=visionhdl.MedianFilter.finalCompare(c1,c2);
            else
                y=visionhdl.MedianFilter.finalCompare(s1,s2);

            end
        end


        function y=finalCompare(c,d)

            len1=length(c);
            len2=length(d);

            if len1>=len2
                len=len2;

                longseq=c;
            else
                len=len1;

                longseq=d;
            end
            y=cast(zeros(len1+len2,1),'like',c);

            if len>0



                kk=1;


                for i=1:len

                    if c(i)>=d(i)

                        y(kk)=d(i);
                        y(kk+1)=c(i);

                    else

                        y(kk)=c(i);
                        y(kk+1)=d(i);

                    end
                    kk=kk+2;
                end

                if len1~=len2
                    y(kk)=longseq(len+1);
                end
            else
                y=longseq;
            end

        end


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
