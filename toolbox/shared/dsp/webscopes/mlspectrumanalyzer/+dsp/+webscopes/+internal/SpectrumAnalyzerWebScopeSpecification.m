classdef SpectrumAnalyzerWebScopeSpecification<dsp.webscopes.internal.BaseWebScopeSpecification&...
    dsp.webscopes.mixin.SpectrumMeasurementsSpecifiable




    properties(AbortSet)
        InputDomain='time';
        SpectrumType='power';
        ShowSpectrum=true;
        ShowSpectrogram=false;
        SampleRate=1e4;
        Method='welch';
        PlotAsTwoSidedSpectrum=true;
        FrequencyScale='linear';
        PlotType='line';
        AxesScaling='auto';
        FrequencyResolutionMethod='rbw';
        RBWSource='auto';
        RBW=9.76;
        WindowLength=1024;
        FFTLengthSource='auto';
        FFTLength=1024;
        FilterSharpness=0.3;
        NumTapsPerBand=6;
        FrequencyVectorSource='auto';
        FrequencyVector=[-5000,5000];
        FrequencySpan='full';
        Span=10000;
        CenterFrequency=0;
        StartFrequency=-5000;
        StopFrequency=5000;
        OverlapPercent=0;
        Window='hann';
        CustomWindow='hann';
        CustomWindowValue=[];
        SidelobeAttenuation=60;
        AveragingMethod='exponential';
        ForgettingFactor=0.9;
        VBWSource='auto';
        VBW=10;
        SpectralAverages=1;
        InputUnits='dBm';
        PowerUnits='dBm';
        PowerDensityUnits='dBm/Hz';
        RMSUnits='Vrms';
        FrequencyDomainUnits='auto';
        FullScaleSource='auto';
        FullScale=1;
        ReferenceLoad=1;
        FrequencyOffset=0;
        SpectrogramChannel=1;
        TimeResolutionSource='auto';
        TimeResolution=1e-3;
        TimeSpanSource='auto'
        TimeSpan=0.1;
        MaximizeAxes='auto';
        PlotNormalTrace=true;
        PlotMaxHoldTrace=false;
        PlotMinHoldTrace=false;
        Title='';
        YLabel='';
        YLimits=[-80,20];
        ColorLimits=[-80,20];
        Colormap='jet';
        ColormapValue=jet;
        ShowGrid=true;
        ChannelNames={''};
        ShowLegend=false;
        ShowColorbar=true;
        AxesLayout='vertical';
        ShowScreenMessages=true;
        DataThinningEnabled=false;
        DefaultSegmentLength=1024;
        AllowTransientAveraging=true;
        UseWelchForFilterBankTransient=true;
    end

    properties(Dependent)
        ViewType;
        SpectrumUnits;
    end

    properties(Hidden)
        Product='dsp';
        DataDomain='frequency';
        MaxNumChannels=100;
    end



    methods
        function this=SpectrumAnalyzerWebScopeSpecification()
            addSpectrumMeasurementsSpecification(this);
        end


        function set.SpectrumUnits(this,value)
            if strcmpi(this.InputDomain,'time')
                if strcmpi(this.SpectrumType,'power')
                    this.PowerUnits=value;
                elseif strcmpi(this.SpectrumType,'power-density')
                    if~contains(lower(value),'/hz')
                        value=[value,'/Hz'];
                    end
                    this.PowerDensityUnits=value;
                else
                    this.RMSUnits=value;
                end
            else
                this.FrequencyDomainUnits=value;
            end
        end
        function value=get.SpectrumUnits(this)
            if strcmpi(this.InputDomain,'time')
                if strcmpi(this.SpectrumType,'power')
                    value=this.PowerUnits;
                elseif strcmpi(this.SpectrumType,'power-density')
                    value=this.PowerDensityUnits;
                else
                    value=this.RMSUnits;
                end
            else
                value=this.FrequencyDomainUnits;
            end
        end


        function set.SpectrumType(this,value)
            if strcmpi(value,'Power density')
                value='power-density';
            elseif strcmpi(value,'Spectrogram')
                value='power';
                setViewType(this,'spectrogram');
            end
            this.SpectrumType=value;
        end


        function set.ViewType(this,value)
            switch value
            case 'spectrum'
                this.ShowSpectrum=true;
                this.ShowSpectrogram=false;
            case 'spectrogram'
                this.ShowSpectrum=false;
                this.ShowSpectrogram=true;
            case 'spectrum-and-spectrogram'
                this.ShowSpectrum=true;
                this.ShowSpectrogram=true;
            end
        end
        function value=get.ViewType(this)
            if this.ShowSpectrum
                value='spectrum';
            end
            if this.ShowSpectrogram
                value='spectrogram';
            end
            if this.ShowSpectrum&&this.ShowSpectrogram
                value='spectrum-and-spectrogram';
            end
        end


        function flag=isInactiveProperty(this,propName)
            flag=isInactiveProperty@dsp.webscopes.internal.BaseWebScopeSpecification(this,propName);
            switch propName
            case 'ShowSpectrum'
                flag=this.ShowSpectrum&&~this.ShowSpectrogram;
            case 'ShowSpectrogram'
                flag=~this.ShowSpectrum&&this.ShowSpectrogram;
            case{'SpectrumType','Method','FrequencyResolutionMethod','FrequencySpan'}
                flag=strcmpi(this.InputDomain,'frequency');
            case 'RBWSource'
                flag=~strcmp(this.FrequencyResolutionMethod,'rbw');
            case 'RBW'
                flag=~strcmp(this.FrequencyResolutionMethod,'rbw')||strcmp(this.RBWSource,'auto');
            case 'WindowLength'
                flag=~strcmp(this.FrequencyResolutionMethod,'WindowLength')||strcmp(this.Method,'filter-bank')||strcmp(obj.InputDomain,'frequency');
            case{'Span','CenterFrequency'}
                flag=any(strcmp({'full','start-and-stop-frequencies'},this.FrequencySpan))||strcmp(this.InputDomain,'frequency');
            case{'StartFrequency','StopFrequency'}
                flag=any(strcmp({'full','span-and-center-frequency'},this.FrequencySpan))||strcmp(this.InputDomain,'frequency');
            case 'FrequencyVectorSource'
                flag=strcmpi(this.InputDomain,'time');
            case 'FrequencyVector'
                flag=strcmp(this.InputDomain,'time')||strcmp(this.FrequencyVectorSource,'auto');
            case 'FFTLengthSource'
                flag=strcmp(this.FrequencyResolutionMethod,'rbw')||strcmp(this.InputDomain,'frequency');
            case 'FFTLength'
                flag=strcmp(this.FrequencyResolutionMethod,'rbw')||strcmp(this.FFTLengthSource,'auto')||strcmp(this.InputDomain,'frequency');
            case 'SidelobeAttenuation'
                flag=~any(strcmp({'chebyshev','kaiser'},this.Window))||strcmpi(this.Method,'filter-bank')||strcmp(this.InputDomain,'frequency');
            case 'InputUnits'
                flag=strcmp(this.InputDomain,'time');
            case{'PlotNormalTrace','PlotMaxHoldTrace','PlotMinHoldTrace'}
                flag=this.ShowSpectrogram&&~this.ShowSpectrum;
            case{'YLimits','YLabel','ShowLegend'}
                flag=~this.ShowSpectrum;
            case 'AveragingMethod'
                flag=strcmpi(this.InputDomain,'frequency');
            case 'SpectralAverages'
                flag=strcmpi(this.AveragingMethod,'exponential')||this.ShowSpectrogram||(this.ShowSpectrum&&this.ShowSpectrogram)||strcmpi(this.InputDomain,'frequency');
            case 'ForgettingFactor'
                flag=any(strcmpi(this.AveragingMethod,{'running','vbw'}))||strcmpi(this.InputDomain,'frequency');
            case 'VBWSource'
                flag=any(strcmpi(this.AveragingMethod,{'running','exponential'}))||strcmpi(this.InputDomain,'frequency');
            case 'VBW'
                flag=any(strcmpi(this.AveragingMethod,{'running','exponential'}))||strcmpi(this.InputDomain,'frequency')||strcmpi(this.VBWSource,'auto');
            case 'PlotType'
                flag=~this.ShowSpectrum||~this.PlotNormalTrace;
            case 'TimeSpanSource'
                flag=~this.ShowSpectrogram;
            case 'TimeSpan'
                flag=~this.ShowSpectrogram||strcmpi(this.TimeSpanSource,'auto');
            case 'TimeResolutionSource'
                flag=~this.ShowSpectrogram||strcmpi(this.InputDomain,'frequency');
            case 'TimeResolution'
                flag=~this.ShowSpectrogram||strcmpi(this.TimeResolutionSource,'auto')||strcmpi(this.InputDomain,'frequency');
            case 'AxesLayout'
                flag=~(this.ShowSpectrogram&&this.ShowSpectrum);
            case 'ReferenceLoad'
                flag=strcmpi(this.SpectrumType,'rms');
            case{'ColorLimits','Colormap','ShowColorbar'}
                flag=~this.ShowSpectrogram;
            case 'FullScale'
                flag=~any(strcmpi(this.SpectrumUnits,{'dBFS','dBFS/Hz'}))||strcmpi(this.FullScaleSource,'auto');
            case 'FullScaleSource'
                flag=~any(strcmpi(this.SpectrumUnits,{'dBFS','dBFS/Hz'}));
            case{'Window','OverlapPercent'}
                flag=strcmpi(this.Method,'filter-bank')||strcmpi(this.InputDomain,'frequency');
            case 'CustomWindow'
                flag=~strcmpi(this.Window,'custom')||strcmpi(this.Method,'filter-bank')||strcmpi(obj.InputDomain,'frequency');
            case 'SpectrogramChannel'
                flag=~this.ShowSpectrogram;
            case 'SpectralMask'
                flag=(this.ShowSpectrogram&&~this.ShowSpectrum)||any(strcmpi(this.SpectrumUnits,{'Watts','Vrms','dBV'}))||strcmpi(this.SpectrumType,'rms');
            case{'MeasurementChannel','PeakFinder','ChannelMeasurements','DistortionMeasurements'}
                flag=this.ShowSpectrogram&&~this.ShowSpectrum;
            case 'FilterSharpness'
                flag=strcmpi(this.Method,'welch')||strcmpi(this.InputDomain,'frequency');
            end
        end


        function settings=getSettings(this)
            settings=struct(...
            'LogDiagnostic',enable_webscopes_diagnostics(),...
            'InputDomain',this.InputDomain,...
            'SpectrumType',this.SpectrumType,...
            'AxesLayout',this.AxesLayout,...
            'ShowSpectrogram',this.ShowSpectrogram,...
            'ShowSpectrum',this.ShowSpectrum,...
            'Method',this.Method,...
            'PlotType',this.PlotType,...
            'AxesScaling',this.AxesScaling,...
            'AxesScalingNumUpdates',this.AxesScalingNumUpdates,...
            'FrequencySpan',this.FrequencySpan,...
            'Span',this.Span,...
            'CenterFrequency',this.CenterFrequency,...
            'StartFrequency',this.StartFrequency,...
            'StopFrequency',this.StopFrequency,...
            'PlotAsTwoSidedSpectrum',this.PlotAsTwoSidedSpectrum,...
            'FrequencyScale',this.FrequencyScale,...
            'SampleRate',this.SampleRate,...
            'FrequencyResolutionMethod',this.FrequencyResolutionMethod,...
            'RBWSource',this.RBWSource,...
            'RBW',this.RBW,...
            'FrequencyVectorSource',this.FrequencyVectorSource,...
            'FrequencyVector',this.FrequencyVector,...
            'FFTLengthSource',this.FFTLengthSource,...
            'FFTLength',this.FFTLength,...
            'FilterSharpness',this.FilterSharpness,...
            'NumTapsPerBand',this.NumTapsPerBand,...
            'WindowLength',this.WindowLength,...
            'OverlapPercent',this.OverlapPercent,...
            'Window',this.Window,...
            'CustomWindow',this.CustomWindow,...
            'CustomWindowValue',this.CustomWindowValue,...
            'SidelobeAttenuation',this.SidelobeAttenuation,...
            'AveragingMethod',this.AveragingMethod,...
            'ForgettingFactor',this.ForgettingFactor,...
            'VBWSource',this.VBWSource,...
            'VBW',this.VBW,...
            'SpectralAverages',this.SpectralAverages,...
            'SpectrumUnits',lower(this.SpectrumUnits),...
            'FullScaleSource',this.FullScaleSource,...
            'FullScale',this.FullScale,...
            'ReferenceLoad',this.ReferenceLoad,...
            'FrequencyOffset',this.FrequencyOffset,...
            'SpectrogramChannel',this.SpectrogramChannel-1,...
            'TimeResolutionSource',this.TimeResolutionSource,...
            'TimeResolution',this.TimeResolution,...
            'TimeSpanSource',this.TimeSpanSource,...
            'TimeSpan',this.TimeSpan,...
            'PlotNormalTrace',this.PlotNormalTrace,...
            'PlotMaxHoldTrace',this.PlotMaxHoldTrace,...
            'PlotMinHoldTrace',this.PlotMinHoldTrace,...
            'Title',this.Title,...
            'YLabel',this.YLabel,...
            'YLimits',this.YLimits,...
            'MaximizeAxes',this.MaximizeAxes,...
            'ColorLimits',this.ColorLimits,...
            'Colormap',this.Colormap,...
            'ColormapValue',this.ColormapValue,...
            'ShowGrid',this.ShowGrid,...
            'ChannelNames',string(this.ChannelNames),...
            'ShowLegend',this.ShowLegend,...
            'ShowColorbar',this.ShowColorbar,...
            'DefaultLegendLabel',this.DefaultLegendLabel,...
            'ExpandToolstrip',this.ExpandToolstrip,...
            'MeasurementChannel',this.MeasurementChannel-1,...
            'Annotation',this.Annotation,...
            'CounterMode',this.CounterMode,...
            'DefaultSegmentLength',this.DefaultSegmentLength);
        end


        function setSettings(this,S)
            fields=fieldnames(S);
            for idx=1:numel(fields)
                prop=fields{idx};
                value=S.(prop);
                if ischar(value)
                    this.(prop)=S.(prop);
                else
                    if strcmpi(prop,'Colormap')

                        this.(prop)=S.(prop);
                    else
                        this.(prop)=S.(prop).';
                    end
                end
            end
        end


        function S=toStruct(this)
            S=toStruct@dsp.webscopes.internal.BaseWebScopeSpecification(this);
            propNames=dsp.webscopes.SpectrumAnalyzerBaseWebScope.getValidPropertyNames;
            for idx=1:numel(propNames)
                S.(propNames{idx})=this.(propNames{idx});
            end
        end


        function fromStruct(this,S)
            fromStruct@dsp.webscopes.internal.BaseWebScopeSpecification(this,S);
            propNames=intersect(fieldnames(S),dsp.webscopes.SpectrumAnalyzerBaseWebScope.getValidPropertyNames);
            for idx=1:numel(propNames)
                this.(propNames{idx})=S.(propNames{idx});
            end
        end


        function name=getScopeName(~)
            name='Spectrum Analyzer';
        end


        function className=getClassName(~)
            className='spectrumAnalyzer';
        end


        function measurers=getSupportedMeasurements(~)
            keys={'cursors','channel','distortion','peaks','spectralmask'};
            values={'CursorMeasurements','ChannelMeasurements','DistortionMeasurements','PeakFinder','SpectralMask'};
            measurers=containers.Map(keys,values);
        end


        function[keys,values]=getSupportedFiltersImpls(this)

            keys={...
            'simmetadata',...
            'postsimstorage',...
            'spectrumestimator',...
            'channel',...
            'distortion',...
            'peaks',...
'spectralmask'
            };
            values={...
            'simulation_meta_data_filter',...
            'webscope_datastorage_filter',...
            'spectrum_estimator_filter',...
            'channel_measurements_filter',...
            'distortion_measurements_filter',...
'frequency_peak_finder_filter'...
            ,'spectral_mask_tester_filter',...
            };
            if this.DataThinningEnabled
                keys{end+1}='spectrumthinner';
                values{end+1}='spectrum_thinner_filter';
            end
        end


        function[Fstart,Fstop]=getCurrentFrequencyLimits(this)
            Fs=this.SampleRate;
            FO=this.FrequencyOffset;
            Fstart=-Fs/2*this.PlotAsTwoSidedSpectrum+min(FO);
            Fstop=Fs/2+max(FO);
        end


        function n=getNumChannels(this)
            n=0;
            for sigIdx=1:this.NumInputPorts
                if this.IsInputComplex(sigIdx)
                    n=n+this.NumChannels(sigIdx)/2;
                else
                    n=n+this.NumChannels(sigIdx);
                end
            end
        end


        function updateSpanFrequencies(this)
            FO=this.FrequencyOffset;
            this.StartFrequency=0;
            if(this.PlotAsTwoSidedSpectrum)
                this.StartFrequency=-this.SampleRate/2+min(FO);
            end
            this.StopFrequency=this.SampleRate/2+max(FO);
            this.Span=this.StopFrequency-this.StartFrequency;
            this.CenterFrequency=this.Span/2;
            if(this.PlotAsTwoSidedSpectrum)
                this.CenterFrequency=this.Span/2+this.StartFrequency;
            end
        end

        function setViewType(this,value)
            this.ViewType=value;
        end
    end



    methods(Hidden)



        function props=getIrrelevantConstructorProperties(~)
            props={'NumInputPorts',...
            'ChannelMeasurements',...
            'CursorMeasurements',...
            'DistortionMeasurements',...
            'PeakFinder',...
            'SpectralMask'};
        end
    end
end
