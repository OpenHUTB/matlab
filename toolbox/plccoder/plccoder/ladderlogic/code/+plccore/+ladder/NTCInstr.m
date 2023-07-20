classdef NTCInstr<plccore.ladder.LadderInstruction




    methods
        function obj=NTCInstr(input_scope,output_scope,local_scope)
            obj@plccore.ladder.LadderInstruction('NTC','Negative Transition Contact',...
            input_scope,output_scope,local_scope);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitNTCInstr(obj,input);
        end
    end

end


