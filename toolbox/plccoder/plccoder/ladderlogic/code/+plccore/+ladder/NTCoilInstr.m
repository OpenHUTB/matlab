classdef NTCoilInstr<plccore.ladder.LadderInstruction




    methods
        function obj=NTCoilInstr(input_scope,output_scope,local_scope)
            obj@plccore.ladder.LadderInstruction('NTCoil','Negative Transition Coil',...
            input_scope,output_scope,local_scope);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitNTCoilInstr(obj,input);
        end
    end

end

