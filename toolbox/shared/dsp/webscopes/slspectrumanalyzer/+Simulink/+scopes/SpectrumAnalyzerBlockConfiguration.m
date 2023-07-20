classdef SpectrumAnalyzerBlockConfiguration<dsp.webscopes.mixin.PropertyValueValidator&...
    matlab.mixin.CustomDisplay








    properties(AbortSet,Dependent)

        NumInputPorts;

        InputDomain;

        SpectrumType;

        ViewType;

        SampleRate;

        SampleRateSource;

        Method;

        PlotAsTwoSidedSpectrum;

        FrequencyScale;

        PlotType;

        AxesScaling;

        AxesScalingNumUpdates;

        FrequencySpan;

        Span;

        CenterFrequency;

        StartFrequency;

        StopFrequency;

        FrequencyResolutionMethod;

        RBWSource;

        RBW;

        WindowLength;

        FFTLengthSource;

        FFTLength;

        NumTapsPerBand;

        FrequencyVectorSource;

        FrequencyVector;

        InputUnits;

        OverlapPercent;

        Window;

        CustomWindow;

        SidelobeAttenuation;

        SpectrumUnits;

        FullScaleSource;

        FullScale;

        AveragingMethod;

        SpectralAverages;

        ForgettingFactor;

        VBWSource;

        VBW;

        ReferenceLoad;

        FrequencyOffset;
        TreatMby1SignalsAsOneChannel;

        SpectrogramChannel;

        TimeResolutionSource;

        TimeResolution;

        TimeSpanSource;

        TimeSpan;

        MeasurementChannel;

        Name;

        Position;

        MaximizeAxes;

        PlotNormalTrace;

        PlotMaxHoldTrace;

        PlotMinHoldTrace;

        Title;

        YLabel;

        YLimits;

        ColorLimits;

        Colormap;

        ShowGrid;

        ShowLegend;

        ShowColorbar;

        ChannelNames;

        AxesLayout;

        OpenAtSimulationStart;

        Visible;
    end

    properties

        ChannelMeasurements;

        CursorMeasurements;

        DistortionMeasurements;

        PeakFinder;

        SpectralMask;
    end

    properties(AbortSet,Dependent,Hidden)

        PowerUnits;

        FrameBasedProcessing;

ExpandToolstrip


