classdef TimeMeasurementsSpecifiable<handle







    properties(Hidden)

        BilevelMeasurements;

        Trigger;
    end



    methods(Access=protected)

        function addTimeMeasurementsSpecification(this)
            this.BilevelMeasurements=getTimeMeasurementSpecification(this,'bilevel');
            this.Trigger=getTimeMeasurementSpecification(this,'trigger');
        end

        function spec=getTimeMeasurementSpecification(this,measurer)
            switch(measurer)
            case 'bilevel'
                spec=dsp.webscopes.measurements.BilevelMeasurementsSpecification(this);
            case 'trigger'
                spec=dsp.webscopes.measurements.TriggerSpecification(this);
            end
        end
    end
end

