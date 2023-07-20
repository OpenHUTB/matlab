classdef pump_motor_loss_spec<int32





    enumeration
        analytical(1)
        table_efficiency(2)
        table_loss(3)
        input_efficiency(4)
        input_loss(5)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('analytical')='Analytical';
            map('table_efficiency')='Tabulated data - volumetric and mechanical efficiencies';
            map('table_loss')='Tabulated data - volumetric and mechanical losses';
            map('input_efficiency')='Input signal - volumetric and mechanical efficiencies';
            map('input_loss')='Input signal - volumetric and mechanical losses';
        end
    end
end