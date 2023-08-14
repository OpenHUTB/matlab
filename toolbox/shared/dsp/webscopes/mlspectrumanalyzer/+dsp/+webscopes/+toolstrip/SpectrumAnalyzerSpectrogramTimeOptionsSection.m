classdef SpectrumAnalyzerSpectrogramTimeOptionsSection<dsp.webscopes.toolstrip.SpectrumAnalyzerSection








    methods

        function this=SpectrumAnalyzerSpectrogramTimeOptionsSection
            this@dsp.webscopes.toolstrip.SpectrumAnalyzerSection('TimeOptions');
            [timeResolutionLabel,timeResolutionCombo]=this.getTimeResolutionWidget();
            [timeSpanLabel,timeSpanCombo]=this.getTimeSpanWidget();

            c=addColumn(this);
            add(c,timeResolutionLabel);
            add(c,timeSpanLabel);

            c=addColumn(this,'Width',100);
            add(c,timeResolutionCombo);
            add(c,timeSpanCombo);
        end
    end



    methods(Access=protected)

        function[label,combo]=getTimeResolutionWidget(this)

            label=this.createLabel('TimeResolution');
            label.Description=getString(this,'TimeResolution','Description');

            values={'AUTO'};
            strings={getString(this,'TimeResolutionAuto')};
            combo=this.createComboBox('TimeResolution',values,strings);
            combo.Description=getString(this,'TimeResolution','Description');
        end

        function[label,combo]=getTimeSpanWidget(this)

            label=this.createLabel('TimeSpan');
            label.Description=getString(this,'TimeSpan','Description');

            values={'AUTO'};
            strings={getString(this,'TimeSpanAuto')};
            combo=this.createComboBox('TimeSpan',values,strings);
            label.Description=getString(this,'TimeSpan','Description');
        end
    end
end