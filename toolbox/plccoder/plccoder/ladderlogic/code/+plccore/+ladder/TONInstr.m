classdef TONInstr<plccore.ladder.LadderInstruction




    methods
        function obj=TONInstr(input_scope,output_scope,local_scope)
            obj@plccore.ladder.LadderInstruction('TON','Timer On Delay',...
            input_scope,output_scope,local_scope);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitTONInstr(obj,input);
        end
    end

end


