classdef SpectrumAnalyzerDomainSection<dsp.webscopes.toolstrip.SpectrumAnalyzerSection








    methods

        function this=SpectrumAnalyzerDomainSection
            this@dsp.webscopes.toolstrip.SpectrumAnalyzerSection('Domain');
            [inputDomainLabel,inputDomainDropDown]=this.getInputDomainWidget();
            [frequencyVectorLabel,frequencyVectorCombo]=this.getFrequencyVectorWidget();
            [inputUnitsLabel,inputUnitsDropDowm]=this.getInputUnitsWidget();

            c=addColumn(this);
            add(c,inputDomainLabel);
            add(c,frequencyVectorLabel);
            add(c,inputUnitsLabel);

            c=addColumn(this,'Width',100);
            add(c,inputDomainDropDown);
            add(c,frequencyVectorCombo);
            add(c,inputUnitsDropDowm);
        end
    end



    methods(Access=protected)

        function[label,drop]=getInputDomainWidget(this)

            label=this.createLabel('InputDomain');
            label.Description=getString(this,'InputDomain','Description');

            values={'TIME';'FREQUENCY'};
            strings={getString(this,'InputDomainTime');...
            getString(this,'InputDomainFrequency')};
            drop=this.createDropDown('InputDomain',values,strings);
            drop.Description=getString(this,'InputDomain','Description');
        end

        function[label,combo]=getFrequencyVectorWidget(this)

            label=this.createLabel('FrequencyVector');
            label.Description=getString(this,'FrequencyVector','Description');

            values={'AUTO'};
            strings={getString(this,'FrequencyVectorAuto')};
            combo=this.createComboBox('FrequencyVectorSource',values,strings);
            combo.Description=getString(this,'FrequencyVector','Description');
        end

        function[label,drop]=getInputUnitsWidget(this)

            label=this.createLabel('InputUnits');
            label.Description=getString(this,'InputUnits','Description');

            values={'AUTO';'DBM'};
            strings={getString(this,'InputUnitsAuto');...
            getString(this,'InputUnitsdBm')};
            drop=this.createDropDown('InputUnits',values,strings);
            drop.Description=getString(this,'InputUnits','Description');
        end
    end
end