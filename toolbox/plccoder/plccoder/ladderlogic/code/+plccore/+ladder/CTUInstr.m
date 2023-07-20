classdef CTUInstr<plccore.ladder.LadderInstruction




    methods
        function obj=CTUInstr(input_scope,output_scope,local_scope)
            obj@plccore.ladder.LadderInstruction('CTU','Up Counter',...
            input_scope,output_scope,local_scope);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitCTUInstr(obj,input);
        end
    end

end


