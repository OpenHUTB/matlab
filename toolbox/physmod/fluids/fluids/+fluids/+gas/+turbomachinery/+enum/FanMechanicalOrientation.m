classdef FanMechanicalOrientation<int32




    enumeration
        Positive(1)
        Negative(-1)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Positive')='Positive angular velocity of port R relative to port C corresponds to normal fan operation';
            map('Negative')='Negative angular velocity of port R relative to port C corresponds to normal fan operation';
        end
    end
end