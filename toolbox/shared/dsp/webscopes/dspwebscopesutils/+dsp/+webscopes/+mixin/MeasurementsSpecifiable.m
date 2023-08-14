classdef MeasurementsSpecifiable<handle






    properties(Hidden)

        CursorMeasurements;

        SignalStatistics;

        PeakFinder;
    end



    methods(Access=protected)

        function addMeasurementsSpecification(this)
            if isMeasurementSupported(this,'peaks')
                this.PeakFinder=getMeasurementSpecification(this,'peaks');
            end
            if isMeasurementSupported(this,'cursors')
                this.CursorMeasurements=getMeasurementSpecification(this,'cursors');
            end
            if isMeasurementSupported(this,'stats')
                this.SignalStatistics=getMeasurementSpecification(this,'stats');
            end
        end

        function spec=getMeasurementSpecification(this,measurer)
            switch(measurer)
            case 'cursors'
                spec=dsp.webscopes.measurements.CursorMeasurementsSpecification(this);
            case 'peaks'
                spec=dsp.webscopes.measurements.PeakFinderSpecification(this);
            case 'stats'
                spec=dsp.webscopes.measurements.SignalStatisticsSpecification(this);

            end
        end
    end
end

