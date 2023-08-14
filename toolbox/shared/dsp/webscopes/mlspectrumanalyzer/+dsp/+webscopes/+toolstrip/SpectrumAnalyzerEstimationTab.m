classdef SpectrumAnalyzerEstimationTab<dsp.webscopes.toolstrip.SpectrumAnalyzerTab






    methods

        function this=SpectrumAnalyzerEstimationTab(~)
            this@dsp.webscopes.toolstrip.SpectrumAnalyzerTab('Estimation');

            this.add(dsp.webscopes.toolstrip.SpectrumAnalyzerFrequencyResolutionSection);
            this.add(dsp.webscopes.toolstrip.SpectrumAnalyzerAveragingSection);
            this.add(dsp.webscopes.toolstrip.SpectrumAnalyzerWindowOptionsSection);
            this.add(dsp.webscopes.toolstrip.SpectrumAnalyzerFrequencyOptionsSection);
        end
    end



    methods(Access=protected)

        function catalog=getCatalog(~)
            catalog='shared_dspwebscopes:spectrumanalyzer';
        end
    end
end
