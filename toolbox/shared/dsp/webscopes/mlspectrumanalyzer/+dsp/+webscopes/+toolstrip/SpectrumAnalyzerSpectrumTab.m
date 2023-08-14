classdef SpectrumAnalyzerSpectrumTab<dsp.webscopes.toolstrip.SpectrumAnalyzerTab






    methods

        function this=SpectrumAnalyzerSpectrumTab(~)
            this@dsp.webscopes.toolstrip.SpectrumAnalyzerTab('Spectrum');
            this.add(dsp.webscopes.toolstrip.SpectrumAnalyzerSpectrumTraceOptionsSection);
            this.add(dsp.webscopes.toolstrip.SpectrumAnalyzerScaleSection);
        end
    end
end
