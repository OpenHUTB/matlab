classdef SpectrumAnalyzerBlockScopeComponent<matlabshared.scopes.container.SimulinkScopeComponent








    methods

        function updateToolstrip(this,tabs)%#ok<INUSD> 

        end

        function processSectionEvent(this,ev)%#ok<INUSD> 

        end

        function tabs=getDynamicTabs(this)
            tabs=this.Application.getTab({'dsp.webscopes.toolstrip.SpectrumAnalyzerAnalyzerTab',...
            'dsp.webscopes.toolstrip.SpectrumAnalyzerMeasurementsTab',...
            'dsp.webscopes.toolstrip.SpectrumAnalyzerEstimationTab',...
            'dsp.webscopes.toolstrip.SpectrumAnalyzerSpectrumTab',...
            'dsp.webscopes.toolstrip.SpectrumAnalyzerSpectrogramTab'});
        end
    end
end