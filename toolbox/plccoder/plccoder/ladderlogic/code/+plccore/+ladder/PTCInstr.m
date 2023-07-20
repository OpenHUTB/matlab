classdef PTCInstr<plccore.ladder.LadderInstruction




    methods
        function obj=PTCInstr(input_scope,output_scope,local_scope)
            obj@plccore.ladder.LadderInstruction('PTC','Positive Transition Contact',...
            input_scope,output_scope,local_scope);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitPTCInstr(obj,input);
        end
    end

end


