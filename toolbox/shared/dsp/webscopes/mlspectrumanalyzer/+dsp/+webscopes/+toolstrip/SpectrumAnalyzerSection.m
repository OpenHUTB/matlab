classdef SpectrumAnalyzerSection<matlabshared.scopes.toolstrip.Section







    methods(Access=protected)

        function p=getIconPath(~)
            p=fullfile(toolboxdir('shared/dsp/webscopes'),'dspwebscopesutils','js','images');
        end

        function catalog=getCatalog(~)
            catalog='shared_dspwebscopes:spectrumanalyzer';
        end
    end
end
