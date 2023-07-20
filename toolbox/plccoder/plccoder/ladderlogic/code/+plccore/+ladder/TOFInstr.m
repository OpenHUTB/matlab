classdef TOFInstr<plccore.ladder.LadderInstruction




    methods
        function obj=TOFInstr(input_scope,output_scope,local_scope)
            obj@plccore.ladder.LadderInstruction('TOF','Timer Off Delay',...
            input_scope,output_scope,local_scope);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitTOFInstr(obj,input);
        end
    end

end


