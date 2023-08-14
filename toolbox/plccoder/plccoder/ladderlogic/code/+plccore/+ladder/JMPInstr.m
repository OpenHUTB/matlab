classdef JMPInstr<plccore.ladder.LadderInstruction



    methods
        function obj=JMPInstr(input_scope,output_scope,local_scope)
            obj@plccore.ladder.LadderInstruction('JMP','Jump',input_scope,output_scope,local_scope);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitJMPInstr(obj,input);
        end
    end

end


