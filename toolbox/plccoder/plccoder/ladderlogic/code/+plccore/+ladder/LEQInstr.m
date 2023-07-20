classdef LEQInstr<plccore.ladder.LadderInstruction




    methods
        function obj=LEQInstr(input_scope,output_scope,local_scope)
            obj@plccore.ladder.LadderInstruction('LEQ','Less Than or Equal',input_scope,output_scope,local_scope);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitLEQInstr(obj,input);
        end
    end

end

