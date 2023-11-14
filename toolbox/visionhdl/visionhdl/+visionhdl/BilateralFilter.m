classdef(StrictDefaults)BilateralFilter<visionhdl.internal.abstractLineMemoryKernel
%#codegen
%#ok<*EMCLS>

    properties(Nontunable)

        NeighborhoodSize='3x3';

        SpatialStdDev=0.5;

        IntensityStdDev=0.5;

        PaddingMethod='Constant';

        PaddingValue=0;

        LineBufferSize=2048;

        CoefficientsDataType='Same as first input';

        CustomCoefficientsDataType=numerictype(1,16,15);


        RoundingMethod='Floor';


        OverflowAction='Saturate';


        OutputDataType='Same as first input';

        CustomOutputDataType=numerictype(1,8,0);
    end

    properties(Constant,Hidden)
        NeighborhoodSizeSet=matlab.system.StringSet({...
        '3x3',...
        '5x5',...
        '7x7',...
        '9x9',...
        '11x11',...
        '13x13',...
        '15x15'});

        PaddingMethodSet=matlab.system.StringSet({...
        'Constant',...
        'Replicate',...
        'Symmetric',...
        'Reflection',...
        'None'});

        CoefficientsDataTypeSet=matlab.system.internal.DataTypeSet(...
        {'Same as first input','Custom',matlab.system.internal.CustomDataType('Signedness',{'Signed','Unsigned'})},...
        'Compatibility','Legacy');


        RoundingMethodSet=matlab.system.internal.RoundingMethodSet({...

        'Ceiling',...
        'Convergent',...
        'Floor',...
        'Nearest',...
        'Round',...
        'Zero'});

        OverflowActionSet=matlab.system.internal.OverflowActionSet;

        OutputDataTypeSet=matlab.system.internal.DataTypeSet(...
        {'Same as first input','Full precision','Custom',matlab.system.internal.CustomDataType('Signedness',{'Signed','Unsigned'})},...
        'Compatibility','Legacy',...
        'HasDesignMinimum',true,...
        'HasDesignMaximum',true);
    end


    properties(Nontunable,Access=private)
        NSize;
        CenterCoord;
        DoubleSingle;
        SummationType;
        AccumulatorType;
        InputExampleType;
        RecipLUTAddrType;
        InputWL;
        InputFL;
    end

    properties(Access=private)
        WeightedSumFi;
        DataDelay;
        CtrlDelay;
        CtrlKernelDelay;
        DelayLine;
        LUT;
        RecipLUT;
        CoeffCastFlip;
        PaddingNoneValid;
        MultiPixelWindow;
        MultiPixelFilterKernel;
    end

    properties(Access=private,Nontunable)
        filterHandle;
        NumberOfPixels;
    end

    methods(Static,Access=protected)










    end

    methods
        function obj=BilateralFilter(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','Vision_HDL_Toolbox'))
                    error(message('visionhdl:visionhdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','Vision_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:},'NeighborhoodSize','LineBufferSize');
        end

        function set.CustomCoefficientsDataType(obj,val)
            validateCustomDataType(obj,'CustomCoefficientsDataType',val,{'Property','CoefficientsDataTypeSet'});
            obj.CustomCoefficientsDataType=val;
        end

        function set.CustomOutputDataType(obj,val)
            validateCustomDataType(obj,'CustomOutputDataType',val,{'Property','OutputDataTypeSet'});
            obj.CustomOutputDataType=val;
        end

        function set.PaddingValue(obj,val)
            validateattributes(val,{'numeric'},{'scalar','real','finite'},'BilateralFilter','PaddingValue');
            obj.PaddingValue=val;
        end

        function set.LineBufferSize(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'BilateralFilter','Line buffer size');
            obj.LineBufferSize=val;
        end

        function set.SpatialStdDev(obj,val)
            validateattributes(val,{'numeric'},{'scalar','real','finite','>',0},'BilateralFilter','SpatialStdDev');
            obj.SpatialStdDev=val;
        end

        function set.IntensityStdDev(obj,val)
            validateattributes(val,{'numeric'},{'scalar','real','finite','>',0},'BilateralFilter','IntensityStdDev');
            obj.IntensityStdDev=val;
        end


    end

    methods(Static,Access=protected)
        function header=getHeaderImpl

            header=matlab.system.display.Header('visionhdl.BilateralFilter',...
            'ShowSourceLink',false,...
            'Title','Bilateral Filter');
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case{'PaddingValue'}
                if~strcmp(obj.PaddingMethod,'Constant')
                    flag=true;
                end
            case{'CustomCoefficientsDataType'}
                if~strcmp(obj.CoefficientsDataType,'Custom')
                    flag=true;
                end
            case{'CustomOutputDataType'}
                if~strcmp(obj.OutputDataType,'Custom')
                    flag=true;
                end
            end
        end

        function validateInputsImpl(~,pixelIn,ctrlIn)

            if isempty(coder.target)||~eml_ambiguous_types
                validateattributes(pixelIn,{'numeric','embedded.fi'},...
                {'real'},'BilateralFilter','pixelIn');


                if~(ismember((size(pixelIn,1)),[1,2,4,8]))
                    coder.internal.error('visionhdl:BilateralFilter:InputDimensions');
                end


                if(size(pixelIn,2))~=1
                    coder.internal.error('visionhdl:BilateralFilter:UnsupportedComps');
                end


                validatecontrolsignals(ctrlIn);
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

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);
            s=saveObjectKernelMemory(obj,s);
            if obj.isLocked
                s.CoeffCastFlip=obj.CoeffCastFlip;
                s.NSize=obj.NSize;
                s.CenterCoord=obj.CenterCoord;
                s.WeightedSumFi=obj.WeightedSumFi;
                s.DataDelay=obj.DataDelay;
                s.CtrlDelay=obj.CtrlDelay;

                s.CtrlKernelDelay=obj.CtrlKernelDelay;

                s.DelayLine=obj.DelayLine;
                s.DoubleSingle=obj.DoubleSingle;
                s.LUT=obj.LUT;
                s.RecipLUT=obj.RecipLUT;
                s.SummationType=obj.SummationType;
                s.AccumulatorType=obj.AccumulatorType;
                s.InputExampleType=obj.InputExampleType;
                s.RecipLUTAddrType=obj.RecipLUTAddrType;
                s.InputWL=obj.InputWL;
                s.InputFL=obj.InputFL;
                s.filterHandle=obj.filterHandle;
                s.NumberOfPixels=obj.NumberOfPixels;
                s.PaddingNoneValid=obj.PaddingNoneValid;
            end
        end

        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end


        function[NSize,CenterCoord]=getSizesForNeighborhood(obj)
            switch obj.NeighborhoodSize
            case '3x3'
                NSize=3;
                CenterCoord=2;
            case '5x5'
                NSize=5;
                CenterCoord=3;
            case '7x7'
                NSize=7;
                CenterCoord=4;
            case '9x9'
                NSize=9;
                CenterCoord=5;
            case '11x11'
                NSize=11;
                CenterCoord=6;
            case '13x13'
                NSize=13;
                CenterCoord=7;
            case '15x15'
                NSize=15;
                CenterCoord=8;
            otherwise
                NSize=3;
                CenterCoord=2;
            end
        end

        function setupImpl(obj,pixelIn,ctrlIn)

            [obj.NSize,obj.CenterCoord]=getSizesForNeighborhood(obj);

            obj.KernelMemoryKernelHeight=obj.NSize;
            obj.KernelMemoryKernelWidth=obj.NSize;
            obj.KernelMemoryMaxLineSize=obj.LineBufferSize;
            obj.KernelMemoryPaddingMethod=obj.PaddingMethod;
            obj.KernelMemoryPaddingValue=obj.PaddingValue;
            obj.KernelMemoryBiasUp=true;
            obj.NumberOfPixels=length(pixelIn);

            w=obj.CenterCoord-1;
            [Xcoord,Ycoord]=meshgrid(-w:w,-w:w);
            G=exp(-(Xcoord.^2+Ycoord.^2)/(2*obj.SpatialStdDev^2));
            G(G<eps(max(G(:))))=0;
            sumG=sum(G(:));
            if sumG~=0
                G=G/sumG;
            end

            if isa(pixelIn,'single')||isa(pixelIn,'double')
                obj.DoubleSingle=true;
                obj.CoeffCastFlip=cast(fliplr(G),'like',pixelIn);
                obj.InputExampleType=cast(0,'like',pixelIn);
                obj.InputWL=0;
                obj.InputFL=0;
            else
                obj.DoubleSingle=false;
                if isa(pixelIn,'uint8')
                    obj.InputExampleType=fi(0,0,8,0);
                    LUT_T=fi(0,0,9,0);
                elseif isa(pixelIn,'int8')
                    obj.InputExampleType=fi(0,1,8,0);
                    LUT_T=fi(0,0,9,0);
                elseif isa(pixelIn,'uint16')
                    obj.InputExampleType=fi(0,0,16,0);
                    LUT_T=fi(0,0,17,0);
                elseif isa(pixelIn,'int16')
                    obj.InputExampleType=fi(0,1,16,0);
                    LUT_T=fi(0,0,17,0);
                elseif isa(pixelIn,'uint32')
                    obj.InputExampleType=fi(0,0,32,0);
                    LUT_T=fi(0,0,33,0);
                elseif isa(pixelIn,'int32')
                    obj.InputExampleType=fi(0,1,32,0);
                    LUT_T=fi(0,0,33,0);
                elseif isa(pixelIn,'uint64')
                    obj.InputExampleType=fi(0,0,64,0);
                    LUT_T=fi(0,0,65,0);
                elseif isa(pixelIn,'int64')
                    obj.InputExampleType=fi(0,1,64,0);
                    LUT_T=fi(0,0,65,0);
                else
                    obj.InputExampleType=cast(0,'like',pixelIn);
                    width=obj.InputExampleType.WordLength+1;
                    LUT_T=fi(0,0,width,0);
                end
                nType=numerictype(obj.InputExampleType);
                obj.InputWL=nType.WordLength;
                obj.InputFL=nType.FractionLength;
            end

            if obj.NumberOfPixels==1
                if obj.DoubleSingle
                    obj.DelayLine=cast(zeros(obj.KernelMemoryKernelHeight,obj.KernelMemoryKernelWidth),'like',pixelIn);
                    setupKernelMemory(obj,pixelIn,ctrlIn.hStart,ctrlIn.hEnd,ctrlIn.vStart,ctrlIn.vEnd,ctrlIn.valid);
                else
                    obj.DelayLine=cast(zeros(obj.KernelMemoryKernelHeight,obj.KernelMemoryKernelWidth),'like',obj.InputExampleType);
                    pixelInCast=cast(pixelIn,'like',obj.InputExampleType);
                    setupKernelMemory(obj,pixelInCast,ctrlIn.hStart,ctrlIn.hEnd,ctrlIn.vStart,ctrlIn.vEnd,ctrlIn.valid);
                end



            else
                if obj.DoubleSingle
                    setupKernelMemory(obj,pixelIn,ctrlIn.hStart,ctrlIn.hEnd,ctrlIn.vStart,ctrlIn.vEnd,ctrlIn.valid);
                    halfWidth=floor(obj.KernelMemoryKernelWidth/2);
                    numMatrices=(ceil(halfWidth/obj.NumberOfPixels))*2+1;
                    obj.DelayLine=cast(zeros(obj.KernelMemoryKernelHeight,obj.NumberOfPixels,numMatrices),'like',pixelIn);
                    if numMatrices==3
                        windowLength=((numMatrices-2)*obj.NumberOfPixels)+halfWidth*2;
                    else
                        windowLength=((numMatrices-2)*obj.NumberOfPixels)+(halfWidth-((ceil(halfWidth/obj.NumberOfPixels))-1)*obj.NumberOfPixels)*2;
                    end
                    obj.MultiPixelWindow=cast(zeros(obj.KernelMemoryKernelHeight,windowLength),'like',pixelIn);
                    obj.MultiPixelFilterKernel=cast(zeros(obj.KernelMemoryKernelHeight,obj.KernelMemoryKernelWidth,obj.NumberOfPixels),'like',pixelIn);
                else
                    pixelInCast=cast(pixelIn,'like',obj.InputExampleType);
                    setupKernelMemory(obj,pixelInCast,ctrlIn.hStart,ctrlIn.hEnd,ctrlIn.vStart,ctrlIn.vEnd,ctrlIn.valid);
                    halfWidth=floor(obj.KernelMemoryKernelWidth/2);



                    numMatrices=(ceil(halfWidth/obj.NumberOfPixels))*2+1;
                    obj.DelayLine=cast(zeros(obj.KernelMemoryKernelHeight,obj.NumberOfPixels,numMatrices),'like',obj.InputExampleType);



                    if numMatrices==3
                        windowLength=((numMatrices-2)*obj.NumberOfPixels)+halfWidth*2;
                    else
                        windowLength=((numMatrices-2)*obj.NumberOfPixels)+(halfWidth-((ceil(halfWidth/obj.NumberOfPixels))-1)*obj.NumberOfPixels)*2;
                    end


                    obj.MultiPixelWindow=cast(zeros(obj.KernelMemoryKernelHeight,windowLength),'like',obj.InputExampleType);


                    obj.MultiPixelFilterKernel=cast(zeros(obj.KernelMemoryKernelHeight,obj.KernelMemoryKernelWidth,obj.NumberOfPixels),'like',obj.InputExampleType);
                end
            end



            if obj.DoubleSingle
                coeffExampleType=obj.InputExampleType;
                tmpSummationType=obj.InputExampleType;
                obj.AccumulatorType=obj.InputExampleType;
            else
                fiM=fimath('RoundingMethod','Nearest','OverflowAction','Saturate');
                if strcmp(obj.CoefficientsDataType,'Same as first input')
                    coeffExampleType=obj.InputExampleType;
                    obj.CoeffCastFlip=cast(fliplr(G),'like',obj.InputExampleType);
                else
                    obj.CoeffCastFlip=fi(fliplr(G),obj.CustomCoefficientsDataType,fiM);
                    coeffExampleType=fi(0,obj.CustomCoefficientsDataType,fiM);
                end
                tmpSummationType=sum(repmat(coeffExampleType,obj.NSize*obj.NSize,1));
                obj.AccumulatorType=sum(repmat(coeffExampleType*obj.InputExampleType,obj.NSize*obj.NSize,1));
            end



            if obj.DoubleSingle
                obj.LUT=0;
                obj.RecipLUT=0;
                obj.SummationType=tmpSummationType;
            else
                if isempty(coder.target)||~eml_ambiguous_types
                    coder.internal.errorIf(obj.InputExampleType.WordLength>16,'visionhdl:BilateralFilter:WordLength','pixel input');
                end
                range=[0:((2^(LUT_T.WordLength-1))-1),(-(2^(LUT_T.WordLength-1))):-1]./(2^(LUT_T.WordLength-1));
                intensityCoeff=exp((range.^2)./(-2*obj.IntensityStdDev.^2));
                H=G(:);
                tempLUT=zeros(length(H),length(range),'like',coeffExampleType);
                LUTisZero=false(length(H),1);
                doubleSum=0.0;
                for ii=1:length(H)
                    tempLUT(ii,:)=H(ii).*intensityCoeff;
                    LUTisZero(ii)=all(tempLUT(ii,:)==0);
                    doubleSum=doubleSum+double(max(tempLUT(ii,:)));
                end
                obj.LUT=tempLUT;
                if all(LUTisZero)
                    if isempty(coder.target)||~eml_ambiguous_types
                        coder.internal.error('visionhdl:BilateralFilter:ZeroCoeffs');
                    end
                end
                if sum(double(LUTisZero))>floor(length(H)/2)
                    if isempty(coder.target)||~eml_ambiguous_types
                        coder.internal.warning('visionhdl:BilateralFilter:HalfZeroCoeffs');
                    end
                end



                cFL=coder.const(coeffExampleType.FractionLength);
                nBits=coder.const(tmpSummationType.WordLength);
                obj.SummationType=fi(0,issigned(coeffExampleType),nBits,cFL);
                RLUTAddrNBits=max(2,min(nBits,11));
                RLUTAddr=0:((2^RLUTAddrNBits)-1);
                obj.RecipLUTAddrType=fi(0,0,RLUTAddrNBits,0);
                RLUTDataNBits=max(nBits,cFL+2);
                sumMSPart=RLUTAddr./2.^(RLUTAddrNBits-max((nBits-cFL),0));
                recipMSPart=1./sumMSPart;
                infParts=isinf(recipMSPart);
                recipMSPart(infParts)=1.0;
                tmpRecipLUT=fi(recipMSPart,0,RLUTDataNBits,cFL);
                tmpRecipLUT(infParts)=realmax(tmpRecipLUT);
                obj.RecipLUT=tmpRecipLUT;
            end


            if obj.DoubleSingle
                outputT=obj.InputExampleType;
            else
                if strcmp(obj.OutputDataType,'Same as first input')
                    outputT=pixelIn;
                elseif strcmp(obj.OutputDataType,'Full precision')
                    if obj.NumberOfPixels==1
                        tmpOutType=sum(obj.DelayLine(:).*obj.CoeffCastFlip(:),...
                        1,'native');
                        outputT=tmpOutType*obj.RecipLUT(2);
                    else
                        kernel=obj.MultiPixelFilterKernel(:,:,1);
                        tmpOutType=sum(kernel(:).*obj.CoeffCastFlip(:),...
                        1,'native');
                        outputT=tmpOutType*obj.RecipLUT(2);
                    end
                else
                    outputT=fi(0,obj.CustomOutputDataType);
                end
                pFimath=fimath('RoundingMethod',obj.RoundingMethod,...
                'OverflowAction',obj.OverflowAction);
            end

            if isa(outputT,'double')||isa(outputT,'single')
                obj.WeightedSumFi=cast(0,'like',outputT);
            else
                if isa(outputT,'uint8')
                    obj.WeightedSumFi=fi(0,0,8,0,pFimath);
                elseif isa(outputT,'int8')
                    obj.WeightedSumFi=fi(0,1,8,0,pFimath);
                elseif isa(outputT,'uint16')
                    obj.WeightedSumFi=fi(0,0,16,0,pFimath);
                elseif isa(outputT,'int16')
                    obj.WeightedSumFi=fi(0,1,16,0,pFimath);
                elseif isa(outputT,'uint32')
                    obj.WeightedSumFi=fi(0,0,32,0,pFimath);
                elseif isa(outputT,'int32')
                    obj.WeightedSumFi=fi(0,1,32,0,pFimath);
                elseif isa(outputT,'uint64')
                    obj.WeightedSumFi=fi(0,0,64,0,pFimath);
                elseif isa(outputT,'int64')
                    obj.WeightedSumFi=fi(0,1,64,0,pFimath);
                else
                    obj.WeightedSumFi=fi(0,issigned(outputT),...
                    outputT.WordLength,...
                    outputT.FractionLength,...
                    pFimath);
                end
            end


            numDelay=coder.internal.const(kernellatency(obj));

            if obj.NumberOfPixels==1
                obj.DataDelay=cast(zeros(1,numDelay),'like',outputT);
                obj.CtrlDelay=false(5,numDelay);

            else
                obj.DataDelay=cast(zeros(obj.NumberOfPixels,numDelay),'like',outputT);
                obj.CtrlDelay=false(5,numDelay);

            end

            if obj.NumberOfPixels==1
                obj.CtrlKernelDelay=false(5,floor(obj.KernelMemoryKernelWidth/2));
            else
                obj.CtrlKernelDelay=false(5,floor(numMatrices/2));
            end


            if obj.NumberOfPixels==1
                obj.filterHandle=@singlePixelFilter;
            else
                obj.filterHandle=@multiPixelFilter;
            end
            obj.PaddingNoneValid=false;


        end

        function resetImpl(obj)
            obj.DataDelay(:)=0;
            obj.CtrlDelay(:)=false;
            obj.CtrlKernelDelay(:,:)=false;
            obj.DelayLine(:,:)=0;
            obj.PaddingNoneValid=false;
        end

        function[dataOut,ctrlOut]=outputImpl(obj,~,~)



            validOut=obj.CtrlDelay(5,end);
            if validOut
                dataOut=obj.DataDelay(1:obj.NumberOfPixels,end);
                ctrlOut=pixelcontrolstruct(obj.CtrlDelay(1,end),...
                obj.CtrlDelay(2,end),...
                obj.CtrlDelay(3,end),...
                obj.CtrlDelay(4,end),...
                validOut);
            else
                dataOut=cast(zeros(obj.NumberOfPixels,1),'like',obj.DataDelay(1:obj.NumberOfPixels,end));
                ctrlOut=pixelcontrolstruct(false,false,false,false,false);
            end
        end

        function updateImpl(obj,pixelIn,ctrlIn)

            pixelInCast=cast(pixelIn,'like',obj.InputExampleType);
            [dataVector,hStartOut,hEndOut,vStartOut,vEndOut,validOut,processDataOut]=...
            stepKernelMemory(obj,pixelInCast,ctrlIn.hStart,ctrlIn.hEnd,ctrlIn.vStart,ctrlIn.vEnd,ctrlIn.valid);

            ctrlInLB=[hStartOut,hEndOut,vStartOut,vEndOut,validOut,processDataOut];


            obj.filterHandle(obj,dataVector,ctrlIn,ctrlInLB);
        end



        function result=BilateralCoreDoubleSingle(obj,DelayLine)
            center=DelayLine(obj.CenterCoord,obj.CenterCoord);
            intensityKernel=DelayLine-center;
            intensityKernel=intensityKernel.^2;
            intensityKernel=intensityKernel./(-2*obj.IntensityStdDev^2);
            intensityKernel=exp(intensityKernel);
            intensityKernel=intensityKernel.*obj.CoeffCastFlip;
            normFactor=sum(intensityKernel(:));
            weighted=DelayLine(:).*intensityKernel(:);
            weighted_sum=sum(weighted,1,'native');
            weighted_sum=weighted_sum/normFactor;
            obj.WeightedSumFi(:)=weighted_sum;
            result=obj.WeightedSumFi;
        end



        function result=BilateralCore(obj,DelayLine)
            subT=numerictype(1,obj.InputWL+1,obj.InputFL);
            subDL=fi(zeros(obj.NSize,obj.NSize),subT);
            subDL(:)=DelayLine(:);
            center=subDL(obj.CenterCoord,obj.CenterCoord);
            subDL(:)=subDL(:)-center;
            T=numerictype(0,obj.InputWL+1,0);
            lutAddr=reinterpretcast(subDL(:),T);
            summation=zeros(1,1,'like',obj.SummationType);
            accumulator=zeros(1,1,'like',obj.AccumulatorType);
            delayFlat=DelayLine(:);
            for ii=1:(obj.NSize*obj.NSize)
                intensityValue=obj.LUT(ii,lutAddr(ii)+cast(1,'like',lutAddr));
                summation(:)=summation+intensityValue;
                accumulator(:)=accumulator+intensityValue*delayFlat(ii);
            end
            recipAddr=zeros(1,1,'like',obj.RecipLUTAddrType);
            recipAddr(:)=bitsliceget(summation,summation.WordLength,max(0,summation.WordLength-recipAddr.WordLength+1));
            recip=obj.RecipLUT(recipAddr+cast(1,'like',recipAddr));
            finalMult=accumulator*recip;
            obj.WeightedSumFi(:)=finalMult;
            result=obj.WeightedSumFi;
        end


        function num=getNumInputsImpl(~)
            num=2;
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end


        function icon=getIconImpl(~)
            icon=sprintf('Bilateral Filter');
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
            intype=propagatedInputDataType(obj,1);
            if isempty(intype)
                dt1=[];
            elseif(ischar(intype)||(isstring(intype)&&isscalar(intype)))&&(strcmp(intype,'double')||strcmp(intype,'single'))
                dt1=intype;
            elseif strcmp(obj.OutputDataType,'Same as first input')
                dt1=intype;
            elseif strcmp(obj.OutputDataType,'Full precision')
                [nsize,~]=getSizesForNeighborhood(obj);
                intype=int2fitype(obj,intype);
                inExample=fi(0,intype);
                fiM=fimath('RoundingMethod','Nearest','OverflowAction','Saturate');
                if strcmp(obj.CoefficientsDataType,'Same as first input')
                    tmpCoeffExampleType=inExample;
                else
                    tmpCoeffExampleType=fi(0,obj.CustomCoefficientsDataType,fiM);
                end
                tmpSummationType=sum(repmat(tmpCoeffExampleType,nsize*nsize,1),1,'native');
                tmpAccumulatorType=sum(repmat(tmpCoeffExampleType*inExample,nsize*nsize,1),1,'native');
                RLUTDataNBits=max(tmpSummationType.WordLength,...
                tmpCoeffExampleType.FractionLength+2);
                tmpRecipType=fi(0,0,RLUTDataNBits,tmpCoeffExampleType.FractionLength);

                resultType=tmpAccumulatorType*tmpRecipType;
                dt1=numerictype(resultType);
            else
                dt1=obj.CustomOutputDataType;
            end

            dt2=pixelcontrolbustype;
        end

        function[sz1,sz2]=isOutputFixedSizeImpl(obj)
            sz1=propagatedInputFixedSize(obj,1);
            sz2=propagatedInputFixedSize(obj,2);
        end

        function[sz,dt,cp]=getDiscreteStateSpecificationImpl(obj,~)
            dt=propagatedInputDataType(obj,1);
            cp=propagatedInputComplexity(obj,1);
            sz=size(zeros(5));


            if(ischar(dt)||(isstring(dt)&&isscalar(dt)))&&(strcmp(dt,'double')||strcmp(dt,'single'))
                dt=dt;%#ok  % do nothing
            elseif strcmp(obj.CoefficientsDataType,'Same as first input')
                dt=dt;%#ok
            else
                dt=obj.CustomCoefficientsDataType;
            end
        end

        function nt=int2fitype(~,dt)
            if(ischar(dt)||(isstring(dt)&&isscalar(dt)))&&strcmp(dt,'uint8')
                nt=numerictype(0,8,0);
            elseif(ischar(dt)||(isstring(dt)&&isscalar(dt)))&&strcmp(dt,'int8')
                nt=numerictype(1,8,0);
            elseif(ischar(dt)||(isstring(dt)&&isscalar(dt)))&&strcmp(dt,'uint16')
                nt=numerictype(0,16,0);
            elseif(ischar(dt)||(isstring(dt)&&isscalar(dt)))&&strcmp(dt,'int16')
                nt=numerictype(1,16,0);
            elseif(ischar(dt)||(isstring(dt)&&isscalar(dt)))&&strcmp(dt,'uint32')
                nt=numerictype(0,32,0);
            elseif(ischar(dt)||(isstring(dt)&&isscalar(dt)))&&strcmp(dt,'int32')
                nt=numerictype(1,32,0);
            elseif(ischar(dt)||(isstring(dt)&&isscalar(dt)))&&strcmp(dt,'uint64')
                nt=numerictype(0,64,0);
            elseif(ischar(dt)||(isstring(dt)&&isscalar(dt)))&&strcmp(dt,'int64')
                nt=numerictype(1,64,0);
            else
                nt=dt;
            end
        end
    end

    methods(Access=protected)
        function KernelDelay=kernellatency(obj)




            KernelDelay=5;
            KernelDelay=KernelDelay+1;
            KernelDelay=KernelDelay+1;
            KernelDelay=KernelDelay+2;
            KernelDelay=KernelDelay+2;
            KernelDelay=KernelDelay+ceil(log2(obj.NSize*obj.NSize))+1;
            KernelDelay=KernelDelay+2;
            KernelDelay=KernelDelay+2;
            KernelDelay=KernelDelay+2;
        end
    end

    methods(Access=private)
        function singlePixelFilter(obj,dataVector,~,ctrlInLB)
            hStartOut=ctrlInLB(1);
            hEndOut=ctrlInLB(2);
            vStartOut=ctrlInLB(3);
            vEndOut=ctrlInLB(4);
            validOut=ctrlInLB(5);
            processDataOut=ctrlInLB(6);

            if processDataOut
                obj.DelayLine(:,:)=[flipud(dataVector),obj.DelayLine(:,1:end-1)];
            end


            if(strcmpi(obj.PaddingMethod,'None')&&obj.PaddingNoneValid)
                padNoneKernel=cast(ones(obj.KernelMemoryKernelHeight,obj.KernelMemoryKernelWidth),'like',obj.DelayLine);
                padNoneKernel(:,1)=flipud(dataVector);
                padNoneKernel(:,2:end)=obj.DelayLine(:,1:end-1);

                if obj.DoubleSingle
                    obj.DataDelay(:)=[BilateralCoreDoubleSingle(obj,padNoneKernel),obj.DataDelay(1:end-1)];
                else
                    obj.DataDelay(:)=[BilateralCore(obj,padNoneKernel),obj.DataDelay(1:end-1)];
                end

            else
                if obj.DoubleSingle
                    obj.DataDelay(:)=[BilateralCoreDoubleSingle(obj,obj.DelayLine),obj.DataDelay(1:end-1)];
                else
                    obj.DataDelay(:)=[BilateralCore(obj,obj.DelayLine(:)),obj.DataDelay(1:end-1)];
                end
            end

            if strcmpi(obj.PaddingMethod,'None')

                obj.CtrlDelay(:,2:end)=obj.CtrlDelay(:,1:end-1);
                if processDataOut||obj.PaddingNoneValid
                    obj.CtrlDelay(1,1)=obj.CtrlKernelDelay(1,end);
                    obj.CtrlDelay(2,1)=obj.CtrlKernelDelay(2,end);
                    obj.CtrlDelay(3,1)=obj.CtrlKernelDelay(3,end);
                    obj.CtrlDelay(4,1)=obj.CtrlKernelDelay(4,end);
                    obj.CtrlDelay(5,1)=obj.CtrlKernelDelay(5,end)||obj.PaddingNoneValid;
                else
                    obj.CtrlDelay(1,1)=false;
                    obj.CtrlDelay(2,1)=false;
                    obj.CtrlDelay(3,1)=false;
                    obj.CtrlDelay(4,1)=false;
                    obj.CtrlDelay(5,1)=false;
                end

                if hEndOut
                    obj.PaddingNoneValid=true;
                    obj.CtrlKernelDelay(5,1:end)=false;
                elseif obj.CtrlKernelDelay(2,end)
                    obj.PaddingNoneValid=false;
                    obj.CtrlKernelDelay(5,1:end)=false;
                end

                if processDataOut
                    obj.CtrlKernelDelay(1,2:end)=obj.CtrlKernelDelay(1,1:end-1);
                    obj.CtrlKernelDelay(3,2:end)=obj.CtrlKernelDelay(3,1:end-1);
                    obj.CtrlKernelDelay(5,2:end)=obj.CtrlKernelDelay(5,1:end-1);
                    obj.CtrlKernelDelay(1,1)=hStartOut;
                    obj.CtrlKernelDelay(3,1)=vStartOut;
                    obj.CtrlKernelDelay(5,1)=validOut;

                end
                obj.CtrlKernelDelay(2,2:end)=obj.CtrlKernelDelay(2,1:end-1);
                obj.CtrlKernelDelay(4,2:end)=obj.CtrlKernelDelay(4,1:end-1);

                obj.CtrlKernelDelay(2,1)=hEndOut;
                obj.CtrlKernelDelay(4,1)=vEndOut;

            else




                if processDataOut
                    obj.CtrlDelay(:)=[obj.CtrlKernelDelay(:,end),obj.CtrlDelay(:,1:end-1)];
                    obj.CtrlKernelDelay(:)=[[hStartOut;hEndOut;vStartOut;vEndOut;validOut],obj.CtrlKernelDelay(:,1:end-1)];
                else
                    obj.CtrlDelay(:)=[false(5,1),obj.CtrlDelay(:,1:end-1)];
                end
            end

        end

        function multiPixelFilter(obj,dataVector,~,ctrlInLB)
            hStartOut=ctrlInLB(1);
            hEndOut=ctrlInLB(2);
            vStartOut=ctrlInLB(3);
            vEndOut=ctrlInLB(4);
            validOut=ctrlInLB(5);
            processDataOut=ctrlInLB(6);

            halfWidth=(floor(obj.KernelMemoryKernelWidth/2))-((ceil((floor(obj.KernelMemoryKernelWidth/2))/obj.NumberOfPixels)-1)*obj.NumberOfPixels);



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

            evenKernelUp=(mod(obj.KernelMemoryKernelWidth,2)==0)&&obj.KernelMemoryBiasUp;

            for kk=1:1:obj.NumberOfPixels

                if obj.DoubleSingle
                    obj.MultiPixelFilterKernel(:,:,kk)=obj.MultiPixelWindow(:,kk+evenKernelUp:obj.KernelMemoryKernelWidth+(kk-1+evenKernelUp));
                    obj.DataDelay(kk,2:end)=obj.DataDelay(kk,1:end-1);
                    obj.DataDelay(kk,1)=BilateralCoreDoubleSingle(obj,fliplr(flipud(obj.MultiPixelFilterKernel(:,:,kk))));%#ok<FLUDLR> % #ok
                else
                    obj.MultiPixelFilterKernel(:,:,kk)=obj.MultiPixelWindow(:,kk+evenKernelUp:obj.KernelMemoryKernelWidth+(kk-1+evenKernelUp));
                    obj.DataDelay(kk,2:end)=obj.DataDelay(kk,1:end-1);
                    obj.DataDelay(kk,1)=BilateralCore(obj,fliplr(flipud(obj.MultiPixelFilterKernel(:,:,kk))));%#ok<FLUDLR> % #ok
                end
            end

            if strcmpi(obj.PaddingMethod,'None')

                obj.CtrlDelay(:,2:end)=obj.CtrlDelay(:,1:end-1);
                if processDataOut||obj.PaddingNoneValid
                    obj.CtrlDelay(1,1)=obj.CtrlKernelDelay(1,end);
                    obj.CtrlDelay(2,1)=obj.CtrlKernelDelay(2,end);
                    obj.CtrlDelay(3,1)=obj.CtrlKernelDelay(3,end);
                    obj.CtrlDelay(4,1)=obj.CtrlKernelDelay(4,end);
                    obj.CtrlDelay(5,1)=obj.CtrlKernelDelay(5,end)||obj.PaddingNoneValid;
                else
                    obj.CtrlDelay(1,1)=false;
                    obj.CtrlDelay(2,1)=false;
                    obj.CtrlDelay(3,1)=false;
                    obj.CtrlDelay(4,1)=false;
                    obj.CtrlDelay(5,1)=false;
                end

                if hEndOut
                    obj.PaddingNoneValid=true;
                    obj.CtrlKernelDelay(5,1:end)=false;
                elseif obj.CtrlKernelDelay(2,end)==true
                    obj.PaddingNoneValid=false;
                    obj.CtrlKernelDelay(5,1:end)=false;
                end

                if processDataOut
                    obj.CtrlKernelDelay(1,2:end)=obj.CtrlKernelDelay(1,1:end-1);
                    obj.CtrlKernelDelay(3,2:end)=obj.CtrlKernelDelay(3,1:end-1);
                    obj.CtrlKernelDelay(5,2:end)=obj.CtrlKernelDelay(5,1:end-1);
                    obj.CtrlKernelDelay(1,1)=hStartOut;
                    obj.CtrlKernelDelay(3,1)=vStartOut;
                    obj.CtrlKernelDelay(5,1)=validOut;

                end
                obj.CtrlKernelDelay(2,2:end)=obj.CtrlKernelDelay(2,1:end-1);
                obj.CtrlKernelDelay(4,2:end)=obj.CtrlKernelDelay(4,1:end-1);

                obj.CtrlKernelDelay(2,1)=hEndOut;
                obj.CtrlKernelDelay(4,1)=vEndOut;

            else

                if processDataOut
                    obj.CtrlDelay(:)=[obj.CtrlKernelDelay(:,end),obj.CtrlDelay(:,1:end-1)];
                    obj.CtrlKernelDelay(:)=[[hStartOut;hEndOut;vStartOut;vEndOut;validOut],obj.CtrlKernelDelay(:,1:end-1)];
                else
                    obj.CtrlDelay(:)=[false(5,1),obj.CtrlDelay(:,1:end-1)];
                end
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

