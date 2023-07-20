classdef DistortionMeasurementsSpecification<dsp.webscopes.measurements.BaseMeasurementSpecification






    properties(AbortSet)
        Type='harmonic';
        NumHarmonics=6;
        LabelValues=false;
    end



    methods


        function settings=getSettings(this)
            settings=getSettings@dsp.webscopes.measurements.BaseMeasurementSpecification(this);
            settings.Type=this.Type;
            settings.NumHarmonics=this.NumHarmonics;
            settings.LabelValues=this.LabelValues;
        end

        function flag=isInactiveProperty(this,propName)
            flag=false;
            switch propName
            case 'NumHarmonics'
                flag=strcmpi(this.Type,'intermodulation');
            end
        end
    end



    methods(Hidden)

        function name=getMeasurementPropertyName(~)
            name='DistortionMeasurements';
        end

        function name=getMeasurementName(~)
            name='Distortion Measurements';
        end
    end
end