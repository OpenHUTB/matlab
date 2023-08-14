classdef ThermostaticExpansionValveEqualization<int32





    enumeration
        Internal(1)
        External(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Internal')='Internal pressure equalization';
            map('External')='External pressure equalization';
        end
    end
end