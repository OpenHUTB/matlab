classdef ArrayPlotWebScopeSpecification<dsp.webscopes.internal.BaseWebScopeSpecification





    properties(AbortSet)
        XDataMode='Sample increment and X-offset';
        CustomXData=[];
        SampleIncrement=1;
        XOffset=0;
        XScale='Linear';
        YScale='Linear';
        PlotType='Stem';
        AxesScaling='OnceAtStop',
        MaximizeAxes='Auto';
        Title='';
        XLabel='';
        YLabel='Amplitude';
        ShowGrid=true;
        ShowLegend=false;
        ChannelNames={''};
        PlotAsMagnitudePhase=false;
        EnablePlotMagPhase=true;
        EnableGenerateScript=true;
    end

    properties(Dependent)
        YLimits;
    end

    properties(Access=private)
        pRealYLimits=[-10,10];
        pMagYLimits=[0,10];
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
            switch propName
            case 'YLabel'
                flag=this.PlotAsMagnitudePhase;
            case{'SampleIncrement','XOffset'}
                flag=~strcmp(this.XDataMode,'Sample increment and X-offset');
            case 'CustomXData'
                flag=~strcmp(this.XDataMode,'Custom');
            end
        end


        function settings=getSettings(this)
            settings=struct(...
            'LogDiagnostic',enable_webscopes_diagnostics(),...
            'XDataMode',this.XDataMode,...
            'SampleIncrement',this.SampleIncrement,...
            'XOffset',this.XOffset,...
            'CustomXData',this.CustomXData,...
            'PlotAsMagnitudePhase',this.PlotAsMagnitudePhase,...
            'PlotType',this.PlotType,...
            'XScale',this.XScale,...
            'YScale',this.YScale,...
            'AxesScaling',this.AxesScaling,...
            'AxesScalingNumUpdates',this.AxesScalingNumUpdates,...
            'Title',this.Title,...
            'XLabel',this.XLabel,...
            'YLabel',this.YLabel,...
            'RealYLimits',this.pRealYLimits,...
            'MagYLimits',this.pMagYLimits,...
            'ShowGrid',this.ShowGrid,...
            'ShowLegend',this.ShowLegend,...
            'ChannelNames',string(this.ChannelNames),...
            'MaximizeAxes',this.MaximizeAxes,...
            'Annotation',this.Annotation,...
            'DefaultLegendLabel',this.DefaultLegendLabel,...
            'MeasurementChannel',this.MeasurementChannel-1,...
            'ExpandToolstrip',this.ExpandToolstrip,...
            'CounterMode',this.CounterMode);
        end


        function S=toStruct(this)
            S=toStruct@dsp.webscopes.internal.BaseWebScopeSpecification(this);
            propNames=dsp.webscopes.ArrayPlotBaseWebScope.getValidPropertyNames;
            for idx=1:numel(propNames)
                S.(propNames{idx})=this.(propNames{idx});
            end
        end


        function fromStruct(this,S)
            fromStruct@dsp.webscopes.internal.BaseWebScopeSpecification(this,S);
            propNames=intersect(fieldnames(S),dsp.webscopes.ArrayPlotBaseWebScope.getValidPropertyNames);
            for idx=1:numel(propNames)
                this.(propNames{idx})=S.(propNames{idx});
            end
        end


        function name=getScopeName(~)
            name='Array Plot';
        end


        function className=getClassName(~)
            className='dsp.ArrayPlot';
        end


        function measurers=getSupportedMeasurements(~)
            keys={'cursors','peaks','stats'};
            values={'CursorMeasurements',...
            'PeakFinder',...
            'SignalStatistics'};
            measurers=containers.Map(keys,values);
        end


        function[keys,values]=getSupportedFiltersImpls(~)

            keys={'simmetadata','postsimstorage','thinner','magphase','peaks','stats'};
            values={...
            'simulation_meta_data_filter',...
            'webscope_datastorage_filter',...
            'webscope_thinner_filter',...
            'magnitude_phase_filter',...
            'peak_finder_filter',...
'signal_statistics_filter'...
            };
        end


        function setPropertyValue(this,propName,propValue)
            if(~isequal(this.(propName),propValue))
                this.(propName)=propValue;
                hMessage=this.MessageHandler;
                hMessage.GraphicalSettingsStale=true;
                hMessage.publishPropertyValue('PropertyChanged','Specification',propName,propValue);


                hMessage.notify('PropertyChanged');

                action=['set',propName];
                if isScopeVisible(this)&&any(strcmpi(action,{'setSampleIncrement','setXOffset'}))&&hMessage.PropertyChangedComplete



                    matlabshared.application.waitfor(hMessage,'PropertyChangedComplete',false,'Timeout',10);
                    hMessage.PropertyChangedComplete=true;
                end
            end
        end
    end



    methods(Access=protected)

        function style=getStyleSpecification(this)
            style=dsp.webscopes.style.ArrayPlotWebScopeStyleSpecification(this);
        end
    end



    methods(Hidden)



        function props=getIrrelevantConstructorProperties(~)
            props={'CursorMeasurements','PeakFinder','SignalStatistics'};
        end
    end
end

