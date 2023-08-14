classdef centrifugal_pump_mech_orientation<int32





    enumeration
        positive(1)
        negative(-1)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('positive')='Positive angular velocity of port R relative to port C corresponds to normal pump operation';
            map('negative')='Negative angular velocity of port R relative to port C corresponds to normal pump operation';
        end
    end
end