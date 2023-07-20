classdef POUScope<plccore.common.Scope




    properties(Access=protected)
Owner
    end

    methods
        function obj=POUScope(name)
            obj.Kind='POUScope';
            obj.Name=name;
        end
    end

    methods(Access={?plccore.common.POU,...
        ?plccore.common.Function,...
        ?plccore.common.FunctionBlock,...
        ?plccore.common.Program})
        function setOwner(obj,pou)
            obj.Owner=pou;
        end
    end

end


