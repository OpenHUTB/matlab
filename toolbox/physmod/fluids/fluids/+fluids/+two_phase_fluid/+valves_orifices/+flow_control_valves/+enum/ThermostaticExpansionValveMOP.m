classdef ThermostaticExpansionValveMOP<int32





    enumeration
        Off(0)
        Pressure(1)
        Temperature(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Off')='Off';
            map('Pressure')='On - Specify maximum operating pressure';
            map('Temperature')='On - Specify maximum operating temperature';
        end
    end
end