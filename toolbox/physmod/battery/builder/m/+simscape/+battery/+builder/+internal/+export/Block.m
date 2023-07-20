classdef(Abstract,Hidden,AllowedSubclasses={?simscape.battery.builder.internal.export.SimscapeBlock,...
    ?simscape.battery.builder.internal.export.SimulinkBlock})...
    Block<matlab.mixin.Heterogeneous




    properties(Abstract,Constant)
        BlockType;
    end

    properties(GetAccess=public,SetAccess=protected)
        Identifier;
        BlockParameters=simscape.battery.builder.internal.export.ComponentParameters();
        BlockVariables=simscape.battery.builder.internal.export.ComponentVariables();
        BlockInputs=simscape.battery.builder.internal.export.ComponentInputs();
        BatteryType=string.empty(0,1);
    end

    methods(Abstract)
        setBatteryType(obj,batteryType);
    end
end
