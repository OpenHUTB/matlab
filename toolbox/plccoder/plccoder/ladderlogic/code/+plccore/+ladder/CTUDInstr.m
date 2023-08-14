classdef CTUDInstr<plccore.ladder.LadderInstruction




    methods
        function obj=CTUDInstr(input_scope,output_scope,local_scope)
            obj@plccore.ladder.LadderInstruction('CTUD','Up-Down Counter',...
            input_scope,output_scope,local_scope);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitCTUDInstr(obj,input);
        end
    end

end


