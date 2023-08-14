classdef(StrictDefaults)ImageFilter<visionhdl.internal.abstractLineMemoryKernel

























































































%#codegen
%#ok<*EMCLS>

    properties(Nontunable)



        CoefficientsSource='Property';




        Coefficients=[1,0;0,-1];




        PaddingMethod='Constant';





        PaddingValue=0;






        LineBufferSize=2048;




        RoundingMethod='Floor';




        OverflowAction='Wrap';




        CoefficientsDataType='Same as first input';





        CustomCoefficientsDataType=numerictype(1,16,15);




        OutputDataType='Same as first input';





        CustomOutputDataType=numerictype(1,8,0);
    end



    properties(DiscreteState)




        CoeffCastFlip;
    end


    properties(Constant,Hidden)

        CoefficientsSourceSet=matlab.system.StringSet({...
        'Property',...
        'Input port'});

        PaddingMethodSet=matlab.system.StringSet({...
        'Constant',...
        'Replicate',...
        'Symmetric',...
        'Reflection',...
        'None'});

        RoundingMethodSet=matlab.system.internal.RoundingMethodSet({...

        'Ceiling',...
        'Convergent',...
        'Floor',...
        'Nearest',...
        'Round',...
        'Zero'});

        OverflowActionSet=matlab.system.internal.OverflowActionSet;

        CoefficientsDataTypeSet=matlab.system.internal.DataTypeSet(...
        {'Same as first input','Custom',matlab.system.internal.CustomDataType('Signedness',{'Signed','Unsigned'})},...
        'Compatibility','Legacy',...
        'ValuePropertyName','Coefficients',...
        'HasDesignMinimum',true,...
        'HasDesignMaximum',true);

        OutputDataTypeSet=matlab.system.internal.DataTypeSet(...
        {'Same as first input','Full precision','Custom',matlab.system.internal.CustomDataType('Signedness',{'Signed','Unsigned'})},...
        'Compatibility','Legacy',...
        'HasDesignMinimum',true,...
        'HasDesignMaximum',true);
    end


    properties(Access=private)
        WeightedSumFi;
        DataDelay;
        CtrlDelay;
        CtrlKernelDelay;
        DelayLine;
        MultiPixelWindow;
        MultiPixelFilterKernel;
        ProgCoeffReg;
        ProgCoeffReg_2;
        PaddingNoneValid;
    end

    properties(Access=private,Nontunable)
        KernelWidthMax;
        KernelHeightMax;
        KernelWidthMin;
        KernelHeightMin;

    end


    properties(Access=private,Nontunable)
        filterHandle;
        NumberOfPixels;
    end

    methods(Static,Access=protected)
        function groups=getPropertyGroupsImpl
            className=mfilename('class');
            mainGroup=matlab.system.display.SectionGroup(className);
            dataTypesGroup=matlab.system.display.internal.DataTypesGroup(className);
            dataTypesGroup.PropertyList{3}=...
            matlab.system.display.internal.DataTypeProperty('CoefficientsDataType',...
            'Prefix','Coeff');

            groups=[mainGroup,dataTypesGroup];
        end
    end

    methods
        function obj=ImageFilter(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','Vision_HDL_Toolbox'))
                    error(message('visionhdl:visionhdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','Vision_HDL_Toolbox');
            end

            coder.extrinsic('visionhdllimits');
            if isempty(coder.target)
                [kernelwidthmax,kernelheightmax,kernelwidthmin,kernelheightmin]=visionhdllimits();
            else
                [kernelwidthmax,kernelheightmax,kernelwidthmin,kernelheightmin]=coder.internal.const(visionhdllimits());
            end
            obj.KernelWidthMax=kernelwidthmax;
            obj.KernelHeightMax=kernelheightmax;
            obj.KernelWidthMin=kernelwidthmin;
            obj.KernelHeightMin=kernelheightmin;

            setProperties(obj,nargin,varargin{:},'Coefficients','LineBufferSize');
        end

        function set.CustomCoefficientsDataType(obj,val)
            validateCustomDataType(obj,'CustomCoefficientsDataType',val,{'Property','CoefficientsDataTypeSet'});
            obj.CustomCoefficientsDataType=val;
        end

        function set.CustomOutputDataType(obj,val)
            validateCustomDataType(obj,'CustomOutputDataType',val,{'Property','OutputDataTypeSet'});
            obj.CustomOutputDataType=val;
        end

        function set.Coefficients(obj,val)
            validateattributes(val,{'numeric'},{'2d'},'ImageFilter','Coefficients');
            [height,width]=size(val);

            validateattributes(height,{'numeric'},{'scalar','<=',obj.KernelHeightMax,'>=',obj.KernelHeightMin},'ImageFilter','first dimension of Coefficients');%#ok<MCSUP>
            validateattributes(width,{'numeric'},{'scalar','<=',obj.KernelWidthMax,'>=',obj.KernelWidthMin},'ImageFilter','second dimension of Coefficients');%#ok<MCSUP>
            obj.Coefficients=val;
        end

        function set.PaddingValue(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','>=',0},'ImageFilter','PaddingValue');
            obj.PaddingValue=val;
        end

        function set.LineBufferSize(obj,val)

            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'ImageFilter','Line buffer size');
            obj.LineBufferSize=val;
        end

    end

    methods(Static,Access=protected)
        function header=getHeaderImpl

            header=matlab.system.display.Header('visionhdl.ImageFilter',...
            'ShowSourceLink',false,...
            'Title','Image Filter');
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
            case{'CoefficientsDataType'}
                if strcmpi(obj.CoefficientsSource,'Input port')


                    flag=true;
                end
            case{'CustomCoefficientsDataType'}
                if~strcmp(obj.CoefficientsDataType,'Custom')||strcmpi(obj.CoefficientsSource,'Input port')


                    flag=true;
                end
            case{'CustomOutputDataType'}
                if~strcmp(obj.OutputDataType,'Custom')
                    flag=true;
                end
            case{'Coefficients'}
                if strcmpi(obj.CoefficientsSource,'Input port')


                    flag=true;
                end
            end
        end


        function setDiscreteStateImpl(obj,ds)
            if~isempty(ds)
                obj.CoeffCastFlip=ds.CoeffCastFlip;
            end
        end


        function ds=getDiscreteStateImpl(obj)
            coeffFromPort=strcmpi(obj.CoefficientsSource,'Input port');
            if coeffFromPort
                ds=struct([]);
            else
                ds=struct('CoeffCastFlip',obj.CoeffCastFlip);
            end
        end


        function validateInputsImpl(obj,pixelIn,ctrlIn,varargin)

            if isempty(coder.target)||~eml_ambiguous_types



                validateattributes(pixelIn,{'numeric','embedded.fi'},...
                {'real','nonnan','finite'},'ImageFilter','pixel input');

                if~ismember(size(pixelIn,1),[1,2,4,8])
                    coder.internal.error('visionhdl:ImageFilter:InputDimensions');
                end

                if~ismember(size(pixelIn,2),[1])%#ok<NBRAK2>
                    coder.internal.error('visionhdl:ImageFilter:InputDimensions');
                end

                validatecontrolsignals(ctrlIn);

                if strcmpi(obj.CoefficientsSource,'Input port')
                    coeffIn=varargin{1};
                    validateattributes(coeffIn,{'numeric','embedded.fi'},...
                    {'2d','real','nonnan','finite'},'ImageFilter','coeff');

                    [height,width]=size(coeffIn);

                    sizeCheck=height>1&&height<=obj.KernelHeightMax&&...
                    width>1&&width<=obj.KernelWidthMax;
                    coder.internal.errorIf(~sizeCheck,'visionhdl:ImageFilter:InvalidCoeffPortSize',height,width)
                    validateattributes(height,{'numeric'},{'scalar','<=',obj.KernelHeightMax,'>',1},'ImageFilter',...
                    'first dimension of Coefficient port in Image Filter');
                    validateattributes(width,{'numeric'},{'scalar','<=',obj.KernelWidthMax,'>',1},'ImageFilter',...
                    'second dimension of Coefficient port in Image Filter');
                end

                if strcmpi(obj.CoefficientsSource,'Input port')
                    kernelSize=[height,width];
                else
                    kernelSize=size(obj.Coefficients);
                end
                validateKernelMemoryConfiguration(obj,pixelIn,kernelSize);
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
                s.WeightedSumFi=obj.WeightedSumFi;
                s.DataDelay=obj.DataDelay;
                s.CtrlDelay=obj.CtrlDelay;

                s.CtrlKernelDelay=obj.CtrlKernelDelay;

                s.DelayLine=obj.DelayLine;
                s.ProgCoeffReg=obj.ProgCoeffReg;
                s.ProgCoeffReg_2=obj.ProgCoeffReg_2;
                s.filterHandle=obj.filterHandle;
                s.NumberOfPixels=obj.NumberOfPixels;
                s.PaddingNoneValid=obj.PaddingNoneValid;

            end
        end

        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end


        function setupImpl(obj,dataIn,ctrlIn,varargin)

            coder.extrinsic('visionhdl.ImageFilter.firkernellatency');
            coder.extrinsic('visionhdl.ImageFilter.firkernellatency_progcoeff');




            obj.NumberOfPixels=size(dataIn,1);

            coeffFromPort=strcmpi(obj.CoefficientsSource,'Input port');
            if coeffFromPort
                coeffs_tmp=varargin{1};

                csize=size(coeffs_tmp);
                validateattributes(csize(1),{'numeric'},{'scalar','<=',obj.KernelHeightMax,'>=',obj.KernelHeightMin},...
                'ImageFilter','first dimension of Coefficients');
                validateattributes(csize(2),{'numeric'},{'scalar','<=',obj.KernelWidthMax,'>=',obj.KernelWidthMin},...
                'ImageFilter','second dimension of Coefficients');



                if isinteger(coeffs_tmp)
                    coeffs=cast(coeffs_tmp,'like',fi(coeffs_tmp));
                else
                    coeffs=coeffs_tmp;
                end
            else
                coeffs=obj.Coefficients;
            end


            obj.ProgCoeffReg=cast(zeros(size(coeffs)),'like',coeffs);
            obj.ProgCoeffReg_2=cast(zeros(size(coeffs)),'like',coeffs);

            [obj.KernelMemoryKernelHeight,obj.KernelMemoryKernelWidth]=size(coeffs);
            obj.KernelMemoryMaxLineSize=obj.LineBufferSize;
            obj.KernelMemoryPaddingMethod=obj.PaddingMethod;
            obj.KernelMemoryPaddingValue=obj.PaddingValue;
            obj.KernelMemoryBiasUp=true;

            setupKernelMemory(obj,dataIn,ctrlIn.hStart,ctrlIn.hEnd,ctrlIn.vStart,ctrlIn.vEnd,ctrlIn.valid);

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

            if~coeffFromPort


                if isa(dataIn,'single')||isa(dataIn,'double')
                    obj.CoeffCastFlip=cast(fliplr(coeffs),'like',dataIn);%#ok<SOINITPROP> 
                else
                    if strcmp(obj.CoefficientsDataType,'Same as first input')






                        if isa(dataIn,'uint8')
                            temp=fi(0,0,8,0);
                        elseif isa(dataIn,'int8')
                            temp=fi(0,1,8,0);
                        elseif isa(dataIn,'uint16')
                            temp=fi(0,0,16,0);
                        elseif isa(dataIn,'int16')
                            temp=fi(0,1,16,0);
                        elseif isa(dataIn,'uint32')
                            temp=fi(0,0,32,0);
                        elseif isa(dataIn,'int32')
                            temp=fi(0,1,32,0);
                        elseif isa(dataIn,'uint64')
                            temp=fi(0,0,64,0);
                        elseif isa(dataIn,'int64')
                            temp=fi(0,1,64,0);
                        else
                            temp=dataIn;
                        end
                        obj.CoeffCastFlip=cast(fliplr(coeffs),'like',temp);
                    else
                        obj.CoeffCastFlip=fi(fliplr(coeffs),obj.CustomCoefficientsDataType);
                    end
                end
            else
                obj.CoeffCastFlip=fliplr(coeffs);
            end


            if isa(dataIn,'single')||isa(dataIn,'double')
                outputT=dataIn;
            else
                if strcmp(obj.OutputDataType,'Same as first input')
                    outputT=dataIn;
                elseif strcmp(obj.OutputDataType,'Full precision')
                    if obj.NumberOfPixels==1
                        outputT=sum(obj.DelayLine(:).*obj.CoeffCastFlip(:),...
                        1,'native');
                    else
                        kernel=obj.MultiPixelFilterKernel(:,:,1);
                        outputT=sum(kernel(:).*obj.CoeffCastFlip(:),...
                        1,'native');
                    end
                else
                    outputT=fi(0,obj.CustomOutputDataType);
                end
            end

            pFimath=fimath('RoundingMethod',obj.RoundingMethod,...
            'OverflowAction',obj.OverflowAction);

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


            temp=cast(0,'like',dataIn);
            if~coeffFromPort
                numDelay=coder.internal.const(...
                visionhdl.ImageFilter.firkernellatency(...
                class(dataIn),...
                coeffs,...
                obj.CoefficientsDataType,...
                obj.CustomCoefficientsDataType,...
                temp));
            else
                numDelay=coder.internal.const(...
                visionhdl.ImageFilter.firkernellatency_progcoeff(...
                numel(coeffs)));
            end

            if obj.NumberOfPixels==1
                obj.CtrlDelay=false(5,numDelay);
                obj.DataDelay=cast(zeros(1,numDelay),'like',outputT);
            else
                obj.CtrlDelay=false(5,numDelay);
                obj.DataDelay=cast(zeros(obj.NumberOfPixels,numDelay),'like',outputT);
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
            obj.ProgCoeffReg(:,:)=0;
            obj.ProgCoeffReg_2(:,:)=0;
            obj.PaddingNoneValid=false;
        end

        function[dataOut,ctrlOut]=outputImpl(obj,~,~,varargin)



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

        function updateImpl(obj,dataIn,ctrlIn,varargin)


            coeffFromPort=strcmpi(obj.CoefficientsSource,'Input port');

            validateattributes(dataIn,{'numeric','embedded.fi'},{'finite'},'ImageFilter','input data');
            if coeffFromPort
                validateattributes(varargin{1},{'numeric','embedded.fi'},{'finite'},'ImageFilter','coefficients');

                cdtdouble=...
                (isa(varargin{1},'double')||isa(varargin{1},'single'))&&...
                ~(isa(dataIn,'double')||isa(dataIn,'single'));
                coder.internal.errorIf(cdtdouble,'visionhdl:ImageFilter:InvalidCoeffDataType','single/double');
            end

            [dataVector,hStartOut,hEndOut,vStartOut,vEndOut,validOut,processDataOut]=...
            stepKernelMemory(obj,dataIn,ctrlIn.hStart,ctrlIn.hEnd,ctrlIn.vStart,ctrlIn.vEnd,ctrlIn.valid);

            ctrlInLB=[hStartOut,hEndOut,vStartOut,vEndOut,validOut,processDataOut];


            obj.filterHandle(obj,dataVector,ctrlIn,ctrlInLB,coeffFromPort,varargin);



        end



        function result=FIRCore(obj,DelayLine)

            coeffFromPort=strcmpi(obj.CoefficientsSource,'Input port');

            if~coeffFromPort
                weighted=DelayLine(:).*obj.CoeffCastFlip(:);
            else
                weighted=DelayLine(:).*obj.ProgCoeffReg_2(:);
            end
            weighted_sum=sum(weighted,1,'native');
            obj.WeightedSumFi(:)=weighted_sum;
            result=obj.WeightedSumFi;
        end

        function num=getNumInputsImpl(obj)
            if strcmpi(obj.CoefficientsSource,'Property')
                num=2;
            else
                num=3;
            end
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end


        function icon=getIconImpl(~)
            icon=sprintf('Image Filter');
        end


        function varargout=getInputNamesImpl(obj)

            varargout=cell(1,getNumInputs(obj));
            varargout{1}='pixel';
            varargout{2}='ctrl';
            if strcmpi(obj.CoefficientsSource,'Input port')
                varargout{3}='coeff';
            end
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
                if strcmpi(obj.CoefficientsSource,'Property')
                    [sz,dt,~]=getDiscreteStateSpecificationImpl(obj);
                else
                    sz=propagatedInputSize(obj,3);
                    cdt=propagatedInputDataType(obj,3);
                    dt=int2fitype(obj,cdt);
                end


                cdtdouble=ischar(dt)&&(strcmp(dt,'double')||strcmp(dt,'single'));


                coder.internal.errorIf(cdtdouble,'visionhdl:ImageFilter:InvalidCoeffDataType',dt);


                tmpCoeff=fi(zeros(sz(1),sz(2)),dt);
                intype=int2fitype(obj,intype);
                tmpDelayLine=fi(zeros(sz(1),sz(2)),intype);
                dt1=numerictype(sum(tmpDelayLine(:).*tmpCoeff(:),...
                1,'native'));

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


            if strcmpi(obj.CoefficientsSource,'Property')
                dt=propagatedInputDataType(obj,1);
                cp=propagatedInputComplexity(obj,1);
                sz=size(obj.Coefficients);


                if(ischar(dt)||(isstring(dt)&&isscalar(dt)))&&(strcmp(dt,'double')||strcmp(dt,'single'))
                    dt=dt;%#ok  % do nothing
                elseif strcmp(obj.CoefficientsDataType,'Same as first input')






                    dt=int2fitype(obj,dt);
                else
                    dt=obj.CustomCoefficientsDataType;
                end
            else

                sz=propagatedInputSize(obj,3);
                dt=propagatedInputDataType(obj,3);
                cp=propagatedInputComplexity(obj,3);
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

    methods(Static,Hidden)
        function firKernelDelay=firkernellatency(dataInDT,coeffs,coeffsDT,CcoeffsDT,FI_zero)


            if strcmp(dataInDT,'single')
                JLCoeffCastFlip=cast(fliplr(coeffs),'like',single(0));
            elseif strcmp(dataInDT,'double')
                JLCoeffCastFlip=cast(fliplr(coeffs),'like',double(0));
            else
                if strcmp(coeffsDT,'Same as first input')






                    if strcmp(dataInDT,'uint8')
                        temp=fi(0,0,8,0);
                    elseif strcmp(dataInDT,'int8')
                        temp=fi(0,1,8,0);
                    elseif strcmp(dataInDT,'uint16')
                        temp=fi(0,0,16,0);
                    elseif strcmp(dataInDT,'int16')
                        temp=fi(0,1,16,0);
                    elseif strcmp(dataInDT,'uint32')
                        temp=fi(0,0,32,0);
                    elseif strcmp(dataInDT,'int32')
                        temp=fi(0,1,32,0);
                    elseif strcmp(dataInDT,'uint64')
                        temp=fi(0,0,64,0);
                    elseif strcmp(dataInDT,'int64')
                        temp=fi(0,1,64,0);
                    else

                        temp=FI_zero;
                    end
                    JLCoeffCastFlip=cast(fliplr(coeffs),'like',temp);
                else
                    JLCoeffCastFlip=fi(fliplr(coeffs),CcoeffsDT);
                end
            end



            hdlDataLatency=5;



            firKernelDelay=hdlDataLatency;


            nonZeroCoeffIndex=(JLCoeffCastFlip~=0);
            nonZeroCoeffs=JLCoeffCastFlip(nonZeroCoeffIndex);

            if isempty(nonZeroCoeffs)

                return;
            end




            multPreDelay=2;
            multPostDelay=2;


            sizeNonZeroCoeffs=size(nonZeroCoeffs);


            if all(sizeNonZeroCoeffs==1)

                firKernelDelay=multPreDelay+multPostDelay+firKernelDelay;
                return;
            end




            coeffsUniqueAbsNonZero=unique(abs(double(nonZeroCoeffs)));
            coeffsUniqueAbsNonZero=cast(coeffsUniqueAbsNonZero,'like',nonZeroCoeffs);



            coeffsNum=numel(coeffsUniqueAbsNonZero);
            if~(numel(coeffsUniqueAbsNonZero)==numel(nonZeroCoeffs))

                preAddLatency=zeros(1,coeffsNum);
                for ii=1:coeffsNum
                    coeffVal=coeffsUniqueAbsNonZero(ii);

                    coeffValSymIndex=(nonZeroCoeffs==coeffVal);
                    coeffValAntiSymIndex=(nonZeroCoeffs==(-1*coeffVal));
                    numSymRepetitions=sum(sum(coeffValSymIndex));
                    numAntiSymRepetitions=sum(sum(coeffValAntiSymIndex));
                    numRepetitions=numSymRepetitions+numAntiSymRepetitions;
                    if numRepetitions==1
                        continue;
                    else
                        preAddLatency(ii)=ceil(log2(numRepetitions))+1;
                    end
                end


                totalPreAddLatency=max(preAddLatency);
            else

                totalPreAddLatency=0;
            end


            firKernelDelay=firKernelDelay+totalPreAddLatency;


            multLatency=multPreDelay+multPostDelay;


            firKernelDelay=firKernelDelay+multLatency;



            if coeffsNum==1
                addLatency=0;
            else

                addLatency=ceil(log2(coeffsNum))+1;
            end


            firKernelDelay=firKernelDelay+addLatency;


            dtclatency=1;


            firKernelDelay=firKernelDelay+dtclatency;
        end

        function firKernelDelay=firkernellatency_progcoeff(numcoeffs)





            hdlDataLatency=5;



            firKernelDelay=hdlDataLatency;


            multPreDelay=2;
            multPostDelay=2;

            firKernelDelay=multPreDelay+multPostDelay+firKernelDelay;


            if numcoeffs==1
                addLatency=0;
            else



                addLatency=ceil(log2(numcoeffs))+1;
            end


            dtclatency=1;


            firKernelDelay=firKernelDelay+addLatency+dtclatency;
        end

    end


    methods(Access=private)

        function singlePixelFilter(obj,dataVector,ctrlIn,ctrlInLB,coeffFromPort,varargin)
            hStartOut=ctrlInLB(1);
            hEndOut=ctrlInLB(2);
            vStartOut=ctrlInLB(3);
            vEndOut=ctrlInLB(4);
            validOut=ctrlInLB(5);
            processDataOut=ctrlInLB(6);

            if processDataOut
                sz=size(obj.DelayLine);
                if sz(2)==1
                    obj.DelayLine(:)=flipud(dataVector);
                else
                    obj.DelayLine(:,:)=[flipud(dataVector),obj.DelayLine(:,1:end-1)];
                end
            end





            if coeffFromPort&&vStartOut&&validOut
                obj.ProgCoeffReg_2(:,:)=obj.ProgCoeffReg;
            end

            if((strcmpi(obj.PaddingMethod,'None'))&&(obj.PaddingNoneValid==true))
                padNoneKernel=cast(ones(obj.KernelMemoryKernelHeight,obj.KernelMemoryKernelWidth),'like',obj.DelayLine);
                padNoneKernel(:,1)=flipud(dataVector);
                padNoneKernel(:,2:end)=obj.DelayLine(:,1:end-1);
                obj.DataDelay(:)=[FIRCore(obj,padNoneKernel),obj.DataDelay(1:end-1)];
            else
                obj.DataDelay(:)=[FIRCore(obj,obj.DelayLine),obj.DataDelay(1:end-1)];
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





            if coeffFromPort&&ctrlIn.vStart&&ctrlIn.valid
                obj.ProgCoeffReg(:,:)=fliplr(varargin{1}{1});
            end
        end




        function multiPixelFilter(obj,dataVector,ctrlIn,ctrlInLB,coeffFromPort,varargin)
            hStartOut=ctrlInLB(1);
            hEndOut=ctrlInLB(2);
            vStartOut=ctrlInLB(3);
            vEndOut=ctrlInLB(4);
            validOut=ctrlInLB(5);
            processDataOut=ctrlInLB(6);

            halfWidth=(floor(obj.KernelMemoryKernelWidth/2))-((ceil((floor(obj.KernelMemoryKernelWidth/2))/obj.NumberOfPixels)-1)*obj.NumberOfPixels);






            if coeffFromPort&&vStartOut&&validOut
                obj.ProgCoeffReg_2(:,:)=obj.ProgCoeffReg;
            end




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
                obj.DataDelay(kk,2:end)=obj.DataDelay(kk,1:end-1);
                obj.DataDelay(kk,1)=FIRCore(obj,fliplr(flipud(obj.MultiPixelFilterKernel(:,:,kk))));%#ok<FLUDLR> % #ok         
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




            if coeffFromPort&&ctrlIn.vStart&&ctrlIn.valid
                obj.ProgCoeffReg(:,:)=fliplr(varargin{1}{1});
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

