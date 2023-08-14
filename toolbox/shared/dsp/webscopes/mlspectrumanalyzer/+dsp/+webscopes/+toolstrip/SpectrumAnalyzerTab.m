classdef SpectrumAnalyzerTab<matlabshared.application.Tab







    methods(Access=protected)

        function catalog=getCatalog(~)
            catalog='shared_dspwebscopes:spectrumanalyzer';
        end
    end
end
