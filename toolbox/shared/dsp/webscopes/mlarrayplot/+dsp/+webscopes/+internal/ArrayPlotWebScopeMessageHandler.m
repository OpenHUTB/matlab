classdef ArrayPlotWebScopeMessageHandler<dsp.webscopes.internal.BaseWebScopeMessageHandler





    methods

        function onInputSizeChange(this,value)
            this.publish('onInputSizeChange',struct(...
            'SampleIncrement',this.Specification.SampleIncrement,...
            'XOffset',this.Specification.XOffset,...
            'NumSamples',value));
        end

        function graphicalSettings=getGraphicalSettings(this)
            graphicalSettings=getGraphicalSettings@dsp.webscopes.internal.BaseWebScopeMessageHandler(this);

            if this.Specification.isMeasurementSupported('stats')
                statsSettings=this.Specification.SignalStatistics.getSettings();
                graphicalSettings.Stats=statsSettings;
            end
        end

        function setGraphicalSettings(this,graphical)

            setGraphicalSettings@dsp.webscopes.internal.BaseWebScopeMessageHandler(this,graphical);

            if isfield(graphical,'Stats')
                statsSettings=graphical.Stats;
                if~isempty(statsSettings)
                    this.Specification.SignalStatistics.setSettings(statsSettings);
                end
            end
        end


        function iconFile=getIconFile(~)
            if ispc
                iconFile=fullfile(toolboxdir('shared/dsp/webscopes'),'mlarrayplot','resources','arrayplot','arrayplot.ico');
            else
                iconFile=fullfile(toolboxdir('shared/dsp/webscopes'),'mlarrayplot','resources','arrayplot','arrayplot.png');
            end
        end


        function url=getUrl(~)
            url='toolbox/shared/dsp/webscopes/mlarrayplot/web/arrayplot/arrayplot-systemobject';
        end
    end
end
