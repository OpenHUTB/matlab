classdef(Abstract)RungOpComposite<plccore.ladder.RungOp




    properties(Access=protected)
RungOpList
    end

    methods
        function obj=RungOpComposite(rungop_list)
            obj.Kind='RungOpComposite';
            obj.RungOpList=rungop_list;
        end

        function ret=rungOps(obj)
            ret=obj.RungOpList;
        end
    end

end

