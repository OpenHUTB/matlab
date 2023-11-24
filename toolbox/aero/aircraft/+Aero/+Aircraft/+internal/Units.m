classdef Units

    properties
        UnitSystem(1,1)string{mustBeMember(UnitSystem,["Metric","English (kts)","English (ft/s)"])}="Metric";
        TemperatureSystem(1,1)Aero.internal.datatype.Temperature="Kelvin";
    end

    properties(Dependent)
        AngleSystem(1,1)Aero.internal.datatype.Angle;
    end

    properties(Hidden)
        AngleSystem_I(1,1)Aero.internal.datatype.Angle="Radians";
        AngleConvertString_I(1,:)char='rad'
    end

    methods
        function obj=set.AngleSystem(obj,value)
            obj.AngleSystem_I=value;
            obj.AngleConvertString_I=obj.AngleSystem.extractBefore(4).lower();
        end
        function value=get.AngleSystem(obj)
            value=string(obj.AngleSystem_I);
        end

        function value=get.TemperatureSystem(obj)
            value=string(obj.TemperatureSystem);
        end
    end
end

