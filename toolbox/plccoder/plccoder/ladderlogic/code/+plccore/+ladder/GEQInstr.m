classdef GEQInstr<plccore.ladder.LadderInstruction




    methods
        function obj=GEQInstr(input_scope,output_scope,local_scope)
            obj@plccore.ladder.LadderInstruction('GEQ','Greater Than or Equal',input_scope,output_scope,local_scope);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitGEQInstr(obj,input);
        end
    end

end