GraphicalSettings
    end

    properties(Hidden)

        ReducePlotRate=true;

        BlockHandle=-1;

        CCDFMeasurements;
    end

    properties(Access=private)

        ClientID='';


        PhysicalModelingMode=false;

        CachedSpectrumData=[];

        CachedEnabledViews=false(1,4);

        CachedMeasurementsData=[];

        CachedEnabledMeasurements=false(1,4);
    end

    properties(Constant,Hidden,Access=protected)


        SpectrumDataFieldNames={'SimulationTime',...
        'Spectrum',...
        'Spectrogram',...
        'MinHoldTrace',...
        'MaxHoldTrace',...
        'FrequencyVector'};
        MeasurementsDataFieldNames={'SimulationTime',...
        'PeakFinder',...
        'CursorMeasurements',...
        'ChannelMeasurements',...
        'DistortionMeasurements'};
    end

    properties(Constant,Hidden)
        InputDomainSet={'Time','Frequency'}
        SpectrumTypeSet={'Power','Power density','RMS'};
        SpectrumTypeObsoleteSet={'Power','Power density','RMS','Spectrogram'};
        ViewTypeSet={'Spectrum','Spectrogram','Spectrum and spectrogram'};
        SampleRateSourceSet={'Inherited','Property'};
        MethodSet={'Welch','Filter bank'};
        FrequencyScaleSet={'Linear','Log'};
        PlotTypeSet={'Line','Stem'};
        AxesScalingSet={'Auto','Updates','Manual','OnceAtStop'};
        FrequencySpanSet={'Full','Span and center frequency','Start and stop frequencies'};
        FrequencyVectorSourceSet={'Auto','Property','Input port'};
        FrequencyVectorSourceObsoleteSet={'Auto','Property','InputPort'};
        InputUnitsSet={'dBm','dBV','dBW','Vrms','Watts','None'};
        FrequencyResolutionMethodSet={'RBW','Window length','Number of frequency bands'};
        FrequencyResolutionMethodObsoleteSet={'RBW','WindowLength','NumFrequencyBands'};
        RBWSourceSet={'Auto','Property','Input port'};
        RBWSourceObsoleteSet={'Auto','Property','InputPort'};
        FFTLengthSourceSet={'Auto','Property'};
        WindowSet={'Blackman-Harris','Chebyshev','Flat top','Hamming','Hann','Kaiser','Rectangular','Custom'};
        SpectrumUnitsPowerSet={'dBm','dBW','dBFS','Watts'};
        SpectrumUnitsPowerDensitySet={'dBm/Hz','dBW/Hz','dBFS/Hz','Watts/Hz'};
        SpectrumUnitsRMSSet={'dBV','Vrms'};
        SpectrumUnitsFrequencyDomainSet={'Auto','dBm','dBV','dBW','Vrms','Watts'};
        FullScaleSourceSet={'Auto','Property'};
        AveragingMethodSet={'Exponential','Running','VBW'};
        VBWSourceSet={'Auto','Property'};
        TimeResolutionSourceSet={'Auto','Property'};
        TimeSpanSourceSet={'Auto','Property'};
        MaximizeAxesSet={'Auto','On','Off'};
        ColormapSet={'jet','hot','bone','cool','copper','gray','parula'};
        AxesLayoutSet={'Vertical','Horizontal'};
    end



    methods

        function this=SpectrumAnalyzerBlockConfiguration(blkHandle,clientID)
            this.BlockHandle=blkHandle;
            this.ClientID=clientID;

            addSpectrumMeasurementsConfiguration(this);

            allocateDataTables(this);

            this.PhysicalModelingMode=Simulink.scopes.SpectrumAnalyzerUtils.isPhysicalModelingMode();
        end

        function data=getSpectrumData(this,allFlag)


















            narginchk(1,2);
            if nargin==2

                allFlag=convertStringsToChars(allFlag);

                validatestring(allFlag,{'all'});
                allFlag=true;
            else
                allFlag=false;
            end

            data=this.CachedSpectrumData;
            enabledViews=this.CachedEnabledViews;
            if isVisualRendered(this)&&isNewDataAvailable(this)


                clientID=this.ClientID;
                newData=dsp.webscopes.SpectrumAnalyzerBaseWebScope.isNewDataReadyBlocking(clientID);
                if newData
                    [data.SimulationTime,...
                    data.FrequencyVector{1},...
                    data.Spectrum{1},...
                    spectrogramData,...
                    data.MinHoldTrace{1},...
                    data.MaxHoldTrace{1},~,...
                    spectrumLength,...
                    numSegments,...
                    numSpectrogramLines]=dsp.webscopes.internal.getSpectrumDataImpl(clientID);
                    if isSpectrogramMode(this)
                        if(isempty(data.Spectrogram{1}))
                            data.Spectrogram{1}=zeros(numSpectrogramLines,spectrumLength);
                        end

                        data.Spectrogram{1}=circshift(data.Spectrogram{1},numSegments);


                        data.Spectrogram{1}(1:numSegments,:)=flipud(reshape(spectrogramData,spectrumLength,numSegments).');
                    end

                    data.FrequencyVector{1}=data.FrequencyVector{1}+str2double(this.FrequencyOffset);

                    enabledViews=[isSpectrumMode(this)&&this.PlotNormalTrace,isSpectrogramMode(this),this.PlotMinHoldTrace,this.PlotMaxHoldTrace];

                    this.CachedSpectrumData=data;

                    this.CachedEnabledViews=enabledViews;
                end
                units=this.SpectrumUnits;
                if strcmpi(this.InputDomain,'frequency')&&strcmpi(units,'auto')
                    units=this.InputUnits;
                end
                data.Properties.VariableUnits={
                's',...
                units,...
                units,...
                units,...
                units,...
                'Hz'};
            end

            if~allFlag
                idx=[true,enabledViews,true];
                data=data(:,idx);
            end
        end

        function data=getMeasurementsData(this,allFlag)

















            narginchk(1,2);
            if nargin==2

                allFlag=convertStringsToChars(allFlag);

                validatestring(allFlag,{'all'});
                allFlag=true;
            else
                allFlag=false;
            end
            data=this.CachedMeasurementsData;
            enabledMeasurements=this.CachedEnabledMeasurements;
            if isVisualRendered(this)&&isNewDataAvailable(this)
                clientID=this.ClientID;
                newData=dsp.webscopes.SpectrumAnalyzerBaseWebScope.isNewDataReadyBlocking(clientID);
                if newData

                    data.SimulationTime=dsp.webscopes.internal.getSimulationTimeImpl(clientID);

                    enabledMeasurements(1)=false;
                    if this.PeakFinder.isEnabled()
                        newData=dsp.webscopes.SpectrumAnalyzerBaseWebScope.isNewPeakFinderDataReadyBlocking(clientID);
                        if newData
                            data.PeakFinder=dsp.webscopes.measurements.getPeakFinderDataImpl(clientID);
                        end
                        enabledMeasurements(1)=true;
                    end

                    enabledMeasurements(2)=false;
                    if this.CursorMeasurements.isEnabled()
                        enabledMeasurements(2)=true;
                    end

                    enabledMeasurements(3)=false;
                    if this.ChannelMeasurements.isEnabled()
                        newData=dsp.webscopes.SpectrumAnalyzerBaseWebScope.isNewChannelMeasurementsDataReadyBlocking(clientID);
                        if newData
                            data.ChannelMeasurements=dsp.webscopes.measurements.getChannelMeasurementsDataImpl(clientID);
                        end
                        enabledMeasurements(3)=true;
                    end

                    enabledMeasurements(4)=false;
                    if this.DistortionMeasurements.isEnabled()
                        newData=dsp.webscopes.SpectrumAnalyzerBaseWebScope.isNewDistortionMeasurementsDataReadyBlocking(clientID);
                        if newData
                            data.DistortionMeasurements=dsp.webscopes.measurements.getDistortionMeasurementsDataImpl(clientID);
                        end
                        enabledMeasurements(4)=true;
                    end

                    this.CachedMeasurementsData=data;

                    this.CachedEnabledMeasurements=enabledMeasurements;
                end
            end

            if~allFlag
                idx=[true,enabledMeasurements];
                data=data(:,idx);
            end
        end

        function maskStatus=getSpectralMaskStatus(this)





















            maskStatus=struct([]);
            if this.SpectralMask.isEnabled()&&isVisualRendered(this)&&isNewDataAvailable(this)
                clientID=this.ClientID;
                newData=dsp.webscopes.SpectrumAnalyzerBaseWebScope.isNewSpectralMaskTesterDataReadyBlocking(clientID);
                if newData
                    maskStatus=dsp.webscopes.measurements.getSpectralMaskStatusImpl(clientID);
                end
            end
        end

        function flag=isNewDataReady(this)




            flag=false;
            if isVisualRendered(this)&&isNewDataAvailable(this)
                flag=dsp.webscopes.SpectrumAnalyzerBaseWebScope.isNewDataReadyBlocking(this.ClientID);
            end
        end


        function set.NumInputPorts(this,strValue)
            this.errorForNonTunableParam('NumInputPorts');
            [rvalue,errorID,errorStr]=evaluateVariable(this,strValue);
            if~isempty(errorID)
                msgObj=message('shared_dspwebscopes:slspectrumanalyzer:invalidSetting',...
                'NumInputPorts',this.Name,errorStr);
                throwAsCaller(MException(msgObj));
            elseif~isnumeric(rvalue)
                errorStr=getString(message('shared_dspwebscopes:slspectrumanalyzer:invalidVariableForNumberOfInputPorts',value));
                msgObj=message('shared_dspwebscopes:slspectrumanalyzer:invalidSetting',...
                'NumInputPorts',this.Name,errorStr);
                throwAsCaller(MException(msgObj));
            end
            validateattributes(rvalue,{'numeric'},{'real','finite','positive','scalar','>=',1,'<=',96},'','NumInputPorts');
            set_param(this.BlockHandle,'NumInputPorts',num2str(rvalue));
        end
        function value=get.NumInputPorts(this)
            value=get_param(this.BlockHandle,'NumInputPorts');
        end


        function set.InputDomain(this,value)
            validatePropertyAccess(this,'InputDomain');
            this.errorForNonTunableParam('InputDomain');
            value=validateEnum(this,'InputDomain',value);
            set_param(this.BlockHandle,'InputDomain',value);
        end
        function value=get.InputDomain(this)
            value=get_param(this.BlockHandle,'InputDomain');
        end


        function set.SpectrumType(this,value)
            value=validateEnum(this,'SpectrumType',value);
            set_param(this.BlockHandle,'SpectrumType',value);
        end
        function value=get.SpectrumType(this)
            value=get_param(this.BlockHandle,'SpectrumType');
        end


        function set.ViewType(this,value)
            validatePropertyAccess(this,'ViewType');
            value=validateEnum(this,'ViewType',value);
            set_param(this.BlockHandle,'ViewType',value);
        end
        function value=get.ViewType(this)
            value=get_param(this.BlockHandle,'ViewType');
        end


        function set.SampleRateSource(this,value)
            this.errorForNonTunableParam('SampleRateSource');
            value=validateEnum(this,'SampleRateSource',value);
            set_param(this.BlockHandle,'SampleRateSource',value);
        end
        function value=get.SampleRateSource(this)
            value=get_param(this.BlockHandle,'SampleRateSource');
        end


        function set.SampleRate(this,strValue)
            this.errorForNonTunableParam('SampleRate');
            [value,varUndefined]=evaluateString(this,strValue,'XOffset');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','scalar','nonnegative'},'','SampleRate');
            end
            set_param(this.BlockHandle,'SampleRate',strValue);
        end
        function value=get.SampleRate(this)
            value=get_param(this.BlockHandle,'SampleRate');
        end


        function set.Method(this,value)
            validatePropertyAccess(this,'Method');
            value=validateEnum(this,'Method',value);
            set_param(this.BlockHandle,'Method',value);
        end
        function value=get.Method(this)
            value=get_param(this.BlockHandle,'Method');
        end


        function set.PlotAsTwoSidedSpectrum(this,value)
            validateattributes(value,{'logical'},{'scalar'},'','PlotAsTwoSidedSpectrum');
            set_param(this.BlockHandle,'PlotAsTwoSidedSpectrum',utils.logicalToOnOff(value));
        end
        function value=get.PlotAsTwoSidedSpectrum(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'PlotAsTwoSidedSpectrum'));
        end


        function set.FrequencyScale(this,value)
            value=validateEnum(this,'FrequencyScale',value);
            set_param(this.BlockHandle,'FrequencyScale',value);
        end
        function value=get.FrequencyScale(this)
            value=get_param(this.BlockHandle,'FrequencyScale');
        end


        function set.PlotType(this,value)
            value=validateEnum(this,'PlotType',value);
            set_param(this.BlockHandle,'PlotType',value);
        end
        function value=get.PlotType(this)
            value=get_param(this.BlockHandle,'PlotType');
        end


        function set.AxesScaling(this,value)
            value=validateEnum(this,'AxesScaling',value);
            set_param(this.BlockHandle,'AxesScaling',value);
        end
        function value=get.AxesScaling(this)
            value=get_param(this.BlockHandle,'AxesScaling');
        end


        function set.AxesScalingNumUpdates(this,strValue)
            [value,varUndefined]=evaluateString(this,strValue,'AxesScalingNumUpdates');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','positive','scalar'},'','AxesScalingNumUpdates');
            end
            set_param(this.BlockHandle,'AxesScalingNumUpdates',strValue);
        end
        function value=get.AxesScalingNumUpdates(this)
            value=get_param(this.BlockHandle,'AxesScalingNumUpdates');
        end


        function set.FrequencySpan(this,value)
            validatePropertyAccess(this,'FrequencySpan');
            value=validateEnum(this,'FrequencySpan',value);
            set_param(this.BlockHandle,'FrequencySpan',value);
        end
        function value=get.FrequencySpan(this)
            value=get_param(this.BlockHandle,'FrequencySpan');
        end


        function set.Span(this,strValue)
            validatePropertyAccess(this,'Span');
            [value,varUndefined]=evaluateString(this,strValue,'Span');
            if~varUndefined
                validateattributes(value,{'double'},{'positive','real','scalar','finite','nonnan'},'','Span');
            end
            set_param(this.BlockHandle,'Span',strValue);
        end
        function value=get.Span(this)
            value=get_param(this.BlockHandle,'Span');
        end


        function set.CenterFrequency(this,strValue)
            validatePropertyAccess(this,'CenterFrequency');
            [value,varUndefined]=evaluateString(this,strValue,'CenterFrequency');
            if~varUndefined
                validateattributes(value,{'double'},{'real','scalar','finite','nonnan'},'','CenterFrequency');
            end
            set_param(this.BlockHandle,'CenterFrequency',strValue);
        end
        function value=get.CenterFrequency(this)
            value=get_param(this.BlockHandle,'CenterFrequency');
        end


        function set.StartFrequency(this,strValue)
            validatePropertyAccess(this,'StartFrequency');
            [value,varUndefined]=evaluateString(this,strValue,'StartFrequency');
            if~varUndefined
                validateattributes(value,{'double'},{'real','scalar','finite','nonnan'},'','StartFrequency');
            end
            set_param(this.BlockHandle,'StartFrequency',strValue);
        end
        function value=get.StartFrequency(this)
            value=get_param(this.BlockHandle,'StartFrequency');
        end


        function set.StopFrequency(this,strValue)
            validatePropertyAccess(this,'StopFrequency');
            [value,varUndefined]=evaluateString(this,strValue,'StopFrequency');
            if~varUndefined
                validateattributes(value,{'double'},{'real','scalar','finite','nonnan'},'','StopFrequency');
            end
            set_param(this.BlockHandle,'StopFrequency',strValue);
        end
        function value=get.StopFrequency(this)
            value=get_param(this.BlockHandle,'StopFrequency');
        end


        function set.FrequencyResolutionMethod(this,value)
            validatePropertyAccess(this,'FrequencyResolutionMethod');
            value=validateEnum(this,'FrequencyResolutionMethod',value);
            set_param(this.BlockHandle,'FrequencyResolutionMethod',value);
        end
        function value=get.FrequencyResolutionMethod(this)
            value=get_param(this.BlockHandle,'FrequencyResolutionMethod');
        end


        function set.RBWSource(this,value)
            value=validateEnum(this,'RBWSource',value);
            set_param(this.BlockHandle,'RBWSource',value);
        end
        function value=get.RBWSource(this)
            value=get_param(this.BlockHandle,'RBWSource');
        end


        function set.RBW(this,strValue)
            [value,varUndefined]=evaluateString(this,strValue,'RBW');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','positive','scalar'},'','RBW');
            end
            set_param(this.BlockHandle,'RBW',strValue);
        end
        function value=get.RBW(this)
            value=get_param(this.BlockHandle,'RBW');
        end


        function set.WindowLength(this,strValue)
            validatePropertyAccess(this,'WindowLength');
            [value,varUndefined]=evaluateString(this,strValue,'WindowLength');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','positive','scalar','integer'},'','WindowLength');
            end
            set_param(this.BlockHandle,'WindowLength',strValue);
        end
        function value=get.WindowLength(this)
            value=get_param(this.BlockHandle,'WindowLength');
        end


        function set.FFTLengthSource(this,value)
            validatePropertyAccess(this,'FFTLengthSource');
            value=validateEnum(this,'FFTLengthSource',value);
            set_param(this.BlockHandle,'FFTLengthSource',value);
        end
        function value=get.FFTLengthSource(this)
            value=get_param(this.BlockHandle,'FFTLengthSource');
        end


        function set.FFTLength(this,strValue)
            validatePropertyAccess(this,'FFTLength');
            [value,varUndefined]=evaluateString(this,strValue,'FFTLength');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','positive','scalar','integer'},'','FFTLength');
            end
            set_param(this.BlockHandle,'FFTLength',strValue);
        end
        function value=get.FFTLength(this)
            value=get_param(this.BlockHandle,'FFTLength');
        end


        function set.NumTapsPerBand(this,strValue)
            validatePropertyAccess(this,'NumTapsPerBand');
            [value,varUndefined]=evaluateString(this,strValue,'NumTapsPerBand');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','positive','scalar'},'','NumTapsPerBand');
            end
            set_param(this.BlockHandle,'NumTapsPerBand',strValue);
        end
        function value=get.NumTapsPerBand(this)
            value=get_param(this.BlockHandle,'NumTapsPerBand');
        end


        function set.FrequencyVectorSource(this,value)
            value=validateEnum(this,'FrequencyVectorSource',value);
            set_param(this.BlockHandle,'FrequencyVectorSource',value);
        end
        function value=get.FrequencyVectorSource(this)
            value=get_param(this.BlockHandle,'FrequencyVectorSource');
        end


        function set.FrequencyVector(this,strValue)
            [value,varUndefined]=evaluateString(this,strValue,'FrequencyVector');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','positive','scalar'},'','FrequencyVector');
            end
            set_param(this.BlockHandle,'FrequencyVector',strValue);
        end
        function value=get.FrequencyVector(this)
            value=get_param(this.BlockHandle,'FrequencyVector');
        end


        function set.InputUnits(this,value)
            validatePropertyAccess(this,'InputUnits');
            value=validateEnum(this,'InputUnits',value);
            set_param(this.BlockHandle,'InputUnits',value);
        end
        function value=get.InputUnits(this)
            value=get_param(this.BlockHandle,'InputUnits');
        end


        function set.OverlapPercent(this,strValue)
            [value,varUndefined]=evaluateString(this,strValue,'OverlapPercent');
            if~varUndefined
                validateattributes(value,{'double'},{'real','nonnegative','scalar','finite','nonnan','>=',0,'<',100},'','OverlapPercent');
            end
            set_param(this.BlockHandle,'OverlapPercent',strValue);
        end
        function value=get.OverlapPercent(this)
            value=get_param(this.BlockHandle,'OverlapPercent');
        end


        function set.Window(this,value)
            value=validateEnum(this,'Window',value);
            set_param(this.BlockHandle,'Window',value);
        end
        function value=get.Window(this)
            value=get_param(this.BlockHandle,'Window');
        end


        function set.CustomWindow(this,value)
            validatePropertyAccess(this,'CustomWindow');

            value=convertStringsToChars(value);
            set_param(this.BlockHandle,'CustomWindow',value);
        end
        function value=get.CustomWindow(this)
            value=get_param(this.BlockHandle,'CustomWindow');
        end


        function set.SidelobeAttenuation(this,strValue)
            validatePropertyAccess(this,'SidelobeAttenuation');
            [value,varUndefined]=evaluateString(this,strValue,'SidelobeAttenuation');
            if~varUndefined
                validateattributes(value,{'numeric'},{'positive','real','scalar','finite','nonnan','>=',45},'','SidelobeAttenuation');
            end
            set_param(this.BlockHandle,'SidelobeAttenuation',strValue);
        end
        function value=get.SidelobeAttenuation(this)
            value=get_param(this.BlockHandle,'SidelobeAttenuation');
        end


        function set.SpectrumUnits(this,value)
            if~strcmpi(this.ViewType,'RMS')
                validatePropertyAccess(this,'SpectrumUnits');
            end
            value=validateEnum(this,'SpectrumUnits',value);
            set_param(this.BlockHandle,'SpectrumUnits',value);
        end
        function value=get.SpectrumUnits(this)
            value=get_param(this.BlockHandle,'SpectrumUnits');
        end


        function set.PowerUnits(this,value)
            this.SpectrumUnits=value;
        end
        function value=get.PowerUnits(this)
            value=this.SpectrumUnits;
        end


        function set.FullScaleSource(this,value)
            validatePropertyAccess(this,'FullScaleSource');
            value=validateEnum(this,'FullScaleSource',value);
            set_param(this.BlockHandle,'FullScaleSource',value);
        end
        function value=get.FullScaleSource(this)
            value=get_param(this.BlockHandle,'FullScaleSource');
        end


        function set.FullScale(this,strValue)
            validatePropertyAccess(this,'FullScale');
            [value,varUndefined]=evaluateString(this,strValue,'FullScale');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','positive','scalar'},'','FullScale');
            end
            set_param(this.BlockHandle,'FullScale',strValue);
        end
        function value=get.FullScale(this)
            value=get_param(this.BlockHandle,'FullScale');
        end


        function set.AveragingMethod(this,value)
            value=validateEnum(this,'AveragingMethod',value);
            set_param(this.BlockHandle,'AveragingMethod',value);
        end
        function value=get.AveragingMethod(this)
            value=get_param(this.BlockHandle,'AveragingMethod');
        end


        function set.SpectralAverages(this,strValue)
            [value,varUndefined]=evaluateString(this,strValue,'SpectralAverages');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','positive','scalar'},'','SpectralAverages');
            end
            set_param(this.BlockHandle,'SpectralAverages',strValue);
        end
        function value=get.SpectralAverages(this)
            value=get_param(this.BlockHandle,'SpectralAverages');
        end


        function set.ForgettingFactor(this,strValue)
            [value,varUndefined]=evaluateString(this,strValue,'ForgettingFactor');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','positive','scalar'},'','ForgettingFactor');
            end
            set_param(this.BlockHandle,'ForgettingFactor',strValue);
        end
        function value=get.ForgettingFactor(this)
            value=get_param(this.BlockHandle,'ForgettingFactor');
        end


        function set.VBWSource(this,value)
            value=validateEnum(this,'VBWSource',value);
            set_param(this.BlockHandle,'VBWSource',value);
        end
        function value=get.VBWSource(this)
            value=get_param(this.BlockHandle,'VBWSource');
        end


        function set.VBW(this,strValue)
            [value,varUndefined]=evaluateString(this,strValue,'VBW');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','positive','scalar'},'','VBW');
            end
            set_param(this.BlockHandle,'VBW',strValue);
        end
        function value=get.VBW(this)
            value=get_param(this.BlockHandle,'VBW');
        end


        function set.ReferenceLoad(this,strValue)
            [value,varUndefined]=evaluateString(this,strValue,'ReferenceLoad');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','positive','scalar'},'','ReferenceLoad');
            end
            set_param(this.BlockHandle,'ReferenceLoad',strValue);
        end
        function value=get.ReferenceLoad(this)
            value=get_param(this.BlockHandle,'ReferenceLoad');
        end


        function set.FrequencyOffset(this,strValue)
            [value,varUndefined]=evaluateString(this,strValue,'FrequencyOffset');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','positive','scalar'},'','FrequencyOffset');
            end
            set_param(this.BlockHandle,'FrequencyOffset',strValue);
        end
        function value=get.FrequencyOffset(this)
            value=get_param(this.BlockHandle,'FrequencyOffset');
        end


        function set.SpectrogramChannel(this,strValue)
            validatePropertyAccess(this,'SpectrogramChannel');
            [value,varUndefined]=evaluateString(this,strValue,'SpectrogramChannel');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','positive','scalar','<=',100},'','SpectrogramChannel');
            end
            set_param(this.BlockHandle,'SpectrogramChannel',strValue);
        end
        function value=get.SpectrogramChannel(this)
            value=get_param(this.BlockHandle,'SpectrogramChannel');
        end


        function set.TimeResolutionSource(this,value)
            validatePropertyAccess(this,'TimeResolutionSource');
            value=validateEnum(this,'TimeResolutionSource',value);
            set_param(this.BlockHandle,'TimeResolutionSource',value);
        end
        function value=get.TimeResolutionSource(this)
            value=get_param(this.BlockHandle,'TimeResolutionSource');
        end


        function set.TimeResolution(this,strValue)
            validatePropertyAccess(this,'TimeResolution');
            [value,varUndefined]=evaluateString(this,strValue,'TimeResolution');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','positive','scalar'},'','TimeResolution');
            end
            set_param(this.BlockHandle,'TimeResolution',strValue);
        end
        function value=get.TimeResolution(this)
            value=get_param(this.BlockHandle,'TimeResolution');
        end


        function set.TimeSpanSource(this,value)
            validatePropertyAccess(this,'TimeSpanSource');
            value=validateEnum(this,'TimeSpanSource',value);
            set_param(this.BlockHandle,'TimeSpanSource',value);
        end
        function value=get.TimeSpanSource(this)
            value=get_param(this.BlockHandle,'TimeSpanSource');
        end


        function set.TimeSpan(this,strValue)
            validatePropertyAccess(this,'TimeSpan');
            [value,varUndefined]=evaluateString(this,strValue,'TimeSpan');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','positive','scalar'},'','TimeSpan');
            end
            set_param(this.BlockHandle,'TimeSpan',strValue);
        end
        function value=get.TimeSpan(this)
            value=get_param(this.BlockHandle,'TimeSpan');
        end


        function set.MeasurementChannel(this,strValue)
            [value,varUndefined]=evaluateString(this,strValue,'MeasurementChannel');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','positive','scalar'},'','MeasurementChannel');
            end
            set_param(this.BlockHandle,'MeasurementChannel',strValue);
        end
        function value=get.MeasurementChannel(this)
            value=get_param(this.BlockHandle,'MeasurementChannel');
        end


        function set.Name(this,value)
            value=convertStringsToChars(value);
            validateattributes(value,{'char'},{},'','Name');
            set_param(this.BlockHandle,'Name',value);
        end
        function value=get.Name(this)
            value=get_param(this.BlockHandle,'Name');
        end


        function set.Position(this,value)
            set_param(this.BlockHandle,'WindowPosition',num2str(value));
        end
        function value=get.Position(this)
            if this.Visible&&isWebWindowValid(this)


                webwindow=getWebWindow(this);
                value=webwindow.Position;
            else
                value=str2num(get_param(this.BlockHandle,'WindowPosition'));%#ok<ST2NM>
                if isempty(value)


                    value=utils.getDefaultWebWindowPosition([800,500]);
                end
            end
        end


        function set.MaximizeAxes(this,value)
            value=validateEnum(this,'MaximizeAxes',value);
            set_param(this.BlockHandle,'MaximizeAxes',value);
        end
        function value=get.MaximizeAxes(this)
            value=get_param(this.BlockHandle,'MaximizeAxes');
        end


        function set.PlotNormalTrace(this,value)
            validatePropertyAccess(this,'PlotNormalTrace');
            validateattributes(value,{'logical'},{'scalar'},'','PlotNormalTrace');
            set_param(this.BlockHandle,'PlotNormalTrace',utils.logicalToOnOff(value));
        end
        function value=get.PlotNormalTrace(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'PlotNormalTrace'));
        end


        function set.PlotMaxHoldTrace(this,value)
            validatePropertyAccess(this,'PlotMaxHoldTrace');
            validateattributes(value,{'logical'},{'scalar'},'','PlotMaxHoldTrace');
            set_param(this.BlockHandle,'PlotMaxHoldTrace',utils.logicalToOnOff(value));
        end
        function value=get.PlotMaxHoldTrace(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'PlotMaxHoldTrace'));
        end


        function set.PlotMinHoldTrace(this,value)
            validatePropertyAccess(this,'PlotMinHoldTrace');
            validateattributes(value,{'logical'},{'scalar'},'','PlotMinHoldTrace');
            set_param(this.BlockHandle,'PlotMinHoldTrace',utils.logicalToOnOff(value));
        end
        function value=get.PlotMinHoldTrace(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'PlotMinHoldTrace'));
        end


        function set.Title(this,value)
            value=convertStringsToChars(value);
            validateattributes(value,{'char'},{},'','Title');
            set_param(this.BlockHandle,'Title',value);
        end
        function value=get.Title(this)
            value=get_param(this.BlockHandle,'Title');
        end


        function set.YLabel(this,value)
            value=convertStringsToChars(value);
            validateattributes(value,{'char'},{},'','YLabel');
            set_param(this.BlockHandle,'YLabel',value);
        end
        function value=get.YLabel(this)
            value=get_param(this.BlockHandle,'YLabel');
        end


        function set.YLimits(this,value)
            if~all(isnumeric(value))||~all(isfinite(value))||...
                numel(value)~=2||value(1)>=value(2)
                msgObj=message('shared_dspwebscopes:spectrumanalyzer:invalidYLimits');
                throwAsCaller(MException(msgObj));
            end
            this.AxesScaling='Manual';
            set_param(this.BlockHandle,'YLimits',['[',num2str(value(1)),',',num2str(value(2)),']']);
        end
        function value=get.YLimits(this)
            value=str2num(get_param(this.BlockHandle,'YLimits'));%#ok<ST2NM>
        end


        function set.ColorLimits(this,value)
            validatePropertyAccess(this,'ColorLimits');
            if~all(isnumeric(value))||~all(isfinite(value))||...
                numel(value)~=2||value(1)>=value(2)
                msgObj=message('shared_dspwebscopes:spectrumanalyzer:invalidColorLimits');
                throwAsCaller(MException(msgObj));
            end
            this.AxesScaling='Manual';
            set_param(this.BlockHandle,'ColorLimits',['[',num2str(value(1)),',',num2str(value(2)),']']);
        end
        function value=get.ColorLimits(this)
            value=str2num(get_param(this.BlockHandle,'ColorLimits'));%#ok<ST2NM>
        end


        function set.Colormap(this,value)
            validatePropertyAccess(this,'Colormap');
            value=validateEnum(this,'Colormap',value);
            set_param(this.BlockHandle,'Colormap',value);
        end
        function value=get.Colormap(this)
            value=get_param(this.BlockHandle,'Colormap');
        end


        function set.ShowGrid(this,value)
            validateattributes(value,{'logical'},{'scalar'},'','ShowGrid');
            set_param(this.BlockHandle,'ShowGrid',utils.logicalToOnOff(value));
        end
        function value=get.ShowGrid(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'ShowGrid'));
        end


        function set.ShowLegend(this,value)
            validateattributes(value,{'logical'},{'scalar'},'','ShowLegend');
            set_param(this.BlockHandle,'ShowLegend',utils.logicalToOnOff(value));
        end
        function value=get.ShowLegend(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'ShowLegend'));
        end


        function set.ShowColorbar(this,value)
            validatePropertyAccess(this,'Colormap');
            validateattributes(value,{'logical'},{'scalar'},'','ShowColorBar');
            set_param(this.BlockHandle,'ShowColorBar',utils.logicalToOnOff(value));
        end
        function value=get.ShowColorbar(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'ShowColorBar'));
        end


        function set.AxesLayout(this,value)
            validatePropertyAccess(this,'AxesLayout');
            value=validateEnum(this,'AxesLayout',value);
            set_param(this.BlockHandle,'AxesLayout',value);
        end
        function value=get.AxesLayout(this)
            value=get_param(this.BlockHandle,'AxesLayout');
        end


        function set.ChannelNames(this,value)
            validateattributes(value,{'string','cell'},{'vector'},'','ChannelNames');
            if(~isempty(value)&&(~isvector(value)||~iscellstr(cellstr(value))))
                msgObj=message('shared_dspwebscopes:spectrumanalyzer:invalidChannelNames');
                throwAsCaller(MException(msgObj));
            end
            value=cellstr(value);
            set_param(this.BlockHandle,'ChannelNames',jsonencode(value));
        end
        function value=get.ChannelNames(this)


            value=strrep(get_param(this.BlockHandle,'ChannelNames'),'''','"');

            value=jsondecode(value).';
            if isempty(value)

                value={''};
            end
        end


        function set.TreatMby1SignalsAsOneChannel(this,value)
            validateattributes(value,{'logical'},{'scalar'},'','TreatMby1SignalsAsOneChannel');
            this.FrameBasedProcessing=value;
        end
        function value=get.TreatMby1SignalsAsOneChannel(this)
            value=this.FrameBasedProcessing;
        end


        function set.OpenAtSimulationStart(this,value)
            validateattributes(value,{'logical'},{'scalar'},'','OpenAtSimulationStart');
            set_param(this.BlockHandle,'OpenAtSimulationStart',utils.logicalToOnOff(value));
        end
        function value=get.OpenAtSimulationStart(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'OpenAtSimulationStart'));
        end


        function set.Visible(this,value)
            validateattributes(value,{'logical'},{'scalar'},'','Visible');
            set_param(this.BlockHandle,'Visible',utils.logicalToOnOff(value));
        end
        function value=get.Visible(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'Visible'));
        end


        function set.FrameBasedProcessing(this,value)
            validateattributes(value,{'logical'},{'scalar'},'','FrameBasedProcessing');
            set_param(this.BlockHandle,'FrameBasedProcessing',utils.logicalToOnOff(value));
        end
        function value=get.FrameBasedProcessing(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'FrameBasedProcessing'));
        end


        function set.ExpandToolstrip(this,value)
            validateattributes(value,{'logical'},{'scalar'},'','ExpandToolstrip');
            set_param(this.BlockHandle,'ExpandToolstrip',utils.logicalToOnOff(value));
        end
        function value=get.ExpandToolstrip(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'ExpandToolstrip'));
        end


        function value=get.GraphicalSettings(this)
            value=Simulink.scopes.SpectrumAnalyzerUtils.getGraphicalSettings(this.BlockHandle);
        end


        function set.ReducePlotRate(~,~)
            import dsp.webscopes.*;
            SpectrumAnalyzerBaseWebScope.localWarning('reducePlotRateObsolete');
        end


        function set.CCDFMeasurements(~,~)
            msgObj=message('shared_dspwebscopes:slspectrumanalyzer:ccdfMeasurementsObsolete');
            throwAsCaller(MException(msgObj));
        end
        function value=get.CCDFMeasurements(~)%#ok<STOUT>
            msgObj=message('shared_dspwebscopes:slspectrumanalyzer:ccdfMeasurementsObsolete');
            throwAsCaller(MException(msgObj));
        end

    end



    methods(Hidden)

        function evalAndSetNumInputPorts(this,numInputPorts)
            if~isempty(numInputPorts)&&ischar(numInputPorts)





                numInputPortsVal=str2num(numInputPorts);%#ok<ST2NM>
                if isempty(numInputPortsVal)





                    if~isvarname(numInputPorts)
                        utils.errorHandler(getString(message('Spcuilib:scopes:InvalidVariableName',numInputPorts)));
                        return
                    end
                    try
                        numInputPortsVal=evalVarInMdlOrBaseWS(this,numInputPorts);
                    catch meNotUsed %#ok<NASGU>
                        utils.errorHandler(getString(message('Spcuilib:scopes:VariableNotFound',numInputPorts)));
                        return
                    end
                    if~isnumeric(numInputPortsVal)
                        utils.errorHandler(getString(message('shared_dspwebscopes:slspectrumanalyzer:invalidVariableForNumberOfInputPorts',numInputPorts)));
                        return
                    end
                end

                try
                    set_param(this.BlockHandle,'NumInputPorts',num2str(double(numInputPortsVal)));
                catch ME
                    utils.errorHandler(ME.message);
                end
            end
        end

        function props=getDisplayProperties(this)
            props=getPropertyGroups(this);
        end

        function updateGraphicalSettings(this,graphicalJSON)
            graphical=jsondecode(graphicalJSON);
            graphical=graphical.GraphicalSettings;

            if isfield(graphical,'Channel')
                channelSettings=graphical.Channel;
                if~isempty(channelSettings)
                    this.ChannelMeasurements.Specification.setSettings(channelSettings);
                end
            end

            if isfield(graphical,'Cursors')
                cursorsSettings=graphical.Cursors;
                if~isempty(cursorsSettings)
                    this.CursorMeasurements.Specification.setSettings(cursorsSettings);
                end
            end

            if isfield(graphical,'Distortion')
                distortionSettings=graphical.Distortion;
                if~isempty(distortionSettings)
                    this.DistortionMeasurements.Specification.setSettings(distortionSettings);
                end
            end

            if isfield(graphical,'Peaks')
                peaksSettings=graphical.Peaks;
                if~isempty(peaksSettings)
                    this.PeakFinder.Specification.setSettings(peaksSettings);
                end
            end

            if isfield(graphical,'SpectralMask')
                maskSettings=graphical.SpectralMask;
                if~isempty(maskSettings)
                    this.SpectralMask.Specification.setSettings(maskSettings);
                end
            end
        end

        function value=validateEnum(this,propName,value)
            value=validateEnum@dsp.webscopes.mixin.PropertyValueValidator(this,propName,value);
            if this.PhysicalModelingMode
                if strcmpi(propName,'SpectrumUnits')&&~strcmpi(this.SpectrumType,'RMS')
                    validValues={'dBm'};
                    ind=find(ismember(lower(validValues),lower(value))==1,1);
                    if isempty(ind)
                        validValuesStr=propertySetToStringList(this,validValues);
                        msgObj=message('shared_dspwebscopes:slspectrumanalyzer:propertyValueRequiresDSTLicense',propName,value,validValuesStr);
                        throwAsCaller(MException(msgObj));
                    end
                end
                if strcmpi(propName,'Window')
                    validValues={'Hann','Rectangular'};
                    ind=find(ismember(lower(validValues),lower(value))==1,1);
                    if isempty(ind)
                        validValuesStr=propertySetToStringList(this,validValues);
                        msgObj=message('shared_dspwebscopes:slspectrumanalyzer:propertyValueRequiresDSTLicense',propName,value,validValuesStr);
                        throwAsCaller(MException(msgObj));
                    end
                end
            end
        end

        function list=propertySetToStringList(~,set)
            set=string(set);
            list='';
            for i=1:numel(set)
                list=[list,newline,'    ','''',char(set(i)),''''];%#ok<AGROW>
            end
        end
    end



    methods(Access=private)

        function b=isSimulationRunning(this)

            simstatus=get_param(bdroot(this.BlockHandle),'SimulationStatus');
            b=~any(strcmpi(simstatus,{'stopped','initializing'}));
        end

        function flag=isVisualRendered(this)

            blockCOSI=get_param(this.BlockHandle,'BlockCOSI');
            flag=blockCOSI.IsVisualRendered;
        end

        function flag=isNewDataAvailable(this)

            flag=dsp.webscopes.internal.isNewDataAvailableImpl(this.ClientID);
        end

        function[value,errorID,errorMessage]=evaluateVariable(this,variableName)






            try
                value=slResolve(variableName,bdroot(getBlockName(this)));
                errorID='';
                errorMessage='';
            catch ME %#ok<NASGU>
                try
                    value=slResolve(variableName,getBlockName(this));
                    errorID='';
                    errorMessage='';
                catch ME1
                    if ischar(variableName)||(isstring(variableName)&&isscalar(variableName))
                        [value,errorID,errorMessage]=utils.evaluate(variableName);
                    else
                        value=variableName;
                        errorID=ME1.identifier;
                        errorMessage=ME1.message;
                    end
                end
            end
        end

        function[value,errorOccured]=evaluateString(this,strValue,propName)
            validateattributes(strValue,{'char'},{},'',propName);
            errorOccured=false;
            [value,~,errStr]=this.evaluateVariable(strValue);
            if~isempty(errStr)
                errorOccured=true;%#ok<NASGU>


                [errStr,errId]=utils.message('EvaluateUndefinedVariable',strValue);
                throw(MException(errId,errStr));
            end
        end

        function errorForNonTunableParam(this,paramName)

            if isSimulationRunning(this)

                msgObj=message('shared_dspwebscopes:slspectrumanalyzer:propertyNotTunable',...
                paramName,this.Name);
                throwAsCaller(MException(msgObj));
            end
        end

        function settings=getGraphicalSettingsStruct(this)


            graphicalSettings=get_param(this.BlockHandle,'GraphicalSettings');

            if isempty(graphicalSettings)
                settings=struct([]);
            else
                graphicalSettings=strrep(graphicalSettings,'''','"');
                settings=jsondecode(graphicalSettings);
            end
        end

        function webwindow=getWebWindow(this)

            modelHandle=get_param(get_param(this.BlockHandle,'Parent'),'Handle');
            allBlocks=matlabshared.scopes.WebScope.getAllInstancesForType(modelHandle,'SpectrumAnalyzerBlock');


            for bIdx=1:numel(allBlocks)
                if strcmp(allBlocks{bIdx}.Name,this.Name)
                    webwindow=allBlocks{bIdx}.WebWindow;
                    break;
                end
            end
        end

        function valid=isWebWindowValid(this)

            webwindow=getWebWindow(this);
            valid=isvalid(webwindow);
            if~isempty(webwindow)&&valid
                valid=webwindow.isWindowValid;
            end
        end

        function validatePropertyAccess(this,propName)


            if this.PhysicalModelingMode
                dstOnlyProps=getDSTOnlyProperties(this);
                if ismember(propName,dstOnlyProps)
                    msgObj=message('shared_dspwebscopes:slspectrumanalyzer:propertyAccessedWithoutDSTLicense',propName);
                    throwAsCaller(MException(msgObj));
                end
            end
        end

        function props=getDSTOnlyProperties(~)



            props={...
            'InputDomain',...
            'ViewType',...
            'Method',...
            'FrequencySpan',...
            'Span',...
            'CenterFrequency',...
            'StartFrequency',...
            'StopFrequency',...
            'FrequencyResolutionMethod',...
            'WindowLength',...
            'FFTLengthSource',...
            'FFTLength',...
            'NumTapsPerBand',...
            'FrequencyVector',...
            'FrequencyVectorSource',...
            'CustomWindow',...
            'SidelobeAttenuation',...
            'InputUnits',...
            'FullScaleSource',...
            'FullScale',...
'SpectrogramChannel'...
            ,'TimeResolutionSource',...
            'TimeResolution',...
            'TimeSpanSource',...
            'TimeSpan',...
            'ChannelMeasurements',...
            'CCDFMeasurements',...
            'SpectralMask',...
            'PlotNormalTrace',...
            'PlotMaxHoldTrace',...
            'PlotMinHoldTrace',...
            'ColorLimits',...
            'Colormap',...
            'ShowColorbar',...
            'AxesLayout'};
        end
    end



    methods(Access=protected)

        function groups=getPropertyGroups(this)

            mainProps=getValidDisplayProperties(this,{...
            'NumInputPorts',...
            'InputDomain',...
            'SpectrumType',...
            'ViewType',...
            'SampleRateSource',...
            'SampleRate',...
            'Method',...
            'PlotAsTwoSidedSpectrum',...
            'FrequencyScale',...
            'PlotType',...
            'AxesScaling',...
            'AxesScalingNumUpdates'});

            advancedProps=getValidDisplayProperties(this,{...
...
            'RBWSource',...
            'RBW',...
...
...
...
...
            'FrequencyVectorSource',...
            'FrequencyVector',...
            'FrequencySpan',...
            'Span',...
            'CenterFrequency',...
            'StartFrequency',...
            'StopFrequency',...
            'OverlapPercent',...
            'Window',...
            'CustomWindow',...
            'SidelobeAttenuation',...
            'AveragingMethod',...
            'ForgettingFactor',...
            'VBWSource',...
            'VBW',...
...
            'InputUnits',...
            'SpectrumUnits',...
            'FullScaleSource',...
            'FullScale',...
            'ReferenceLoad',...
            'FrequencyOffset',...
            'TreatMby1SignalsAsOneChannel'});

            spectrogramProps=getValidDisplayProperties(this,{'SpectrogramChannel',...
            'TimeResolutionSource',...
            'TimeResolution',...
            'TimeSpanSource',...
            'TimeSpan'});

            measurementsProps=getValidDisplayProperties(this,{'MeasurementChannel',...
            'ChannelMeasurements',...
            'CursorMeasurements',...
            'DistortionMeasurements',...
            'PeakFinder',...
            'SpectralMask'});

            visualizationProps=getValidDisplayProperties(this,{'Name',...
            'Position',...
            'MaximizeAxes',...
            'PlotNormalTrace',...
            'PlotMaxHoldTrace',...
            'PlotMinHoldTrace',...
            'Title',...
            'YLabel',...
            'YLimits',...
            'ColorLimits',...
            'Colormap',...
            'ShowGrid',...
            'ChannelNames',...
            'ShowLegend',...
            'ShowColorbar',...
            'AxesLayout',...
            'OpenAtSimulationStart',...
            'Visible'});

            if this.PhysicalModelingMode
                dstProps=getDSTOnlyProperties(this);
                mainProps=setdiff(mainProps,dstProps,'stable');
                advancedProps=setdiff(advancedProps,dstProps,'stable');
                spectrogramProps=setdiff(spectrogramProps,dstProps,'stable');
                measurementsProps=setdiff(measurementsProps,dstProps,'stable');
                visualizationProps=setdiff(visualizationProps,dstProps,'stable');
            end

            advancedGroupTitle=getString(message('shared_dspwebscopes:dspwebscopes:advancedProperties'));
            spectrogramGroupTitle=getString(message('shared_dspwebscopes:dspwebscopes:spectrogramProperties'));
            measurementsGroupTitle=getString(message('shared_dspwebscopes:dspwebscopes:measurementsProperties'));
            visualizationGroupTitle=getString(message('shared_dspwebscopes:dspwebscopes:visualizationProperties'));

            mainGroup=matlab.mixin.util.PropertyGroup(mainProps,'');
            advancedGroup=matlab.mixin.util.PropertyGroup(advancedProps,advancedGroupTitle);
            spectrogramGroup=matlab.mixin.util.PropertyGroup(spectrogramProps,spectrogramGroupTitle);
            measurementsGroup=matlab.mixin.util.PropertyGroup(measurementsProps,measurementsGroupTitle);
            visualizationGroup=matlab.mixin.util.PropertyGroup(visualizationProps,visualizationGroupTitle);

            groups=[mainGroup,advancedGroup,spectrogramGroup,measurementsGroup,visualizationGroup];
        end

        function validProps=getValidDisplayProperties(this,props)
            validProps={};
            for idx=1:numel(props)
                if~isInactiveProperty(this,props{idx})
                    validProps=[validProps,props{idx}];%#ok<AGROW>
                end
            end
        end


        function flag=isInactiveProperty(this,propName)
            flag=false;
            switch propName
            case 'SampleRate'
                flag=strcmpi(this.SampleRateSource,'Inherited');
            case 'AxesScalingNumUpdates'
                flag=~strcmpi(this.AxesScaling,'Updates');
            case{'SpectrumType','Method','FrequencyResolutionMethod','FrequencySpan'}
                flag=strcmpi(this.InputDomain,'Frequency');
            case 'RBW'
                flag=strcmpi(this.RBWSource,'Auto');
            case{'Span','CenterFrequency'}
                flag=any(strcmpi({'Full','Start and stop frequencies'},this.FrequencySpan))||strcmpi(this.InputDomain,'Frequency');
            case{'StartFrequency','StopFrequency'}
                flag=any(strcmpi({'Full','Span and center frequency'},this.FrequencySpan))||strcmpi(this.InputDomain,'Frequency');
            case 'FrequencyVectorSource'
                flag=strcmpi(this.InputDomain,'Time');
            case 'FrequencyVector'
                flag=strcmpi(this.InputDomain,'Time')||strcmpi(this.FrequencyVectorSource,'Auto');
            case 'FFTLengthSource'
                flag=strcmpi(this.FrequencyResolutionMethod,'RBW')||strcmpi(this.InputDomain,'Frequency');
            case 'FFTLength'
                flag=strcmpi(this.FrequencyResolutionMethod,'RBW')||strcmpi(this.FFTLengthSource,'Auto')||strcmpi(this.InputDomain,'Frequency');
            case 'SidelobeAttenuation'
                flag=~any(strcmpi({'Chebyshev','Kaiser'},this.Window))||strcmpi(this.Method,'Filter bank')||strcmpi(this.InputDomain,'Frequency');
            case 'InputUnits'
                flag=strcmpi(this.InputDomain,'Time');
            case{'PlotNormalTrace','PlotMaxHoldTrace','PlotMinHoldTrace'}
                flag=~isSpectrumMode(this);
            case{'YLimits','YLabel','ShowLegend'}
                flag=~isSpectrumMode(this);
            case 'AveragingMethod'
                flag=strcmpi(this.InputDomain,'Frequency');
            case 'SpectralAverages'
                flag=any(strcmpi(this.AveragingMethod,'Exponential','VBW'))||strcmpi(this.InputDomain,'Frequency');
            case 'ForgettingFactor'
                flag=any(strcmpi(this.AveragingMethod,{'Running','VBW'}))||strcmpi(this.InputDomain,'Frequency');
            case 'VBWSource'
                flag=any(strcmpi(this.AveragingMethod,{'Running','Exponential'}))||strcmpi(this.InputDomain,'Frequency');
            case 'VBW'
                flag=any(strcmpi(this.AveragingMethod,{'Running','Exponential'}))||strcmpi(this.InputDomain,'Frequency')||strcmpi(this.VBWSource,'Auto');
            case 'PlotType'
                flag=~isSpectrumMode(this)||~this.PlotNormalTrace;
            case 'TimeSpanSource'
                flag=~isSpectrogramMode(this);
            case 'TimeSpan'
                flag=~isSpectrogramMode(this)||strcmpi(this.TimeSpanSource,'Auto');
            case 'TimeResolutionSource'
                flag=~isSpectrogramMode(this)||strcmpi(this.InputDomain,'Frequency');
            case 'TimeResolution'
                flag=~isSpectrogramMode(this)||strcmpi(this.TimeResolutionSource,'Auto')||strcmpi(this.InputDomain,'Frequency');
            case 'AxesLayout'
                flag=~isDualViewMode(this);
            case 'ReferenceLoad'
                flag=strcmpi(this.SpectrumType,'RMS');
            case{'ColorLimits','Colormap','ShowColorbar'}
                flag=~isSpectrogramMode(this);
            case 'FullScale'
                flag=~any(strcmpi(this.SpectrumUnits,{'dBFS','dBFS/Hz'}))||strcmpi(this.FullScaleSource,'Auto');
            case 'FullScaleSource'
                flag=~any(strcmpi(this.SpectrumUnits,{'dBFS','dBFS/Hz'}));
            case{'Window','OverlapPercent'}
                flag=strcmpi(this.Method,'Filter bank')||strcmpi(this.InputDomain,'Frequency');
            case 'CustomWindow'
                flag=~strcmpi(this.Window,'Custom')||strcmpi(this.Method,'Filter bank')||strcmpi(this.InputDomain,'Frequency');
            case 'SpectrogramChannel'
                flag=~isSpectrogramMode(this);
            case 'SpectralMask'
                flag=~isSpectrumMode(this)||any(strcmpi(this.SpectrumUnits,{'Watts','Vrms','dBV'}))||strcmpi(this.SpectrumType,'RMS');
            case{'MeasurementChannel','PeakFinder','ChannelMeasurements','DistortionMeasurements','CursorMeasurements'}
                flag=~isSpectrumMode(this);
            end
        end

        function flag=isDualViewMode(this)
            flag=strcmpi(this.ViewType,'Spectrum and spectrogram');
        end

        function flag=isSpectrogramMode(this)
            flag=any(strcmpi(this.ViewType,{'Spectrogram','Spectrum and spectrogram'}));
        end

        function flag=isSpectrumMode(this)
            flag=any(strcmpi(this.ViewType,{'Spectrum','Spectrum and spectrogram'}));
        end

        function flag=isFrequencyInputDomain(this)
            flag=strcmpi(this.InputDomain,'Frequency');
        end

        function flag=hasPropertySet(this,propName)
            postfix='';
            if strcmpi(propName,'SpectrumUnits')
                postfix=getSpectrumUnitsPropertySetPostFix(this);
            end
            flag=isprop(this,[propName,postfix,'Set']);
        end

        function set=getPropertySet(this,propName)
            postfix='';
            if strcmpi(propName,'SpectrumUnits')
                postfix=getSpectrumUnitsPropertySetPostFix(this);
            end
            set=this.([propName,postfix,'Set']);
        end

        function postfix=getSpectrumUnitsPropertySetPostFix(this)
            if isFrequencyInputDomain(this)
                postfix='FrequencyDomain';
            else
                postfix='Power';
                if strcmpi(this.SpectrumType,'Power density')
                    postfix='PowerDensity';
                end

                if strcmpi(this.SpectrumType,'RMS')
                    postfix='RMS';
                end
            end
        end

        function addSpectrumMeasurementsConfiguration(this)


            this.ChannelMeasurements=ChannelMeasurementsConfiguration();
            this.ChannelMeasurements.ClientID=this.ClientID;

            this.CursorMeasurements=CursorMeasurementsConfiguration();
            this.CursorMeasurements.ClientID=this.ClientID;

            this.DistortionMeasurements=DistortionMeasurementsConfiguration();
            this.DistortionMeasurements.ClientID=this.ClientID;

            this.PeakFinder=PeakFinderConfiguration();
            this.PeakFinder.ClientID=this.ClientID;

            this.SpectralMask=SpectralMaskConfiguration();
            this.SpectralMask.ClientID=this.ClientID;
        end

        function allocateDataTables(this)

            this.CachedSpectrumData=table({[]},{[]},{[]},{[]},{[]},{[]},'VariableNames',...
            this.SpectrumDataFieldNames);
            if isempty(this.CachedSpectrumData.Properties.VariableUnits)
                units=this.SpectrumUnits;
                this.CachedSpectrumData.Properties.VariableUnits={
                's',...
                units,...
                units,...
                units,...
                units,...
                'Hz'};
            end

            this.CachedMeasurementsData=table({[]},{[]},{[]},{[]},{[]},'VariableNames',...
            this.MeasurementsDataFieldNames);
        end
    end
end