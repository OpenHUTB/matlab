classdef SpectrumAnalyzerSpectrogramTraceOptionsSection<dsp.webscopes.toolstrip.SpectrumAnalyzerSection








    methods

        function this=SpectrumAnalyzerSpectrogramTraceOptionsSection
            this@dsp.webscopes.toolstrip.SpectrumAnalyzerSection('TraceOptions');
            c=addColumn(this);
            add(c,this.getPlotAsTwoSidedSpectrumWidget());
        end
    end



    methods(Access=protected)

        function check=getPlotAsTwoSidedSpectrumWidget(this)

            check=this.createCheckBox('PlotAsTwoSidedSpectrum');
            check.Description=getString(this,'PlotAsTwoSidedSpectrum','Description');
        end
    end
end
