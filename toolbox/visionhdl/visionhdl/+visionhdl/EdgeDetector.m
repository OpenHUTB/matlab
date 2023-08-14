classdef(StrictDefaults)EdgeDetector<visionhdl.internal.abstractLineMemoryKernel










































































































%#codegen
%#ok<*EMCLS>


    properties(Nontunable)



        Method='Sobel';







        BinaryImageOutputPort(1,1)logical=true;












        GradientComponentOutputPorts(1,1)logical=false;





        ThresholdSource='Property';





        Threshold=20;





        LineBufferSize=2048;




        RoundingMethod='Floor';




        OverflowAction='Wrap';




        GradientDataType='Full precision';





        CustomGradientDataType=numerictype(1,8,0);





        PaddingMethod='Symmetric';


    end

    properties(Constant,Hidden)
        MethodSet=matlab.system.StringSet({...
        'Sobel',...
        'Prewitt',...
        'Roberts'});

        ThresholdSourceSet=matlab.system.StringSet({...
        'Property',...
        'Input port'});

        RoundingMethodSet=matlab.system.internal.RoundingMethodSet({...
        'Ceiling',...
        'Convergent',...
        'Floor',...
        'Nearest',...
        'Round',...
        'Zero'});

        OverflowActionSet=matlab.system.internal.OverflowActionSet;

        GradientDataTypeSet=matlab.system.internal.DataTypeSet(...
        {'Same as first input','Full precision','Custom',matlab.system.internal.CustomDataType('Signedness',{'Signed','Unsigned'})},...
        'Compatibility','Legacy',...
        'HasDesignMinimum',true,...
        'HasDesignMaximum',true);

        PaddingMethodSet=matlab.system.StringSet({...
        'Symmetric',...
        'None'});
    end

    properties(Nontunable,Access=private)
        Coeff1;
        Coeff2;
        CoreHandle;
        ThresholdSq;
    end

    properties(Access=private)
        ThresholdInputSq;
        POCI;
        pFimath;
        gradientFP;
        EdgeDelay;
        GradientDelay;
        GradientDelayFM;
        CtrlDelay;
        CtrlKernelDelay;
        DelayLine;
        MultiPixelWindow;
        MultiPixelFilterKernel;
        PaddingNoneValid;

    end

    properties(Access=private,Nontunable)
        filterHandle;
        NumberOfPixels;
    end

    methods
        function obj=EdgeDetector(varargin)
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
            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'EdgeDetector','Line buffer size');
            obj.LineBufferSize=val;
        end


        function set.Threshold(obj,val)
            validateattributes(val,{'numeric'},{'real','scalar','finite'},'EdgeDetector','Threshold');
            obj.Threshold=val;
        end


        function set.CustomGradientDataType(obj,val)
            validateCustomDataType(obj,'CustomGradientDataType',val,{'Property','GradientDataTypeSet'});
            obj.CustomGradientDataType=val;
        end
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl

            header=matlab.system.display.Header('visionhdl.EdgeDetector',...
            'ShowSourceLink',false,...
            'Title','Edge Detector');
        end
    end

    methods(Access=protected)
        function num=getNumInputsImpl(obj)
            if strcmp(obj.ThresholdSource,'Input port')&&...
                obj.BinaryImageOutputPort
                num=3;
            else
                num=2;
            end
        end


        function num=getNumOutputsImpl(obj)
            coder.internal.errorIf(~(obj.BinaryImageOutputPort|obj.GradientComponentOutputPorts),...
            'visionhdl:EdgeDetector:NoOutputsSpecified');

            if obj.BinaryImageOutputPort&&obj.GradientComponentOutputPorts
                num=4;
            elseif~obj.BinaryImageOutputPort&&obj.GradientComponentOutputPorts
                num=3;
            elseif obj.BinaryImageOutputPort&&~obj.GradientComponentOutputPorts
                num=2;
            end
        end


        function icon=getIconImpl(obj)
            icon=sprintf('%s',obj.Method);
        end


        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='pixel';
            varargout{2}='ctrl';
            if strcmp(obj.ThresholdSource,'Input port')
                varargout{3}='Th';
            end
        end


        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            if obj.BinaryImageOutputPort&&obj.GradientComponentOutputPorts
                varargout{1}='Edge';
                if strcmp(obj.Method,'Roberts')
                    varargout{2}='G45';
                    varargout{3}='G135';
                else
                    varargout{2}='Gv';
                    varargout{3}='Gh';
                end
                IX=4;
            elseif~obj.BinaryImageOutputPort&&obj.GradientComponentOutputPorts
                if strcmp(obj.Method,'Roberts')
                    varargout{1}='G45';
                    varargout{2}='G135';
                else
                    varargout{1}='Gv';
                    varargout{2}='Gh';
                end
                IX=3;
            elseif obj.BinaryImageOutputPort&&~obj.GradientComponentOutputPorts
                varargout{1}='Edge';
                IX=2;
            end
            varargout{IX}='ctrl';
        end


        function varargout=getOutputSizeImpl(obj)
            if obj.BinaryImageOutputPort&&obj.GradientComponentOutputPorts
                varargout{1}=propagatedInputSize(obj,1);
                varargout{2}=propagatedInputSize(obj,1);
                varargout{3}=propagatedInputSize(obj,1);
                varargout{4}=propagatedInputSize(obj,2);
            elseif obj.BinaryImageOutputPort&&~obj.GradientComponentOutputPorts
                varargout{1}=propagatedInputSize(obj,1);
                varargout{2}=propagatedInputSize(obj,2);

            elseif~obj.BinaryImageOutputPort&&obj.GradientComponentOutputPorts
                varargout{1}=propagatedInputSize(obj,1);
                varargout{2}=propagatedInputSize(obj,1);
                varargout{3}=propagatedInputSize(obj,2);
            end
        end


        function varargout=isOutputComplexImpl(obj)
            for ii=1:obj.getNumOutputsImpl
                varargout{ii}=propagatedInputComplexity(obj,1);
            end
        end


        function varargout=getOutputDataTypeImpl(obj)
            if obj.GradientComponentOutputPorts
                dataInDT=propagatedInputDataType(obj,1);
                if isempty(dataInDT)
                    gradDT=[];
                elseif(~isa(dataInDT,'embedded.numerictype'))&&...
                    (strcmp(dataInDT,'double')||strcmp(dataInDT,'single'))
                    gradDT=dataInDT;
                else
                    switch(obj.GradientDataType)
                    case 'Same as first input'
                        gradDT=dataInDT;
                    case 'Custom'
                        gradDT=obj.CustomGradientDataType;
                    otherwise
                        if isa(dataInDT,'embedded.numerictype')
                            T=dataInDT;
                        else
                            if strcmp(dataInDT,'uint8'),T=numerictype('Signed',0,'WordLength',8,'FractionLength',0);
                            elseif strcmp(dataInDT,'int8'),T=numerictype('Signed',1,'WordLength',8,'FractionLength',0);
                            elseif strcmp(dataInDT,'uint16'),T=numerictype('Signed',0,'WordLength',16,'FractionLength',0);
                            elseif strcmp(dataInDT,'int16'),T=numerictype('Signed',1,'WordLength',16,'FractionLength',0);
                            elseif strcmp(dataInDT,'uint32'),T=numerictype('Signed',0,'WordLength',32,'FractionLength',0);
                            elseif strcmp(dataInDT,'int32'),T=numerictype('Signed',1,'WordLength',32,'FractionLength',0);
                            elseif strcmp(dataInDT,'uint64'),T=numerictype('Signed',0,'WordLength',64,'FractionLength',0);
                            elseif strcmp(dataInDT,'int64'),T=numerictype('Signed',1,'WordLength',64,'FractionLength',0);
                            end
                        end


                        switch obj.Method
                        case 'Sobel'
                            ExtraBitsWord=3;
                            ExtraBitsFrac=3;
                        case 'Prewitt'
                            ExtraBitsWord=19;
                            ExtraBitsFrac=18;
                        otherwise
                            ExtraBitsWord=1;
                            ExtraBitsFrac=1;
                        end
                        gradDT=numerictype('Signed',1,...
                        'WordLength',T.WordLength+ExtraBitsWord,...
                        'FractionLength',T.FractionLength+ExtraBitsFrac);
                    end
                end
            end

            if obj.BinaryImageOutputPort&&obj.GradientComponentOutputPorts
                varargout{1}='logical';
                varargout{2}=gradDT;
                varargout{3}=gradDT;
                varargout{4}=pixelcontrolbustype;
            elseif~obj.BinaryImageOutputPort&&obj.GradientComponentOutputPorts
                varargout{1}=gradDT;
                varargout{2}=gradDT;
                varargout{3}=pixelcontrolbustype;
            elseif obj.BinaryImageOutputPort&&~obj.GradientComponentOutputPorts
                varargout{1}='logical';
                varargout{2}=pixelcontrolbustype;
            end
        end


        function varargout=isOutputFixedSizeImpl(obj)

            if obj.BinaryImageOutputPort&&obj.GradientComponentOutputPorts
                varargout{1}=propagatedInputFixedSize(obj,1);
                varargout{2}=propagatedInputFixedSize(obj,1);
                varargout{3}=propagatedInputFixedSize(obj,1);
                varargout{4}=propagatedInputFixedSize(obj,2);
            elseif obj.BinaryImageOutputPort&&~obj.GradientComponentOutputPorts
                varargout{1}=propagatedInputFixedSize(obj,1);
                varargout{2}=propagatedInputFixedSize(obj,2);

            elseif~obj.BinaryImageOutputPort&&obj.GradientComponentOutputPorts
                varargout{1}=propagatedInputFixedSize(obj,1);
                varargout{2}=propagatedInputFixedSize(obj,1);
                varargout{3}=propagatedInputFixedSize(obj,2);
            end
        end


        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case{'ThresholdSource'}
                if~obj.BinaryImageOutputPort
                    flag=true;
                end
            case{'Threshold'}
                if~obj.BinaryImageOutputPort||...
                    ~strcmp(obj.ThresholdSource,'Property')
                    flag=true;
                end
            case{'CustomCoefficientsDataType'}
                if~strcmp(obj.CoefficientsDataType,'Custom')
                    flag=true;
                end
            case{'GradientDataType'}
                if~obj.GradientComponentOutputPorts
                    flag=true;
                end
            case{'CustomGradientDataType'}
                if~strcmp(obj.GradientDataType,'Custom')
                    flag=true;
                end
            end
        end


        function validateInputsImpl(obj,varargin)

            pixelIn=varargin{1};
            ctrlIn=varargin{2};

            if isempty(coder.target)||~eml_ambiguous_types



                validateattributes(pixelIn,{'numeric','embedded.fi'},...
                {'real','nonnan','finite'},'EdgeDetector','pixel input');

                if~ismember(size(pixelIn,1),[1,4,8])
                    coder.internal.error('visionhdl:EdgeDetector:InputDimensions');
                end

                if~ismember(size(pixelIn,2),[1])%#ok<NBRAK2>
                    coder.internal.error('visionhdl:EdgeDetector:InputDimensions');
                end

                validatecontrolsignals(ctrlIn);

                if obj.getNumInputsImpl==3
                    thresholdIn=varargin{3};
                    validateattributes(thresholdIn,{'numeric','embedded.fi'},...
                    {'scalar','real','nonnan','finite'},'EdgeDetector','Threshold');
                end

                coder.internal.errorIf(~(obj.BinaryImageOutputPort|obj.GradientComponentOutputPorts),...
                'visionhdl:EdgeDetector:NoOutputsSpecified');
            end

        end


        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);
            s=saveObjectKernelMemory(obj,s);

            if obj.isLocked
                s.POCI=obj.POCI;
                s.pFimath=obj.pFimath;
                s.gradientFP=obj.gradientFP;
                s.CtrlDelay=obj.CtrlDelay;
                s.CtrlKernelDelay=obj.CtrlKernelDelay;
                s.Coeff1=obj.Coeff1;
                s.Coeff2=obj.Coeff2;
                s.CoreHandle=obj.CoreHandle;
                s.ThresholdSq=obj.ThresholdSq;
                s.ThresholdInputSq=obj.ThresholdInputSq;
                s.EdgeDelay=obj.EdgeDelay;
                s.GradientDelay=obj.GradientDelay;
                s.GradientDelayFM=obj.GradientDelayFM;
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


        function setupImpl(obj,varargin)

            dataIn=varargin{1};





            obj.pFimath=fimath('RoundingMethod',obj.RoundingMethod,...
            'OverflowAction',obj.OverflowAction);

            if isfi(dataIn)
                dataInFimath=fimath('RoundingMethod',dataIn.RoundingMethod,...
                'OverflowAction',dataIn.OverflowAction);
            end

            switch obj.Method
            case 'Sobel'
                obj.KernelMemoryKernelHeight=3;
                ExtraBitsWord=3;
                ExtraBitsFrac=3;

                if isfloat(dataIn)
                    obj.Coeff1=0;
                    obj.Coeff2=0;
                    obj.CoreHandle=@SobelCoreFloatingPoint;
                else
                    Coeff1Temp=[1,0,-1;2,0,-2;1,0,-1]/8;
                    Coeff2Temp=Coeff1Temp.';
                    if isinteger(dataIn)
                        obj.Coeff1=fi(fliplr(Coeff1Temp),1,3,ExtraBitsFrac,obj.pFimath);
                        obj.Coeff2=fi(fliplr(Coeff2Temp),1,3,ExtraBitsFrac,obj.pFimath);
                    else
                        obj.Coeff1=fi(fliplr(Coeff1Temp),1,3,ExtraBitsFrac,dataInFimath);
                        obj.Coeff2=fi(fliplr(Coeff2Temp),1,3,ExtraBitsFrac,dataInFimath);
                    end
                    obj.CoreHandle=@SobelCoreFixedPoint;
                end
            case 'Prewitt'
                obj.KernelMemoryKernelHeight=3;
                ExtraBitsWord=19;
                ExtraBitsFrac=18;

                if isfloat(dataIn)
                    obj.Coeff1=0;
                    obj.Coeff2=0;
                    obj.CoreHandle=@PrewittCoreFloatingPoint;
                else
                    if isinteger(dataIn)
                        obj.Coeff1=fi(1/6,0,16,ExtraBitsFrac,obj.pFimath);
                    else
                        obj.Coeff1=fi(1/6,0,16,ExtraBitsFrac,dataInFimath);
                    end
                    obj.Coeff2=0;
                    obj.CoreHandle=@PrewittCoreFixedPoint;
                end
            otherwise
                obj.KernelMemoryKernelHeight=2;
                ExtraBitsWord=1;
                ExtraBitsFrac=1;

                if isfloat(dataIn)
                    obj.Coeff1=0;
                    obj.Coeff2=0;
                    obj.CoreHandle=@RobertsCoreFloatingPoint;
                else
                    Coeff1Temp=[1,0;0,-1]/2;
                    Coeff2Temp=[0,1;-1,0]/2;
                    if isinteger(dataIn)
                        obj.Coeff1=fi(fliplr(Coeff1Temp),1,2,ExtraBitsFrac,obj.pFimath);
                        obj.Coeff2=fi(fliplr(Coeff2Temp),1,2,ExtraBitsFrac,obj.pFimath);
                    else
                        obj.Coeff1=fi(fliplr(Coeff1Temp),1,2,ExtraBitsFrac,dataInFimath);
                        obj.Coeff2=fi(fliplr(Coeff2Temp),1,2,ExtraBitsFrac,dataInFimath);
                    end
                    obj.CoreHandle=@RobertsCoreFixedPoint;
                end
            end
            obj.KernelMemoryKernelWidth=obj.KernelMemoryKernelHeight;
            obj.KernelMemoryMaxLineSize=obj.LineBufferSize;
            obj.KernelMemoryBiasUp=true;
            obj.KernelMemoryPaddingMethod=obj.PaddingMethod;
            setupKernelMemory(obj,dataIn,true,true,true,true,true);

            obj.NumberOfPixels=length(dataIn);

            obj.POCI=cast(zeros(obj.KernelMemoryKernelHeight^2,obj.NumberOfPixels),'like',dataIn);

            if obj.NumberOfPixels==1
                obj.filterHandle=@singlePixelFilter;
            else
                obj.filterHandle=@multiPixelFilter;
            end

            if obj.NumberOfPixels>1
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


            if isfloat(dataIn)
                obj.gradientFP=cast([0;0],'like',dataIn);
            else
                if isa(dataIn,'uint8'),T=numerictype('Signed',0,'WordLength',8,'FractionLength',0);
                elseif isa(dataIn,'int8'),T=numerictype('Signed',1,'WordLength',8,'FractionLength',0);
                elseif isa(dataIn,'uint16'),T=numerictype('Signed',0,'WordLength',16,'FractionLength',0);
                elseif isa(dataIn,'int16'),T=numerictype('Signed',1,'WordLength',16,'FractionLength',0);
                elseif isa(dataIn,'uint32'),T=numerictype('Signed',0,'WordLength',32,'FractionLength',0);
                elseif isa(dataIn,'int32'),T=numerictype('Signed',1,'WordLength',32,'FractionLength',0);
                elseif isa(dataIn,'uint64'),T=numerictype('Signed',0,'WordLength',64,'FractionLength',0);
                elseif isa(dataIn,'int64'),T=numerictype('Signed',1,'WordLength',64,'FractionLength',0);
                else
                    T=numerictype('Signed',issigned(dataIn),...
                    'WordLength',dataIn.WordLength,...
                    'FractionLength',dataIn.FractionLength);
                end
                obj.gradientFP=fi([0;0],...
                1,...
                T.WordLength+ExtraBitsWord,...
                T.FractionLength+ExtraBitsFrac,...
                obj.pFimath);
            end



            switch obj.Method
            case 'Sobel'
                if obj.BinaryImageOutputPort
                    numDelay=12-1;
                else
                    numDelay=6-1;
                end
            case 'Prewitt'
                if obj.BinaryImageOutputPort
                    numDelay=16-1;
                else
                    numDelay=10-1;
                end
            case 'Roberts'
                if obj.BinaryImageOutputPort
                    numDelay=10-1;
                else
                    numDelay=4-1;
                end
            end

            obj.EdgeDelay=false(obj.NumberOfPixels,numDelay);
            if obj.GradientComponentOutputPorts
                if isfloat(dataIn)
                    obj.GradientDelayFM=cast([0;0],'like',dataIn);
                    obj.GradientDelay=cast(zeros(obj.NumberOfPixels,2,numDelay),'like',dataIn);
                else
                    switch(obj.GradientDataType)
                    case 'Same as first input'
                        obj.GradientDelayFM=fi([0;0],T,obj.pFimath);
                        obj.GradientDelay=cast(zeros(obj.NumberOfPixels,2,numDelay),'like',dataIn);
                    case 'Custom'
                        obj.GradientDelayFM=fi([0;0],obj.CustomGradientDataType,obj.pFimath);
                        obj.GradientDelay=fi(zeros(obj.NumberOfPixels,2,numDelay),obj.CustomGradientDataType);
                    otherwise
                        obj.GradientDelayFM=obj.gradientFP;
                        obj.GradientDelay=cast(zeros(obj.NumberOfPixels,2,numDelay),'like',obj.gradientFP);
                    end
                end
            else
                obj.GradientDelayFM=obj.gradientFP;
                obj.GradientDelay=cast(zeros(obj.NumberOfPixels,2,numDelay),'like',obj.gradientFP);
            end

            obj.CtrlDelay=false(5,numDelay);

            if obj.NumberOfPixels==1
                obj.CtrlKernelDelay=false(5,1);
            else
                obj.CtrlKernelDelay=false(5,floor(numMatrices/2));
            end


            if obj.BinaryImageOutputPort
                if obj.GradientComponentOutputPorts



                    thresholdD=sum(obj.GradientDelay(:,1).*obj.GradientDelay(:,1),1,'native');
                else



                    thresholdD=sum(obj.gradientFP.*obj.gradientFP,1,'native');
                end

                if isfi(thresholdD)
                    thresholdDBK=fi(0,...
                    issigned(thresholdD),...
                    (thresholdD.WordLength)*2,...
                    (thresholdD.FractionLength),...
                    'RoundingMethod',obj.RoundingMethod,...
                    'OverflowAction','Saturate');
                else
                    thresholdDBK=thresholdD;
                end

                if obj.getNumInputsImpl==3
                    obj.ThresholdInputSq=cast(0,'like',thresholdDBK);
                    obj.ThresholdSq=0;
                else
                    obj.ThresholdInputSq=0;

                    obj.ThresholdSq=cast((obj.Threshold)*(obj.Threshold),'like',thresholdDBK);
                    if~isfloat(thresholdDBK)
                        if isfi(thresholdDBK)

                            if double(realmax(thresholdDBK))<double((obj.Threshold)*(obj.Threshold))
                                assert(realmax(thresholdDBK)==obj.ThresholdSq);
                                coder.internal.warning('visionhdl:EdgeDetector:ThresholdOverflow');
                            elseif(abs(double(obj.ThresholdSq)-double((obj.Threshold)*(obj.Threshold)))>0)&&...
                                (abs(double(obj.ThresholdSq)-double((obj.Threshold)*(obj.Threshold)))<eps(thresholdDBK))
                                coder.internal.warning('visionhdl:EdgeDetector:ThresholdPrecision');
                            end
                        else
                            if double(intmax(class(thresholdDBK)))<double((obj.Threshold)*(obj.Threshold))
                                assert(intmax(class(thresholdDBK))==obj.ThresholdSq);
                                coder.internal.warning('visionhdl:EdgeDetector:ThresholdOverflow');
                            elseif(abs(double(obj.ThresholdSq)-double((obj.Threshold)*(obj.Threshold)))>0)&&...
                                (abs(double(obj.ThresholdSq)-double((obj.Threshold)*(obj.Threshold)))<1)
                                coder.internal.warning('visionhdl:EdgeDetector:ThresholdPrecision');
                            end
                        end
                    end
                end
            else
                obj.ThresholdSq=0;
                obj.ThresholdInputSq=0;
            end

            obj.PaddingNoneValid=false;

        end


        function resetImpl(obj)
            obj.EdgeDelay(:)=0;
            obj.GradientDelay(:)=0;
            obj.CtrlDelay(:)=false;
            obj.CtrlKernelDelay(:)=false;
            obj.POCI(:)=0;
        end


        function varargout=outputImpl(obj,varargin)


            if obj.CtrlDelay(5,end)
                if obj.getNumOutputs==4
                    varargout{1}=obj.EdgeDelay(:,end);
                    varargout{2}=obj.GradientDelay(:,1,end);
                    varargout{3}=obj.GradientDelay(:,2,end);
                elseif obj.getNumOutputs==3
                    varargout{1}=obj.GradientDelay(:,1,end);
                    varargout{2}=obj.GradientDelay(:,2,end);
                elseif obj.getNumOutputs==2
                    varargout{1}=obj.EdgeDelay(:,end);
                end

                varargout{obj.getNumOutputs}.hStart=obj.CtrlDelay(1,end);
                varargout{obj.getNumOutputs}.hEnd=obj.CtrlDelay(2,end);
                varargout{obj.getNumOutputs}.vStart=obj.CtrlDelay(3,end);
                varargout{obj.getNumOutputs}.vEnd=obj.CtrlDelay(4,end);
                varargout{obj.getNumOutputs}.valid=obj.CtrlDelay(5,end);
            else
                if obj.getNumOutputs==4
                    varargout{1}=cast(zeros(obj.NumberOfPixels,1),'like',obj.EdgeDelay);
                    varargout{2}=cast(zeros(obj.NumberOfPixels,1),'like',obj.GradientDelay);
                    varargout{3}=cast(zeros(obj.NumberOfPixels,1),'like',obj.GradientDelay);
                elseif obj.getNumOutputs==3
                    varargout{1}=cast(zeros(obj.NumberOfPixels,1),'like',obj.GradientDelay);
                    varargout{2}=cast(zeros(obj.NumberOfPixels,1),'like',obj.GradientDelay);
                elseif obj.getNumOutputs==2
                    varargout{1}=cast(zeros(obj.NumberOfPixels,1),'like',obj.EdgeDelay);
                end

                varargout{obj.getNumOutputs}=pixelcontrolstruct(0,0,0,0,0);
            end
        end


        function updateImpl(obj,varargin)


            if(varargin{2}.vStart)&&(varargin{2}.hStart)&&(obj.getNumInputsImpl==3)


                obj.ThresholdInputSq(:)=double(varargin{3})*double(varargin{3});
                if~isfloat(obj.ThresholdInputSq)
                    if isfi(obj.ThresholdInputSq)

                        if double(realmax(obj.ThresholdInputSq))<double(varargin{3}*varargin{3})
                            assert(realmax(obj.ThresholdInputSq)==obj.ThresholdInputSq);
                            coder.internal.warning('visionhdl:EdgeDetector:ThresholdOverflow');
                        elseif(abs(double(obj.ThresholdInputSq)-double(varargin{3}*varargin{3}))>0)&&...
                            (abs(double(obj.ThresholdInputSq)-double(varargin{3}*varargin{3}))<double(eps(obj.ThresholdInputSq)))
                            coder.internal.warning('visionhdl:EdgeDetector:ThresholdPrecision');
                        end
                    else

                        if double(intmax(class(obj.ThresholdInputSq)))<double(varargin{3}*varargin{3})
                            assert(intmax(class(obj.ThresholdInputSq))==obj.ThresholdInputSq);
                            coder.internal.warning('visionhdl:EdgeDetector:ThresholdOverflow');
                        elseif(abs(double(obj.ThresholdInputSq)-double(varargin{3}*varargin{3}))>0)&&...
                            (abs(double(obj.ThresholdInputSq)-double(varargin{3}*varargin{3}))<1)
                            coder.internal.warning('visionhdl:EdgeDetector:ThresholdPrecision');
                        end
                    end
                end
            end

            [dataVector,hStart,hEnd,vStart,vEnd,valid,processData]=...
            stepKernelMemory(obj,varargin{1},varargin{2}.hStart,varargin{2}.hEnd,varargin{2}.vStart,varargin{2}.vEnd,varargin{2}.valid);

            ctrlIn=[hStart,hEnd,vStart,vEnd,valid,processData];


            obj.filterHandle(obj,dataVector,ctrlIn);

        end


        function FIRCore(obj,POCI,kk)
            obj.gradientFP(:)=obj.CoreHandle(obj,POCI);


            obj.GradientDelayFM(:)=obj.gradientFP;

            obj.GradientDelay(kk,:,2:end)=obj.GradientDelay(kk,:,1:end-1);
            obj.GradientDelay(kk,:,1)=obj.GradientDelayFM';



            if obj.BinaryImageOutputPort

                if obj.getNumInputsImpl==3
                    threshold=obj.ThresholdInputSq;
                else
                    threshold=obj.ThresholdSq;
                end


                if~obj.GradientComponentOutputPorts


                    obj.EdgeDelay(kk,:)=[sum(obj.gradientFP.*obj.gradientFP,1,'native')>threshold...
                    ,obj.EdgeDelay(kk,1:end-1)];
                else


                    obj.EdgeDelay(kk,:)=[sum(obj.GradientDelay(kk,:,1)'.*obj.GradientDelay(kk,:,1)',1,'native')>threshold...
                    ,obj.EdgeDelay(kk,1:end-1)];
                end
            end
        end


        function out=SobelCoreFloatingPoint(obj,POCI)%#ok<INUSL>
            out=[-1,-2,-1,0,0,0,1,2,1;1,0,-1,2,0,-2,1,0,-1]*POCI/8;...
        end
        function out=PrewittCoreFloatingPoint(obj,POCI)%#ok<INUSL>
            out=[-1,-1,-1,0,0,0,1,1,1;1,0,-1,1,0,-1,1,0,-1]*POCI/6;
        end
        function out=RobertsCoreFloatingPoint(obj,POCI)%#ok<INUSL>
            out=[0,-1,1,0;1,0,0,-1]*POCI/2;
        end
        function out=SobelCoreFixedPoint(obj,POCI)
            weighted1=POCI.*obj.Coeff1(:);
            weighted_sum1=sum(weighted1,1,'native');
            weighted2=POCI.*obj.Coeff2(:);
            weighted_sum2=sum(weighted2,1,'native');
            out=[weighted_sum1;weighted_sum2];
        end
        function out=PrewittCoreFixedPoint(obj,POCI)

            if~isfloat(POCI)
                inC=fi(POCI,...
                1,...
                obj.gradientFP.WordLength-16-2,...
                obj.gradientFP.FractionLength-18);



            end
            weighted_sum1=(inC(7)+inC(8)+inC(9)-inC(1)-inC(2)-inC(3))*obj.Coeff1;
            weighted_sum2=(inC(1)+inC(4)+inC(7)-inC(3)-inC(6)-inC(9))*obj.Coeff1;
            out=[weighted_sum1;weighted_sum2];
        end
        function out=RobertsCoreFixedPoint(obj,POCI)
            weighted1=POCI.*obj.Coeff1(:);
            weighted_sum1=sum(weighted1,1,'native');
            weighted2=POCI.*obj.Coeff2(:);
            weighted_sum2=sum(weighted2,1,'native');
            out=[weighted_sum1;weighted_sum2];
        end
    end

    methods(Access=private)

        function singlePixelFilter(obj,dataVector,ctrlIn)

            hStart=ctrlIn(1);
            hEnd=ctrlIn(2);
            vStart=ctrlIn(3);
            vEnd=ctrlIn(4);
            valid=ctrlIn(5);
            processData=ctrlIn(6);


            if processData
                if strcmp(obj.Method,'Roberts')
                    obj.POCI=[flipud(dataVector(1:2));obj.POCI(1:2)];
                else
                    obj.POCI=[flipud(dataVector(1:3));obj.POCI(1:6)];
                end
            end

            FIRCore(obj,obj.POCI,1);

            if strcmpi(obj.PaddingMethod,'None')

                obj.CtrlDelay(:,2:end)=obj.CtrlDelay(:,1:end-1);
                if processData||obj.PaddingNoneValid
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

                if hEnd
                    obj.PaddingNoneValid=true;
                    obj.CtrlKernelDelay(5,1:end)=false;
                elseif obj.CtrlKernelDelay(2,end)
                    obj.PaddingNoneValid=false;
                    obj.CtrlKernelDelay(5,1:end)=false;
                end

                if processData
                    obj.CtrlKernelDelay(1,2:end)=obj.CtrlKernelDelay(1,1:end-1);
                    obj.CtrlKernelDelay(3,2:end)=obj.CtrlKernelDelay(3,1:end-1);
                    obj.CtrlKernelDelay(5,2:end)=obj.CtrlKernelDelay(5,1:end-1);
                    obj.CtrlKernelDelay(1,1)=hStart;
                    obj.CtrlKernelDelay(3,1)=vStart;
                    obj.CtrlKernelDelay(5,1)=valid;

                end
                obj.CtrlKernelDelay(2,2:end)=obj.CtrlKernelDelay(2,1:end-1);
                obj.CtrlKernelDelay(4,2:end)=obj.CtrlKernelDelay(4,1:end-1);

                obj.CtrlKernelDelay(2,1)=hEnd;
                obj.CtrlKernelDelay(4,1)=vEnd;

            else
                if processData
                    obj.CtrlDelay=[obj.CtrlKernelDelay,obj.CtrlDelay(:,1:end-1)];
                    obj.CtrlKernelDelay=[hStart;hEnd;vStart;vEnd;valid];
                else
                    obj.CtrlDelay=[false(5,1),obj.CtrlDelay(:,1:end-1)];
                end

            end

        end

        function multiPixelFilter(obj,dataVector,ctrlIn)
            hStartOut=ctrlIn(1);
            hEndOut=ctrlIn(2);
            vStartOut=ctrlIn(3);
            vEndOut=ctrlIn(4);
            validOut=ctrlIn(5);
            processDataOut=ctrlIn(6);

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

                obj.MultiPixelFilterKernel(:,:,kk)=obj.MultiPixelWindow(:,kk+evenKernelUp:obj.KernelMemoryKernelWidth+(kk-1+evenKernelUp));
                POCIMat=rot90(obj.MultiPixelFilterKernel(:,:,kk),2);
                POCISub=POCIMat(:);
                FIRCore(obj,POCISub,kk);
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
    end

    methods(Static,Access=protected)
        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end

        function simMode=getSimulateUsingImpl(platformName)
            simMode=["Code generation","Interpreted execution"];
            if strcmp(platformName,'MATLAB')
                simMode="Code generation";
            end
        end
    end

    methods(Access=protected)
        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end
    end
end
