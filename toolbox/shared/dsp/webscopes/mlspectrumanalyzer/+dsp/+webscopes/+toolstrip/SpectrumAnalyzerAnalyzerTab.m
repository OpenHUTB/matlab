classdef SpectrumAnalyzerAnalyzerTab<dsp.webscopes.toolstrip.SpectrumAnalyzerTab






    methods

        function this=SpectrumAnalyzerAnalyzerTab(~)
            this@dsp.webscopes.toolstrip.SpectrumAnalyzerTab('Analyzer');
            this.add(dsp.webscopes.toolstrip.SpectrumAnalyzerViewsSection);
            this.add(dsp.webscopes.toolstrip.SpectrumAnalyzerBandwidthSection);
        end
    end
end
