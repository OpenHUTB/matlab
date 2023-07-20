classdef SpectrumAnalyzerSpectrogramChannelSection<dsp.webscopes.toolstrip.SpectrumAnalyzerSection








    methods

        function this=SpectrumAnalyzerSpectrogramChannelSection
            this@dsp.webscopes.toolstrip.SpectrumAnalyzerSection('SpectrogramChannel');
            [spectrogramChannelLabel,spectrogramChannelDropDown]=this.getSpectrogramChannelWidget();
            c=addColumn(this,'Width',90);
            add(c,spectrogramChannelLabel);
            add(c,spectrogramChannelDropDown);
        end
    end



    methods(Access=protected)

        function[label,drop]=getSpectrogramChannelWidget(this)

            label=this.createLabel('SpectrogramChannel','select_channel_16.png');
            label.Description=getString(this,'SpectrogramChannel','Description');

            values={'1'};
            strings={getString(message('shared_dspwebscopes:dspwebscopes:defaultChannelName',1))};
            drop=this.createDropDown('SpectrogramChannel',values,strings);
            drop.Description=getString(this,'SpectrogramChannel','Description');
        end
    end
end
