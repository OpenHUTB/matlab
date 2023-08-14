classdef GuiComponentRegistry





    properties(Constant)
        Components=lMakeRegistry()
    end

end

function reg=lMakeRegistry()

    reg=[];


    lRegister("SimscapeMultibody",...
    @simscape.statistics.gui.internal.MultibodyComponent);


    lRegister("network_engine_domain.NumVariables",...
    @simscape.statistics.gui.internal.VariablesComponent);
    lRegister("network_engine_domain.NumZcSignals",...
    @simscape.statistics.gui.internal.ZCComponent);
    lRegister("network_engine_domain.NumPartitions",...
    @simscape.statistics.gui.internal.PartitionsComponent);
    lRegister("network_engine_domain.NumConstraints",...
    @simscape.statistics.gui.internal.ConstraintsComponent);
    lRegister("interface",...
    @simscape.statistics.gui.internal.InterfaceComponent);

    function lRegister(p,fcn)
        item.Path=p;
        item.Function=fcn;
        reg=[reg;item];
    end
end
