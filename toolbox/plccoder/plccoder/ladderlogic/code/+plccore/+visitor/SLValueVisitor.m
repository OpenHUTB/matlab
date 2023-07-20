classdef SLValueVisitor<plccore.visitor.AbstractVisitor



    methods
        function obj=SLValueVisitor
            obj.Kind='SLValueVisitor';
        end

        function ret=visitConstFalse(obj,host,input)%#ok<INUSD>
            ret='false';
        end

        function ret=visitConstTrue(obj,host,input)%#ok<INUSD>
            ret='true';
        end

        function ret=visitConstValue(obj,host,input)%#ok<INUSD>
            ret=host.toString;
        end
    end
end

