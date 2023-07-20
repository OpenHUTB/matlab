classdef SpectrumAnalyzerWindowOptionsSection<dsp.webscopes.toolstrip.SpectrumAnalyzerSection








    methods

        function this=SpectrumAnalyzerWindowOptionsSection
            this@dsp.webscopes.toolstrip.SpectrumAnalyzerSection('WindowOptions');
            [windowLabel,windowDropDown]=this.getWindowWidget();
            [sidelobeAttenuationLabel,sidelobeAttenuationEdit]=this.getSidelobeAttenuationWidget();
            [overlapPercentLabel,overlapPercentSpinner]=this.getOverlapPercentWidget();
            c=addColumn(this);
            add(c,windowLabel);
            add(c,sidelobeAttenuationLabel);
            add(c,overlapPercentLabel);
            c=addColumn(this,'Width',80);
            add(c,windowDropDown);
            add(c,sidelobeAttenuationEdit);
            add(c,overlapPercentSpinner);
        end
    end



    methods(Access=protected)

        function[label,drop]=getWindowWidget(this)

            label=this.createLabel('Window');
            label.Description=getString(this,'Window','Description');

            values={'HANN';'BLACKMAN-HARRIS';'CHEBYSHEV';'FLAT-TOP';'HAMMING';'KAISER';'RECTANGULAR'};
            strings={getString(this,'WindowHann');...
            getString(this,'WindowBlackmanHarris');...
            getString(this,'WindowChebyshev');...
            getString(this,'WindowFlattop');...
            getString(this,'WindowHamming');...
            getString(this,'WindowKaiser');...
            getString(this,'WindowRectangular')};
            drop=this.createDropDown('Window',values,strings);
            drop.Description=getString(this,'Window','Description');
        end

        function[label,edit]=getSidelobeAttenuationWidget(this)

            label=this.createLabel('SidelobeAttenuation');
            label.Description=getString(this,'SidelobeAttenuation','Description');

            edit=this.createEditField('SidelobeAttenuation','60');
            edit.Description=getString(this,'SidelobeAttenuation','Description');
        end

        function[label,spinner]=getOverlapPercentWidget(this)

            label=this.createLabel('OverlapPercent');
            label.Description=getString(this,'OverlapPercent','Description');

            spinner=this.createSpinner('OverlapPercent',[0,100],0);
            spinner.Description=getString(this,'OverlapPercent','Description');
        end
    end
end