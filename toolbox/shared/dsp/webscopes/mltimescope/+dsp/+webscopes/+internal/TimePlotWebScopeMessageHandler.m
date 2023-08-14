classdef TimePlotWebScopeMessageHandler<dsp.webscopes.internal.BaseWebScopeMessageHandler





    properties
        BufferLengthChangeComplete=false;
    end

    methods

        function onInputSizeChange(this,value)
            this.publish('onInputSizeChange',struct(...
            'NumSamples',value));
        end

        function graphicalSettings=getGraphicalSettings(this)
            graphicalSettings=getGraphicalSettings@dsp.webscopes.internal.BaseWebScopeMessageHandler(this);

            if this.Specification.isMeasurementSupported('bilevel')
                bilevelSettings=this.Specification.BilevelMeasurements.getSettings();
                graphicalSettings.Bilevel=bilevelSettings;
            end

            if this.Specification.isMeasurementSupported('stats')
                statsSettings=this.Specification.SignalStatistics.getSettings();
                graphicalSettings.Stats=statsSettings;
            end

            if this.Specification.isMeasurementSupported('trigger')
                triggerSettings=this.Specification.Trigger.getSettings();
                graphicalSettings.Trigger=triggerSettings;
            end
        end

        function setGraphicalSettings(this,graphical)

            setGraphicalSettings@dsp.webscopes.internal.BaseWebScopeMessageHandler(this,graphical);

            if isfield(graphical,'Bilevel')
                bilevelSettings=graphical.Bilevel;
                if~isempty(bilevelSettings)
                    this.Specification.BilevelMeasurements.setSettings(bilevelSettings);
                end
            end

            if isfield(graphical,'Stats')
                statsSettings=graphical.Stats;
                if~isempty(statsSettings)
                    this.Specification.SignalStatistics.setSettings(statsSettings);
                end
            end

            if isfield(graphical,'Trigger')
                triggerSettings=graphical.Trigger;
                if~isempty(triggerSettings)
                    this.Specification.Trigger.setSettings(triggerSettings);
                end
            end
        end

        function iconFile=getIconFile(~)
            if ispc
                iconFile=fullfile(toolboxdir('shared/dsp/webscopes'),'mltimescope','resources','timescope','timescope.ico');
            else
                iconFile=fullfile(toolboxdir('shared/dsp/webscopes'),'mltimescope','resources','timescope','timescope.png');
            end
        end


        function url=getUrl(~)
            url='toolbox/shared/dsp/webscopes/mltimescope/web/timescope/timescope-systemobject';
        end

        function node=getPrintDomNodePath(~)
            node={'timeScope','mainDisplay','mainDisplayTileContainer','domNode'};
        end

        function updateBufferLength(this,~)
            this.BufferLengthChangeComplete=true;
        end
    end
end
