classdef JSRInstr<plccore.ladder.LadderInstruction




    methods
        function obj=JSRInstr(input_scope,output_scope,local_scope)
            obj@plccore.ladder.LadderInstruction('JSR','Jump to Subroutine',input_scope,output_scope,local_scope);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitJSRInstr(obj,input);
        end
    end
end


