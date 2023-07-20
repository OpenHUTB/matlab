classdef CoilInstr<plccore.ladder.LadderInstruction




    methods
        function obj=CoilInstr(input_scope,output_scope,local_scope)
            obj@plccore.ladder.LadderInstruction('Coil','Coil',input_scope,output_scope,local_scope);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitCoilInstr(obj,input);
        end
    end

end

