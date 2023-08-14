classdef CursorMeasurementsSpecification<dsp.webscopes.measurements.BaseMeasurementSpecification





    properties(AbortSet)
        XLocation=[2,8];
        SnapToData=false;
        LockSpacing=false;
    end



    methods


        function settings=getSettings(this)
            settings=getSettings@dsp.webscopes.measurements.BaseMeasurementSpecification(this);
            settings.XLocation=this.XLocation;
            settings.SnapToData=this.SnapToData;
            settings.LockSpacing=this.LockSpacing;
        end
    end



    methods(Hidden)

        function name=getMeasurementPropertyName(~)
            name='CursorMeasurements';
        end

        function name=getMeasurementName(~)
            name='Cursor Measurements';
        end
    end
end