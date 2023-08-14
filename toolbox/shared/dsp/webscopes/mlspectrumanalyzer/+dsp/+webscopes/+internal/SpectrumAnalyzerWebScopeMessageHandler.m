classdef SpectrumAnalyzerWebScopeMessageHandler<dsp.webscopes.internal.BaseWebScopeMessageHandler





    methods

        function graphicalSettings=getGraphicalSettings(this)
            graphicalSettings=getGraphicalSettings@dsp.webscopes.internal.BaseWebScopeMessageHandler(this);

            if this.Specification.isMeasurementSupported('channel')
                channelSettings=this.Specification.ChannelMeasurements.getSettings();
                graphicalSettings.Channel=channelSettings;
            end

            if this.Specification.isMeasurementSupported('distortion')
                distortionSettings=this.Specification.DistortionMeasurements.getSettings();
                graphicalSettings.Distortion=distortionSettings;
            end

            if this.Specification.isMeasurementSupported('spectralmask')
                maskSettings=this.Specification.SpectralMask.getSettings();
                graphicalSettings.SpectralMask=maskSettings;
            end
        end

        function setGraphicalSettings(this,graphical)

            setGraphicalSettings@dsp.webscopes.internal.BaseWebScopeMessageHandler(this,graphical);

            if isfield(graphical,'Channel')
                channelSettings=graphical.Channel;
                if~isempty(channelSettings)
                    this.Specification.ChannelMeasurements.setSettings(channelSettings);
                end
            end

            if isfield(graphical,'Distortion')
                distortionSettings=graphical.Distortion;
                if~isempty(distortionSettings)
                    this.Specification.DistortionMeasurements.setSettings(distortionSettings);
                end
            end

            if isfield(graphical,'SpectralMask')
                maskSettings=graphical.SpectralMask;
                if~isempty(maskSettings)
                    this.Specification.SpectralMask.setSettings(maskSettings);
                end
            end
        end

        function notifyMaskTestFailed(this,data)
            this.Specification.SpectralMask.Configuration.notify('MaskTestFailed',SpectralMaskTestInfo(data));
        end


        function iconFile=getIconFile(~)
            if ispc
                iconFile=fullfile(toolboxdir('shared/dsp/webscopes'),'mlspectrumanalyzer','resources','spectrumanalyzer','spectrumanalyzer.ico');
            else
                iconFile=fullfile(toolboxdir('shared/dsp/webscopes'),'mlspectrumanalyzer','resources','spectrumanalyzer','spectrumanalyzer.png');
            end
        end


        function url=getUrl(~)
            url='toolbox/shared/dsp/webscopes/mlspectrumanalyzer/web/spectrumanalyzer/spectrumanalyzer-systemobject';
        end
    end
end
