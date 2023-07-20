classdef TransformRegistry





    properties(Constant)
        Transforms=lMakeRegistry()
    end

end

function reg=lMakeRegistry()

    reg=[];


    lRegister("SimscapeMultibody",...
    @simscape.statistics.data.internal.multibody);
    lRegister("network_engine_domain",...
    @simscape.statistics.data.internal.network_engine_domain);
    lRegister("network_engine_domain.NumVariables",...
    @simscape.statistics.data.internal.variables);
    lRegister("network_engine_domain.NumZcSignals",...
    @simscape.statistics.data.internal.zcs);
    lRegister("network_engine_domain.NumPartitions",...
    @simscape.statistics.data.internal.partitions);
    lRegister("network_engine_domain.NumConstraints",...
    @simscape.statistics.data.internal.constraints);
    lRegister("interface",...
    @simscape.statistics.data.internal.interface);

    function lRegister(p,fcn)
        item.Path=p;
        item.Function=fcn;
        reg=[reg;item];
    end
end
