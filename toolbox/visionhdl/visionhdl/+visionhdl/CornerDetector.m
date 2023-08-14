classdef(StrictDefaults)CornerDetector<visionhdl.internal.abstractLineMemoryKernel

























































































%#codegen
%#ok<*EMCLS>

    properties(Nontunable)



        Method='FAST 5 of 8';
    end

    properties(Nontunable)




        MinContrastSource='Property';






        MinContrast=20;





        ThresholdSource='Property';






        Threshold=2000;





        LineBufferSize=2048;




        PaddingMethod='Symmetric';




        RoundingMethod='Floor';




        OverflowAction='Wrap';




        OutputDataType='Same as first input';





        CustomOutputDataType=numerictype(0,8,0);

    end

    properties(Constant,Hidden)
        MethodSet=matlab.system.StringSet({...
        'FAST 5 of 8',...
        'FAST 7 of 12',...
        'FAST 9 of 16',...
        'Harris'});
        MinContrastSourceSet=matlab.system.StringSet({...
        'Property',...
        'Input port'});
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

        OutputDataTypeSet=matlab.system.internal.DataTypeSet(...
        {'Same as first input','Full precision','Custom',matlab.system.internal.CustomDataType('Signedness',{'Signed','Unsigned'})},...
        'Compatibility','Legacy',...
        'HasDesignMinimum',true,...
        'HasDesignMaximum',true);

        PaddingMethodSet=matlab.system.StringSet({...
        'Replicate',...
        'Symmetric',...
        'Reflection',...
        'None'});

    end

    properties(Nontunable,Access=private)
        CoreHandle;
        pFimath;
    end

    properties(Access=private)
        minCon;
        POCI;
        CornerDelay;
        CtrlDelay;
        CtrlKernelDelay;
        DelayLine;
        InterX2Delay;
        InterY2Delay;
        InterXYDelay;
        InterCtrlDelay;
        MultiPixelWindow;
        MultiPixelFilterKernel;
        AlgFP;
        CenterType;
        CenterSubRingType;
        AbsRingType;
        OutType;
        RoundType;
        PaddingNoneValid;
        EdgeType;
        HarrisMetric;
    end

    properties(Access=private,Nontunable)
        filterHandle;
        updateHandle;
        NumberOfPixels;
        GaussFilterA;
        GaussFilterB;
        GaussFilterC;
    end


    methods
        function obj=CornerDetector(varargin)
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
            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'CornerDetector','Line buffer size');
            obj.LineBufferSize=val;
        end

        function set.MinContrast(obj,val)
            validateattributes(val,{'numeric','embedded.fi'},{'real','scalar','finite','>',0},'CornerDetector','MinContrast');
            obj.MinContrast=val;
        end

        function set.Threshold(obj,val)
            validateattributes(val,{'numeric','embedded.fi'},{'real','scalar','finite','>',0},'CornerDetector','Threshold');
            obj.Threshold=val;
        end

        function set.CustomOutputDataType(obj,val)
            validateCustomDataType(obj,'CustomOutputDataType',val,{'Property','OutputDataTypeSet'});
            obj.CustomOutputDataType=val;
        end

    end

    methods(Static,Access=protected)
        function header=getHeaderImpl

            header=matlab.system.display.Header('visionhdl.CornerDetector',...
            'ShowSourceLink',false,...
            'Title','Corner Detector');
        end
    end

    methods(Access=protected)
        function num=getNumInputsImpl(obj)
            if(strcmp(obj.MinContrastSource,'Input port')&&~strcmp(obj.Method,'Harris'))||...
                (strcmp(obj.ThresholdSource,'Input port')&&strcmp(obj.Method,'Harris'))
                num=3;
            else
                num=2;
            end
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end

        function icon=getIconImpl(obj)
            icon=sprintf('%s',obj.Method);
        end

        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='pixel';
            varargout{2}='ctrl';
            if strcmp(obj.MinContrastSource,'Input port')&&~strcmp(obj.Method,'Harris')
                varargout{3}='minC';
            elseif strcmp(obj.ThresholdSource,'Input port')&&strcmp(obj.Method,'Harris')
                varargout{3}='thresh';
            end
        end

        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='corner';
            varargout{2}='ctrl';
        end

        function varargout=getOutputSizeImpl(obj)
            varargout{1}=propagatedInputSize(obj,1);
            varargout{2}=propagatedInputSize(obj,2);
        end

        function varargout=isOutputComplexImpl(obj)
            for ii=1:obj.getNumOutputsImpl
                varargout{ii}=propagatedInputComplexity(obj,1);
            end
        end

        function varargout=getOutputDataTypeImpl(obj)
            switch obj.Method
            case 'FAST 5 of 8'
                bitGrowth=3;
                isFAST=true;
            case 'FAST 9 of 16'
                bitGrowth=4;
                isFAST=true;
            case 'FAST 7 of 12'
                bitGrowth=4;
                isFAST=true;
            otherwise
                bitGrowth=0;
                isFAST=false;
            end
            intype=propagatedInputDataType(obj,1);
            if isempty(intype)
                dt1=[];
            elseif(ischar(intype)||(isstring(intype)&&isscalar(intype)))&&(strcmp(intype,'double')||strcmp(intype,'single'))
                dt1=intype;
            elseif strcmp(obj.OutputDataType,'Same as first input')
                dt1=intype;
            elseif strcmp(obj.OutputDataType,'Full precision')
                idt=int2fitype(obj,intype);
                if isFAST
                    dt1=numerictype('Signedness',idt.Signedness,...
                    'WordLength',idt.WordLength+2+bitGrowth,...
                    'FractionLength',idt.FractionLength);
                else
                    dt1=numerictype('Signedness','Signed',...
                    'WordLength',(idt.WordLength+2)*4+4+bitGrowth,...
                    'FractionLength',idt.FractionLength*4);
                end
            else
                dt1=obj.CustomOutputDataType;
            end
            varargout{1}=dt1;
            varargout{2}=pixelcontrolbustype;

        end

        function varargout=isOutputFixedSizeImpl(obj)
            varargout{1}=propagatedInputFixedSize(obj,1);
            varargout{2}=propagatedInputFixedSize(obj,2);
        end

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case{'MinContrast'}
                if~strcmp(obj.MinContrastSource,'Property')||strcmp(obj.Method,'Harris')
                    flag=true;
                end
            case{'Threshold'}
                if~strcmp(obj.ThresholdSource,'Property')||~strcmp(obj.Method,'Harris')
                    flag=true;
                end
            case{'ThresholdSource'}
                if~strcmp(obj.Method,'Harris')
                    flag=true;
                end
            case{'MinContrastSource'}
                if strcmp(obj.Method,'Harris')
                    flag=true;
                end
            case{'CustomOutputDataType'}
                if~strcmp(obj.OutputDataType,'Custom')
                    flag=true;
                end
            end
        end

        function validateInputsImpl(obj,varargin)

            pixelIn=varargin{1};
            ctrlIn=varargin{2};

            if isempty(coder.target)||~eml_ambiguous_types



                validateattributes(pixelIn,{'numeric','embedded.fi'},...
                {'scalar','real','nonnan','finite'},'CornerDetector','pixel input');

                validatecontrolsignals(ctrlIn);

                if obj.getNumInputsImpl==3
                    validateattributes(varargin{3},{'numeric','embedded.fi'},...
                    {'scalar','real','nonnan','finite'},'CornerDetector','MinContrast');
                end
            end

        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);
            s=saveObjectKernelMemory(obj,s);

            if obj.isLocked
                s.CoreHandle=obj.CoreHandle;
                s.pFimath=obj.pFimath;
                s.minCon=obj.minCon;
                s.POCI=obj.POCI;
                s.CornerDelay=obj.CornerDelay;
                s.CtrlDelay=obj.CtrlDelay;
                s.CtrlKernelDelay=obj.CtrlKernelDelay;
                s.InterX2Delay=obj.InterX2Delay;
                s.InterY2Delay=obj.InterY2Delay;
                s.InterXYDelay=obj.InterXYDelay;
                s.InterCtrlDelay=obj.InterCtrlDelay;
                s.MultiPixelWindow=obj.MultiPixelWindow;
                s.MultiPixelFilterKernel=obj.MultiPixelFilterKernel;
                s.AlgFP=obj.AlgFP;
                s.CenterType=obj.CenterType;
                s.CenterSubRingType=obj.CenterSubRingType;
                s.AbsRingType=obj.AbsRingType;
                s.OutType=obj.OutType;
                s.RoundType=obj.RoundType;
                s.PaddingNoneValid=obj.PaddingNoneValid;
                s.EdgeType=obj.EdgeType;
                s.HarrisMetric=obj.HarrisMetric;
                s.filterHandle=obj.filterHandle;
                s.updateHandle=obj.updateHandle;
                s.NumberOfPixels=obj.NumberOfPixels;
                s.GaussFilterA=obj.GaussFilterA;
                s.GaussFilterB=obj.GaussFilterB;
                s.GaussFilterC=obj.GaussFilterC;
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

        function setupImpl(obj,varargin)

            dataIn=varargin{1};

            if isfloat(dataIn)
                obj.pFimath=[];
            else
                obj.pFimath=fimath('RoundingMethod',obj.RoundingMethod,...
                'OverflowAction',obj.OverflowAction);
            end

            obj.NumberOfPixels=length(dataIn);

            isFAST=false;%#ok<NASGU>
            switch obj.Method
            case 'FAST 5 of 8'
                isFAST=true;
                obj.updateHandle=@FASTUpdate;
                obj.KernelMemoryKernelHeight=3;
                if isfloat(dataIn)
                    obj.CoreHandle=@FAST5of8DoubleCore;
                else
                    obj.CoreHandle=@FAST5of8Core;
                end
                if obj.NumberOfPixels==1
                    obj.filterHandle=@singlePixelFASTFilter;


                end
                bitGrowth=3;
                numDelay=11;
                delayOffset=0;
            case 'FAST 9 of 16'
                isFAST=true;
                obj.updateHandle=@FASTUpdate;
                obj.KernelMemoryKernelHeight=7;
                if isfloat(dataIn)
                    obj.CoreHandle=@FAST9of16DoubleCore;
                else
                    obj.CoreHandle=@FAST9of16Core;
                end
                if obj.NumberOfPixels==1
                    obj.filterHandle=@singlePixelFASTFilter;


                end
                bitGrowth=4;
                numDelay=11;
                delayOffset=2;
            case 'FAST 7 of 12'
                isFAST=true;
                obj.updateHandle=@FASTUpdate;
                obj.KernelMemoryKernelHeight=5;
                if isfloat(dataIn)
                    obj.CoreHandle=@FAST7of12DoubleCore;
                else
                    obj.CoreHandle=@FAST7of12Core;
                end
                if obj.NumberOfPixels==1
                    obj.filterHandle=@singlePixelFASTFilter;


                end
                bitGrowth=4;
                numDelay=11;
                delayOffset=1;
            otherwise
                isFAST=false;
                bitGrowth=0;
                numDelay=13;
                delayOffset=0;
                obj.updateHandle=@HarrisUpdate;
                obj.KernelMemoryKernelHeight=3;
                if isfloat(dataIn)
                    obj.CoreHandle=@HarrisDoubleCore;
                else
                    obj.CoreHandle=@HarrisCore;
                end
                if obj.NumberOfPixels==1
                    obj.filterHandle=@singlePixelHarrisFilter;


                end
            end

            obj.KernelMemoryKernelWidth=obj.KernelMemoryKernelHeight;
            obj.KernelMemoryMaxLineSize=obj.LineBufferSize;
            obj.KernelMemoryBiasUp=true;
            obj.KernelMemoryPaddingMethod=obj.PaddingMethod;
            setupKernelMemory(obj,dataIn,true,true,true,true,true);

            obj.POCI=cast(zeros(obj.KernelMemoryKernelHeight^2,obj.NumberOfPixels),'like',dataIn);

            if isfloat(dataIn)
                if isFAST
                    obj.AlgFP=cast(0,'like',dataIn);
                else
                    obj.AlgFP=cast([0;0],'like',dataIn);
                end
                obj.OutType=cast(0,'like',dataIn);
                obj.RoundType=cast(0,'like',dataIn);
                obj.EdgeType=cast(0,'like',dataIn);
                obj.HarrisMetric=cast(0,'like',dataIn);
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
                if isFAST
                    obj.AlgFP=fi(0,T.SignednessBool,T.WordLength+2+bitGrowth,T.FractionLength);
                else
                    obj.AlgFP=fi([0;0],true,T.WordLength+2+bitGrowth,T.FractionLength);
                end
                obj.CenterType=fi(0,1,T.WordLength+2,T.FractionLength);
                obj.CenterSubRingType=fi(0,1,T.WordLength+2,T.FractionLength);
                obj.AbsRingType=fi(0,1,T.WordLength+2+bitGrowth,T.FractionLength);
                obj.EdgeType=fi(0,1,T.WordLength+2,T.FractionLength);
                obj.HarrisMetric=fi(0,true,(T.WordLength+2)*4+4,4*T.FractionLength);
            end

            if~isfloat(dataIn)
                if strcmp(obj.OutputDataType,'Same as first input')
                    obj.RoundType=fi(0,T.SignednessBool,T.WordLength,T.FractionLength,obj.pFimath);
                    obj.OutType=cast(0,'like',dataIn);
                elseif strcmp(obj.OutputDataType,'Full precision')
                    if isFAST
                        obj.RoundType=obj.AlgFP;
                        obj.OutType=obj.AlgFP;
                    else
                        obj.RoundType=obj.HarrisMetric;
                        obj.OutType=obj.HarrisMetric;
                    end
                else
                    Tout=obj.CustomOutputDataType;
                    obj.OutType=fi(0,Tout.SignednessBool,Tout.WordLength,Tout.FractionLength,obj.pFimath);
                    obj.RoundType=obj.OutType;
                end
            end

            if isFAST













                if obj.getNumInputsImpl==3
                    obj.minCon=cast(0,'like',dataIn);
                else
                    obj.minCon=obj.MinContrast;
                end

                obj.CornerDelay=zeros(obj.NumberOfPixels,numDelay-delayOffset,'like',obj.AlgFP);

                obj.CtrlDelay=false(5,numDelay-delayOffset);

                if obj.NumberOfPixels==1
                    obj.CtrlKernelDelay=false(5,floor(obj.KernelMemoryKernelWidth/2));


                end
                obj.PaddingNoneValid=false;
                obj.InterX2Delay=[];
                obj.InterY2Delay=[];
                obj.InterXYDelay=[];
                obj.InterCtrlDelay=[];

            else

                coeffs=visionhdl.CornerDetector.getGaussCoeffs();
                if isfloat(dataIn)
                    obj.GaussFilterA=visionhdl.ImageFilter(coeffs,obj.LineBufferSize,...
                    'RoundingMethod','Nearest',...
                    'OverflowAction','Saturate',...
                    'PaddingMethod','Replicate',...
                    'CoefficientsSource','Property',...
                    'CoefficientsDataType','Same as first input',...
                    'OutputDataType','Same as first input');
                    obj.GaussFilterB=visionhdl.ImageFilter(coeffs,obj.LineBufferSize,...
                    'RoundingMethod','Nearest',...
                    'OverflowAction','Saturate',...
                    'PaddingMethod','Replicate',...
                    'CoefficientsSource','Property',...
                    'CoefficientsDataType','Same as first input',...
                    'OutputDataType','Same as first input');
                    obj.GaussFilterC=visionhdl.ImageFilter(coeffs,obj.LineBufferSize,...
                    'RoundingMethod','Nearest',...
                    'OverflowAction','Saturate',...
                    'PaddingMethod','Replicate',...
                    'CoefficientsSource','Property',...
                    'CoefficientsDataType','Same as first input',...
                    'OutputDataType','Same as first input');

                else
                    cSign=false;
                    cWL=16;
                    cFL=cWL+3;
                    ccdt=numerictype(cSign,cWL,cFL);

                    obj.GaussFilterA=visionhdl.ImageFilter(coeffs,obj.LineBufferSize,...
                    'RoundingMethod','Nearest',...
                    'OverflowAction','Saturate',...
                    'PaddingMethod','Replicate',...
                    'CoefficientsSource','Property',...
                    'CoefficientsDataType','custom',...
                    'CustomCoefficientsDataType',ccdt,...
                    'OutputDataType','Same as first input');
                    obj.GaussFilterB=visionhdl.ImageFilter(coeffs,obj.LineBufferSize,...
                    'RoundingMethod','Nearest',...
                    'OverflowAction','Saturate',...
                    'PaddingMethod','Replicate',...
                    'CoefficientsSource','Property',...
                    'CoefficientsDataType','custom',...
                    'CustomCoefficientsDataType',ccdt,...
                    'OutputDataType','Same as first input');
                    obj.GaussFilterC=visionhdl.ImageFilter(coeffs,obj.LineBufferSize,...
                    'RoundingMethod','Nearest',...
                    'OverflowAction','Saturate',...
                    'PaddingMethod','Replicate',...
                    'CoefficientsSource','Property',...
                    'CoefficientsDataType','custom',...
                    'CustomCoefficientsDataType',ccdt,...
                    'OutputDataType','Same as first input');
                end













                if obj.getNumInputsImpl==3
                    obj.minCon=cast(0,'like',obj.OutType);
                else
                    obj.minCon=cast(obj.Threshold,'like',obj.OutType);
                end

                obj.CornerDelay=zeros(obj.NumberOfPixels,numDelay-delayOffset,'like',obj.HarrisMetric);

                obj.CtrlDelay=false(5,numDelay-delayOffset);

                interDelay=5;
                if isfloat(dataIn)
                    obj.InterX2Delay=zeros(1,interDelay);
                    obj.InterY2Delay=zeros(1,interDelay);
                    obj.InterXYDelay=zeros(1,interDelay);
                    obj.InterCtrlDelay=false(5,interDelay);
                else
                    tmpCast=obj.AlgFP(1).*obj.AlgFP(1);
                    obj.InterX2Delay=zeros(1,interDelay,'like',tmpCast);
                    obj.InterY2Delay=zeros(1,interDelay,'like',tmpCast);
                    obj.InterXYDelay=zeros(1,interDelay,'like',tmpCast);
                    obj.InterCtrlDelay=false(5,interDelay);
                end


                if obj.NumberOfPixels==1
                    obj.CtrlKernelDelay=false(5,floor(obj.KernelMemoryKernelWidth/2));


                end

                obj.PaddingNoneValid=false;



            end
        end

        function resetImpl(obj)
            obj.CornerDelay(:)=0;
            obj.CtrlDelay(:)=false;
            obj.CtrlKernelDelay(:)=false;
            obj.POCI(:)=0;
        end

        function varargout=outputImpl(obj,varargin)


            if obj.CtrlDelay(5,end)
                tmpPreOut=cast(obj.CornerDelay(:,end),'like',obj.RoundType);
                tmpOut=cast(tmpPreOut,'like',obj.OutType);
                varargout{1}=tmpOut;
                varargout{2}.hStart=obj.CtrlDelay(1,end);
                varargout{2}.hEnd=obj.CtrlDelay(2,end);
                varargout{2}.vStart=obj.CtrlDelay(3,end);
                varargout{2}.vEnd=obj.CtrlDelay(4,end);
                varargout{2}.valid=obj.CtrlDelay(5,end);
            else
                varargout{1}=cast(zeros(obj.NumberOfPixels,1),'like',obj.OutType);
                varargout{2}=pixelcontrolstruct(0,0,0,0,0);
            end
        end


        function FASTUpdate(obj,varargin)
            if(obj.getNumInputsImpl==3)&&(varargin{2}.vStart)&&(varargin{2}.hStart)&&(varargin{2}.valid)
                obj.minCon=cast(varargin{3},'like',varargin{1});
            end

            [dataVector,hStart,hEnd,vStart,vEnd,valid,processData]=...
            stepKernelMemory(obj,varargin{1},varargin{2}.hStart,varargin{2}.hEnd,varargin{2}.vStart,varargin{2}.vEnd,varargin{2}.valid);

            ctrlIn=[hStart,hEnd,vStart,vEnd,valid,processData];


            obj.filterHandle(obj,dataVector,ctrlIn);
        end

        function HarrisUpdate(obj,varargin)

            if(obj.getNumInputsImpl==3)&&(varargin{2}.vStart)&&(varargin{2}.hStart)&&(varargin{2}.valid)
                obj.minCon=cast(varargin{3},'like',obj.OutType);
            end

            [dataVector,hStart,hEnd,vStart,vEnd,valid,processData]=...
            stepKernelMemory(obj,varargin{1},varargin{2}.hStart,varargin{2}.hEnd,varargin{2}.vStart,varargin{2}.vEnd,varargin{2}.valid);

            ctrlIn=[hStart,hEnd,vStart,vEnd,valid,processData];


            obj.filterHandle(obj,dataVector,ctrlIn);


        end

        function updateImpl(obj,varargin)

            obj.updateHandle(obj,varargin{:});
        end

        function FIRCore(obj,POCI)
            obj.AlgFP(:)=obj.CoreHandle(obj,POCI);
        end
























        function out=FASTCore(obj,POCI,centeridx,ringidx,predicate)
            compge=false(size(ringidx));%#ok  % pre-allocate comparison vectors
            comple=false(size(ringidx));%#ok
            minContrast=cast(obj.minCon,'like',obj.CenterType);
            center=cast(POCI(centeridx),'like',obj.CenterType);
            centerHi=cast(0,'like',obj.CenterType);
            centerHi(:)=cast(POCI(centeridx),'like',obj.CenterType)+minContrast;
            centerLo=cast(0,'like',obj.CenterType);
            centerLo(:)=cast(POCI(centeridx),'like',obj.CenterType)-minContrast;

            ring=cast(POCI(ringidx),'like',obj.CenterSubRingType);
            compge=ring>centerHi;
            comple=ring<centerLo;

            out=cast(0,'like',obj.AlgFP);
            outge=cast(0,'like',obj.AbsRingType);
            outle=cast(0,'like',obj.AbsRingType);
            foundge=false;
            foundle=false;
            if sum(int32(compge),'native')<5&&sum(int32(comple),'native')<5
                return
            end
            if(predicate(obj,compge))
                tempRing=abs(center-ring)-minContrast;
                tempRing(~compge)=cast(0,'like',tempRing);
                outge(:)=sum(tempRing);
                foundge=true;
            end
            if(predicate(obj,comple))
                tempRing=abs(center-ring)-minContrast;
                tempRing(~comple)=cast(0,'like',tempRing);
                outle(:)=sum(tempRing);
                foundle=true;
            end
            if foundge
                out(:)=outge;
            elseif foundle
                out(:)=outle;
            end
        end

        function out=FASTDoubleCore(obj,POCI,centeridx,ringidx,predicate)
            compge=false(size(ringidx));%#ok  % pre-allocate comparison vectors
            comple=false(size(ringidx));%#ok
            centerHi=double(POCI(centeridx))+double(obj.minCon);
            centerLo=double(POCI(centeridx))-double(obj.minCon);

            ring=double(POCI(ringidx));
            compge=ring>centerHi;
            comple=ring<centerLo;

            out=cast(0,'like',obj.AlgFP);
            outge=double(0);
            outle=double(0);
            foundge=false;
            foundle=false;
            if sum(double(compge),'double')<5&&sum(double(comple),'double')<5
                return
            end
            if(predicate(obj,compge))
                outge=double(sum(double(abs(double(POCI(centeridx))-ring(compge)))-double(obj.minCon)));
                foundge=true;
            end
            if(predicate(obj,comple))
                outle=double(sum(double(abs(double(POCI(centeridx))-ring(comple)))-double(obj.minCon)));
                foundle=true;
            end
            if foundge
                out(:)=outge;
            elseif foundle
                out(:)=outle;
            end
        end


        function out=predicate5of8(~,vect)
            out=(all(vect(1:5))||...
            all(vect(2:6))||...
            all(vect(3:7))||...
            all(vect(4:8))||...
            all([vect(5:8);vect(1)])||...
            all([vect(6:8);vect(1:2)])||...
            all([vect(7:8);vect(1:3)])||...
            all([vect(8);vect(1:4)]));
        end

        function out=FAST5of8Core(obj,POCI)
            centeridx=5;
            ringidx=[1;4;7;8;9;6;3;2];
            predicate=@predicate5of8;
            out=FASTCore(obj,POCI,centeridx,ringidx,predicate);
        end

        function out=FAST5of8DoubleCore(obj,POCI)
            centeridx=5;
            ringidx=[1;4;7;8;9;6;3;2];
            predicate=@predicate5of8;
            out=FASTDoubleCore(obj,POCI,centeridx,ringidx,predicate);
        end

        function out=predicate7of12(~,vect)
            out=(all(vect(1:7))||...
            all(vect(2:8))||...
            all(vect(3:9))||...
            all(vect(4:10))||...
            all(vect(5:11))||...
            all(vect(6:12))||...
            all([vect(7:12);vect(1)])||...
            all([vect(8:12);vect(1:2)])||...
            all([vect(9:12);vect(1:3)])||...
            all([vect(10:12);vect(1:4)])||...
            all([vect(11:12);vect(1:5)])||...
            all([vect(12);vect(1:6)]));
        end

        function out=FAST7of12Core(obj,POCI)
            centeridx=13;
            ringidx=[6;11;16;22;23;24;20;15;10;4;3;2];
            predicate=@predicate7of12;
            out=FASTCore(obj,POCI,centeridx,ringidx,predicate);
        end

        function out=FAST7of12DoubleCore(obj,POCI)
            centeridx=13;
            ringidx=[6;11;16;22;23;24;20;15;10;4;3;2];
            predicate=@predicate7of12;
            out=FASTDoubleCore(obj,POCI,centeridx,ringidx,predicate);
        end

        function out=predicate9of16(~,vect)
            out=(all(vect(1:9))||...
            all(vect(2:10))||...
            all(vect(3:11))||...
            all(vect(4:12))||...
            all(vect(5:13))||...
            all(vect(6:14))||...
            all(vect(7:15))||...
            all(vect(8:16))||...
            all([vect(9:16);vect(1)])||...
            all([vect(10:16);vect(1:2)])||...
            all([vect(11:16);vect(1:3)])||...
            all([vect(12:16);vect(1:4)])||...
            all([vect(13:16);vect(1:5)])||...
            all([vect(14:16);vect(1:6)])||...
            all([vect(15:16);vect(1:7)])||...
            all([vect(16);vect(1:8)]));
        end

        function out=FAST9of16Core(obj,POCI)
            centeridx=25;
            ringidx=[22;29;37;45;...
            46;47;41;35;...
            28;21;13;5;...
            4;3;9;15];
            predicate=@predicate9of16;
            out=FASTCore(obj,POCI,centeridx,ringidx,predicate);
        end

        function out=FAST9of16DoubleCore(obj,POCI)
            centeridx=25;
            ringidx=[22;29;37;45;...
            46;47;41;35;...
            28;21;13;5;...
            4;3;9;15];
            predicate=@predicate9of16;
            out=FASTDoubleCore(obj,POCI,centeridx,ringidx,predicate);
        end

    end
    methods(Access=private)

        function singlePixelFASTFilter(obj,dataVector,ctrlIn)
            hStart=ctrlIn(1);
            hEnd=ctrlIn(2);
            vStart=ctrlIn(3);
            vEnd=ctrlIn(4);
            valid=ctrlIn(5);
            processData=ctrlIn(6);

            sizeDV=numel(dataVector);

            if processData

                obj.POCI(:,:)=[flipud(dataVector);obj.POCI(1:(end-sizeDV))];
            end

            FIRCore(obj,obj.POCI);
            kk=1;
            obj.CornerDelay(kk,:)=[obj.AlgFP,obj.CornerDelay(kk,1:end-1)];

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
                    obj.CtrlDelay=[obj.CtrlKernelDelay(:,end),obj.CtrlDelay(:,1:end-1)];
                    obj.CtrlKernelDelay(:)=[[hStart;hEnd;vStart;vEnd;valid],obj.CtrlKernelDelay(:,1:end-1)];
                else
                    obj.CtrlDelay=[false(5,1),obj.CtrlDelay(:,1:end-1)];
                end
            end
        end







































































        function singlePixelHarrisFilter(obj,dataVector,ctrlIn)
            hStart=ctrlIn(1);
            hEnd=ctrlIn(2);
            vStart=ctrlIn(3);
            vEnd=ctrlIn(4);
            valid=ctrlIn(5);
            processData=ctrlIn(6);

            sizeDV=numel(dataVector);

            filterctrlbool=false(5,1);

            if((strcmpi(obj.PaddingMethod,'None'))&&(obj.PaddingNoneValid==true))
                padNoneKernel=cast(ones(obj.KernelMemoryKernelHeight*obj.KernelMemoryKernelWidth,1),'like',obj.POCI);
                padNoneKernel(:,:)=[flipud(dataVector);obj.POCI(1:(end-sizeDV))];
                FIRCore(obj,padNoneKernel);
                filterctrlbool=obj.CtrlKernelDelay(:,end);
            else
                if processData
                    obj.POCI(:,:)=[flipud(dataVector);obj.POCI(1:(end-sizeDV))];
                    filterctrlbool=obj.CtrlKernelDelay(:,end);
                end
                FIRCore(obj,obj.POCI);
            end

            if strcmpi(obj.PaddingMethod,'None')
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
                    obj.CtrlKernelDelay(:)=[[hStart;hEnd;vStart;vEnd;valid],obj.CtrlKernelDelay(:,1:end-1)];
                end
            end

            xSquared=obj.AlgFP(1).*obj.AlgFP(1);
            ySquared=obj.AlgFP(2).*obj.AlgFP(2);
            xy=obj.AlgFP(1).*obj.AlgFP(2);


            tX2=obj.InterX2Delay(end);
            tY2=obj.InterY2Delay(end);
            tXY=obj.InterXYDelay(end);
            tCtrl=obj.InterCtrlDelay(:,end);

            newctrl=[filterctrlbool(1);filterctrlbool(2);...
            filterctrlbool(3);filterctrlbool(4);...
            filterctrlbool(5)];

            obj.InterX2Delay(:)=[xSquared,obj.InterX2Delay(1:end-1)];
            obj.InterY2Delay(:)=[ySquared,obj.InterY2Delay(1:end-1)];
            obj.InterXYDelay(:)=[xy,obj.InterXYDelay(1:end-1)];
            obj.InterCtrlDelay(:)=[newctrl,obj.InterCtrlDelay(:,1:end-1)];

            filterctrl=pixelcontrolstruct(tCtrl(1),tCtrl(2),tCtrl(3),tCtrl(4),tCtrl(5));
            [filterxSq,xSqctrl]=step(obj.GaussFilterA,tX2,filterctrl);
            [filterySq,~]=step(obj.GaussFilterB,tY2,filterctrl);
            [filterxy,~]=step(obj.GaussFilterC,tXY,filterctrl);

            if~isfloat(dataVector(1))
                k=fi(0.04,0,16,20);
                data=obj.HarrisMetric;
                inWL=data.WordLength;
                inFL=data.FractionLength;

                tempAB=fi(0,1,inWL,inFL,'fimath',hdlfimath);
                tempCsq=fi(0,1,inWL,inFL,'fimath',hdlfimath);
                tempApBsq=fi(0,1,inWL,inFL,'fimath',hdlfimath);
                tempkApBsq=fi(0,1,inWL,inFL,'fimath',hdlfimath);
            else
                k=0.04;
                tempAB=0.0;
                tempCsq=0.0;
                tempApBsq=0.0;
                tempkApBsq=0.0;
            end

            tempAB(:)=(filterxSq.*filterySq);
            tempCsq(:)=(filterxy.^2);
            tempApBsq(:)=(filterxSq+filterySq).^2;
            tempkprod=k*tempApBsq;
            tempkApBsq(:)=tempkprod;
            tempMetric=tempAB-tempCsq-tempkApBsq;
            if tempMetric<0
                tempMetric(:)=0;
            end

            tempCompareVal=cast(tempMetric,'like',obj.RoundType);
            if tempCompareVal>obj.minCon
                obj.HarrisMetric(:)=tempMetric;
            else
                obj.HarrisMetric(:)=0;
            end
            kk=1;
            obj.CornerDelay(kk,:)=[obj.HarrisMetric,obj.CornerDelay(kk,1:end-1)];
            filterctrlout=[xSqctrl.hStart;xSqctrl.hEnd;xSqctrl.vStart;xSqctrl.vEnd;xSqctrl.valid];
            obj.CtrlDelay=[filterctrlout,obj.CtrlDelay(:,1:end-1)];
        end






        function out=HarrisCore(obj,POCI)



            out=cast([0;0],'like',obj.EdgeType);
            out(1)=cast(POCI(8),'like',obj.EdgeType)-cast(POCI(2),'like',obj.EdgeType);
            out(2)=cast(POCI(4),'like',obj.EdgeType)-cast(POCI(6),'like',obj.EdgeType);
        end

        function out=HarrisDoubleCore(~,POCI)



            out=zeros(2,1);
            out(1)=POCI(8)-POCI(2);
            out(2)=POCI(4)-POCI(6);
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

        function GaussCoeffs=getGaussCoeffs()

            GaussCoeffs=[0.0178422039268339,0.0306173443749486,0.0366556162983683,0.0306173443749486,0.0178422039268339;...
            0.0306173443749486,0.0525395730492887,0.0629012891056152,0.0525395730492887,0.0306173443749486;...
            0.0366556162983683,0.0629012891056152,0.0753065154799872,0.0629012891056152,0.0366556162983683;...
            0.0306173443749486,0.0525395730492887,0.0629012891056152,0.0525395730492887,0.0306173443749486;...
            0.0178422039268339,0.0306173443749486,0.0366556162983683,0.0306173443749486,0.0178422039268339];
        end


    end

    methods(Access=protected)
        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end
    end

end
