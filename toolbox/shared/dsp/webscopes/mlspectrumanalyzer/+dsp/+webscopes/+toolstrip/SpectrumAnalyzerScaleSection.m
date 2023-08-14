classdef SpectrumAnalyzerScaleSection<dsp.webscopes.toolstrip.SpectrumAnalyzerSection








    methods

        function this=SpectrumAnalyzerScaleSection
            this@dsp.webscopes.toolstrip.SpectrumAnalyzerSection('Scale');
            [frequencyScaleLabel,frequencyScaleDropDown]=this.getFrequencyScaleWidget();
            [referenceLoadLabel,referenceLoadEdit]=this.getReferenceLoadWidget();
            [spectrumUnitsLabel,spectrumUnitsDropDown]=this.getSpectrumUnitsWidget();
            [fullScaleLabel,fullScaleCombo]=this.getFullScaleWidget();
            c=addColumn(this);
            add(c,frequencyScaleLabel);
            add(c,referenceLoadLabel);
            c=addColumn(this,'Width',100);
            add(c,frequencyScaleDropDown);
            add(c,referenceLoadEdit);
            c=addColumn(this);
            add(c,spectrumUnitsLabel);
            add(c,fullScaleLabel);
            c=addColumn(this,'Width',100);
            add(c,spectrumUnitsDropDown);
            add(c,fullScaleCombo);
        end

        function updateWidgets(this,spec)
            spectrumType=spec.SpectrumType;
            switch spectrumType
            case 'power'
                values={'DBM';'DBW';'WATTS';'DBFS'};
                strings={getString(this,'SpectrumUnitsdBm');...
                getString(this,'SpectrumUnitsdBW');...
                getString(this,'SpectrumUnitsWatts');...
                getString(this,'SpectrumUnitsdBFS')};
            case 'power-density'
                values={'DBM/HZ';'DBW/HZ';'WATTS/HZ';'DBFS/HZ'};
                strings={getString(this,'SpectrumUnitsdBmPerHz');...
                getString(this,'SpectrumUnitsdBWPerHz');...
                getString(this,'SpectrumUnitsWattsPerHz');...
                getString(this,'SpectrumUnitsdBFSPerHz')};
            case 'rms'
                values={'VRMS';'DBV'};
                strings={getString(this,'SpectrumUnitsVrms');...
                getString(this,'SpectrumUnitsdBV')};
            end
            this.setWidgetProperty('SpectrumUnits','Items',[values,strings]);


            if~isequal(this.getProperty('SpectrumUnits'),upper(spec.SpectrumUnits))
                pause(1);
                this.setProperty('SpectrumUnits',upper(spec.SpectrumUnits))
            end
        end
    end



    methods(Access=protected)

        function[label,drop]=getFrequencyScaleWidget(this)

            label=this.createLabel('FrequencyScale');
            label.Description=getString(this,'FrequencyScale','Description');

            values={'LINEAR';'LOG'};
            strings={getString(this,'FrequencyScaleLinear');...
            getString(this,'FrequencyScaleLog')};
            drop=this.createDropDown('FrequencyScale',values,strings);
            drop.Description=getString(this,'FrequencyScale','Description');
        end

        function[label,edit]=getReferenceLoadWidget(this)

            label=this.createLabel('ReferenceLoad');
            label.Description=getString(this,'ReferenceLoad','Description');

            edit=this.createEditField('ReferenceLoad','1');
            edit.Description=getString(this,'ReferenceLoad','Description');
        end

        function[label,drop]=getSpectrumUnitsWidget(this)

            label=this.createLabel('SpectrumUnits');
            label.Description=getString(this,'SpectrumUnits','Description');

            values={'DBM';'DBW';'WATTS';'DBFS'};
            strings={getString(this,'SpectrumUnitsdBm');...
            getString(this,'SpectrumUnitsdBW');...
            getString(this,'SpectrumUnitsWatts');...
            getString(this,'SpectrumUnitsdBFS')};
            drop=this.createDropDown('SpectrumUnits',values,strings);
            drop.Description=getString(this,'SpectrumUnits','Description');
        end

        function[label,combo]=getFullScaleWidget(this)

            label=this.createLabel('FullScale');
            label.Description=getString(this,'FullScale','Description');

            values={'AUTO'};
            strings={getString(this,'FullScaleAuto')};
            combo=this.createComboBox('FullScale',values,strings);
            combo.Description=getString(this,'FullScale','Description');
        end
    end
end