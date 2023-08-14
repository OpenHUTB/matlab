classdef PTCoilInstr<plccore.ladder.LadderInstruction




    methods
        function obj=PTCoilInstr(input_scope,output_scope,local_scope)
            obj@plccore.ladder.LadderInstruction('PTCoil','Positive Transition Coil',...
            input_scope,output_scope,local_scope);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitPTCoilInstr(obj,input);
        end
    end

end

