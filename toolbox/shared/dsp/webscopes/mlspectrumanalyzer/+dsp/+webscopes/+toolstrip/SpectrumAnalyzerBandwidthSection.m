classdef SpectrumAnalyzerBandwidthSection<dsp.webscopes.toolstrip.SpectrumAnalyzerSection








    methods

        function this=SpectrumAnalyzerBandwidthSection
            this@dsp.webscopes.toolstrip.SpectrumAnalyzerSection('Bandwidth');

            [rbwEdit,rbwCombo]=this.getRBWWidget();
            [frequencyOffsetLabel,frequencyOffsetEdit]=this.getFrequencyOffsetWidget();

            c=addColumn(this);

            add(c,rbwEdit);
            add(c,frequencyOffsetLabel);

            c=addColumn(this,'Width',80);

            add(c,rbwCombo);
            add(c,frequencyOffsetEdit);
        end
    end



    methods(Access=protected)

        function[label,edit]=getSampleRateWidget(this)

            label=this.createLabel('SampleRate');
            label.Description=getString(this,'SampleRate','Description');

            edit=this.createEditField('SampleRate','1e4');
            edit.Description=getString(this,'SampleRate','Description');
        end

        function[label,combo]=getRBWWidget(this)

            label=this.createLabel('RBW');
            label.Description=getString(this,'RBW','Description');

            values={'AUTO'};
            strings={getString(this,'RBWAuto')};
            combo=this.createComboBox('RBW',values,strings);
            combo.Description=getString(this,'RBW','Description');
        end

        function[label,edit]=getFrequencyOffsetWidget(this)

            label=this.createLabel('FrequencyOffset');
            label.Description=getString(this,'FrequencyOffset','Description');

            edit=this.createEditField('FrequencyOffset','0');
            edit.Description=getString(this,'FrequencyOffset','Description');
        end
    end
end

