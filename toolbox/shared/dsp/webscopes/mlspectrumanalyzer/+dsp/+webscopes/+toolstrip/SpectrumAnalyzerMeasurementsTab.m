classdef SpectrumAnalyzerMeasurementsTab<dsp.webscopes.toolstrip.SpectrumAnalyzerTab







    methods

        function this=SpectrumAnalyzerMeasurementsTab
            this@dsp.webscopes.toolstrip.SpectrumAnalyzerTab('Measurements');
            this.add(matlabshared.scopes.toolstrip.ChannelSelectionSection);
            this.add(matlabshared.scopes.toolstrip.DataCursorsSection);
            this.add(matlabshared.scopes.toolstrip.PeakFinderSection);
            this.add(dsp.webscopes.toolstrip.DistortionMeasurementsSection);
        end
    end



    methods(Access=protected)

        function catalog=getCatalog(~)
            catalog='Spcuilib:scopes';
        end
    end
end
