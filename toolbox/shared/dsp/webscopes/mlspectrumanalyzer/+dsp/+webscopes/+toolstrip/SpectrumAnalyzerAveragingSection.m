classdef SpectrumAnalyzerAveragingSection<dsp.webscopes.toolstrip.SpectrumAnalyzerSection








    methods

        function this=SpectrumAnalyzerAveragingSection
            this@dsp.webscopes.toolstrip.SpectrumAnalyzerSection('Averaging');
            [label,slider]=this.getForgettingFactorWidget();
            c=addColumn(this);
            add(c,label);
            add(c,slider);
        end
    end



    methods(Access=protected)

        function[label,slider]=getForgettingFactorWidget(this)

            label=this.createLabel('ForgettingFactor');
            label.Description=getString(this,'ForgettingFactor','Description');

            slider=this.createSlider('ForgettingFactor',[0,1],0.9);
            slider.Labels={'0',0;'1',11};
            slider.Description=getString(this,'ForgettingFactor','Description');
        end
    end
end