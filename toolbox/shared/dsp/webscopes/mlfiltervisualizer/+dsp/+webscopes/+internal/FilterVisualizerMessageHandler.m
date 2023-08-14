classdef FilterVisualizerMessageHandler<dsp.webscopes.internal.BaseWebScopeMessageHandler





    events
        LocalUpdateRequested;
    end

    methods

        function onInputSizeChange(this,value)
            this.publish('onInputSizeChange',struct(...
            'NumSamples',value));
        end

        function setParameterSettings(this,params)
            if(~isempty(params))
                this.Specification.setSettings(params);
                if any(isfield(params,{'SampleRate','FFTLength','FrequencyRange'}))
                    this.notify('LocalUpdateRequested');
                end
            end
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
                iconFile=fullfile(toolboxdir('shared/dsp/webscopes'),'mlfiltervisualizer','resources','filtervisualizer','filtervisualizer.ico');
            else
                iconFile=fullfile(toolboxdir('shared/dsp/webscopes'),'mlfiltervisualizer','resources','filtervisualizer','filtervisualizer.png');
            end
        end


        function url=getUrl(~)
            url='toolbox/shared/dsp/webscopes/mlfiltervisualizer/web/filtervisualizer/filtervisualizer-object';
        end
    end
end
