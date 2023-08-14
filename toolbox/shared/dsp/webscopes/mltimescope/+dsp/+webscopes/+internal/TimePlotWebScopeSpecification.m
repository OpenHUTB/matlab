classdef TimePlotWebScopeSpecification<dsp.webscopes.internal.BaseWebScopeSpecification&...
    dsp.webscopes.mixin.TimeMeasurementsSpecifiable





    properties(AbortSet)
        SampleRate=1;
        TimeSpanSource='auto',
        TimeSpan=10;
        TimeSpanOverrunAction='scroll';
        PlotType='line';
        AxesScaling='onceatstop';
        LayoutDimensions=[1,1];
        BufferLength=50000;
        FrameBasedProcessing=true;
        TimeUnits='seconds';
        TimeDisplayOffset=0;
        TimeAxisLabels='all';
        MaximizeAxes='auto';
        ActiveDisplay=1;
        ChannelNames={''};
    end

    properties(Dependent)

        Title;
        YLabel;
        YLimits;
        ShowLegend;
        ShowGrid;
        PlotAsMagnitudePhase;
    end

    properties(Access=private)
        pTitle=repmat("",1,16);
        pYLabel=repmat("Amplitude",1,16);
        pRealYLimits=repmat([-10,10],16,1);
        pMagYLimits=repmat([0,10],16,1);
        pShowLegend=false(1,16);
        pShowGrid=true(1,16);
        pPlotAsMagnitudePhase=false(1,16);
    end

    properties(Hidden)
        Product='dsp';
        DataDomain='time';
        MaxNumChannels=100;
    end



    methods
        function this=TimePlotWebScopeSpecification()
            addTimeMeasurementsSpecification(this);
        end


        function flag=isInactiveProperty(this,propName)
            flag=isInactiveProperty@dsp.webscopes.internal.BaseWebScopeSpecification(this,propName);
            switch propName
            case 'TimeSpan'
                flag=strcmpi(this.TimeSpanSource,'auto');
            case 'YLabel'
                flag=this.PlotAsMagnitudePhase(getActiveDisplay(this));
            end
        end


        function settings=getSettings(this)
            displays=this.getNumDisplays();
            settings=struct(...
            'LogDiagnostic',enable_webscopes_diagnostics(),...
            'NumInputPorts',this.NumInputPorts,...
            'SampleRate',this.SampleRate,...
            'TimeSpanSource',this.TimeSpanSource,...
            'TimeSpan',this.TimeSpan,...
            'TimeSpanOverrunAction',this.TimeSpanOverrunAction,...
            'PlotType',this.PlotType,...
            'AxesScaling',this.AxesScaling,...
            'AxesScalingNumUpdates',this.AxesScalingNumUpdates,...
            'LayoutDimensions',this.LayoutDimensions,...
            'BufferLength',this.BufferLength,...
            'FrameBasedProcessing',this.FrameBasedProcessing,...
            'TimeUnits',this.TimeUnits,...
            'TimeDisplayOffset',this.TimeDisplayOffset,...
            'TimeAxisLabels',this.TimeAxisLabels,...
            'PlotAsMagnitudePhase',this.PlotAsMagnitudePhase,...
            'Title',this.Title,...
            'YLabel',this.YLabel,...
            'RealYLimits',this.pRealYLimits(1:displays,:),...
            'MagYLimits',this.pMagYLimits(1:displays,:),...
            'ShowLegend',this.ShowLegend,...
            'ChannelNames',string(this.ChannelNames),...
            'ShowGrid',this.ShowGrid,...
            'ActiveDisplay',this.ActiveDisplay,...
            'DefaultLegendLabel',this.DefaultLegendLabel,...
            'MaximizeAxes',this.MaximizeAxes,...
            'ExpandToolstrip',this.ExpandToolstrip,...
            'MeasurementChannel',this.MeasurementChannel-1,...
            'Annotation',this.Annotation,...
            'CounterMode',this.CounterMode);
        end


        function set.Title(this,value)
            value=convertCharsToStrings(value);
            if(numel(value)>1)
                this.pTitle(1:numel(value))=value;
            else
                display=this.getActiveDisplay();
                this.pTitle(display)=value;
            end
        end
        function value=get.Title(this)
            displays=this.getNumDisplays();
            value=this.pTitle(1:displays);
        end


        function set.YLabel(this,value)
            value=convertCharsToStrings(value);
            if(numel(value)>1)
                this.pYLabel(1:numel(value))=value;
            else
                display=this.getActiveDisplay();
                this.pYLabel(display)=value;
            end
        end
        function value=get.YLabel(this)
            displays=this.getNumDisplays();
            value=this.pYLabel(1:displays);
        end


        function set.YLimits(this,value)
            if(~isvector(value))


                displays=this.getNumDisplays();
                magPhase=this.pPlotAsMagnitudePhase;
                for dIdx=1:displays
                    if magPhase(dIdx)
                        this.pMagYLimits(dIdx,:)=value(dIdx,:);
                    else
                        this.pRealYLimits(dIdx,:)=value(dIdx,:);
                    end
                end
            else
                display=this.getActiveDisplay();
                if this.pPlotAsMagnitudePhase(display)
                    this.pMagYLimits(display,:)=value;
                else
                    this.pRealYLimits(display,:)=value;
                end
            end
        end
        function value=get.YLimits(this)
            displays=this.getNumDisplays();
            magPhase=this.pPlotAsMagnitudePhase;
            value=zeros(displays,2);
            for dIdx=1:displays
                if magPhase(dIdx)
                    value(dIdx,:)=this.pMagYLimits(dIdx,:);
                else
                    value(dIdx,:)=this.pRealYLimits(dIdx,:);
                end
            end
        end


        function set.ShowLegend(this,value)
            if(numel(value)>1)
                displays=this.getNumDisplays();
                this.pShowLegend(1:displays)=value;
            else
                display=this.getActiveDisplay();
                this.pShowLegend(display)=value;
            end
        end
        function value=get.ShowLegend(this)
            displays=this.getNumDisplays();
            value=this.pShowLegend(1:displays);
        end


        function set.ShowGrid(this,value)
            if(numel(value)>1)
                displays=this.getNumDisplays();
                this.pShowGrid(1:displays)=value;
            else
                display=this.getActiveDisplay();
                this.pShowGrid(display)=value;
            end
        end
        function value=get.ShowGrid(this)
            displays=this.getNumDisplays();
            value=this.pShowGrid(1:displays);
        end


        function set.PlotAsMagnitudePhase(this,value)
            if(numel(value)>1)
                displays=this.getNumDisplays();
                this.pPlotAsMagnitudePhase(1:displays)=value;
            else
                display=this.getActiveDisplay();
                this.pPlotAsMagnitudePhase(display)=value;
            end
        end
        function value=get.PlotAsMagnitudePhase(this)
            displays=this.getNumDisplays();
            value=this.pPlotAsMagnitudePhase(1:displays);
        end


        function S=toStruct(this)
            S=toStruct@dsp.webscopes.internal.BaseWebScopeSpecification(this);
            propNames=dsp.webscopes.TimePlotBaseWebScope.getValidPropertyNames;
            for idx=1:numel(propNames)
                S.(propNames{idx})=this.(propNames{idx});
            end
        end


        function fromStruct(this,S)
            fromStruct@dsp.webscopes.internal.BaseWebScopeSpecification(this,S);
            propNames=intersect(fieldnames(S),dsp.webscopes.TimePlotBaseWebScope.getValidPropertyNames);
            for idx=1:numel(propNames)
                this.(propNames{idx})=S.(propNames{idx});
            end
        end


        function name=getScopeName(~)
            name='Time Scope';
        end


        function className=getClassName(~)
            className='timescope';
        end


        function measurers=getSupportedMeasurements(~)
            keys={'bilevel','cursors','peaks','stats','trigger'};
            values={'BilevelMeasurements',...
            'CursorMeasurements',...
            'PeakFinder',...
            'SignalStatistics',...
            'Trigger'};
            measurers=containers.Map(keys,values);
        end


        function[keys,values]=getSupportedFiltersImpls(~)

            keys={'simmetadata','postsimstorage','thinner','magphase','trigger','simstorage','bilevel','peaks','stats'};
            values={...
            'simulation_meta_data_filter',...
            'webscope_datastorage_filter',...
            'webscope_thinner_filter',...
            'magnitude_phase_filter',...
            'trigger_filter',...
            'dsp_webscope_measurements_data_cache_filter',...
            'bilevel_measurements_filter',...
            'time_peak_finder_filter',...
'time_signal_statistics_filter'...
            };
        end


        function setPropertyValue(this,propName,propValue)
            if(~isequal(this.(propName),propValue))
                this.(propName)=propValue;
                hMessage=this.MessageHandler;
                hMessage.GraphicalSettingsStale=true;
                hMessage.publishPropertyValue('PropertyChanged','Specification',propName,propValue);


                hMessage.notify('PropertyChanged');
                if strcmpi(propName,'BufferLength')&&isScopeVisible(this)&&~hMessage.BufferLengthChangeComplete
                    matlabshared.application.waitfor(hMessage,'BufferLengthChangeComplete',true,'Timeout',10);
                    hMessage.BufferLengthChangeComplete=false;
                end
            end
        end

        function release(this)
            release@dsp.webscopes.internal.BaseWebScopeSpecification(this);
            this.MessageHandler.BufferLengthChangeComplete=false;
        end
    end



    methods(Access=protected)


        function display=getActiveDisplay(this)
            display=this.ActiveDisplay;
        end
    end



    methods(Hidden)


        function displays=getNumDisplays(this)
            displays=prod(this.LayoutDimensions);
        end


        function display=signalIdxToDisplayIdx(this,signal)
            numDisplays=this.getNumDisplays();
            if(signal<numDisplays)
                display=signal;
            else
                display=numDisplays;
            end
        end


        function props=getDisplaySpecificProperties(~)
            props={'PlotAsMagnitudePhase',...
            'Title',...
            'YLabel',...
            'YLimits',...
            'ShowLegend',...
            'ShowGrid'};
        end



        function props=getIrrelevantConstructorProperties(~)
            props={'NumInputPorts',...
            'ActiveDisplay',...
            'BilevelMeasurements',...
            'CursorMeasurements',...
            'PeakFinder',...
            'SignalStatistics',...
            'Trigger'};
        end
    end
end
