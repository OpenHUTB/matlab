classdef FBCallExpr<plccore.expr.CallExpr




    properties(Access=public)
Instance
ArgList
    end

    methods
        function obj=FBCallExpr(pou,instance,arglist)
            obj@plccore.expr.CallExpr(pou,[],[]);
            obj.Kind='FBCallExpr';
            obj.Instance=instance;
            obj.ArgList=arglist;
        end

        function ret=instance(obj)
            ret=obj.Instance;
        end

        function ret=argList(obj)
            ret=obj.ArgList;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitFBCallExpr(obj,input);
        end
    end

end


