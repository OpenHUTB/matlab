classdef NegCoilInstr<plccore.ladder.LadderInstruction




    methods
        function obj=NegCoilInstr(input_scope,output_scope,local_scope)
            obj@plccore.ladder.LadderInstruction('NegCoil','Negated Coil',...
            input_scope,output_scope,local_scope);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitNegCoilInstr(obj,input);
        end
    end

end

