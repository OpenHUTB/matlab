classdef(StrictDefaults)BiquadFilter<matlab.System




































































%#codegen




    properties(Nontunable)



        Structure='Direct form II';




        Numerator=[1,2,1];








        Denominator=[1,.1,.2];




        ScaleValues=[1];




        RoundingMethod='Floor';




        OverflowAction='Wrap';




        NumeratorDataType='Same word length as input';





        CustomNumeratorDataType=numerictype(1,16,15);




        DenominatorDataType='Same word length as input';





        CustomDenominatorDataType=numerictype(1,16,15);




        ScaleValuesDataType='Same word length as input';





        CustomScaleValuesDataType=numerictype(1,16,15);




        AccumulatorDataType='Same as first input';





        CustomAccumulatorDataType=numerictype(1,16,15);




        OutputDataType='Same as first input';





        CustomOutputDataType=numerictype(1,16,15);
    end


    properties(Constant,Hidden)

        StructureSet=matlab.system.StringSet({...
        'Direct form II',...
        'Direct form II transposed',...
        'Pipelined feedback form'});


        RoundingMethodSet=matlab.system.internal.RoundingMethodSet({...

        'Ceiling',...
        'Convergent',...
        'Floor',...
        'Nearest',...
        'Round',...
        'Zero'});

        OverflowActionSet=matlab.system.internal.OverflowActionSet;

        NumeratorDataTypeSet=matlab.system.internal.DataTypeSet(...
        {'Same word length as input','Custom',matlab.system.internal.CustomDataType('Signedness',{'Signed','Unsigned'})},...
        'Compatibility','Legacy',...
        'ValuePropertyName','Numerator');

        DenominatorDataTypeSet=matlab.system.internal.DataTypeSet(...
        {'Same word length as input','Custom',matlab.system.internal.CustomDataType('Signedness',{'Signed','Unsigned'})},...
        'Compatibility','Legacy',...
        'ValuePropertyName','Denominator');

        ScaleValuesDataTypeSet=matlab.system.internal.DataTypeSet(...
        {'Same word length as input','Custom',matlab.system.internal.CustomDataType('Signedness',{'Signed','Unsigned'})},...
        'Compatibility','Legacy',...
        'ValuePropertyName','ScaleValues');

        AccumulatorDataTypeSet=matlab.system.internal.DataTypeSet(...
        {'Same as first input','Custom',matlab.system.internal.CustomDataType('Signedness',{'Signed','Unsigned'})},...
        'Compatibility','Legacy');

        OutputDataTypeSet=matlab.system.internal.DataTypeSet(...
        {'Same as first input','Full precision','Custom',matlab.system.internal.CustomDataType('Signedness',{'Signed','Unsigned'})},...
        'Compatibility','Legacy');
    end

    properties(Access=private)
        FilterHandle;
        FrameFilterHandle;
        UpdateHandle;
        FrameSize;
        OutputDelay;
        CtrlDelay;
        nSections;
        Section0CtrlDelay;
        SectionNValidDelay;
        SectionNCtrlDelay;
        SectionEndCtrlDelay;
        Section0DataDelay;
        SectionNDataDelay;
        SectionNPipeDataDelay;
        SectionEndDataDelay;
        pFimath;
        QuantizedNum;
        QuantizedDen;
        QuantizedScaleValues;
        QuantizedNewNum;
        QuantizedOrigDen;
        NumeratorMap;
        AccumulatorType;
        States;
        NextStates;
        States2;
        NextStates2;
        IntermediateStates;
        NextIntermediateStates;
        NumDelayLine;
        NextNumDelayLine;
        NewNumDelayLine;
        NextNewNumDelayLine;
        StateIdx;
        DenIdx;
        SectionOutType;
        StateType;
        RoundType;
        InType;
        OutType;
        NumSumType;
        NewNumSumType;
    end




    methods

        function obj=BiquadFilter(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','DSP_HDL_Toolbox'))
                    error(message('dsphdl:dsphdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','DSP_HDL_Toolbox');
            end
            setProperties(obj,nargin,varargin{:});
        end


        function set.CustomNumeratorDataType(obj,val)
            validateCustomDataType(obj,'CustomNumeratorDataType',val,{'Property','NumeratorDataTypeSet'});
            obj.CustomNumeratorDataType=val;
        end

        function set.CustomDenominatorDataType(obj,val)
            validateCustomDataType(obj,'CustomDenominatorDataType',val,{'Property','DenominatorDataTypeSet'});
            obj.CustomDenominatorDataType=val;
        end

        function set.CustomScaleValuesDataType(obj,val)
            validateCustomDataType(obj,'CustomScaleValuesDataType',val,{'Property','ScaleValuesDataTypeSet'});
            obj.CustomScaleValuesDataType=val;
        end

        function set.CustomAccumulatorDataType(obj,val)
            validateCustomDataType(obj,'CustomAccumulatorDataType',val,{'Property','AccumulatorDataTypeSet'});
            obj.CustomAccumulatorDataType=val;
        end

        function set.CustomOutputDataType(obj,val)
            validateCustomDataType(obj,'CustomOutputDataType',val,{'Property','OutputDataTypeSet'});
            obj.CustomOutputDataType=val;
        end

        function set.Numerator(obj,value)
            validateattributes(value,...
            {'numeric'},...
            {'finite','real','nonempty','ncols',3},...
            'BiquadFilter','Numerator');
            obj.Numerator=value;
        end

        function set.Denominator(obj,value)
            validateattributes(value,...
            {'numeric'},...
            {'finite','real','nonempty','ncols',3},...
            'BiquadFilter','Denominator');
            obj.Denominator=value;
        end

        function set.ScaleValues(obj,value)
            validateattributes(value,...
            {'numeric'},...
            {'finite','real','nonempty'},...
            'BiquadFilter','ScaleValues');
            obj.ScaleValues=value;
        end
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl
            text=sprintf(['Filter input signal biquad filter.\n\n',...
            'The biquad filter implementation is optimized for HDL code generation.\n']);
            header=matlab.system.display.Header(...
            'Title','Biquad Filter',...
            'Text',text,...
            'ShowSourceLink',false);
        end

        function groups=getPropertyGroupsImpl
            className=mfilename('class');
            mainGroup=matlab.system.display.SectionGroup(className);
            dataTypesGroup=matlab.system.display.internal.DataTypesGroup(className);




            groups=[mainGroup,dataTypesGroup];
        end

        function isVisible=showSimulateUsingImpl




            isVisible=false;
        end
    end

    methods(Access=public)
        function latency=getLatency(obj,varargin)
            nSec=size(obj.Denominator,1);
            switch obj.Structure
            case 'Direct form II'
                delayPerSection=6;
                delayScaleValue0=3;
                delayScaleValueN=2;
                delayOutputReg=1;
            case 'Direct form II transposed'
                delayPerSection=4;
                delayScaleValue0=3;
                delayScaleValueN=2;
                delayOutputReg=1;
            case 'Pipelined feedback form'
                delayScaleValue0=2;
                delayScaleValueN=5;
                delayOutputReg=2;
                pipelevel=4;
                if isempty(obj.FrameSize)
                    if nargin<2||isempty(varargin{1})
                        framesize=1;
                    else
                        framesize=varargin{1};
                    end
                else
                    framesize=obj.FrameSize;
                end
                if framesize>1
                    denomDelay=framesize*pipelevel;
                else
                    denomDelay=pipelevel-1;
                end

                delayPerSection=pipelevel+ceil(log2(3))+pipelevel+ceil(log2(2*framesize*pipelevel-1))+denomDelay-2;
            end
            latency=delayScaleValue0+nSec*delayPerSection+nSec*delayScaleValueN+delayOutputReg;
        end
    end

    methods(Access=protected)
        function setupImpl(obj,varargin)
            coder.extrinsic('dsphdlpipebiquadcoeffs');
            dataIn=varargin{1};
            framesize=numel(dataIn);
            obj.FrameSize=framesize;
            legalSizes=2.^(1:6);
            coder.internal.errorIf(framesize>1&&~any(framesize==legalSizes),'dsphdl:BiquadFilter:FrameSize')

            if isfloat(dataIn)
                obj.pFimath=[];
            else
                obj.pFimath=fimath('RoundingMethod',obj.RoundingMethod,...
                'OverflowAction',obj.OverflowAction);
            end

            nSec=size(obj.Denominator,1);
            obj.nSections=nSec;
            coder.internal.errorIf(nSec~=size(obj.Numerator,1),'dsphdl:BiquadFilter:NumDenSizes');
            coder.internal.errorIf(numel(obj.ScaleValues)>nSec+1,'dsphdl:BiquadFilter:TooManyScaleValues');
            coder.internal.errorIf(~(size(obj.ScaleValues,1)==1||size(obj.ScaleValues,2)==1),'dsphdl:BiquadFilter:TooManyScaleValues');


            if~isfloat(dataIn)
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
                obj.InType=fi(0,T.SignednessBool,T.WordLength,T.FractionLength,obj.pFimath);
            end

            isPiped=0;
            switch obj.Structure
            case 'Direct form II'
                coder.internal.errorIf(framesize>1,'dsphdl:BiquadFilter:FramePipeOnly');
                if isfloat(dataIn)
                    obj.FilterHandle=@scalardoubledf2filter;
                    obj.UpdateHandle=@updateBiquadFilter;
                else
                    obj.FilterHandle=@scalardf2filter;
                    obj.UpdateHandle=@updateBiquadFilter;
                end

            case 'Direct form II transposed'
                coder.internal.errorIf(framesize>1,'dsphdl:BiquadFilter:FramePipeOnly');
                if isfloat(dataIn)
                    obj.FilterHandle=@scalardoubledf2tfilter;
                    obj.UpdateHandle=@updateBiquadFilter;
                else
                    obj.FilterHandle=@scalardf2tfilter;
                    obj.UpdateHandle=@updateBiquadFilter;
                end

            case 'Pipelined feedback form'
                isPiped=1;
                pipelevel=4;



                if isempty(coder.target)
                    [~,~,newnum,newden,~]=...
                    dsphdlpipebiquadcoeffs(obj.Numerator,obj.Denominator,obj.ScaleValues,pipelevel,framesize);
                else
                    [~,~,newnum,newden,~]=...
                    coder.internal.const(dsphdlpipebiquadcoeffs(obj.Numerator,obj.Denominator,obj.ScaleValues,pipelevel,framesize));
                end
                newnum=fliplr(newnum);

                if isfloat(dataIn)
                    if framesize>1
                        obj.FrameFilterHandle=@framedoublepipefilter;
                        obj.UpdateHandle=@updateFramePipeBiquadFilter;
                    else
                        obj.FilterHandle=@scalardoublepipefilter;
                        obj.UpdateHandle=@updatePipeBiquadFilter;
                    end
                else
                    if framesize>1
                        obj.FrameFilterHandle=@framepipefilter;
                        obj.UpdateHandle=@updateFramePipeBiquadFilter;
                    else
                        obj.FilterHandle=@scalarpipefilter;
                        obj.UpdateHandle=@updatePipeBiquadFilter;
                    end
                end
            end


            if~isfloat(dataIn)

                if strcmp(obj.OutputDataType,'Same as first input')
                    obj.RoundType=fi(0,T.SignednessBool,T.WordLength,T.FractionLength,obj.pFimath);
                    obj.OutType=cast(0,'like',dataIn);
                elseif strcmp(obj.OutputDataType,'Full precision')
                    if strcmp(obj.AccumulatorDataType,'Same as first input')
                        obj.RoundType=fi(0,T.SignednessBool,T.WordLength,T.FractionLength,obj.pFimath);
                        obj.OutType=cast(0,'like',dataIn);
                    else
                        Taccum=obj.CustomAccumulatorDataType;
                        obj.OutType=fi(0,Taccum.SignednessBool,Taccum.WordLength,Taccum.FractionLength,obj.pFimath);
                        obj.RoundType=obj.OutType;
                    end
                else
                    Tout=obj.CustomOutputDataType;
                    obj.OutType=fi(0,Tout.SignednessBool,Tout.WordLength,Tout.FractionLength,obj.pFimath);
                    obj.RoundType=obj.OutType;
                end

                if strcmp(obj.AccumulatorDataType,'Same as first input')

                    obj.StateType=fi(0,T.SignednessBool,T.WordLength,T.FractionLength,obj.pFimath);
                else
                    Taccum=obj.CustomAccumulatorDataType;
                    obj.StateType=fi(0,Taccum.SignednessBool,Taccum.WordLength,Taccum.FractionLength,obj.pFimath);
                end
                obj.AccumulatorType=obj.StateType;
                obj.SectionOutType=obj.RoundType;
            else
                obj.SectionOutType=cast(0,'like',dataIn);
                obj.StateType=cast(0,'like',dataIn);
                obj.OutType=cast(0,'like',dataIn);
                obj.RoundType=cast(0,'like',dataIn);
            end


            if isfloat(dataIn)
                if isPiped
                    obj.QuantizedNum=double(obj.Numerator);
                    obj.QuantizedNewNum=double(newnum);
                    obj.QuantizedDen=double(newden(:,2:end));
                    obj.QuantizedOrigDen=double(obj.Denominator(:,2:end));
                else
                    obj.QuantizedNum=double(obj.Numerator);
                    obj.QuantizedNewNum=0;
                    obj.QuantizedDen=double(obj.Denominator(:,2:end));
                    obj.QuantizedOrigDen=double(obj.Denominator(:,2:end));
                end
                temp=double(obj.ScaleValues(:));
                if numel(obj.ScaleValues)<nSec+1
                    obj.QuantizedScaleValues=[temp;ones(nSec-numel(obj.ScaleValues)+1,1)];
                else
                    obj.QuantizedScaleValues=temp;
                end
            else
                if isa(dataIn,'uint8')
                    inputWL=8;
                elseif isa(dataIn,'int8')
                    inputWL=8;
                elseif isa(dataIn,'uint16')
                    inputWL=16;
                elseif isa(dataIn,'int16')
                    inputWL=16;
                elseif isa(dataIn,'uint32')
                    inputWL=32;
                elseif isa(dataIn,'int32')
                    inputWL=32;
                elseif isa(dataIn,'uint64')
                    inputWL=32;
                elseif isa(dataIn,'int64')
                    inputWL=32;
                else
                    inputWL=dataIn.WordLength;
                end


                if strcmp(obj.NumeratorDataType,'Same word length as input')
                    obj.QuantizedNum=fi(obj.Numerator,[],inputWL);
                else
                    obj.QuantizedNum=fi(obj.Numerator,obj.CustomNumeratorDataType);
                end


                if strcmp(obj.DenominatorDataType,'Same word length as input')
                    if isPiped
                        obj.QuantizedDen=fi(newden(:,2:end),1,inputWL);
                        obj.QuantizedOrigDen=fi(obj.Denominator(:,2:end),1,inputWL);
                        obj.QuantizedNewNum=fi(newnum,1,obj.QuantizedDen.WordLength);
                    else
                        obj.QuantizedDen=fi(obj.Denominator(:,2:end),1,inputWL);
                        obj.QuantizedOrigDen=fi(obj.Denominator(:,2:end),1,inputWL);
                        obj.QuantizedNewNum=[];
                    end
                else
                    if isPiped
                        obj.QuantizedDen=fi(newden(:,2:end),obj.CustomDenominatorDataType);
                        obj.QuantizedOrigDen=fi(obj.Denominator(:,2:end),obj.CustomDenominatorDataType);
                        obj.QuantizedNewNum=fi(newnum,1,obj.CustomDenominatorDataType.WordLength);
                    else
                        obj.QuantizedDen=fi(obj.Denominator(:,2:end),obj.CustomDenominatorDataType);
                        obj.QuantizedOrigDen=fi(obj.Denominator(:,2:end),obj.CustomDenominatorDataType);
                        obj.QuantizedNewNum=[];
                    end
                end

                if strcmp(obj.ScaleValuesDataType,'Same word length as input')
                    tempQuantizedScaleValues=fi(obj.ScaleValues(:),[],inputWL);
                else
                    tempQuantizedScaleValues=fi(obj.ScaleValues(:),obj.CustomScaleValuesDataType);
                end

                coder.internal.errorIf(numel(tempQuantizedScaleValues)>nSec+1,'dsphdl:BiquadFilter:TooManyScaleValues');

                obj.QuantizedScaleValues=zeros(nSec+1,1,'like',tempQuantizedScaleValues);
                if numel(obj.ScaleValues)<obj.nSections+1
                    obj.QuantizedScaleValues(:)=[tempQuantizedScaleValues;ones(nSec-numel(obj.ScaleValues)+1,1,...
                    'like',tempQuantizedScaleValues)];
                else
                    obj.QuantizedScaleValues(:)=tempQuantizedScaleValues;
                end
            end

            if any(obj.QuantizedScaleValues==0)
                coder.internal.warning('dsphdl:BiquadFilter:ZeroScaleValues');
            end

            for ii=1:size(obj.QuantizedNum,1)
                if all(obj.QuantizedNum(ii,:)==0)
                    coder.internal.warning('dsphdl:BiquadFilter:ZeroNumerator');
                end
            end

            if isPiped
                nzDen=newden(:,2:end)~=0;
                if any(obj.QuantizedDen(nzDen)==0)
                    coder.internal.warning('dsphdl:BiquadFilter:ZeroDenominator');
                end
                nzOrigDen=obj.Denominator(:,2:end)~=0;
                if any(obj.QuantizedOrigDen(nzOrigDen)==0)
                    coder.internal.warning('dsphdl:BiquadFilter:ZeroDenominator');
                end
            else
                nzDen=obj.Denominator(:,2:end)~=0;
                if any(obj.QuantizedDen(nzDen)==0)
                    coder.internal.warning('dsphdl:BiquadFilter:ZeroDenominator');
                end
            end


            switch obj.Structure
            case 'Direct form II'
                delayScaleValue0=3;
                delayScaleValueN=2;
                delayOutputReg=1;
                delayPerSection=6;
                obj.States=zeros(nSec,2,'like',obj.AccumulatorType);
                obj.NextStates=zeros(nSec,2,'like',obj.AccumulatorType);
            case 'Direct form II transposed'
                delayScaleValue0=3;
                delayScaleValueN=2;
                delayOutputReg=1;
                delayPerSection=4;
                if isfloat(dataIn)
                    stateFi=0.0;
                else
                    WL=max(obj.QuantizedNum.WordLength+obj.SectionOutType.WordLength,...
                    obj.QuantizedDen.WordLength+obj.SectionOutType.WordLength)+2;
                    FL=max(obj.QuantizedNum.FractionLength+obj.SectionOutType.FractionLength,...
                    obj.QuantizedDen.FractionLength+obj.SectionOutType.FractionLength);
                    stateFi=fi(0,1,WL,FL);
                end
                obj.States=zeros(nSec,2,'like',stateFi);
                obj.NextStates=zeros(nSec,2,'like',stateFi);
            case 'Pipelined feedback form'

                delayScaleValue0=2;
                delayScaleValueN=5;
                delayOutputReg=1;
                if framesize>1
                    denomDelay=framesize*pipelevel;
                else
                    denomDelay=pipelevel-1;
                end
                delayPerSection=pipelevel+ceil(log2(3))+pipelevel+ceil(log2(2*framesize*pipelevel-1))+denomDelay;

                if isfloat(dataIn)
                    stateFi=0.0;
                else
                    IntBitsSection=obj.SectionOutType.WordLength-obj.SectionOutType.FractionLength;
                    IntBitsQDen=obj.QuantizedDen.WordLength-obj.QuantizedDen.FractionLength;
                    FL=max(obj.QuantizedDen.FractionLength,obj.SectionOutType.FractionLength);
                    WL=max(IntBitsSection,IntBitsQDen)+2+FL;
                    stateFi=fi(0,1,WL,FL);
                end
                obj.DenIdx=[framesize*pipelevel,2*framesize*pipelevel];
                obj.States=zeros(nSec,2*pipelevel+1,'like',stateFi);
                obj.States2=zeros(nSec,2*pipelevel+1,'like',stateFi);
                obj.NextStates=zeros(nSec,2*pipelevel+1,'like',stateFi);
                obj.NextStates2=zeros(nSec,2*pipelevel+1,'like',stateFi);
                obj.IntermediateStates=zeros(nSec,1,'like',stateFi);
                obj.NextIntermediateStates=zeros(nSec,1,'like',stateFi);
                if framesize==1
                    effectiveSize=3;
                else
                    effectiveSize=framesize;
                end

                obj.NumDelayLine=zeros(nSec,effectiveSize,'like',obj.SectionOutType);
                obj.NextNumDelayLine=zeros(nSec,effectiveSize,'like',obj.SectionOutType);
                if isfloat(dataIn)
                    obj.NumSumType=0.0;
                    obj.NewNumSumType=0.0;
                else
                    tmpNum=obj.NumDelayLine(1)*obj.QuantizedNum(1,1);
                    obj.NumSumType=fi(0,1,tmpNum.WordLength+ceil(log2(size(obj.QuantizedNum,2))),tmpNum.FractionLength);
                    tmpNewNum=obj.NumSumType*obj.QuantizedNewNum(1,1);
                    obj.NewNumSumType=fi(0,1,tmpNewNum.WordLength+ceil(log2(size(obj.QuantizedNewNum,2))),tmpNewNum.FractionLength);
                end
                obj.NewNumDelayLine=zeros(nSec,2*framesize*pipelevel-1,'like',obj.NumSumType);
                obj.NextNewNumDelayLine=zeros(nSec,2*framesize*pipelevel-1,'like',obj.NumSumType);
                obj.StateIdx=[2*pipelevel+1-3,pipelevel+1-3];
            end

            delaySize=delayScaleValue0+nSec*delayPerSection+nSec*delayScaleValueN+delayOutputReg;

            obj.Section0CtrlDelay=false(1,delayScaleValue0);
            obj.SectionNValidDelay=false(nSec,delayPerSection);
            obj.SectionNCtrlDelay=false(nSec,delayScaleValueN);
            obj.SectionEndCtrlDelay=false(1,delayOutputReg);

            if framesize==1
                obj.Section0DataDelay=zeros(1,delayScaleValue0,'like',obj.SectionOutType);
                obj.SectionNDataDelay=zeros(nSec,delayPerSection,'like',obj.SectionOutType);
                obj.SectionNPipeDataDelay=zeros(nSec,delayScaleValueN,'like',obj.SectionOutType);
                obj.SectionEndDataDelay=zeros(1,delayOutputReg,'like',obj.SectionOutType);
            else
                obj.Section0DataDelay=zeros(framesize,delayScaleValue0,'like',obj.SectionOutType);
                obj.SectionNDataDelay=zeros(framesize,nSec,delayPerSection,'like',obj.SectionOutType);
                obj.SectionNPipeDataDelay=zeros(framesize,nSec,delayScaleValueN,'like',obj.SectionOutType);
                obj.SectionEndDataDelay=zeros(framesize,delayOutputReg,'like',obj.SectionOutType);
            end

            obj.CtrlDelay=false(1,delaySize);
            if framesize==1
                obj.OutputDelay=zeros(framesize,delaySize,'like',obj.SectionOutType);
            else
                obj.OutputDelay=zeros(framesize,nSec*delayPerSection+1,'like',obj.SectionOutType);
            end
        end

        function[varargout]=outputImpl(obj,varargin)

            if strcmp(obj.Structure,'Pipelined feedback form')
                currentOut=obj.SectionEndDataDelay(:,end);
                forceZero=~obj.SectionEndCtrlDelay(1,end);
            else
                currentOut=obj.OutputDelay(:,end);
                forceZero=~obj.CtrlDelay(1,end);
            end
            tmpPreOut=cast(currentOut,'like',obj.RoundType);
            tmpOut=cast(tmpPreOut,'like',obj.OutType);
            if forceZero
                tmpOut(:)=0;
            end
            varargout{1}=tmpOut;
            varargout{2}=~forceZero;
        end

        function updateImpl(obj,varargin)

            obj.UpdateHandle(obj,varargin{:});
        end

        function resetImpl(obj)
            for ii=1:size(obj.CtrlDelay,2)
                obj.CtrlDelay(1,ii)=0;
            end

            for ii=1:size(obj.OutputDelay,2)
                obj.OutputDelay(:,ii)=0;
            end
            obj.Section0CtrlDelay(:)=false;
            obj.SectionEndCtrlDelay(:)=false;
            obj.SectionNValidDelay(:)=false;
            obj.SectionNCtrlDelay(:)=false;
            obj.Section0DataDelay(:)=0;
            obj.SectionNDataDelay(:)=0;
            obj.SectionNPipeDataDelay(:)=0;
            obj.SectionEndDataDelay(:)=0;
            obj.States(:)=0;
            obj.States2(:)=0;
            obj.NextStates(:)=0;
            obj.NumDelayLine(:)=0;
            obj.NextNumDelayLine(:)=0;
            obj.NewNumDelayLine(:)=0;
            obj.NextNewNumDelayLine(:)=0;
            obj.IntermediateStates(:)=0;
        end

        function flag=getExecutionSemanticsImpl(~)



            flag={'Classic','Synchronous'};

        end


        function validateInputsImpl(~,varargin)
            if isempty(coder.target)||~eml_ambiguous_types
                validateattributes(varargin{1},{'numeric','embedded.fi'},...
                {'vector','column','real'},'BiquadFilter','data');
                validateattributes(varargin{2},{'logical'},...
                {'scalar'},'BiquadFilter','valid');
            end
            framesize=numel(varargin{1});
            legalSizes=2.^(1:6);
            coder.internal.errorIf(framesize>1&&~any(framesize==legalSizes),'dsphdl:BiquadFilter:FrameSize')
        end

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case 'CustomNumeratorDataType'
                if~strcmp(obj.NumeratorDataType,'Custom')
                    flag=true;
                end
            case 'CustomDenominatorDataType'
                if~strcmp(obj.DenominatorDataType,'Custom')
                    flag=true;
                end
            case 'CustomScaleValuesDataType'
                if~strcmp(obj.ScaleValuesDataType,'Custom')
                    flag=true;
                end
            case 'CustomAccumulatorDataType'
                if~strcmp(obj.AccumulatorDataType,'Custom')
                    flag=true;
                end
            case{'CustomOutputDataType'}
                if~strcmp(obj.OutputDataType,'Custom')
                    flag=true;
                end
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

        function varargout=getOutputDataTypeImpl(obj)
            intype=propagatedInputDataType(obj,1);
            validtype=propagatedInputDataType(obj,2);
            if isempty(intype)
                dt1=[];
            elseif(ischar(intype)||(isstring(intype)&&isscalar(intype)))&&(strcmp(intype,'double')||strcmp(intype,'single'))
                dt1=intype;
            elseif strcmp(obj.OutputDataType,'Same as first input')
                dt1=intype;
            elseif strcmp(obj.OutputDataType,'Full precision')
                idt=int2fitype(obj,intype);
                switch obj.AccumulatorDataType
                case 'Same as first input'
                    dt1=idt;
                case 'Custom'
                    idt=obj.CustomAccumulatorDataType;
                    dt1=numerictype('Signedness',idt.Signedness,...
                    'WordLength',idt.WordLength,...
                    'FractionLength',idt.FractionLength);
                end
            else
                dt1=obj.CustomOutputDataType;
            end
            varargout{1}=dt1;
            varargout{2}=validtype;
        end

        function varargout=isOutputFixedSizeImpl(~)
            varargout{1}=true;
            varargout{2}=true;
        end

        function varargout=getOutputSizeImpl(obj)
            inSize=propagatedInputSize(obj,1);
            varargout{1}=inSize;
            varargout{2}=1;
        end

        function varargout=isOutputComplexImpl(obj,varargin)
            varargout{1}=propagatedInputComplexity(obj,1);
            varargout{2}=false;
        end

        function num=getNumInputsImpl(~)
            num=2;
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end

        function varargout=getOutputNamesImpl(~)
            varargout{1}='data';
            varargout{2}='valid';
        end

        function varargout=getInputNamesImpl(~)
            varargout{1}='data';
            varargout{2}='valid';
        end

        function icon=getIconImpl(obj)
            inVecSize=propagatedInputSize(obj,1);
            if isempty(inVecSize)
                latency=getLatency(obj);
            else
                latency=getLatency(obj,prod(inVecSize));
            end
            if isempty(latency)
                icon=sprintf('Biquad Filter\nLatency = --');
            else
                icon=sprintf('Biquad Filter\nLatency = %d',latency);
            end
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked

                s.FilterHandle=obj.FilterHandle;
                s.FrameFilterHandle=obj.FrameFilterHandle;
                s.UpdateHandle=obj.UpdateHandle;
                s.FrameSize=obj.FrameSize;
                s.CtrlDelay=obj.CtrlDelay;
                s.OutputDelay=obj.OutputDelay;
                s.nSections=obj.nSections;
                s.Section0CtrlDelay=obj.Section0CtrlDelay;
                s.SectionNValidDelay=obj.SectionNValidDelay;
                s.SectionNCtrlDelay=obj.SectionNCtrlDelay;
                s.SectionEndCtrlDelay=obj.SectionEndCtrlDelay;
                s.Section0DataDelay=obj.Section0DataDelay;
                s.SectionNDataDelay=obj.SectionNDataDelay;
                s.SectionNPipeDataDelay=obj.SectionNPipeDataDelay;
                s.SectionEndDataDelay=obj.SectionEndDataDelay;
                s.pFimath=obj.pFimath;
                s.QuantizedNum=obj.QuantizedNum;
                s.QuantizedDen=obj.QuantizedDen;
                s.QuantizedScaleValues=obj.QuantizedScaleValues;
                s.QuantizedNewNum=obj.QuantizedNewNum;
                s.QuantizedOrigDen=obj.QuantizedOrigDen;
                s.AccumulatorType=obj.AccumulatorType;
                s.NumeratorMap=obj.NumeratorMap;
                s.States=obj.States;
                s.NextStates=obj.NextStates;
                s.States2=obj.States2;
                s.NextStates2=obj.NextStates2;
                s.IntermediateStates=obj.IntermediateStates;
                s.NextIntermediateStates=obj.NextIntermediateStates;
                s.NumDelayLine=obj.NumDelayLine;
                s.NextNumDelayLine=obj.NextNumDelayLine;
                s.NewNumDelayLine=obj.NewNumDelayLine;
                s.NextNewNumDelayLine=obj.NextNewNumDelayLine;
                s.StateIdx=obj.StateIdx;
                s.DenIdx=obj.DenIdx;
                s.SectionOutType=obj.SectionOutType;
                s.StateType=obj.StateType;
                s.RoundType=obj.RoundType;
                s.InType=obj.InType;
                s.OutType=obj.OutType;
                s.NumSumType=obj.NumSumType;
                s.NewNumSumType=obj.NewNumSumType;
            end
        end

        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for i=1:numel(fn)
                obj.(fn{i})=s.(fn{i});
            end
        end

        function flag=isInputComplexityMutableImpl(~,~)

            flag=true;
        end

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

    end


    methods(Access=protected)

        function out=scalardoubledf2filter(obj,input)
            sectionoutput=input*obj.QuantizedScaleValues(1);
            for sec=1:obj.nSections
                a2=-obj.States(sec,1)*obj.QuantizedDen(sec,1);
                a3=-obj.States(sec,2)*obj.QuantizedDen(sec,2);
                a23=a2+a3;
                a23i=a23+sectionoutput;
                statein=a23i;
                b1=statein*obj.QuantizedNum(sec,1);
                b2=obj.States(sec,1)*obj.QuantizedNum(sec,2);
                b3=obj.States(sec,2)*obj.QuantizedNum(sec,3);
                b23=b2+b3;
                b123=b1+b23;
                sectionoutput=b123*obj.QuantizedScaleValues(sec+1);

                obj.NextStates(sec,2)=obj.States(sec,1);
                obj.NextStates(sec,1)=statein;
            end
            out=sectionoutput;
        end

        function out=scalardoubledf2tfilter(obj,input)
            sectionoutput=input*obj.QuantizedScaleValues(1);
            for sec=1:obj.nSections
                b1=sectionoutput*obj.QuantizedNum(sec,1);
                b2=sectionoutput*obj.QuantizedNum(sec,2);
                b3=sectionoutput*obj.QuantizedNum(sec,3);
                b1add=b1+obj.States(sec,1);
                b1addquant=b1add;
                b2add=b2+obj.States(sec,2);
                a2=-b1addquant*obj.QuantizedDen(sec,1);
                a3=-b1addquant*obj.QuantizedDen(sec,2);
                sectionoutput=b1addquant*obj.QuantizedScaleValues(sec+1);

                obj.NextStates(sec,2)=a3+b3;
                obj.NextStates(sec,1)=a2+b2add;
            end
            out=sectionoutput;
        end

        function out=scalardf2filter(obj,input)
            quantizedinput=cast(input,'like',obj.InType);
            sectionoutput=obj.SectionOutType;
            statein=obj.StateType;
            sectionoutput(:)=quantizedinput*obj.QuantizedScaleValues(1);
            for sec=1:obj.nSections
                a2=obj.States(sec,1)*-obj.QuantizedDen(sec,1);
                a3=obj.States(sec,2)*-obj.QuantizedDen(sec,2);
                a23=a2+a3;
                a23i=a23+sectionoutput;
                statein(:)=a23i;
                b1=statein*obj.QuantizedNum(sec,1);
                b2=obj.States(sec,1)*obj.QuantizedNum(sec,2);
                b3=obj.States(sec,2)*obj.QuantizedNum(sec,3);
                b23=b2+b3;
                b123=b1+b23;
                sectionoutput(:)=b123;
                sectionoutput(:)=sectionoutput*obj.QuantizedScaleValues(sec+1);

                obj.NextStates(sec,2)=obj.States(sec,1);
                obj.NextStates(sec,1)=statein;
            end
            out=sectionoutput;
        end

        function out=scalardf2tfilter(obj,input)
            quantizedinput=cast(input,'like',obj.InType);
            sectionoutput=obj.SectionOutType;
            b1addquant=obj.SectionOutType;
            sectionoutput(:)=quantizedinput*obj.QuantizedScaleValues(1);
            for sec=1:obj.nSections
                b1=sectionoutput*obj.QuantizedNum(sec,1);
                b2=sectionoutput*obj.QuantizedNum(sec,2);
                b3=sectionoutput*obj.QuantizedNum(sec,3);
                b1add=b1+obj.States(sec,1);
                b1addquant(:)=b1add;
                b2add=b2+obj.States(sec,2);
                a2=b1addquant*-obj.QuantizedDen(sec,1);
                a3=b1addquant*-obj.QuantizedDen(sec,2);
                sectionoutput(:)=b1addquant*obj.QuantizedScaleValues(sec+1);

                obj.NextStates(sec,2)=a3+b3;
                obj.NextStates(sec,1)=a2+b2add;
            end
            out=sectionoutput;
        end

        function out=scalardoublepipefilter(obj,input)
            sectionoutput=input*obj.QuantizedScaleValues(1);
            idx=obj.StateIdx;
            for sec=1:obj.nSections

                b1=sectionoutput*obj.QuantizedNum(sec,1);
                b2=obj.NumDelayLine(sec,3)*obj.QuantizedNum(sec,2);
                b3=obj.NumDelayLine(sec,2)*obj.QuantizedNum(sec,3);
                b12add=b1+b2;
                numout=b12add+b3;

                newnumout=obj.QuantizedNewNum(sec,end)*numout;
                for nn=1:numel(obj.NewNumDelayLine(sec,:))-1
                    newnumout=newnumout+obj.QuantizedNewNum(sec,nn)*obj.NewNumDelayLine(sec,nn);
                end

                a2=obj.States(sec,idx(1))*-obj.QuantizedDen(sec,4);
                a3=obj.States(sec,idx(2))*-obj.QuantizedDen(sec,8);
                a23add=a2+a3;
                numden=newnumout+a23add;


                temp=obj.NewNumDelayLine(sec,2:end-1);
                obj.NextNewNumDelayLine(sec,:)=[[temp,numout],0];
                obj.NextStates(sec,:)=[obj.States(sec,2:end),numden];
                obj.NextNumDelayLine(sec,:)=[obj.NumDelayLine(sec,2:end),sectionoutput];
                sectionoutput=numden*obj.QuantizedScaleValues(sec+1);
            end
            out=sectionoutput;
        end


        function out=scalarpipefilter(obj,input)
            quantizedinput=cast(input,'like',obj.InType);
            sectionoutput=obj.SectionOutType;
            sectionoutput(:)=quantizedinput*obj.QuantizedScaleValues(1);
            idx=obj.StateIdx;
            for sec=1:obj.nSections

                b1=sectionoutput*obj.QuantizedNum(sec,1);
                b2=obj.NumDelayLine(sec,3)*obj.QuantizedNum(sec,2);
                b3=obj.NumDelayLine(sec,2)*obj.QuantizedNum(sec,3);
                b12add=cast(0,'like',obj.NumSumType);
                b12add(:)=b1+b2;
                numout=cast(0,'like',obj.NumSumType);
                numout(:)=b12add+b3;

                newnumout=cast(obj.QuantizedNewNum(sec,end)*numout,...
                'like',obj.NewNumSumType);
                for nn=1:numel(obj.NewNumDelayLine(sec,:))-1
                    newnumout(:)=newnumout+obj.QuantizedNewNum(sec,nn)*obj.NewNumDelayLine(sec,nn);
                end

                a2=obj.States(sec,idx(1))*-obj.QuantizedDen(sec,4);
                a3=obj.States(sec,idx(2))*-obj.QuantizedDen(sec,8);

                a23add=a2+a3;
                numden=cast(0,'like',obj.RoundType);
                numden(:)=newnumout+a23add;

                obj.NextNewNumDelayLine(sec,:)=[[obj.NewNumDelayLine(sec,2:end-1),numout],0];
                obj.NextStates(sec,:)=[obj.States(sec,2:end),numden];
                obj.NextNumDelayLine(sec,:)=[obj.NumDelayLine(sec,2:end),sectionoutput];
                sectionoutput(:)=numden;
                sectionoutput(:)=sectionoutput*obj.QuantizedScaleValues(sec+1);
            end
            out=sectionoutput;
        end

        function out=framedoublepipefilter(obj,input)
            sectionoutput=input.*obj.QuantizedScaleValues(1);
            idx=obj.StateIdx;
            didx=obj.DenIdx;
            for sec=1:obj.nSections

                numData=[obj.NumDelayLine(sec,:),sectionoutput.'];
                firstData=obj.FrameSize;
                numout=zeros(1,obj.FrameSize);
                for samp=1:obj.FrameSize
                    b1=numData(firstData+samp).*obj.QuantizedNum(sec,1);
                    b2=numData(firstData+samp-1).*obj.QuantizedNum(sec,2);
                    b3=numData(firstData+samp-2).*obj.QuantizedNum(sec,3);
                    b12add=b1+b2;
                    numout(samp)=b12add+b3;
                end

                newNumData=[obj.NewNumDelayLine(sec,:),numout];
                newnumout=obj.QuantizedNewNum(sec,end)*numout(1);
                newnumout2=obj.QuantizedNewNum(sec,end)*numout(end);
                for nn=1:(size(obj.QuantizedNewNum,2)-1)
                    newnumout=newnumout+obj.QuantizedNewNum(sec,nn).*newNumData(nn+1);
                    newnumout2=newnumout2+obj.QuantizedNewNum(sec,nn).*newNumData(nn+obj.FrameSize);
                end

                a2=obj.States(sec,idx(1))*-obj.QuantizedDen(sec,didx(1));
                a3=obj.States(sec,idx(2))*-obj.QuantizedDen(sec,didx(2));
                a23add=a2+a3;
                numden=newnumout+a23add;

                a22=obj.States2(sec,idx(1))*-obj.QuantizedDen(sec,didx(1));
                a32=obj.States2(sec,idx(2))*-obj.QuantizedDen(sec,didx(2));
                a23add2=a22+a32;
                numden2=newnumout2+a23add2;

                outFrame=zeros(obj.FrameSize,1);
                outFrame(1)=numden;
                outFrame(end)=numden2;
                for ii=2:obj.FrameSize-1
                    if ii==2
                        outFrame(ii)=outFrame(ii-1)*-obj.QuantizedOrigDen(sec,1)...
                        +obj.IntermediateStates(sec)*-obj.QuantizedOrigDen(sec,2)+numout(ii);
                    else
                        outFrame(ii)=outFrame(ii-1)*-obj.QuantizedOrigDen(sec,1)...
                        +outFrame(ii-2)*-obj.QuantizedOrigDen(sec,2)+numout(ii);
                    end
                end

                obj.NextNewNumDelayLine(sec,:)=[obj.NewNumDelayLine(sec,1+obj.FrameSize:end),numout];
                obj.NextStates(sec,:)=[obj.States(sec,2:end),numden];
                obj.NextStates2(sec,:)=[obj.States2(sec,2:end),numden2];
                obj.NextNumDelayLine(sec,:)=[obj.NumDelayLine(sec,obj.FrameSize+1:end),sectionoutput.'];
                obj.NextIntermediateStates(sec,:)=outFrame(end);
                sectionoutput(:)=outFrame.*obj.QuantizedScaleValues(sec+1);
            end
            out=sectionoutput;
        end

        function out=framepipefilter(obj,input)
            sectionoutput=zeros(size(input,1),1,'like',obj.SectionOutType);
            sectionoutput(:)=input.*obj.QuantizedScaleValues(1);
            idx=obj.StateIdx;
            didx=obj.DenIdx;
            for sec=1:obj.nSections

                numData=[obj.NumDelayLine(sec,:),sectionoutput'];
                firstData=obj.FrameSize;
                numout=zeros(1,numel(input),'like',obj.NumSumType);
                for samp=1:obj.FrameSize
                    b1=numData(firstData+samp).*obj.QuantizedNum(sec,1);
                    b2=numData(firstData+samp-1).*obj.QuantizedNum(sec,2);
                    b3=numData(firstData+samp-2).*obj.QuantizedNum(sec,3);
                    b12add=cast(0,'like',obj.NumSumType);
                    b12add(:)=b1+b2;
                    numout(samp)=b12add+b3;
                end

                newNumData=[obj.NewNumDelayLine(sec,:),numout];
                newnumout=cast(obj.QuantizedNewNum(sec,end)*numout(1),'like',obj.NewNumSumType);
                newnumout2=cast(obj.QuantizedNewNum(sec,end)*numout(end),'like',obj.NewNumSumType);
                for nn=1:(size(obj.QuantizedNewNum,2)-1)
                    newnumout(:)=newnumout+obj.QuantizedNewNum(sec,nn).*newNumData(nn+1);
                    newnumout2(:)=newnumout2+obj.QuantizedNewNum(sec,nn).*newNumData(nn+obj.FrameSize);
                end

                a2=obj.States(sec,idx(1))*-obj.QuantizedDen(sec,didx(1));
                a3=obj.States(sec,idx(2))*-obj.QuantizedDen(sec,didx(2));

                a23add=a2+a3;
                numden=cast(0,'like',obj.RoundType);
                numden(:)=newnumout+a23add;

                a22=obj.States2(sec,idx(1))*-obj.QuantizedDen(sec,didx(1));
                a32=obj.States2(sec,idx(2))*-obj.QuantizedDen(sec,didx(2));

                a23add2=a22+a32;
                numden2=cast(0,'like',obj.RoundType);
                numden2(:)=newnumout2+a23add2;

                outFrame=zeros(numel(input),1,'like',obj.RoundType);
                outFrame(1)=numden;
                outFrame(end)=numden2;
                for ii=2:obj.FrameSize-1
                    if ii==2
                        outFrame(ii)=outFrame(ii-1)*-obj.QuantizedOrigDen(sec,1)+...
                        obj.IntermediateStates(sec)*-obj.QuantizedOrigDen(sec,2)+numout(ii);
                    else
                        outFrame(ii)=outFrame(ii-1)*-obj.QuantizedOrigDen(sec,1)+...
                        outFrame(ii-2)*-obj.QuantizedOrigDen(sec,2)+numout(ii);
                    end
                end

                obj.NextNewNumDelayLine(sec,:)=[obj.NewNumDelayLine(sec,1+obj.FrameSize:end),numout];
                obj.NextStates(sec,:)=[obj.States(sec,2:end),numden];
                obj.NextStates2(sec,:)=[obj.States2(sec,2:end),numden2];
                obj.NextNumDelayLine(sec,:)=[obj.NumDelayLine(sec,obj.FrameSize+1:end),sectionoutput.'];
                obj.NextIntermediateStates(sec,:)=outFrame(end);
                sectionoutput(:)=outFrame.*obj.QuantizedScaleValues(sec+1);
            end
            out=sectionoutput;
        end


        function updateBiquadFilter(obj,varargin)
            out=obj.FilterHandle(obj,varargin{1});
            obj.CtrlDelay=[varargin{2},obj.CtrlDelay(:,1:end-1)];
            obj.OutputDelay=[out,obj.OutputDelay(:,1:end-1)];

            if varargin{2}
                for sec=1:obj.nSections
                    obj.States(sec,1)=obj.NextStates(sec,1);
                    obj.States(sec,2)=obj.NextStates(sec,2);
                end
            end
        end

        function updatePipeBiquadFilter(obj,varargin)
            out=obj.FilterHandle(obj,varargin{1});
            validIn=varargin{2};
            obj.SectionEndCtrlDelay=[obj.SectionNCtrlDelay(end,end),obj.SectionEndCtrlDelay(1,1:end-1)];
            obj.SectionEndDataDelay=[obj.SectionNPipeDataDelay(end,end),obj.SectionEndDataDelay(1,1:end-1)];
            validProp=obj.Section0CtrlDelay(1,end);
            dataProp=obj.Section0DataDelay(1,end);
            for sec=1:obj.nSections
                if validProp
                    obj.SectionNValidDelay(sec,:)=[validProp,obj.SectionNValidDelay(sec,1:end-1)];
                    obj.SectionNDataDelay(sec,:)=[dataProp,obj.SectionNDataDelay(sec,1:end-1)];
                end
                obj.SectionNCtrlDelay(sec,:)=[(obj.SectionNValidDelay(sec,end)&validProp),obj.SectionNCtrlDelay(sec,1:end-1)];
                obj.SectionNPipeDataDelay(sec,:)=[obj.SectionNDataDelay(sec,end),obj.SectionNPipeDataDelay(sec,1:end-1)];
                validProp=obj.SectionNCtrlDelay(sec,end);
                dataProp=obj.SectionNPipeDataDelay(sec,end);
            end
            obj.Section0CtrlDelay=[validIn,obj.Section0CtrlDelay(1,1:end-1)];
            obj.Section0DataDelay=[out,obj.Section0DataDelay(1,1:end-1)];

            if varargin{2}
                obj.OutputDelay=[out,obj.OutputDelay(:,1:end-1)];
                for sec=1:obj.nSections
                    obj.States(sec,:)=obj.NextStates(sec,:);
                    obj.States2(sec,:)=obj.NextStates2(sec,:);
                    obj.IntermediateStates(sec,:)=obj.NextIntermediateStates(sec,:);
                    obj.NumDelayLine(sec,:)=obj.NextNumDelayLine(sec,:);
                    obj.NewNumDelayLine(sec,:)=obj.NextNewNumDelayLine(sec,:);
                end
            end
        end


        function updateFramePipeBiquadFilter(obj,varargin)
            out=obj.FrameFilterHandle(obj,varargin{1});
            validIn=varargin{2};
            obj.SectionEndCtrlDelay=[obj.SectionNCtrlDelay(end,end),obj.SectionEndCtrlDelay(1,1:end-1)];
            obj.SectionEndDataDelay=[obj.SectionNPipeDataDelay(:,end,end),obj.SectionEndDataDelay(:,1:end-1)];
            validProp=obj.Section0CtrlDelay(1,end);
            dataProp=obj.Section0DataDelay(:,end);
            for sec=1:obj.nSections
                if validProp
                    obj.SectionNValidDelay(sec,:)=[validProp,obj.SectionNValidDelay(sec,1:end-1)];

                    for ii=size(obj.SectionNDataDelay,3):-1:2
                        obj.SectionNDataDelay(:,sec,ii)=obj.SectionNDataDelay(:,sec,ii-1);
                    end
                    obj.SectionNDataDelay(:,sec,1)=dataProp;
                end
                obj.SectionNCtrlDelay(sec,:)=[(obj.SectionNValidDelay(sec,end)&validProp),obj.SectionNCtrlDelay(sec,1:end-1)];

                for ii=size(obj.SectionNPipeDataDelay,3):-1:2
                    obj.SectionNPipeDataDelay(:,sec,ii)=obj.SectionNPipeDataDelay(:,sec,ii-1);
                end
                obj.SectionNPipeDataDelay(:,sec,1)=obj.SectionNDataDelay(:,sec,end);
                validProp=obj.SectionNCtrlDelay(sec,end);
                dataProp=obj.SectionNPipeDataDelay(:,sec,end);
            end
            obj.Section0CtrlDelay=[validIn,obj.Section0CtrlDelay(1,1:end-1)];
            obj.Section0DataDelay=[out,obj.Section0DataDelay(:,1:end-1)];

            if varargin{2}
                obj.OutputDelay=[out,obj.OutputDelay(:,1:end-1)];
                for sec=1:obj.nSections
                    obj.States(sec,:)=obj.NextStates(sec,:);
                    obj.States2(sec,:)=obj.NextStates2(sec,:);
                    obj.IntermediateStates(sec,:)=obj.NextIntermediateStates(sec,:);
                    obj.NumDelayLine(sec,:)=obj.NextNumDelayLine(sec,:);
                    obj.NewNumDelayLine(sec,:)=obj.NextNewNumDelayLine(sec,:);
                end
            end
        end


    end

end
