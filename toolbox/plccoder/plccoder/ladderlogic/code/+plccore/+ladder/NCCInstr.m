classdef NCCInstr<plccore.ladder.LadderInstruction




    methods
        function obj=NCCInstr(input_scope,output_scope,local_scope)
            obj@plccore.ladder.LadderInstruction('NCC','Nomally Closed Contact',...
            input_scope,output_scope,local_scope);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitNCCInstr(obj,input);
        end
    end

end


