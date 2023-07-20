classdef CallExpr<plccore.expr.AbstractExpr




    properties(Access=protected)
POU
Inputs
Outputs
    end

    methods
        function obj=CallExpr(pou,inputs,outputs)
            obj.Kind='CallExpr';
            obj.POU=pou;
            obj.Inputs=inputs;
            obj.Outputs=outputs;
        end

        function ret=pou(obj)
            ret=obj.POU;
        end

        function ret=inputs(obj)
            ret=obj.Inputs;
        end

        function ret=outputs(obj)
            ret=obj.Outputs;
        end

        function setInputs(obj,inputs)
            obj.Inputs=inputs;
        end

        function setOutputs(obj,outputs)
            obj.Outputs=outputs;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitCallExpr(obj,input);
        end
    end

end

