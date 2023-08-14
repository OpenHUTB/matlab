classdef DistortionMeasurementsSection<dsp.webscopes.toolstrip.SpectrumAnalyzerSection








    methods

        function this=DistortionMeasurementsSection
            this@dsp.webscopes.toolstrip.SpectrumAnalyzerSection('Distortion');
            c=addColumn(this);
            add(c,this.getDistortionWidget());
            [distortionTypeLabel,distortionTypeDropDown]=this.getDistortionTypeWidget();
            [numHarmonicsLabel,numHarmonicsSpinner]=this.getNumHarmonicsWidget();
            [labelHarmonicsLabel,labelHarmonicsCheck]=this.getLabelHarmonicsWidget();

            c=addColumn(this);
            add(c,distortionTypeLabel);
            add(c,numHarmonicsLabel);
            add(c,labelHarmonicsLabel);

            c=addColumn(this,'Width',90);
            add(c,distortionTypeDropDown);
            add(c,numHarmonicsSpinner);
            add(c,labelHarmonicsCheck);
        end
    end



    methods(Access=protected)

        function button=getDistortionWidget(this)
            button=this.createToggleButton('ShowDistortion','distortion_24.png');
            button.Description=getString(this,'ShowDistortion','Description');
        end

        function[label,drop]=getDistortionTypeWidget(this)

            label=this.createLabel('DistortionType');
            label.Description=getString(this,'DistortionType','Description');

            values={'HARMONIC';'INTERMODULATION'};
            strings={getString(this,'DistortionTypeHarmonic');...
            getString(this,'DistortionTypeIntermodulation')};
            drop=this.createDropDown('DistortionType',values,strings);
            drop.Description=getString(this,'DistortionType','Description');
        end

        function[label,spinner]=getNumHarmonicsWidget(this)

            label=this.createLabel('NumHarmonics');
            label.Description=getString(this,'NumHarmonics','Description');

            spinner=this.createSpinner('NumHarmonics',[1,99],6);
            spinner.Description=getString(this,'NumHarmonics','Description');
        end

        function[label,check]=getLabelHarmonicsWidget(this)

            label=this.createLabel('LabelHarmonics');
            label.Description=getString(this,'LabelHarmonics','Description');

            check=this.createCheckBox('LabelHarmonics');
            check.Text='';
            check.Description=getString(this,'LabelHarmonics','Description');
        end
    end
end
