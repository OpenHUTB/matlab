classdef MetaData<handle












































    properties
        BatteryId=''
        RatingAh=''
        Name=''
        Date=''
        Source=''
        TestType=''
        TestCurrent=NaN
        TestTemperature=NaN
    end
    properties(Dependent=true,SetAccess='private')
TestCRate
TestTemperatureK
    end





    methods
        function value=get.TestCRate(obj)
            CRate=obj.TestCurrent/obj.RatingAh;

            CRate=round(5*CRate)/5;
            value=CRate;
        end
        function value=get.TestTemperatureK(obj)
            value=obj.TestTemperature+273.15;
        end
    end

end