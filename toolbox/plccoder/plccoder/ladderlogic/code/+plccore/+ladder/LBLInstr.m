classdef LBLInstr<plccore.ladder.LadderInstruction



    properties(Access=protected)
        LabelName;
    end

    methods
        function obj=LBLInstr(input_scope,output_scope,local_scope)
            obj@plccore.ladder.LadderInstruction('LBL','Label',input_scope,output_scope,local_scope);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitLBLInstr(obj,input);
        end
    end

end


