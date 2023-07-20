classdef(Abstract)POUImplementation<plccore.common.Object




    properties(Access=protected)
Owner
    end

    methods
        function obj=POUImplementation
            obj.Kind='POUImplementation';
        end

        function ret=owner(obj)
            ret=obj.Owner;
        end
    end

    methods(Access={?plccore.common.POU,...
        ?plccore.common.Function,...
        ?plccore.common.FunctionBlock,...
        ?plccore.common.Program,...
        ?plccore.ladder.LadderDiagram})
        function obj=setOwner(obj,pou)
            obj.Owner=pou;
            pou.setImplementation(obj);
        end
    end

end


