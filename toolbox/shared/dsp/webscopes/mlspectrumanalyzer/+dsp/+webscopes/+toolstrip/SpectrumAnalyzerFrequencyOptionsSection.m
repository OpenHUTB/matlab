classdef SpectrumAnalyzerFrequencyOptionsSection<dsp.webscopes.toolstrip.SpectrumAnalyzerSection








    methods

        function this=SpectrumAnalyzerFrequencyOptionsSection
            this@dsp.webscopes.toolstrip.SpectrumAnalyzerSection('FrequencyOptions');
            [frequencySpanLabel,frequencySpanDropDown]=this.getFrequencySpanWidget();
            [startFrequencyLabel,startFrequencyEdit]=this.getStartFrequencyWidget();
            [stopFrequencyLabel,stopFrequencyEdit]=this.getStopFrequencyWidget();

            c=addColumn(this);
            add(c,frequencySpanLabel);
            add(c,startFrequencyLabel);
            add(c,stopFrequencyLabel);

            c=addColumn(this,'Width',100);
            add(c,frequencySpanDropDown);
            add(c,startFrequencyEdit);
            add(c,stopFrequencyEdit);
        end

        function updateWidgets(this,frequencySpan)
            if strcmpi(frequencySpan,'span-and-center-frequency')
                this.setText('StartFrequencyLabel','SpanLabel');
                this.setDescription('StartFrequencyLabel','Span');
                this.setText('StopFrequencyLabel','CenterFrequencyLabel');
                this.setDescription('StopFrequencyLabel','CenterFrequency');
            else
                this.setText('StartFrequencyLabel','StartFrequencyLabel');
                this.setDescription('StartFrequencyLabel','StartFrequency');
                this.setText('StopFrequencyLabel','StopFrequencyLabel');
                this.setDescription('StopFrequencyLabel','StopFrequency');
            end
        end
    end



    methods(Access=protected)

        function[label,drop]=getFrequencySpanWidget(this)

            label=this.createLabel('FrequencySpan');
            label.Description=getString(this,'FrequencySpan','Description');

            values={'FULL';'SPAN-AND-CENTER-FREQUENCY';'START-AND-STOP-FREQUENCIES'};
            strings={getString(this,'FrequencySpanFull');...
            getString(this,'FrequencySpanSpanAndCenterFrequency');...
            getString(this,'FrequencySpanStartAndStopFrequencies')};
            drop=this.createDropDown('FrequencySpan',values,strings);
            drop.Description=getString(this,'FrequencySpan','Description');
        end

        function[label,edit]=getStartFrequencyWidget(this)

            label=this.createLabel('StartFrequency');
            label.Description=getString(this,'StartFrequency','Description');

            edit=this.createEditField('StartFrequency','-5000');
            edit.Description=getString(this,'StartFrequency','Description');
        end

        function[label,edit]=getStopFrequencyWidget(this)

            label=this.createLabel('StopFrequency');
            label.Description=getString(this,'StopFrequency','Description');

            edit=this.createEditField('StopFrequency','5000');
            edit.Description=getString(this,'StopFrequency','Description');
        end
    end
end