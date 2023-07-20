classdef TimeMeasurementsConfigurable<handle





    properties








        BilevelMeasurements;










        Trigger;
    end



    methods

        function set.BilevelMeasurements(this,value)
            import dsp.webscopes.internal.*;
            if isa(value,'BilevelMeasurementsConfiguration')&&isvalid(value)
                if isempty(this.BilevelMeasurements)
                    this.BilevelMeasurements=value;
                else
                    set(this.BilevelMeasurements,get(value));
                end
            else
                BaseWebScope.localError('invalidMeasurementConfigurationObject','BilevelMeasurements','BilevelMeasurementsConfiguration');
            end
        end

        function set.Trigger(this,value)
            import dsp.webscopes.internal.*;
            if isa(value,'TriggerConfiguration')&&isvalid(value)
                if isempty(this.Trigger)
                    this.Trigger=value;
                else
                    set(this.Trigger,get(value));
                end
            else
                BaseWebScope.localError('invalidMeasurementConfigurationObject','Trigger','TriggerConfiguration');
            end
        end
    end



    methods(Access=protected)

        function addTimeMeasurementsConfiguration(this)
            this.BilevelMeasurements=getTimeMeasurementConfiguration(this,'bilevel');
            this.Trigger=getTimeMeasurementConfiguration(this,'trigger');
        end

        function config=getTimeMeasurementConfiguration(this,measurer)
            switch(measurer)
            case 'bilevel'
                if isempty(this.BilevelMeasurements)
                    config=BilevelMeasurementsConfiguration(this.Specification.BilevelMeasurements);
                else
                    config=this.BilevelMeasurements;
                end

                this.Specification.BilevelMeasurements.Configuration=config;
            case 'trigger'
                if isempty(this.Trigger)
                    config=TriggerConfiguration(this.Specification.Trigger);
                else
                    config=this.Trigger;
                end

                this.Specification.Trigger.Configuration=config;
            end
        end
    end
end