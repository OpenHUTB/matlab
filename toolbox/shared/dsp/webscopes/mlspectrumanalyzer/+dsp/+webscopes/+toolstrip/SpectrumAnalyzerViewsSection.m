classdef SpectrumAnalyzerViewsSection<dsp.webscopes.toolstrip.SpectrumAnalyzerSection








    methods

        function this=SpectrumAnalyzerViewsSection
            this@dsp.webscopes.toolstrip.SpectrumAnalyzerSection('Views');

            c=addColumn(this);
            add(c,this.getShowSpectrumWidget());

            c=addColumn(this);
            add(c,this.getShowSpectrogramWidget());
        end
    end



    methods(Access=protected)

        function items=getSpectrumTypeItems(this,viewType)
            group=matlab.ui.internal.toolstrip.ButtonGroup;
            viewType=[viewType,'Type'];
            items{1}=this.createListItemWithRadioButton(group,viewType,'Power',true);
            items{1}.Description=getString(this,[viewType,'Power'],'Description');
            items{2}=this.createListItemWithRadioButton(group,viewType,'PowerDensity',false);
            items{2}.Description=getString(this,[viewType,'PowerDensity'],'Description');
            items{3}=this.createListItemWithRadioButton(group,viewType,'RMS',false);
            items{3}.Description=getString(this,[viewType,'RMS'],'Description');
        end

        function button=getShowSpectrumWidget(this)
            items=this.getSpectrumTypeItems('Spectrum');
            button=this.createToggleSplitButton('ShowSpectrum','spectrum_24.png',items{:});
            button.Description=getString(this,'ShowSpectrum','Description');
            button.Value=true;
            button.Enabled=false;
        end

        function button=getShowSpectrogramWidget(this)
            items=this.getSpectrumTypeItems('Spectrogram');
            button=this.createToggleSplitButton('ShowSpectrogram','spectrogram_24.png',items{:});
            button.Description=getString(this,'ShowSpectrogram','Description');
        end
    end
end
