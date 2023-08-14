classdef SetCoilInstr<plccore.ladder.LadderInstruction




    methods
        function obj=SetCoilInstr(input_scope,output_scope,local_scope)
            obj@plccore.ladder.LadderInstruction('SetCoil','Set Coil',...
            input_scope,output_scope,local_scope);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitSetCoilInstr(obj,input);
        end
    end

end

