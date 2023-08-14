classdef NOCInstr<plccore.ladder.LadderInstruction




    methods
        function obj=NOCInstr(input_scope,output_scope,local_scope)
            obj@plccore.ladder.LadderInstruction('NOC','Nomally Open Contact',...
            input_scope,output_scope,local_scope);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitNOCInstr(obj,input);
        end
    end

end


