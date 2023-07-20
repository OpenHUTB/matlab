classdef SpectrumAnalyzerFrequencyResolutionSection<dsp.webscopes.toolstrip.SpectrumAnalyzerSection








    methods

        function this=SpectrumAnalyzerFrequencyResolutionSection
            this@dsp.webscopes.toolstrip.SpectrumAnalyzerSection('FrequencyResolution');
            [methodLabel,methodDropDown]=this.getMethodWidget();

            c=addColumn(this);
            add(c,methodLabel);

            c=addColumn(this,'Width',100);
            add(c,methodDropDown);
        end
    end



    methods(Access=protected)

        function[label,drop]=getMethodWidget(this)

            label=this.createLabel('Method');
            label.Description=getString(this,'Method','Description');

            values={'WELCH';'FILTER-BANK'};
            strings={getString(this,'MethodWelch');...
            getString(this,'MethodFilterbank')};
            drop=this.createDropDown('Method',values,strings);
            drop.Description=getString(this,'Method','Description');
        end
    end
end