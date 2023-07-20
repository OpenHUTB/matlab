classdef ResetCoilInstr<plccore.ladder.LadderInstruction




    methods
        function obj=ResetCoilInstr(input_scope,output_scope,local_scope)
            obj@plccore.ladder.LadderInstruction('ResetCoil','Reset Coil',...
            input_scope,output_scope,local_scope);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitResetCoilInstr(obj,input);
        end
    end

end

