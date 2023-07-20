classdef SpectrumAnalyzerBaseWebScope<dsp.webscopes.internal.BaseWebScope&...
    dsp.webscopes.mixin.SpectrumMeasurementsConfigurable








    properties(Dependent)



        InputDomain;





        SpectrumType;




        ViewType;



        SampleRate;








        Method;





        PlotAsTwoSidedSpectrum;






        FrequencyScale;






        PlotType;













        AxesScaling;









        RBWSource;







        RBW;





        FilterSharpness;









        FrequencyVectorSource;







        FrequencyVector;






















        FrequencySpan;













        Span;














        CenterFrequency;













        StartFrequency;













        StopFrequency;







        OverlapPercent;







        Window;






        CustomWindow(1,:)char;






        SidelobeAttenuation;








        AveragingMethod;





        ForgettingFactor;








        VBWSource;





        VBW;





        InputUnits;


















        SpectrumUnits;









        FullScaleSource;






        FullScale;




        ReferenceLoad;


















        FrequencyOffset;





        SpectrogramChannel;


























        TimeResolutionSource;







        TimeResolution;











        TimeSpanSource;









        TimeSpan;








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









        ChannelNames;







        ShowLegend;





        ShowColorbar;





        AxesLayout;
    end

    properties(Dependent,Hidden,AbortSet)





        ShowSpectrum;





        ShowSpectrogram;



















        FrequencyResolutionMethod;









        WindowLength;











        FFTLengthSource;








        FFTLength;







        NumTapsPerBand;






        SpectralAverages;

        PowerUnits;

        ShowScreenMessages;

        DefaultSegmentLength;


        AllowTransientAveraging;


        UseWelchForFilterBankTransient;
    end

    properties(Hidden,AbortSet)

        ReducePlotRate=true;
    end

    properties(Constant,Hidden)
        InputDomainSet={'time','frequency'}
        SpectrumTypeSet={'power','power-density','rms'};
        SpectrumTypeObsoleteSet={'Power','Power density','RMS','Spectrogram'};
        ViewTypeSet={'spectrum','spectrogram','spectrum-and-spectrogram'};
        ViewTypeObsoleteSet={'Spectrum','Spectrogram','Spectrum and spectrogram'};
        MethodSet={'welch','filter-bank'};
        MethodObsoleteSet={'Welch','Filter bank'};
        FrequencyScaleSet={'linear','log'};
        PlotTypeSet={'line','stem'};
        AxesScalingSet={'auto','updates','manual','onceatstop'};
        FrequencyResolutionMethodSet={'rbw','window-length','num-frequency-bands'};
        FrequencyResolutionMethodObsoleteSet={'RBW','WindowLength','NumFrequencyBands'};
        RBWSourceSet={'auto','property'};
        FFTLengthSourceSet={'auto','property'};
        FrequencyVectorSourceSet={'auto','property'};
        WindowSet={'blackman-harris','chebyshev','flat-top','hamming','hann','kaiser','rectangular','custom'};
        WindowObsoleteSet={'Blackman-Harris','Chebyshev','Flat top','Hamming','Hann','Kaiser','Rectangular','Custom'};
        FrequencySpanSet={'full','span-and-center-frequency','start-and-stop-frequencies'};
        FrequencySpanObsoleteSet={'Full','Span and center frequency','Start and stop frequencies'};
        InputUnitsSet={'dBm','dBV','dBW','Vrms','Watts','none'};
        SpectrumUnitsPowerSet={'dBm','dBW','dBFS','Watts'};
        SpectrumUnitsPowerDensitySet={'dBm/Hz','dBW/Hz','dBFS/Hz','Watts/Hz'};
        SpectrumUnitsRMSSet={'dBV','Vrms'};
        SpectrumUnitsFrequencyDomainSet={'auto','dBm','dBV','dBW','Vrms','Watts'};
        FullScaleSourceSet={'auto','property'};
        AveragingMethodSet={'exponential','vbw'};
        AveragingMethodObsoleteSet={'Exponential','vbw','running'};
        VBWSourceSet={'auto','property'};
        TimeResolutionSourceSet={'auto','property'};
        TimeSpanSourceSet={'auto','property'};
        MaximizeAxesSet={'auto','on','off'};
        ColormapSet={'jet','hot','bone','cool','copper','gray','parula'};
        AxesLayoutSet={'vertical','horizontal'};
        DataTimeoutValue=0.05;
        MeasurementsTimeoutValue=2;
    end

    properties(Hidden,Access=protected)

        InputDataType='double';

        InputRange=-1;

        CachedSpectrumData=[];

        CachedEnabledViews=false(1,4);

        CachedMeasurementsData=[];

        CachedEnabledMeasurements=false(1,4);


        CachedSpectralMaskStatus=struct([]);


        AutoSpanFrequencies=true;


        AutoTimeResolution=true;

        AutoTimeSpan=true;
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



    methods


        function this=SpectrumAnalyzerBaseWebScope(varargin)
            this@dsp.webscopes.internal.BaseWebScope(...
            'TimeBased',true,...
            'Name','Spectrum Analyzer',...
            'Position',utils.getDefaultWebWindowPosition([800,500]),...
            'PlotType','Line',...
            'Tag','SpectrumAnalyzer',...
            varargin{:});

            this.NeedsTimedBuffer=false;

            addSpectrumMeasurementsConfiguration(this);

            this.allocateDataTables();
        end


        function set.InputDomain(this,value)
            this.validatePropertiesOnSet('InputDomain');
            value=validateEnum(this,'InputDomain',value);
            setPropertyValueAndNotify(this,'InputDomain',value);
        end
        function value=get.InputDomain(this)
            value=getPropertyValue(this,'InputDomain');
        end


        function set.SpectrumType(this,value)
            import dsp.webscopes.*;
            value=validateEnum(this,'SpectrumType',value);
            if strcmpi(value,'spectrogram')
                SpectrumAnalyzerBaseWebScope.localWarning('spectrumTypeSpectrogramObsolete');
                this.ViewType='spectrogram';
            else
                setPropertyValueAndNotify(this,'SpectrumType',value);
            end
        end
        function value=get.SpectrumType(this)
            value=getPropertyValue(this,'SpectrumType');
        end


        function set.ViewType(this,value)
            value=validateEnum(this,'ViewType',value);
            setPropertyValueAndNotify(this,'ViewType',value);
        end
        function value=get.ViewType(this)
            value=getPropertyValue(this,'ViewType');
        end


        function set.SampleRate(this,value)
            this.validatePropertiesOnSet('SampleRate');
            validateattributes(value,{'double'},{'positive','real','scalar','finite','nonnan'},'','SampleRate');
            this.SampleTime=1/value;
            setPropertyValueAndNotify(this,'SampleRate',value);
        end
        function value=get.SampleRate(this)
            value=getPropertyValue(this,'SampleRate');
        end


        function set.Method(this,value)
            this.validatePropertiesOnSet('Method');
            value=validateEnum(this,'Method',value);
            setPropertyValueAndNotify(this,'Method',value);
        end
        function value=get.Method(this)
            value=getPropertyValue(this,'Method');
        end


        function set.PlotAsTwoSidedSpectrum(this,value)
            this.validatePropertiesOnSet('PlotAsTwoSidedSpectrum');
            validateattributes(value,{'logical'},{'scalar'},'','PlotAsTwoSidedSpectrum');
            if value
                this.Offset=-1*this.SampleRate/2;
            else
                this.Offset=0;
            end

            if~value
                this.FrequencyScale='Linear';
            end
            setPropertyValueAndNotify(this,'PlotAsTwoSidedSpectrum',value);
        end
        function value=get.PlotAsTwoSidedSpectrum(this)
            value=getPropertyValue(this,'PlotAsTwoSidedSpectrum');
        end


        function set.FrequencyScale(this,value)
            import dsp.webscopes.*;
            value=validateEnum(this,'FrequencyScale',value);
            if this.PlotAsTwoSidedSpectrum&&strcmp(value,'log')&&~isFrequencyInputDomain(this)
                SpectrumAnalyzerBaseWebScope.localError('invalidFrequencyScale');
            end
            setPropertyValueAndNotify(this,'FrequencyScale',value);
        end
        function value=get.FrequencyScale(this)
            value=getPropertyValue(this,'FrequencyScale');
        end


        function set.PlotType(this,value)
            value=validateEnum(this,'PlotType',value);
            this.validatePropertiesOnSet('PlotType');
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


        function set.FrequencyResolutionMethod(this,value)
            value=validateEnum(this,'FrequencyResolutionMethod',value);
            setPropertyValue(this,'FrequencyResolutionMethod',value);
        end
        function value=get.FrequencyResolutionMethod(this)
            value=getPropertyValue(this,'FrequencyResolutionMethod');
        end


        function set.RBWSource(this,value)
            value=validateEnum(this,'RBWSource',value);
            setPropertyValueAndNotify(this,'RBWSource',value);
        end
        function value=get.RBWSource(this)
            value=getPropertyValue(this,'RBWSource');
        end


        function set.RBW(this,value)
            import dsp.webscopes.*;
            this.validatePropertiesOnSet('RBW');
            validateattributes(value,{'double'},{'positive','real','scalar','finite','nonnan'},'','RBW');

            if isLocked(this)&&strcmpi(this.RBWSource,'property')
                span=this.StopFrequency-this.StartFrequency;
                if(span/value)<=2
                    SpectrumAnalyzerBaseWebScope.localError('invalidSpanRBW')
                end
            end
            setPropertyValueAndNotify(this,'RBW',value);
        end
        function value=get.RBW(this)
            value=getPropertyValue(this,'RBW');
        end


        function set.FilterSharpness(this,value)
            validateattributes(value,{'double'},{'real','nonnegative','scalar','>=',0,'<=',1,'finite','nonnan'},'','FilterSharpness');
            setPropertyValueAndNotify(this,'FilterSharpness',value);


            N=dsp.webscopes.SpectrumAnalyzerBaseWebScope.filterSharpnessToNumTapsPerBand(value);
            this.Specification.NumTapsPerBand=N;
        end
        function value=get.FilterSharpness(this)
            value=getPropertyValue(this,'FilterSharpness');
        end


        function set.WindowLength(this,value)
            import dsp.webscopes.*;
            validateattributes(value,{'double'},{'positive','real','integer','scalar','>',2,'finite','nonnan'},'','WindowLength');
            if isLocked(this)&&~isInactiveProperty(this,'FFTLength')
                NFFT=this.FFTLength;
                if NFFT<value
                    SpectrumAnalyzerBaseWebScope.localError('invalidFFTLength');
                end
            end
            setPropertyValueAndNotify(this,'WindowLength',value);
        end
        function value=get.WindowLength(this)
            value=getPropertyValue(this,'WindowLength');
        end


        function set.FFTLengthSource(this,value)
            value=validateEnum(this,'FFTLengthSource',value);
            setPropertyValueAndNotify(this,'FFTLengthSource',value);
        end
        function value=get.FFTLengthSource(this)
            value=getPropertyValue(this,'FFTLengthSource');
        end


        function set.FFTLength(this,value)
            import dsp.webscopes.*;
            validateattributes(value,{'double'},{'positive','real','scalar','integer','finite','nonnan'},'','FFTLength');
            if isLocked(this)&&~isInactiveProperty(this,'FFTLength')
                if strcmp(this.FrequencyResolutionMethod,'window-length')

                    WL=this.WindowLength;
                    if value<WL
                        SpectrumAnalyzerBaseWebScope.localError('invalidFFTLength');
                    end
                else
                    if value<2
                        SpectrumAnalyzerBaseWebScope.localError('invalidNumFrequencyBands');
                    end
                end
            end
            setPropertyValueAndNotify(this,'FFTLength',value);
        end
        function value=get.FFTLength(this)
            value=getPropertyValue(this,'FFTLength');
        end


        function set.NumTapsPerBand(this,value)
            validateattributes(value,...
            {'numeric'},...
            {'finite','real','scalar','>',0,'integer','even'},...
            '','NumTapsPerBand');

            S=dsp.webscopes.SpectrumAnalyzerBaseWebScope.numTapsPerBandToFilterSharpness(value);
            this.Specification.FilterSharpness=S;
            setPropertyValueAndNotify(this,'NumTapsPerBand',value);
        end
        function value=get.NumTapsPerBand(this)
            value=getPropertyValue(this,'NumTapsPerBand');
        end


        function set.FrequencyVectorSource(this,value)
            value=validateEnum(this,'FrequencyVectorSource',value);
            this.validatePropertiesOnSet('FrequencyVectorSource');
            setPropertyValueAndNotify(this,'FrequencyVectorSource',value);
        end
        function value=get.FrequencyVectorSource(this)
            value=getPropertyValue(this,'FrequencyVectorSource');
        end


        function set.FrequencyVector(this,value)
            import dsp.webscopes.*;
            validateattributes(value,{'double'},{'real','vector','finite','nonnan','nonempty'},'','FrequencyVector');
            this.validatePropertiesOnSet('FrequencyVector');
            value=value(:)';
            if isscalar(value)||~issorted(value)||abs(min(diff(value)))==0


                SpectrumAnalyzerBaseWebScope.localError('invalidFrequencyVector');
            end
            setPropertyValueAndNotify(this,'FrequencyVector',value);
        end
        function value=get.FrequencyVector(this)
            value=getPropertyValue(this,'FrequencyVector');
        end


        function set.FrequencySpan(this,value)
            value=validateEnum(this,'FrequencySpan',value);
            this.validatePropertiesOnSet('FrequencySpan');
            setPropertyValueAndNotify(this,'FrequencySpan',value);
            updateSpanFrequencies(this);
        end
        function value=get.FrequencySpan(this)
            value=getPropertyValue(this,'FrequencySpan');
        end


        function set.Span(this,value)
            validateattributes(value,{'double'},{'positive','real','scalar','finite','nonnan'},'','Span');
            this.validatePropertiesOnSet('Span');
            if isLocked(this)&&~isInactiveProperty(this,'Span')



                span=value;
                Fstart=this.CenterFrequency-span/2;
                Fstop=this.CenterFrequency+span/2;
                validateSpan(this,Fstart,Fstop);
            end
            this.AutoSpanFrequencies=false;
            setPropertyValueAndNotify(this,'Span',value);
        end
        function value=get.Span(obj)
            value=getPropertyValue(obj,'Span');
        end


        function set.CenterFrequency(this,value)
            validateattributes(value,{'double'},{'real','scalar','finite','nonnan'},'','CenterFrequency');
            this.validatePropertiesOnSet('CenterFrequency');
            if isLocked(this)&&~isInactiveProperty(this,'CenterFrequency')



                CF=value;
                Fstart=CF-this.Span/2;
                Fstop=CF+this.Span/2;
                validateSpan(this,Fstart,Fstop);
            end
            this.AutoSpanFrequencies=false;
            setPropertyValueAndNotify(this,'CenterFrequency',value);
        end
        function value=get.CenterFrequency(obj)
            value=getPropertyValue(obj,'CenterFrequency');
        end


        function set.StartFrequency(this,value)
            validateattributes(value,{'double'},{'real','scalar','finite','nonnan'},'','StartFrequency');
            this.validatePropertiesOnSet('StartFrequency');
            if isLocked(this)&&~isInactiveProperty(this,'StartFrequency')



                Fstart=value;
                Fstop=this.StopFrequency;
                validateSpan(this,Fstart,Fstop);
            end
            this.AutoSpanFrequencies=false;
            setPropertyValueAndNotify(this,'StartFrequency',value);
        end
        function value=get.StartFrequency(this)
            value=getPropertyValue(this,'StartFrequency');
        end

        function set.StopFrequency(this,value)
            validateattributes(value,{'double'},{'real','scalar','finite','nonnan'},'','StopFrequency');
            this.validatePropertiesOnSet('StopFrequency');
            if isLocked(this)&&~isInactiveProperty(this,'StopFrequency')



                Fstart=this.StartFrequency;
                Fstop=value;
                validateSpan(this,Fstart,Fstop);
            end
            this.AutoSpanFrequencies=false;
            setPropertyValueAndNotify(this,'StopFrequency',value);
        end
        function value=get.StopFrequency(this)
            value=getPropertyValue(this,'StopFrequency');
        end


        function set.OverlapPercent(this,value)
            validateattributes(value,{'double'},{'real','nonnegative','scalar','finite','nonnan','>=',0,'<',100},'','OverlapPercent');
            setPropertyValueAndNotify(this,'OverlapPercent',value);
        end
        function value=get.OverlapPercent(this)
            value=getPropertyValue(this,'OverlapPercent');
        end


        function set.Window(this,value)
            value=validateEnum(this,'Window',value);
            setPropertyValueAndNotify(this,'Window',value);
            if this.SetupCalled&&strcmpi(value,'custom')
                setPropertyValueAndNotify(this,'CustomWindowValue',getCustomWindow(this));
            end
        end
        function value=get.Window(this)
            value=getPropertyValue(this,'Window');
        end


        function set.CustomWindow(this,value)
            this.validatePropertiesOnSet('Window');
            validateCustomWindow(this,value);
            setPropertyValue(this,'CustomWindow',value);
            setPropertyValueAndNotify(this,'CustomWindowValue',getCustomWindow(this));
        end
        function value=get.CustomWindow(this)
            value=getPropertyValue(this,'CustomWindow');
        end


        function set.SidelobeAttenuation(this,value)
            this.validatePropertiesOnSet('SidelobeAttenuation');
            validateattributes(value,{'double'},{'positive','real','scalar','finite','nonnan','>=',45},'','SidelobeAttenuation');
            setPropertyValueAndNotify(this,'SidelobeAttenuation',value);
        end
        function value=get.SidelobeAttenuation(this)
            value=getPropertyValue(this,'SidelobeAttenuation');
        end


        function set.AveragingMethod(this,value)
            value=validateEnum(this,'AveragingMethod',value);
            setPropertyValueAndNotify(this,'AveragingMethod',value);
        end
        function value=get.AveragingMethod(this)
            value=getPropertyValue(this,'AveragingMethod');
        end


        function set.ForgettingFactor(this,value)
            validateattributes(value,{'double'},{'real','nonnegative','scalar','>=',0,'<=',1,'finite','nonnan'},'','ForgettingFactor');
            setPropertyValueAndNotify(this,'ForgettingFactor',value);
        end
        function value=get.ForgettingFactor(this)
            value=getPropertyValue(this,'ForgettingFactor');
        end


        function set.VBWSource(this,value)
            value=validateEnum(this,'VBWSource',value);
            setPropertyValueAndNotify(this,'VBWSource',value);
        end
        function value=get.VBWSource(this)
            value=getPropertyValue(this,'VBWSource');
        end


        function set.VBW(this,value)
            validateattributes(value,{'double'},{'real','nonnegative','scalar','finite','nonnan'},'','VBW');
            setPropertyValueAndNotify(this,'VBW',value);
        end
        function value=get.VBW(this)
            value=getPropertyValue(this,'VBW');
        end


        function set.InputUnits(this,value)
            value=validateEnum(this,'InputUnits',value);
            setPropertyValueAndNotify(this,'InputUnits',value);
        end
        function value=get.InputUnits(this)
            value=getPropertyValue(this,'InputUnits');
        end


        function set.SpectrumUnits(this,value)




            if strcmpi(this.SpectrumType,'power-density')
                value=convertStringsToChars(value);
                if~contains(lower(value),'/hz')
                    value=[value,'/Hz'];
                end
            end
            value=validateEnum(this,'SpectrumUnits',value);
            setPropertyValueAndNotify(this,'SpectrumUnits',value);
        end
        function value=get.SpectrumUnits(this)
            value=getPropertyValue(this,'SpectrumUnits');
        end


        function set.FullScaleSource(this,value)
            value=validateEnum(this,'FullScaleSource',value);
            setPropertyValueAndNotify(this,'FullScaleSource',value);
        end
        function value=get.FullScaleSource(this)
            value=getPropertyValue(this,'FullScaleSource');
        end


        function set.FullScale(this,value)
            validateattributes(value,{'double'},{'positive','real','scalar','finite','nonnan'},'','FullScale');
            setPropertyValueAndNotify(this,'FullScale',value);
        end
        function value=get.FullScale(this)
            value=getPropertyValue(this,'FullScale');
        end


        function set.ReferenceLoad(this,value)
            validateattributes(value,{'double'},{'positive','real','scalar','finite','nonnan'},'','ReferenceLoad');
            setPropertyValueAndNotify(this,'ReferenceLoad',value);
        end
        function value=get.ReferenceLoad(this)
            value=getPropertyValue(this,'ReferenceLoad');
        end


        function set.FrequencyOffset(this,value)
            validateattributes(value,{'double'},{'real','vector','finite','nonnan'},'','FrequencyOffset');
            setPropertyValueAndNotify(this,'FrequencyOffset',value);
            if~isempty(this.SpectralMask)
                if this.SpectralMask.isEnabled()
                    validateSpectralMaskFrequencyLimits(this.SpectralMask);
                end
            end
        end
        function value=get.FrequencyOffset(this)
            value=getPropertyValue(this,'FrequencyOffset');
        end


        function set.SpectrogramChannel(this,value)
            import dsp.webscopes.*;
            validateattributes(value,{'numeric'},...
            {'real','scalar','integer','finite','nonnan','>',0,'<=',this.MaxNumChannels},'','SpectrogramChannel');
            if this.isLocked()
                numChannels=this.getNumChannels();
                if value>numChannels
                    SpectrumAnalyzerBaseWebScope.localError('invalidSpectrogramChannel',numChannels);
                end
            end
            setPropertyValueAndNotify(this,'SpectrogramChannel',value);
        end
        function value=get.SpectrogramChannel(this)
            value=getPropertyValue(this,'SpectrogramChannel');
        end


        function set.TimeResolutionSource(this,value)
            this.validatePropertiesOnSet('TimeResolutionSource');
            value=validateEnum(this,'TimeResolutionSource',value);
            setPropertyValueAndNotify(this,'TimeResolutionSource',value);
            updateTimeResolution(this);
        end
        function value=get.TimeResolutionSource(this)
            value=getPropertyValue(this,'TimeResolutionSource');
        end


        function set.TimeResolution(this,value)
            this.validatePropertiesOnSet('TimeResolution');
            validateattributes(value,{'double'},{'positive','real','scalar','finite','nonnan'},'','TimeResolution');
            this.AutoTimeResolution=false;
            setPropertyValueAndNotify(this,'TimeResolution',value);
        end
        function value=get.TimeResolution(this)
            value=getPropertyValue(this,'TimeResolution');
        end


        function set.TimeSpanSource(this,value)
            this.validatePropertiesOnSet('TimeSpanSource');
            value=validateEnum(this,'TimeSpanSource',value);
            setPropertyValueAndNotify(this,'TimeSpanSource',value);
            updateTimeSpan(this);
        end
        function value=get.TimeSpanSource(this)
            value=getPropertyValue(this,'TimeSpanSource');
        end


        function set.TimeSpan(this,value)
            this.validatePropertiesOnSet('TimeSpan');
            validateattributes(value,{'double'},{'positive','real','scalar','finite','nonnan'},'','TimeSpan');
            this.AutoTimeSpan=false;
            setPropertyValueAndNotify(this,'TimeSpan',value);
        end
        function value=get.TimeSpan(this)
            value=getPropertyValue(this,'TimeSpan');
        end


        function set.MaximizeAxes(this,value)
            value=validateEnum(this,'MaximizeAxes',value);
            setPropertyValueAndNotify(this,'MaximizeAxes',value);
        end
        function value=get.MaximizeAxes(this)
            value=getPropertyValue(this,'MaximizeAxes');
        end


        function set.PlotNormalTrace(this,value)
            this.validatePropertiesOnSet('PlotNormalTrace');
            validateattributes(value,{'logical'},{'scalar'},'','PlotNormalTrace');
            setPropertyValueAndNotify(this,'PlotNormalTrace',value);
        end
        function value=get.PlotNormalTrace(this)
            value=getPropertyValue(this,'PlotNormalTrace');
        end


        function set.PlotMaxHoldTrace(this,value)
            this.validatePropertiesOnSet('PlotMaxHoldTrace');
            validateattributes(value,{'logical'},{'scalar'},'','PlotMaxHoldTrace');
            setPropertyValueAndNotify(this,'PlotMaxHoldTrace',value);
        end
        function value=get.PlotMaxHoldTrace(this)
            value=getPropertyValue(this,'PlotMaxHoldTrace');
        end


        function set.PlotMinHoldTrace(this,value)
            this.validatePropertiesOnSet('PlotMinHoldTrace');
            validateattributes(value,{'logical'},{'scalar'},'','PlotMinHoldTrace');
            setPropertyValueAndNotify(this,'PlotMinHoldTrace',value);
        end
        function value=get.PlotMinHoldTrace(this)
            value=getPropertyValue(this,'PlotMinHoldTrace');
        end


        function set.Title(this,value)
            value=convertStringsToChars(value);
            validateattributes(value,{'string','char'},{'2d'},'','Title');
            setPropertyValueAndNotify(this,'Title',value);
        end
        function value=get.Title(this)
            value=getPropertyValue(this,'Title');
        end


        function set.YLabel(this,value)
            value=convertStringsToChars(value);
            validateattributes(value,{'string','char'},{'2d'},'','YLabel');
            setPropertyValueAndNotify(this,'YLabel',value);
        end
        function value=get.YLabel(this)
            value=getPropertyValue(this,'YLabel');
        end


        function set.YLimits(this,value)
            import dsp.webscopes.*;
            if~all(isnumeric(value))||~all(isfinite(value))||...
                numel(value)~=2||value(1)>=value(2)||any(~isreal(value))
                SpectrumAnalyzerBaseWebScope.localError('invalidYLimits');
            end
            setPropertyValueAndNotify(this,'AxesScaling','manual');
            setPropertyValueAndNotify(this,'YLimits',value);
        end
        function value=get.YLimits(this)
            value=getPropertyValue(this,'YLimits');
        end


        function set.ColorLimits(this,value)
            import dsp.webscopes.*;
            if~all(isnumeric(value))||~all(isfinite(value))||...
                numel(value)~=2||value(1)>=value(2)||any(~isreal(value))
                SpectrumAnalyzerBaseWebScope.localError('invalidColorLimits');
            end
            setPropertyValueAndNotify(this,'ColorLimits',value);
        end
        function value=get.ColorLimits(this)
            value=getPropertyValue(this,'ColorLimits');
        end


        function set.Colormap(this,value)
            if ischar(value)||isstring(value)
                value=validateEnum(this,'Colormap',value);
                valueNumeric=eval(value);
            else
                validateattributes(value,...
                {'numeric'},{'finite','real','ncols',3,'>=',0,'<=',1},'','Colormap');
                valueNumeric=value;
            end
            setPropertyValue(this,'Colormap',value);
            setPropertyValueAndNotify(this,'ColormapValue',valueNumeric);
        end
        function value=get.Colormap(this)
            value=getPropertyValue(this,'Colormap');
        end


        function set.ShowGrid(this,value)
            validateattributes(value,{'logical'},{'scalar'},'','ShowGrid');
            setPropertyValueAndNotify(this,'ShowGrid',value);
        end
        function value=get.ShowGrid(this)
            value=getPropertyValue(this,'ShowGrid');
        end


        function set.ChannelNames(this,value)
            import dsp.webscopes.*;
            validateattributes(value,{'string','cell'},{'vector'},'','ChannelNames');

            if(~isempty(value)&&(~isvector(value)||~iscellstr(cellstr(value))))
                SpectrumAnalyzerBaseWebScope.localError('invalidChannelNames');
            end
            value=cellstr(value);
            if this.ShowLegend
                setPropertyValueAndNotify(this,'ChannelNames',value);
            else
                setPropertyValue(this,'ChannelNames',value);
            end
        end
        function value=get.ChannelNames(this)
            value=getPropertyValue(this,'ChannelNames');
        end


        function set.ShowLegend(this,value)
            validateattributes(value,{'logical'},{'scalar'},'','ShowLegend');
            setPropertyValueAndNotify(this,'ShowLegend',value);
        end
        function value=get.ShowLegend(this)
            value=getPropertyValue(this,'ShowLegend');
        end


        function set.ShowColorbar(this,value)
            validateattributes(value,{'logical'},{'scalar'},'','ShowColorbar');
            setPropertyValueAndNotify(this,'ShowColorbar',value);
        end
        function value=get.ShowColorbar(this)
            value=getPropertyValue(this,'ShowColorbar');
        end


        function set.AxesLayout(this,value)
            value=validateEnum(this,'AxesLayout',value);
            setPropertyValueAndNotify(this,'AxesLayout',value);
        end
        function value=get.AxesLayout(this)
            value=getPropertyValue(this,'AxesLayout');
        end


        function set.ShowSpectrum(this,value)
            validateattributes(value,{'logical'},{'scalar'},'','ShowSpectrum');
            setPropertyValueAndNotify(this,'ShowSpectrum',value);
        end
        function value=get.ShowSpectrum(this)
            value=getPropertyValue(this,'ShowSpectrum');
        end


        function set.ShowSpectrogram(this,value)
            validateattributes(value,{'logical'},{'scalar'},'','ShowSpectrogram');
            setPropertyValueAndNotify(this,'ShowSpectrogram',value);
        end
        function value=get.ShowSpectrogram(this)
            value=getPropertyValue(this,'ShowSpectrogram');
        end


        function set.SpectralAverages(this,value)
            validateattributes(value,{'double'},{'positive','real','scalar','integer','finite','nonnan'},'','SpectralAverages');
            validatePropertiesOnSet(this,'SpectralAverages');
            setPropertyValueAndNotify(this,'SpectralAverages',value);
        end
        function value=get.SpectralAverages(this)
            value=getPropertyValue(this,'SpectralAverages');
        end


        function set.PowerUnits(this,value)
            import dsp.webscopes.*;
            this.SpectrumUnits=value;

        end
        function value=get.PowerUnits(this)
            import dsp.webscopes.*;
            value=this.SpectrumUnits;

        end


        function set.ShowScreenMessages(this,value)
            validateattributes(value,{'logical'},{'scalar'},'','ShowScreenMessages');
            setPropertyValue(this,'ShowScreenMessages',value);
        end
        function value=get.ShowScreenMessages(this)
            value=getPropertyValue(this,'ShowScreenMessages');
        end


        function set.DefaultSegmentLength(this,value)
            import dsp.webscopes.*;
            this.validatePropertiesOnSet('DefaultSegmentLength');
            validateattributes(value,{'double'},{'positive','real','scalar','integer','finite','nonnan'},'','DefaultSegmentLength');
            setPropertyValue(this,'DefaultSegmentLength',value);
        end
        function value=get.DefaultSegmentLength(this)
            value=getPropertyValue(this,'DefaultSegmentLength');
        end


        function set.AllowTransientAveraging(this,value)
            this.validatePropertiesOnSet('AllowTransientAveraging');
            validateattributes(value,{'logical'},{'scalar'},'','AllowTransientAveraging');
            setPropertyValue(this,'AllowTransientAveraging',value);
        end
        function value=get.AllowTransientAveraging(this)
            value=getPropertyValue(this,'AllowTransientAveraging');
        end


        function set.UseWelchForFilterBankTransient(this,value)
            this.validatePropertiesOnSet('AllowTransientAveraging');
            validateattributes(value,{'logical'},{'scalar'},'','UseWelchForFilterBankTransient');
            setPropertyValue(this,'UseWelchForFilterBankTransient',value);
        end
        function value=get.UseWelchForFilterBankTransient(this)
            value=getPropertyValue(this,'UseWelchForFilterBankTransient');
        end


        function set.ReducePlotRate(~,~)


        end

        function maskStatus=getSpectralMaskStatus(this)




















            maskStatus=this.CachedSpectralMaskStatus;
            if(this.SpectralMask.isEnabled()&&~this.ResetCalled&&(isLocked(this)||this.ReleaseCalled))
                clientID=this.MessageHandler.ClientId;
                newData=dsp.webscopes.SpectrumAnalyzerBaseWebScope.isNewSpectralMaskTesterDataReadyBlocking(clientID);
                if newData
                    maskStatus=dsp.webscopes.measurements.getSpectralMaskStatusImpl(clientID);
                    this.CachedSpectralMaskStatus=maskStatus;
                end
            end
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
            if(~this.ResetCalled&&(isLocked(this)||this.ReleaseCalled))


                clientID=this.MessageHandler.ClientId;
                newData=dsp.webscopes.SpectrumAnalyzerBaseWebScope.isNewDataReadyBlocking(clientID);
                if newData
                    [simTime,...
                    data.FrequencyVector{1},...
                    data.Spectrum{1},...
                    spectrogramData,...
                    data.MinHoldTrace{1},...
                    data.MaxHoldTrace{1},~,...
                    spectrumLength,...
                    numSegments,...
                    numSpectrogramLines]=dsp.webscopes.internal.getSpectrumDataImpl(clientID);
                    if this.ShowSpectrogram
                        if(isempty(data.Spectrogram{1}))
                            data.Spectrogram{1}=zeros(numSpectrogramLines,spectrumLength);
                        end

                        data.Spectrogram{1}=circshift(data.Spectrogram{1},numSegments);


                        if~isempty(spectrogramData)
                            data.Spectrogram{1}(1:numSegments,:)=flipud(reshape(spectrogramData,spectrumLength,numSegments).');
                        end
                    end

                    data.SimulationTime{1}=simTime;

                    data.FrequencyVector{1}=data.FrequencyVector{1}+this.FrequencyOffset;
                    enabledViews=[this.ShowSpectrum&&this.PlotNormalTrace,this.ShowSpectrogram,this.PlotMinHoldTrace,this.PlotMaxHoldTrace];

                    this.CachedSpectrumData=data;

                    this.CachedEnabledViews=enabledViews;
                end
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
            if(~this.ResetCalled&&(isLocked(this)||this.ReleaseCalled))
                clientID=this.MessageHandler.ClientId;
                newData=dsp.webscopes.SpectrumAnalyzerBaseWebScope.isNewDataReadyBlocking(clientID);
                if newData

                    data.SimulationTime={dsp.webscopes.internal.getSimulationTimeImpl(clientID)};

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

        function flag=isNewDataReady(this)




            flag=false;
            if(isLocked(this))
                flag=dsp.webscopes.SpectrumAnalyzerBaseWebScope.isNewDataReadyBlocking(this.MessageHandler.ClientId)&&~this.ResetCalled;
            end
        end

        function reset(this)
            reset@dsp.webscopes.internal.BaseWebScope(this);
            if(this.isLocked)
                this.allocateDataTables();
                this.CachedEnabledViews=false(1,4);
                this.CachedEnabledMeasurements=false(1,4);
            end
        end

    end



    methods(Access=protected)


        function h=getMessageHandler(~)
            h=dsp.webscopes.internal.SpectrumAnalyzerWebScopeMessageHandler;
        end

        function validateClientInputs(this,data)

            import dsp.webscopes.*;

            x=data{:};
            if~ismatrix(x)
                SpectrumAnalyzerBaseWebScope.localError('invalidInputDims');
            end

            if this.NumInputPorts>1
                [frameLength,~]=cellfun(@size,data);
                if numel(unique(frameLength))~=1
                    SpectrumAnalyzerBaseWebScope.localError('frameSizesDiffer');
                end
            else
                frameLength=size(x,1);
            end

            if this.isFrequencyInputDomain()
                if~any(isreal(x))
                    SpectrumAnalyzerBaseWebScope.localError('invalidInputDomainComplexity');
                end
                if strcmpi(this.FrequencyVectorSource,'property')&&numel(this.FrequencyVector)~=frameLength
                    SpectrumAnalyzerBaseWebScope.localError('invalidFrequencyVectorForInputFrameSize');
                end
            end


            if(size(x,1)==1&&strcmp(this.FrequencyResolutionMethod,'num-frequency-bands')...
                &&strcmp(this.FFTLengthSource,'auto'))||(size(x,1)==1&&strcmp(this.InputDomain,'frequency'))
                SpectrumAnalyzerBaseWebScope.localError('scalarInput');
            end

            this.InputDataType=cell(1,this.NumInputPorts);

            cacheInputRange(this,data);

            updateSpanFrequencies(this);
        end

        function validatePropertiesOnSet(this,propName)

            import dsp.webscopes.*;
            validatePropertiesOnSet@dsp.webscopes.internal.BaseWebScope(this,propName);
            switch propName
            case{'InputDomain','SampleRate','PlotAsTwoSidedSpectrum','DefaultSegmentLength','AllowTransientAveraging','UseWelchForFilterBankTransient'}
                if(this.isLocked)
                    SpectrumAnalyzerBaseWebScope.localError('propertySetWhenLocked',propName);
                end
            otherwise
                if isInactiveProperty(this,propName)&&this.WarnOnInactivePropertySet
                    SpectrumAnalyzerBaseWebScope.localWarning('nonRelevantProperty',propName);
                end
            end
        end

        function validatePropertiesOnSetup(this,~)

            import dsp.webscopes.*;
            validatePropertiesOnSetup@dsp.webscopes.internal.BaseWebScope(this);

            Fstart=getFstart(this);
            Fstop=getFstop(this);
            validateSpan(this,Fstart,Fstop);
            numChannels=getNumChannels(this);

            if this.SpectrogramChannel>numChannels
                SpectrumAnalyzerBaseWebScope.localError('invalidSpectrogramChannel',numChannels);
            end

            if~this.isFrequencyInputDomain()&&strcmp(this.AveragingMethod,'vbw')&&strcmp(this.VBWSource,'property')&&2*this.VBW/this.SampleRate>1
                [nyquistVal,~,nyquistUnit]=engunits(this.SampleRate/2);
                SpectrumAnalyzerBaseWebScope.localError('invalidVBWSampleRateRatio',nyquistVal,nyquistUnit);
            end

            if~this.PlotMaxHoldTrace&&~this.PlotMinHoldTrace&&~this.PlotNormalTrace
                SpectrumAnalyzerBaseWebScope.localError('allTracesOff');
            end

            if strcmpi(this.SpectralMask.ReferenceLevel,'spectrum-peak')
                if this.SpectralMask.SelectedChannel>numChannels
                    SpectrumAnalyzerBaseWebScope.localError('invalidMaskChannelNumber',numChannels);
                end
            end


            if~this.PlotAsTwoSidedSpectrum&&any(this.IsInputComplex)
                SpectrumAnalyzerBaseWebScope.localError('invalidPlotAsTwoSidedSpectrum');
            end

            this.Specification.CustomWindowValue=getCustomWindow(this);
        end

        function validateSpan(this,Fstart,Fstop,RBW,rbwSrc)
            import dsp.webscopes.*;
            if nargin<4
                RBW=this.RBW;
            end
            if nargin<5
                rbwSrc=this.RBWSource;
            end
            if Fstart>=Fstop
                SpectrumAnalyzerBaseWebScope.localError('FstartGreaterThanFstop');
            end
            FO=this.FrequencyOffset;
            NyquistRange=[(-this.SampleRate/2)*this.PlotAsTwoSidedSpectrum,this.SampleRate/2]+[min(FO),max(FO)];
            if(Fstart<NyquistRange(1))||(Fstop>NyquistRange(2))


                [NyquistRange,~,unitsNyquistRange]=engunits(NyquistRange);
                [spanRange,~,unitsSpanRange]=engunits([Fstart,Fstop]);
                switch this.FrequencySpan
                case 'span-and-center-frequency'
                    SpectrumAnalyzerBaseWebScope.localError('invalidSpanAndCenterFrequency',...
                    num2str(spanRange(1)),num2str(spanRange(2)),unitsSpanRange,...
                    num2str(NyquistRange(1)),num2str(NyquistRange(2)),unitsNyquistRange);
                case 'start-and-stop-frequencies'
                    SpectrumAnalyzerBaseWebScope.localError('invalidStartAndStopFrequencies',...
                    num2str(spanRange(1)),num2str(spanRange(2)),unitsSpanRange,...
                    num2str(NyquistRange(1)),num2str(NyquistRange(2)),unitsNyquistRange);
                end
            end

            if strcmp(rbwSrc,'property')
                span=Fstop-Fstart;
                if(span/RBW)<=2
                    SpectrumAnalyzerBaseWebScope.localError('invalidSpanRBW')
                end
            end
        end

        function validateCustomWindow(~,value)
            import dsp.webscopes.*;
            if any(strcmpi(value,{'blackman','blackmanharris','flattopwin','hamming','hann','nuttallwin'}))




                try
                    feval(value,10,'periodic');
                catch








                    SpectrumAnalyzerBaseWebScope.localError('invalidCustomWindowShadowing',value);
                end
            else
                try



                    winValue=feval(value,10);
                    if~isa(winValue,'double')&&numel(winValue)~=10
                        SpectrumAnalyzerBaseWebScope.localError('invalidCustomWindowName',value);
                    end

                    if numel(winValue)~=10||isrow(winValue)
                        SpectrumAnalyzerBaseWebScope.localError('invalidCustomWindowDimensions',value)
                    end
                catch ME
                    switch ME.identifier
                    case 'MATLAB:UndefinedFunction'


                        errMsgId='undefinedCustomWindowName';
                    case{'MATLAB:minrhs','MATLAB:TooManyInputs'}


                        errMsgId='InvalidCustomWindowNotEnoughArgs';
                    case 'shared_dspwebscopes:spectrumanalyzer:invalidCustomWindowDimensions'



                        errMsgId='invalidCustomWindowDimensions';
                    otherwise


                        errMsgId='invalidCustomWindowName';
                    end
                    SpectrumAnalyzerBaseWebScope.localError(errMsgId,value);
                end
            end
        end


        function value=getDataProcessingStrategy(~)
            value='dsp_webscope_frequency_data_strategy';
        end

        function optionList=addFilterProperties(this,optionList)
            optionList.inputDomain=this.InputDomain;
            optionList.spectrumType=this.SpectrumType;
            optionList.showSpectrum=this.ShowSpectrum;
            optionList.showSpectrogram=this.ShowSpectrogram;
            optionList.sampleRate=this.SampleRate;
            optionList.frequencyOffset=getFrequencyOffset(this);
            optionList.method=this.Method;
            optionList.frequencyRange=getFrequencyRange(this);
            optionList.frequencyResolutionMethod=this.FrequencyResolutionMethod;
            optionList.defaultSegmentLength=int32(this.DefaultSegmentLength);
            optionList.autoRBW=strcmpi(this.RBWSource,'auto');
            optionList.rbw=this.RBW;
            optionList.autoFFTLength=strcmpi(this.FFTLengthSource,'auto');
            optionList.fftLength=int32(this.FFTLength);
            optionList.autoFrequencyVector=isAutoFrequencyVectorMode(this);
            optionList.frequencyVector=this.FrequencyVector;
            optionList.inputUnits=lower(this.InputUnits);
            optionList.numTapsPerBand=int32(this.NumTapsPerBand);
            optionList.windowLength=int32(this.WindowLength);
            optionList.frequencySpan=this.FrequencySpan;
            optionList.span=this.Span;
            optionList.centerFrequency=this.CenterFrequency;
            optionList.startFrequency=this.StartFrequency;
            optionList.stopFrequency=this.StopFrequency;
            optionList.overlapPercent=this.OverlapPercent;
            optionList.window=this.Window;
            optionList.customWindow=getPropertyValue(this,'CustomWindowValue');
            optionList.sidelobeAttenuation=this.SidelobeAttenuation;
            optionList.averagingMethod=lower(this.AveragingMethod);
            optionList.forgettingFactor=this.ForgettingFactor;
            optionList.autoVBW=strcmpi(this.VBWSource,'auto');
            optionList.vbw=this.VBW;
            optionList.spectralAverages=int32(this.SpectralAverages);
            optionList.spectrumUnits=lower(this.SpectrumUnits);
            optionList.referenceLoad=this.ReferenceLoad;
            optionList.autoFullScale=strcmpi(this.FullScaleSource,'auto');
            optionList.fullScale=this.FullScale;
            optionList.plotMaxHoldTrace=this.PlotMaxHoldTrace;
            optionList.plotMinHoldTrace=this.PlotMinHoldTrace;
            optionList.spectrogramChannel=int32(this.SpectrogramChannel-1);
            optionList.autoTimeSpan=strcmpi(this.TimeSpanSource,'auto');
            optionList.timeSpan=this.TimeSpan;
            optionList.autoTimeResolution=strcmpi(this.TimeResolutionSource,'auto');
            optionList.timeResolution=this.TimeResolution;
            optionList.inputDataType=string(this.InputDataType);
            optionList.inputRange=this.InputRange;
            optionList.magPhaseData=false;
            optionList.autoSpan=true;
            optionList.customSpan=this.SampleRate/2;
            optionList.allowTransientAveraging=this.AllowTransientAveraging;
            optionList.useWelchForFilterBankTransient=this.UseWelchForFilterBankTransient;

            optionList.spectralMaskEnabled=this.SpectralMask.isEnabled();



            optionList.releaseAllResources=true;
        end

        function optionList=addOnStartProperties(this,optionList)
            optionList.numSamplesPerUpdate=getInputSamplesPerUpdate(this);
        end

        function optionList=addStreamingOptions(~,optionList)


            optionList.bufferLength=Inf;
        end

        function groups=getPropertyGroups(this)

            mainProps=getValidDisplayProperties(this,{'InputDomain',...
            'SpectrumType',...
            'ViewType',...
            'SampleRate',...
            'Method',...
            'PlotAsTwoSidedSpectrum',...
            'FrequencyScale',...
            'PlotType',...
            'AxesScaling',...
            'AxesScalingNumUpdates'});
            groups=matlab.mixin.util.PropertyGroup(mainProps,'');

            if(this.ShowAllProperties)


                advancedProps=getValidDisplayProperties(this,{'RBWSource',...
                'RBW',...
                'FilterSharpness',...
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
                'InputUnits',...
                'SpectrumUnits',...
                'FullScaleSource',...
                'FullScale',...
                'ReferenceLoad',...
                'FrequencyOffset'});

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
                'AxesLayout'});

                advancedGroupTitle=getString(message('shared_dspwebscopes:dspwebscopes:advancedProperties'));
                spectrogramGroupTitle=getString(message('shared_dspwebscopes:dspwebscopes:spectrogramProperties'));
                measurementsGroupTitle=getString(message('shared_dspwebscopes:dspwebscopes:measurementsProperties'));
                visualizationGroupTitle=getString(message('shared_dspwebscopes:dspwebscopes:visualizationProperties'));

                groups=[groups,...
                matlab.mixin.util.PropertyGroup(advancedProps,advancedGroupTitle),...
                matlab.mixin.util.PropertyGroup(spectrogramProps,spectrogramGroupTitle),...
                matlab.mixin.util.PropertyGroup(measurementsProps,measurementsGroupTitle),...
                matlab.mixin.util.PropertyGroup(visualizationProps,visualizationGroupTitle)];
            end
        end

        function updateSampleTimeAndOffset(this)


            this.SampleTime=1/this.SampleRate.*ones(1,this.NumInputPorts);
            this.Offset=this.FrequencyOffset.*ones(1,this.NumInputPorts);
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
                if strcmpi(this.SpectrumType,'power-density')
                    postfix='PowerDensity';
                end

                if strcmpi(this.SpectrumType,'rms')
                    postfix='RMS';
                end
            end
        end

        function isTimeBased=isTimeBased(~)
            isTimeBased=true;
        end

        function S=saveobj(this)
            S=saveobj@dsp.webscopes.internal.BaseWebScope(this);
            S.ChannelMeasurements=this.Specification.ChannelMeasurements.toStruct();
            S.CursorMeasurements=this.Specification.CursorMeasurements.toStruct();
            S.DistortionMeasurements=this.Specification.DistortionMeasurements.toStruct();
            S.PeakFinder=this.Specification.PeakFinder.toStruct();
            S.SpectralMask=this.Specification.SpectralMask.toStruct();
            S.InputDataType=this.InputDataType;
            S.InputRange=this.InputRange;
            S.AutoSpanFrequencies=this.AutoSpanFrequencies;
            S.AutoTimeResolution=this.AutoTimeResolution;
            S.AutoTimeSpan=this.AutoTimeSpan;
        end

        function createScopeView(this)
            this.ScopeView=dsp.webscopes.view.SpectrumAnalyzerView(this.MessageHandler,this.getFullUrl());
            show(this.ScopeView);
        end
    end



    methods(Access=private)

        function span=getSpan(this)
            span=getFstop(this)-getFstart(this);
        end

        function fstart=getFstart(this)
            Fs=this.SampleRate;
            if strcmp(this.FrequencySpan,'full')
                fstart=-Fs/2*this.PlotAsTwoSidedSpectrum;
            elseif strcmp(this.FrequencySpan,'span-and-center-frequency')
                if~this.PlotAsTwoSidedSpectrum&&this.CenterFrequency==0
                    fstart=0;
                else
                    fstart=this.CenterFrequency-this.Span/2;
                end
            else
                fstart=this.StartFrequency;
            end
        end

        function fstop=getFstop(this)
            Fs=this.SampleRate;
            if strcmp(this.FrequencySpan,'full')
                fstop=Fs/2;
            elseif strcmp(this.FrequencySpan,'span-and-center-frequency')
                if~this.PlotAsTwoSidedSpectrum&&this.CenterFrequency==0
                    fstop=this.Span;
                else
                    fstop=this.CenterFrequency+this.Span/2;
                end
            else
                fstop=this.StopFrequency;
            end
        end

        function flag=isFrequencyInputDomain(this)
            flag=strcmpi(this.InputDomain,'frequency');
        end

        function flag=isAutoFrequencyVectorMode(this)
            freqDomain=isFrequencyInputDomain(this);
            flag=(freqDomain&&strcmpi(this.FrequencyVectorSource,'auto'))||~freqDomain;
        end

        function range=getFrequencyRange(this)
            range='one-sided';
            if this.PlotAsTwoSidedSpectrum
                range='centered';
            end
        end

        function cacheInputRange(this,data)

            for indx=1:this.NumInputPorts
                if isempty(data{indx})
                    return;
                end
                dataType=class(data{indx});
                this.InputDataType{indx}=dataType;
                switch dataType
                case{'double','float'}


                    this.InputRange(indx)=abs(max(data{indx},[],'all'));
                case{'uint8','int8','uint16','int16','uint32','int32','uint64','int64'}



                    this.InputRange(indx)=double(intmax(dataType));
                case 'embedded.fi'



                    range=data{indx}.range;
                    this.InputRange(indx)=double(range(2));
                end
            end
        end

        function win=getCustomWindow(this)
            win=[];
            if strcmpi(this.Window,'custom')
                win=dsp.webscopes.SpectrumAnalyzerBaseWebScope.evaluateCustomWindow(this.CustomWindow,...
                struct('sampleRate',this.SampleRate,...
                'rbw',this.getRBW(),...
                'method',this.Method,...
                'window',this.Window,...
                'sidelobeAttenuation',this.SidelobeAttenuation));
            end
        end

        function RBW=getRBW(this)
            if strcmp(this.RBWSource,'auto')
                RBW=getSpan(this)/this.DefaultSegmentLength;
            else
                RBW=this.RBW;
            end
        end

        function offset=getFrequencyOffset(this)
            n=this.getNumChannels();
            if n==-1
                offset=this.FrequencyOffset;
            else
                offset=zeros(1,n);
                if numel(this.FrequencyOffset)>n
                    offset(1:n)=this.FrequencyOffset(1,1:n);
                elseif numel(this.FrequencyOffset)==1
                    offset(1:n)=this.FrequencyOffset;
                else
                    offset(1:numel(this.FrequencyOffset))=this.FrequencyOffset;
                end
            end
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

        function updateSpanFrequencies(this)
            if this.AutoSpanFrequencies



                updateSpanFrequencies(this.Specification);
            end
        end

        function updateTimeResolution(this)
            if this.AutoTimeResolution&&isLocked(this)
                this.Specification.TimeResolution=1/this.getRBW();
            end
        end

        function updateTimeSpan(this)
            if this.AutoTimeSpan&&isLocked(this)
                this.Specification.TimeSpan=getInputSamplesPerUpdate(this)/this.SampleRate*100;
            end
        end
    end



    methods(Access=public,Hidden)
        function sc=constructScopeApplicationComponent(this,application)
            sc=dsp.webscopes.view.SpectrumAnalyzerContainerView(application,this);
        end

        function forceSynchronous(this)
            if isLocked(this)
                msg=this.MessageHandler;
                texp=dsp.webscopes.internal.getSimulationTimeImpl(msg.ClientId);
                t=tic;
                simTime=-inf;
                while~isempty(simTime)&&texp>simTime&&toc(t)<10
                    simTime=getProperty(msg,'simTime','spectrumAnalyzer');
                end
                pause(1);
            end



            t=this.LastWriteTime;
            timeToWait=0.3;
            if this.ShowSpectrogram
                timeToWait=timeToWait+double(this.getNumChannels())*0.3;
            end
            while toc(t)<timeToWait
            end
        end

        function str=getQueryString(this,varargin)

            str=getQueryString@dsp.webscopes.internal.BaseWebScope(this,...
            'ShowScreenMessages',utils.logicalToOnOff(this.ShowScreenMessages),...
            varargin{:});
        end

        function value=getInputSamplesPerUpdate(this)
            value=dsp.webscopes.SpectrumAnalyzerBaseWebScope.getNumSamplesPerUpdate(this.SampleRate,...
            this.getRBW(),this.Method,this.Window,this.CustomWindow,this.SidelobeAttenuation);
        end


        function spec=getScopeSpecification(this)
            spec=this.Specification;
            if isempty(spec)
                spec=dsp.webscopes.internal.SpectrumAnalyzerWebScopeSpecification();
            end
        end
    end



    methods(Static,Hidden)
        function this=loadobj(S_load)
            import dsp.webscopes.internal.*;
            import dsp.webscopes.*;

            if(BaseWebScope.isSavedAsUnifiedScope(S_load))



                S.class=BaseWebScope.getUnifiedScopeClassName(S_load);
                cfg=BaseWebScope.getUnifiedScopeConfiguration(S_load);
                scopeCfg=cfg.ScopeConfig;
                propNames=intersect(cfg.ScopeConfig.PropertyNames,...
                SpectrumAnalyzerBaseWebScope.getValidPropertyNames,'stable');


                for idx=1:numel(propNames)
                    propName=propNames{idx};
                    specPropName=SpectrumAnalyzerBaseWebScope.mapObsoletePropertyName(propName);
                    if any(strcmpi(propName,{'SampleRate','FrequencyOffset'}))
                        S.Specification.(specPropName)=str2double(scopeCfg.getValue(propName));
                    else
                        S.Specification.(specPropName)=scopeCfg.getValue(propName);
                    end
                end

                S.Specification.NumInputPorts=cfg.NumInputPorts;

                S.Visible=utils.onOffToLogical(cfg.Visible);

                S.MessageHandler.GraphicalSettings=[];
                S.MessageHandler.ClientSettings=[];
                S.MessageHandler.CallMethodCache={};
                S.MessageHandler.InputIds=cellstr(matlab.lang.internal.uuid(1,S.Specification.NumInputPorts));
                S.MessageHandler.GraphicalSettingsStale=false;
                S.MessageHandler.ClientSettingsStale=false;
            else
                S=S_load;
            end

            this=loadobj@dsp.webscopes.internal.BaseWebScope(S);
            if(isfield(S,'InputDataType'))
                this.InputDataType=S.InputDataType;
            end
            if(isfield(S,'InputRange'))
                this.InputRange=this.InputRange;
            end
            if(isfield(S,'AutoSpanFrequencies'))
                this.AutoSpanFrequencies=S.AutoSpanFrequencies;
            end
            if(isfield(S,'AutoTimeResolution'))
                this.AutoTimeResolution=S.AutoTimeResolution;
            end
            if(isfield(S,'AutoTimeSpan'))
                this.AutoTimeSpan=S.AutoTimeSpan;
            end
            if(isfield(S,'ChannelMeasurements'))
                this.Specification.ChannelMeasurements.fromStruct(S.ChannelMeasurements);
            end
            if(isfield(S,'CursorMeasurements'))
                this.Specification.CursorMeasurements.fromStruct(S.CursorMeasurements);
            end
            if(isfield(S,'DistortionMeasurements'))
                this.Specification.DistortionMeasurements.fromStruct(S.DistortionMeasurements);
            end
            if(isfield(S,'PeakFinder'))
                this.Specification.PeakFinder.fromStruct(S.PeakFinder);
            end
            if(isfield(S,'SpectralMask'))
                this.Specification.SpectralMask.fromStruct(S.SpectralMask);
            end
            if isfield(S,'ScopeLocked')
                this.ScopeLocked=S.ScopeLocked;
            end

            if(S.Visible)
                this.show();
            end
        end

        function propNames=getValidPropertyNames(~)


            propNames=properties('dsp.webscopes.SpectrumAnalyzerBaseWebScope');
            propNames{end+1}='PowerUnits';


            propNames(ismember(propNames,{'ChannelMeasurements','CursorMeasurements',...
            'DistortionMeasurements','PeakFinder','SpectralMask'}))=[];
        end

        function a=getAlternateBlock
            a='dspsnks4/Spectrum Analyzer';
        end

        function localError(ID,varargin)
            id=['shared_dspwebscopes:spectrumanalyzer:',ID];
            ME=MException(message(id,varargin{:}));
            throwAsCaller(ME);
        end

        function localWarning(ID,varargin)
            id=['shared_dspwebscopes:spectrumanalyzer:',ID];
            warning(message(id,varargin{:}));
        end

        function win=evaluateCustomWindow(customWin,params)

            L=dsp.webscopes.SpectrumAnalyzerBaseWebScope.getNumSamplesPerUpdate(params.sampleRate,...
            params.rbw,params.method,params.window,customWin,params.sidelobeAttenuation);
            switch customWin
            case{'blackman','blackmanharris','flattopwin','hamming','hann','nuttallwin'}


                win=feval(customWin,L,'periodic');
            otherwise
                win=double(feval(customWin,L));
            end
        end

        function segLen=getNumSamplesPerUpdate(sampleRate,desiredRBW,method,win,customWin,SLA)



            ENBW=dsp.webscopes.SpectrumAnalyzerBaseWebScope.getENBW(win,customWin,method,1000,SLA);

            segLen=ceil(ENBW*sampleRate/desiredRBW);


            count=1;
            segLenVect=segLen;
            while(count<100)
                ENBW=round(dsp.webscopes.SpectrumAnalyzerBaseWebScope.getENBW(win,customWin,method,ceil(segLen),SLA)*1e8)/1e8;
                new_segLen=ceil(ENBW*sampleRate/desiredRBW);
                err=abs(new_segLen-segLen);
                if err==0
                    segLen=new_segLen;
                    break
                end
                if~any(segLenVect==new_segLen)
                    segLenVect=[segLenVect,new_segLen];%#ok<AGROW>
                    segLen=new_segLen;
                    count=count+1;
                else



                    L=length(segLenVect);
                    computed_RBW=zeros(L,1);
                    for ind=1:L

                        computed_RBW(ind)=dsp.webscopes.SpectrumAnalyzerBaseWebScope.getENBW(win,customWin,method,segLenVect(ind),SLA)*sampleRate/segLenVect(ind);
                    end


                    RBWErr=abs(desiredRBW-computed_RBW);
                    [~,ind_min]=min(RBWErr);
                    segLen=segLenVect(ind_min);
                    break
                end
            end
        end

        function value=getENBW(win,customWin,method,L,SLA)
            value=1;
            if strcmpi(method,'welch')
                switch(win)
                case{'custom','Custom'}
                    switch customWin
                    case{'blackman','blackmanharris','flattopwin','hamming','hann','nuttallwin'}


                        winVal=feval(customWin,L,'periodic');
                    otherwise
                        winVal=double(feval(customWin,L));
                    end
                case{'blackman-harris','Blackman-Harris'}
                    winVal=blackmanharris(L,'periodic');
                case{'chebyshev','Chebyshev'}
                    winVal=chebwin(L,SLA);
                case{'flat-top','Flat Top'}
                    winVal=flattopwin(L);
                case{'kaiser','Kaiser'}
                    if SLA>50
                        winParam=0.1102*(SLA-8.7);
                    elseif SLA<21
                        winParam=0;
                    else
                        winParam=(0.5842*(SLA-21)^0.4)+0.07886*(SLA-21);
                    end
                    winVal=kaiser(L,winParam);
                case{'rectangular','Rectangular'}
                    winVal=ones(1,L);
                otherwise
                    winVal=feval(win,L,'periodic');
                end
                value=enbw(winVal);
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

        function propName=mapObsoletePropertyName(legacyParamName)
            propName=legacyParamName;
            if strcmpi(legacyParamName,'PowerUnits')
                propName='SpectrumUnits';
            end
        end

        function N=filterSharpnessToNumTapsPerBand(S)
            N=2*round(exp(S*log(39)));
        end

        function S=numTapsPerBandToFilterSharpness(N)
            S=log(N/2)/log(39);
        end

        function newData=isNewDataReadyBlocking(clientID)




            t=tic;
            while toc(t)<dsp.webscopes.SpectrumAnalyzerBaseWebScope.DataTimeoutValue&&...
                ~dsp.webscopes.internal.isNewDataReadyImpl(clientID)
                drawnow;
            end
            newData=dsp.webscopes.internal.isNewDataReadyImpl(clientID);
        end

        function newData=isNewChannelMeasurementsDataReadyBlocking(clientID)




            t=tic;
            while toc(t)<dsp.webscopes.SpectrumAnalyzerBaseWebScope.MeasurementsTimeoutValue&&...
                ~dsp.webscopes.internal.isNewChannelMeasurementsDataReadyImpl(clientID)
                drawnow;
            end
            newData=dsp.webscopes.internal.isNewChannelMeasurementsDataReadyImpl(clientID);
        end

        function newData=isNewDistortionMeasurementsDataReadyBlocking(clientID)




            t=tic;
            while toc(t)<dsp.webscopes.SpectrumAnalyzerBaseWebScope.MeasurementsTimeoutValue&&...
                ~dsp.webscopes.internal.isNewDistortionMeasurementsDataReadyImpl(clientID)
                drawnow;
            end
            newData=dsp.webscopes.internal.isNewDistortionMeasurementsDataReadyImpl(clientID);
        end

        function newData=isNewPeakFinderDataReadyBlocking(clientID)




            t=tic;
            while toc(t)<dsp.webscopes.SpectrumAnalyzerBaseWebScope.MeasurementsTimeoutValue&&...
                ~dsp.webscopes.internal.isNewPeakFinderDataReadyImpl(clientID)
                drawnow;
            end
            newData=dsp.webscopes.internal.isNewPeakFinderDataReadyImpl(clientID);
        end

        function newData=isNewSpectralMaskTesterDataReadyBlocking(clientID)




            t=tic;
            while toc(t)<dsp.webscopes.SpectrumAnalyzerBaseWebScope.MeasurementsTimeoutValue&&...
                ~dsp.webscopes.internal.isNewSpectralMaskTesterDataReadyImpl(clientID)
                drawnow;
            end
            newData=dsp.webscopes.internal.isNewSpectralMaskTesterDataReadyImpl(clientID);
        end
    end
end
