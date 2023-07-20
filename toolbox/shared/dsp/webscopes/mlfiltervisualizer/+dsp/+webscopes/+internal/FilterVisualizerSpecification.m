classdef FilterVisualizerSpecification<dsp.webscopes.internal.BaseWebScopeSpecification





    properties(AbortSet)
        SampleRate=44100;
        FFTLength=2048;
        FrequencyRange=[0,22050];
        XScale='Linear';
        MagnitudeDisplay='Magnitude (dB)'
        PlotType='Line';
        AxesScaling='Auto',
        MaximizeAxes='Auto';
        Title=getString(message('shared_dspwebscopes:filtervisualizer:axesTitle'));
        ShowGrid=true;
        ShowLegend=false;
        FilterNames={''};
        PlotAsMagnitudePhase=false;
        UpperMask=Inf;
        LowerMask=-Inf;
        MaskStatus='None';
        NormalizedFrequency=false;
        FrequencyVector=[];
    end

    properties(Dependent)
        YLimits;
    end

    properties(Access=private)
        pRealYLimits=[-25,25];
        pMagYLimits=[-25,25];
    end

    properties(Hidden)
        Product='dsp';
        DataDomain='none';
        MaxNumChannels=128;
    end



    methods


        function set.YLimits(this,value)
            if this.PlotAsMagnitudePhase
                this.pMagYLimits=value;
            else
                this.pRealYLimits=value;
            end
        end
        function value=get.YLimits(this)
            if this.PlotAsMagnitudePhase
                value=this.pMagYLimits;
            else
                value=this.pRealYLimits;
            end
        end


        function flag=isInactiveProperty(this,propName)
            flag=isInactiveProperty@dsp.webscopes.internal.BaseWebScopeSpecification(this,propName);
        end


        function settings=getSettings(this)
            settings=struct(...
            'LogDiagnostic',enable_webscopes_diagnostics(),...
            'SampleRate',this.SampleRate,...
            'FFTLength',this.FFTLength,...
            'FrequencyRange',this.FrequencyRange,...
            'MagnitudeDisplay',this.MagnitudeDisplay,...
            'PlotAsMagnitudePhase',this.PlotAsMagnitudePhase,...
            'PlotType',this.PlotType,...
            'XScale',this.XScale,...
            'AxesScaling',this.AxesScaling,...
            'AxesScalingNumUpdates',this.AxesScalingNumUpdates,...
            'Title',this.Title,...
            'RealYLimits',this.pRealYLimits,...
            'MagYLimits',this.pMagYLimits,...
            'ShowGrid',this.ShowGrid,...
            'ShowLegend',this.ShowLegend,...
            'FilterNames',string(this.FilterNames),...
            'MaximizeAxes',this.MaximizeAxes,...
            'UpperMask',this.UpperMask,...
            'LowerMask',this.LowerMask,...
            'NormalizedFrequency',this.NormalizedFrequency,...
            'FrequencyVector',this.FrequencyVector,...
            'Annotation',this.Annotation,...
            'DefaultLegendLabel',this.DefaultLegendLabel,...
            'MeasurementChannel',this.MeasurementChannel-1,...
            'ExpandToolstrip',this.ExpandToolstrip,...
            'CounterMode',this.CounterMode);
        end


        function S=toStruct(this)
            S=toStruct@dsp.webscopes.internal.BaseWebScopeSpecification(this);
            propNames=dsp.webscopes.FilterVisualizerBaseWebScope.getValidPropertyNames;
            for idx=1:numel(propNames)
                S.(propNames{idx})=this.(propNames{idx});
            end
        end


        function fromStruct(this,S)
            fromStruct@dsp.webscopes.internal.BaseWebScopeSpecification(this,S);
            propNames=intersect(fieldnames(S),dsp.webscopes.FilterVisualizerBaseWebScope.getValidPropertyNames);
            for idx=1:numel(propNames)
                this.(propNames{idx})=S.(propNames{idx});
            end
        end


        function name=getScopeName(~)
            name='Dynamic Filter Visualizer';
        end


        function className=getClassName(~)
            className='dsp.DynamicFilterVisualizer';
        end


        function measurers=getSupportedMeasurements(~)
            keys={'cursors','peaks'};
            values={'CursorMeasurements',...
            'PeakFinder'};
            measurers=containers.Map(keys,values);
        end


        function[keys,values]=getSupportedFiltersImpls(~)

            keys={'simmetadata','postsimstorage','thinner','magphase','peaks'};
            values={...
            'simulation_meta_data_filter',...
            'webscope_datastorage_filter',...
            'webscope_thinner_filter',...
            'magnitude_phase_response_filter',...
'peak_finder_filter'...
            };
        end
    end



    methods(Hidden)



        function props=getIrrelevantConstructorProperties(~)
            props={'CursorMeasurements','PeakFinder','SignalStatistics'};
        end
    end
end

