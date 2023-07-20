classdef(Hidden=true)FilterVisualizerBaseWebScope<dsp.webscopes.internal.BaseWebScope




    properties(Dependent)




        SampleRate;




        FFTLength;




        FrequencyRange;




        MagnitudeDisplay;



        XScale;



        PlotType;












        AxesScaling;








        MaximizeAxes;



        PlotAsMagnitudePhase;




        Title(:,:)char;



        YLimits;





        ShowLegend;







        FilterNames;



        ShowGrid;






        UpperMask;






        LowerMask;
    end

    properties(Dependent,Hidden,AbortSet)



        MaskStatus;




        NormalizedFrequency;

        FrequencyVector;
    end

    properties(Constant,Hidden)
        MagnitudeDisplaySet={'Magnitude','Magnitude (dB)','Magnitude squared'};
        XScaleSet={'Linear','Log'};
        PlotTypeSet={'Stem','Line','Stairs'};
        AxesScalingSet={'Auto','Updates','Manual','OnceAtStop'};
        MaximizeAxesSet={'Auto','On','Off'};
        MaskStatusSet={'Pass','Fail','None'};
    end

    properties(Hidden)


        FreqzFcn=@dsp.webscopes.FilterVisualizerBaseWebScope.computefreqz;
    end

    properties(Access=private)

        pFrequencyResponse;

        pUserInput;

        pObjectFlag;

        pPropValues;

        pChangedInputs;


        pResponseAddress;

