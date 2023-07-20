classdef SpectrumAnalyzerSpectrumTraceOptionsSection<dsp.webscopes.toolstrip.SpectrumAnalyzerSection








    methods

        function this=SpectrumAnalyzerSpectrumTraceOptionsSection
            this@dsp.webscopes.toolstrip.SpectrumAnalyzerSection('TraceOptions');
            c=addColumn(this);
            add(c,this.getPlotAsTwoSidedSpectrumWidget());
            add(c,this.getPlotNormalTraceWidget());
            c=addColumn(this);
            add(c,this.getPlotMaxHoldTraceWidget());
            add(c,this.getPlotMinHoldTraceWidget());
        end
    end



    methods(Access=protected)

        function check=getPlotAsTwoSidedSpectrumWidget(this)

            check=this.createCheckBox('PlotAsTwoSidedSpectrum');
            check.Description=getString(this,'PlotAsTwoSidedSpectrum','Description');
        end

        function check=getPlotNormalTraceWidget(this)

            check=this.createCheckBox('PlotNormalTrace');
            check.Value=true;
            check.Description=getString(this,'PlotNormalTrace','Description');
        end

        function check=getPlotMaxHoldTraceWidget(this)

            check=this.createCheckBox('PlotMaxHoldTrace');
            check.Description=getString(this,'PlotMaxHoldTrace','Description');
        end

        function check=getPlotMinHoldTraceWidget(this)

            check=this.createCheckBox('PlotMinHoldTrace');
            check.Description=getString(this,'PlotMinHoldTrace','Description');
        end
    end
end
