classdef SpectrumAnalyzerSpectrogramTab<dsp.webscopes.toolstrip.SpectrumAnalyzerTab






    methods

        function this=SpectrumAnalyzerSpectrogramTab(~)
            this@dsp.webscopes.toolstrip.SpectrumAnalyzerTab('Spectrogram');
            this.add(dsp.webscopes.toolstrip.SpectrumAnalyzerSpectrogramChannelSection);
            this.add(dsp.webscopes.toolstrip.SpectrumAnalyzerSpectrogramTimeOptionsSection);
            this.add(dsp.webscopes.toolstrip.SpectrumAnalyzerSpectrogramTraceOptionsSection);
            this.add(dsp.webscopes.toolstrip.SpectrumAnalyzerScaleSection);
        end
    end
end
