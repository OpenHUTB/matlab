classdef CTDInstr<plccore.ladder.LadderInstruction




    methods
        function obj=CTDInstr(input_scope,output_scope,local_scope)
            obj@plccore.ladder.LadderInstruction('CTD','Down Counter',...
            input_scope,output_scope,local_scope);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitCTDInstr(obj,input);
        end
    end

end