pLocalUpdateRequested

        pUpperMask=Inf;

        pLowerMask=-Inf;
    end




    methods


        function this=FilterVisualizerBaseWebScope(varargin)


            this@dsp.webscopes.internal.BaseWebScope(...
            'TimeBased',false,...
            'Name',getString(message('shared_dspwebscopes:filtervisualizer:windowName')),...
            'HasStatusBar',false,...
            'Position',utils.getDefaultWebWindowPosition([800,500]),...
            'PlotType','Line',...
            'Tag','DynamicFilterVisualizer',...
            'DefaultLegendLabel','Filter',...
            varargin{:});

            this.NeedsTimedBuffer=false;

            updateFrequencyRange(this);

            this.pLocalUpdateRequested=event.listener(this.MessageHandler,'LocalUpdateRequested',@this.localUpdate);
        end

        function step(this,varargin)














            if nargin<2



                localUpdateFlag=false;
            elseif islogical(varargin{1})
                localUpdateFlag=varargin{1};
            else

                flag=isInputChanged(this,varargin);
                if~flag
                    drawnow limitrate

                    return;
                end

                validateInput(this,varargin);
                localUpdateFlag=false;
            end
            if(localUpdateFlag&&~isLocked(this))||...
                isempty(this.pUserInput)
                return;
            end

            [~,data]=computeFrequencyResponse(this);

            step@dsp.webscopes.internal.BaseWebScope(this,complex(data));
        end

        function delete(this)
            delete@dsp.webscopes.internal.BaseWebScope(this);
            this.pLocalUpdateRequested=[];
        end


        function set.SampleRate(this,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','finite','real','scalar','positive'},...
            'set.SampleRate','SampleRate');
            setPropertyValue(this,'SampleRate',double(value));
            updateFrequencyRange(this);

            localUpdate(this,true);
        end
        function value=get.SampleRate(this)
            value=getPropertyValue(this,'SampleRate');
        end


        function set.FFTLength(this,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','finite','real','scalar','positive'},...
            'set.FFTLength','FFTLength');
            setPropertyValue(this,'FFTLength',double(value));

            localUpdate(this,true);
        end
        function value=get.FFTLength(this)
            value=getPropertyValue(this,'FFTLength');
        end


        function set.FrequencyRange(this,value)
            import dsp.webscopes.*;
            validateattributes(value,{'numeric'},...
            {'nonempty','finite','real','row','numel',2,'nondecreasing'},...
            'set.FrequencyRange','FrequencyRange');
            Fs=this.SampleRate;

            if value(1)<-Fs/2||value(2)>Fs/2
                FilterVisualizerBaseWebScope.localError('invalidFrequencyRangeForNyquistInterval',-Fs/2,Fs/2);
            end

            if any(value<0)&&strcmpi(this.XScale,'Log')
                FilterVisualizerBaseWebScope.localError('invalidFrequencyRangeForLogScale');
            end
            setPropertyValue(this,'FrequencyRange',double(value));

            updateFrequencyRange(this);

            localUpdate(this,true);
        end
        function value=get.FrequencyRange(this)
            value=getPropertyValue(this,'FrequencyRange');
        end


        function set.MagnitudeDisplay(this,value)
            value=validateEnum(this,'MagnitudeDisplay',value);
            setPropertyValueAndNotify(this,'MagnitudeDisplay',value);
        end
        function value=get.MagnitudeDisplay(this)
            value=getPropertyValue(this,'MagnitudeDisplay');
        end


        function set.XScale(this,value)
            import dsp.webscopes.*;
            value=validateEnum(this,'XScale',value);
            if strcmp(value,'Log')&&any(this.FrequencyRange<0)
                FilterVisualizerBaseWebScope.localError('invalidXScale');
            end
            setPropertyValue(this,'XScale',value);
            updateFrequencyRange(this);
            localUpdate(this,true);
        end
        function value=get.XScale(this)
            value=getPropertyValue(this,'XScale');
        end


        function set.PlotType(this,value)
            value=validateEnum(this,'PlotType',value);
            setPropertyValueAndNotify(this,'PlotType',value);
        end
        function value=get.PlotType(this)
            value=getPropertyValue(this,'PlotType');
        end


        function set.AxesScaling(this,value)
            value=validateEnum(this,'AxesScaling',value);
            setPropertyValue(this,'AxesScaling',value);
        end
        function value=get.AxesScaling(this)
            value=getPropertyValue(this,'AxesScaling');
        end


        function set.MaximizeAxes(this,value)
            value=validateEnum(this,'MaximizeAxes',value);
            setPropertyValueAndNotify(this,'MaximizeAxes',value);
        end
        function value=get.MaximizeAxes(this)
            value=getPropertyValue(this,'MaximizeAxes');
        end


        function set.PlotAsMagnitudePhase(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','PlotAsMagnitudePhase');
            setPropertyValueAndNotify(this,'PlotAsMagnitudePhase',logical(value));
        end
        function value=get.PlotAsMagnitudePhase(this)
            value=getPropertyValue(this,'PlotAsMagnitudePhase');
        end


        function set.Title(this,value)
            import dsp.webscopes.*;

            value=convertStringsToChars(value);

            if~ischar(value)
                FilterVisualizerBaseWebScope.localError('invalidTitle');
            end
            setPropertyValueAndNotify(this,'Title',value);
        end
        function value=get.Title(this)
            value=getPropertyValue(this,'Title');
        end


        function set.YLimits(this,value)
            import dsp.webscopes.*;
            if~all(isnumeric(value))||~all(isfinite(value))||...
                numel(value)~=2||value(1)>=value(2)
                FilterVisualizerBaseWebScope.localError('invalidYLimits');
            end
            setPropertyValue(this,'AxesScaling','Manual');
            setPropertyValueAndNotify(this,'YLimits',value);
        end
        function value=get.YLimits(this)
            value=getPropertyValue(this,'YLimits');
        end


        function set.ShowGrid(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','ShowGrid');
            setPropertyValueAndNotify(this,'ShowGrid',logical(value));
        end
        function value=get.ShowGrid(this)
            value=getPropertyValue(this,'ShowGrid');
        end


        function set.ShowLegend(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','ShowLegend');
            setPropertyValueAndNotify(this,'ShowLegend',logical(value));
        end
        function value=get.ShowLegend(this)
            value=getPropertyValue(this,'ShowLegend');
        end


        function set.FilterNames(this,value)
            import dsp.webscopes.*;
            validateattributes(value,{'string','cell'},{'vector'},'','FilterNames');

            if(~isempty(value)&&(~isvector(value)||~iscellstr(cellstr(value))))
                FilterVisualizerBaseWebScope.localError('invalidFilterNames');
            end
            value=cellstr(value);
            if this.ShowLegend
                setPropertyValueAndNotify(this,'FilterNames',value);
            else
                setPropertyValue(this,'FilterNames',value);
            end
        end
        function value=get.FilterNames(this)
            value=getPropertyValue(this,'FilterNames');
        end


        function set.UpperMask(this,value)
            import dsp.webscopes.*;
            validateattributes(value,{'numeric'},{'real'},...
            'set.UpperMask','UpperMask');
            isValidMaskData=@(x)(isscalar(x)||(ismatrix(x)&&size(x,1)>1&&size(x,2)==2));
            if~isempty(value)
                if~isValidMaskData(value)
                    FilterVisualizerBaseWebScope.localError('invalidUpperMaskData');
                end
            end

            this.pUpperMask=value;
            if isscalar(value)

                value=interpolateMask(this,value);
            end
            setPropertyValueAndNotify(this,'UpperMask',value);
        end
        function value=get.UpperMask(this)
            value=this.pUpperMask;
        end


        function set.LowerMask(this,value)
            import dsp.webscopes.*;
            validateattributes(value,{'numeric'},{'real'},...
            'set.LowerMask','LowerMask');
            isValidMaskData=@(x)(isscalar(x)||(ismatrix(x)&&size(x,1)>1&&size(x,2)==2));
            if~isempty(value)
                if~isValidMaskData(value)
                    FilterVisualizerBaseWebScope.localError('invalidLowerMaskData');
                end
            end

            this.pLowerMask=value;
            if isscalar(value)

                value=interpolateMask(this,value);
            end
            setPropertyValueAndNotify(this,'LowerMask',value);
        end
        function value=get.LowerMask(this)
            value=this.pLowerMask;
        end


        function set.MaskStatus(this,value)
            value=validateEnum(this,'MaskStatus',value);
            setPropertyValueAndNotify(this,'MaskStatus',value);
        end
        function value=get.MaskStatus(this)
            value=getPropertyValue(this,'MaskStatus');
        end


        function set.NormalizedFrequency(this,value)
            validateattributes(value,{'logical'},{'scalar'},'set.NormalizedFrequency','NormalizedFrequency');
            setPropertyValueAndNotify(this,'NormalizedFrequency',value);
            updateSampleRate(this);
            updateFrequencyRange(this);

            localUpdate(this,true);
        end
        function value=get.NormalizedFrequency(this)
            value=getPropertyValue(this,'NormalizedFrequency');
        end


        function set.FrequencyVector(this,value)
            import dsp.webscopes.*;
            if~isempty(value)
                validateattributes(value,{'numeric'},...
                {'vector','real','finite','increasing'},'set.FrequencyVector','FrequencyVector');
            end
            setPropertyValue(this,'FrequencyVector',value);
        end
        function value=get.FrequencyVector(this)
            value=getPropertyValue(this,'FrequencyVector');
        end
    end



    methods(Access=protected)


        function h=getMessageHandler(~)
            h=dsp.webscopes.internal.FilterVisualizerMessageHandler;
        end


        function validatePropertiesOnSet(this,propName)
            import dsp.webscopes.*;
            validatePropertiesOnSet@dsp.webscopes.internal.BaseWebScope(this,propName);
            if isInactiveProperty(this,propName)
                FilterVisualizerBaseWebScope.localWarning('nonRelevantProperty',propName);
            end
        end


        function value=getDataProcessingStrategy(~)
            value='magnitude_phase_response_data_strategy';
        end

        function optionList=addFilterProperties(this,optionList)
            optionList.magPhaseData=true(1,this.NumInputPorts);
            optionList.autoSpan=true;
            customSpan=this.FrequencyRange(1);
            if(~isempty(this.FrequencyVector))
                customSpan=this.FrequencyVector(end);
            end
            optionList.customSpan=customSpan;
            optionList.magnitudeDisplay=this.MagnitudeDisplay;
        end

        function groups=getPropertyGroups(this)

            mainProps=getValidDisplayProperties(this,{...
            'FFTLength',...
            'SampleRate',...
            'FrequencyRange',...
            'XScale',...
            'MagnitudeDisplay',...
            'PlotAsMagnitudePhase',...
            'PlotType',...
            'AxesScaling',...
            'AxesScalingNumUpdates'});
            groups=matlab.mixin.util.PropertyGroup(mainProps,'');

            if(this.ShowAllProperties)


                measurementsProps={'MeasurementChannel',...
                'CursorMeasurements',...
                'PeakFinder'};

                visualizationProps=getValidDisplayProperties(this,{
                'Name',...
                'Position',...
                'MaximizeAxes',...
                'Title',...
                'YLimits',...
                'ShowLegend',...
                'FilterNames',...
                'ShowGrid',...
                'UpperMask',...
                'LowerMask'});
                groups=[groups,...
                matlab.mixin.util.PropertyGroup(measurementsProps,...
                getString(message('shared_dspwebscopes:dspwebscopes:measurementsProperties'))),...
                matlab.mixin.util.PropertyGroup(visualizationProps,...
                getString(message('shared_dspwebscopes:dspwebscopes:visualizationProperties')))];
            end
        end

        function updateSampleTimeAndOffset(this)


            this.SampleTime=1;
            this.Offset=0;
        end

        function mask=interpolateMask(this,limit)
            freqVector=this.getFrequencyVector();
            mask=limit.*ones(1,numel(freqVector));
            mask=[freqVector;mask].';
        end

        function value=getFrequencyVector(this)
            N=this.FFTLength;
            R=this.FrequencyRange;
            if strcmpi(this.XScale,'Log')
                value=logspace(log10(R(1)),log10(R(2)),N);
            else
                value=linspace(R(1),R(2),N);
            end
        end

        function h=freqz(this,c,f,Fs)
            h=this.FreqzFcn(c,f,Fs);
        end

        function updateSampleRate(this)
            if this.NormalizedFrequency
                setPropertyValue(this,'SampleRate',2);
            end
        end

        function updateFrequencyRange(this)
            R=this.FrequencyRange;
            Fs=this.SampleRate;


            if R(2)>Fs/2
                R(2)=Fs/2;
                setPropertyValue(this,'FrequencyRange',R);
            end


            if strcmpi(this.XScale,'Log')&&R(1)==0
                N=this.FFTLength;
                Fs=this.SampleRate;
                R(1)=diff(R)/(N*Fs);
                setPropertyValue(this,'FrequencyRange',R);
            end
        end

        function[fVector,H]=computeFrequencyResponse(this)
            input=this.pUserInput;
            Fs=this.SampleRate;
            fVector=getFrequencyVector(this);
            NFFT=this.FFTLength;
            inputIdx=1;
            outputIdx=1;
            while inputIdx<=numel(input)
                if this.pObjectFlag(inputIdx)

                    if this.pChangedInputs(inputIdx)

                        h=freqz(input{inputIdx},fVector,Fs);
                        if size(h,1)~=NFFT


                            h=h.';
                        end


                        numResponses=size(h,2);


                        H(:,outputIdx:outputIdx+numResponses-1)=h;


                        this.pResponseAddress(inputIdx,:)=[outputIdx,outputIdx+numResponses-1];
                    else


                        responseAddress=this.pResponseAddress(inputIdx,:);
                        h=this.pFrequencyResponse(:,responseAddress(1):responseAddress(2));
                        numResponses=size(h,2);


                        H(:,outputIdx:outputIdx+numResponses-1)=h;
                    end

                    inputIdx=inputIdx+1;
                    outputIdx=outputIdx+numResponses;
                else

                    H(:,outputIdx)=freqz(this,{input{inputIdx},input{inputIdx+1}},fVector,Fs);%#ok<AGROW>
                    this.pResponseAddress(inputIdx,:)=[outputIdx,outputIdx+1];
                    inputIdx=inputIdx+2;
                    outputIdx=outputIdx+1;
                end
            end
            if size(H,2)~=size(this.pFrequencyResponse,2)&&isLocked(this)



                release(this)
            end
            this.pFrequencyResponse=H;
            if(length(this.FrequencyVector)~=length(fVector))||...
                (norm(this.FrequencyVector-fVector)>sqrt(eps))
                this.FrequencyVector=fVector;
            end
        end

        function flag=isInputChanged(this,input)
            numInputs=numel(input);
            if isequal(input,this.pUserInput)
                this.pChangedInputs=false(1,numInputs);


                inputIdx=1;
                numObjects=1;
                while inputIdx<=numInputs
                    if this.pObjectFlag(inputIdx)




                        newPropValues=get(input{inputIdx});
                        cachedPropValues=this.pPropValues{numObjects};


                        numObjects=numObjects+1;
                        flag=~isequal(newPropValues,cachedPropValues);
                        this.pChangedInputs(inputIdx)=flag;
                    else



                        this.pChangedInputs(inputIdx)=false;
                        this.pChangedInputs(inputIdx+1)=false;


                        inputIdx=inputIdx+1;
                    end

                    inputIdx=inputIdx+1;
                end
            else
                this.pChangedInputs=true(1,numInputs);
            end


            flag=any(this.pChangedInputs==true);

        end

        function validateInput(this,input)
            import dsp.webscopes.*;
            inputIdx=1;
            numInputObjects=1;
            this.pObjectFlag=false(1,numel(input));
            numInputs=numel(input);
            while inputIdx<=numInputs
                objFlag=false;

                if isobject(input{inputIdx})

                    if~ismethod(input{inputIdx},'freqz')

                        if~isHiddenMethod(input{inputIdx},'freqz')
                            FilterVisualizerBaseWebScope.localError('invalidObjFreqzImplementation');
                        end
                    end
                    objFlag=true;

                    this.pObjectFlag(inputIdx)=objFlag;

                    this.pPropValues{numInputObjects}=getObjectPublicProperties(input{inputIdx});

                    numInputObjects=numInputObjects+1;

                    inputIdx=inputIdx+1;
                end


                numFlag=false;
                denFlag=false;
                if~objFlag


                    if all(isnumeric(input{inputIdx}))
                        numFlag=true;
                        inputIdx=inputIdx+1;
                    end
                    if numFlag
                        if inputIdx<=numInputs
                            if all(isnumeric(input{inputIdx}))
                                denFlag=true;

                                inputIdx=inputIdx+1;
                            elseif isobject(input{inputIdx})
                                FilterVisualizerBaseWebScope.localError('invalidInputFormat');
                            end
                        else

                            input{numInputs+1}=ones(size(input{numInputs},1),1);
                        end
                    end
                end
                if~(objFlag||numFlag||denFlag)
                    FilterVisualizerBaseWebScope.localError('invalidInputFormat');
                end
            end
            if numel(this.pUserInput)~=numel(input)&&isLocked(this)


                release(this)
            end
            this.pUserInput=input;
        end

        function localUpdate(this,~,~)
            this.pChangedInputs=true(1,numel(this.pUserInput));

            step(this,true);
        end
    end



    methods(Static,Hidden)


        function this=loadobj(s)

            this=loadobj@dsp.webscopes.internal.BaseWebScope(s);
            if isfield(s,'ScopeLocked')
                this.ScopeLocked=s.ScopeLocked;
            end

            if(s.Visible)
                this.show();
            end
        end

        function fevalHandler(action,clientID,varargin)
            import dsp.webscopes.internal.*;
            BaseWebScope.fevalHandler(action,clientID,varargin{:});
            switch action
            case 'showHelp'
                mapFileLocation=fullfile(docroot,'toolbox','dsp','dsp.map');
                helpview(mapFileLocation,varargin{1});
            end
        end

        function propNames=getValidPropertyNames(~)


            propNames=properties('dsp.webscopes.FilterVisualizerBaseWebScope');


            propNames(ismember(propNames,{'CursorMeasurements','PeakFinder','SignalStatistics'}))=[];
        end

        function a=getAlternateBlock
            a='';
        end

        function localError(ID,varargin)
            id=['shared_dspwebscopes:filtervisualizer:',ID];
            ME=MException(message(id,varargin{:}));
            throwAsCaller(ME);
        end

        function localWarning(ID,varargin)
            id=['shared_dspwebscopes:filtervisualizer:',ID];
            warning(message(id,varargin{:}));
        end

        function h=computefreqz(c,f,Fs)
            B=c{1};
            A=c{2};

            hNum(:,1)=freqz(B(1,:),1,f,Fs);
            for k=2:size(B,1)
                hNum(:,1)=hNum(:,1).*freqz(B(k,:),1,f,Fs).';
            end

            hDen(:,1)=freqz(1,A(1,:),f,Fs);
            for k=2:size(A,1)
                hDen(:,1)=hDen(:,1).*freqz(1,A(k,:),f,Fs).';
            end

            h=hNum.*hDen;
        end
    end



    methods(Access=public,Hidden)

        function p=getValueOnlyProperties(~)
            p={'FFTLength','SampleRate','FrequencyRange'};
        end

        function setMaskStatus(this,isMaskPassed)

            validateattributes(isMaskPassed,{'logical'},{'scalar'},'setMask','isMaskPassed');
            if isMaskPassed
                this.MaskStatus='Pass';
            else
                this.MaskStatus='Fail';
            end
        end


        function spec=getScopeSpecification(this)
            spec=this.Specification;
            if isempty(spec)
                spec=dsp.webscopes.internal.FilterVisualizerSpecification;
            end
        end
    end
end



function propValStruct=getObjectPublicProperties(h)

    propNames=properties(h);
    numPublicProps=numel(propNames);
    for idx=1:numPublicProps
        propVals{idx,1}=h.(propNames{idx});%#ok<AGROW>
    end
    propValStruct=cell2struct(propVals,propNames,1);
end

function flag=isHiddenMethod(hObj,methodName)
    mc=meta.class.fromName(class(hObj));
    hiddenMethodInfo=findobj((mc.MethodList(:)),'Hidden',true);
    hiddenMethodName={hiddenMethodInfo(:).Name};
    flag=ismember(methodName,hiddenMethodName);
end

