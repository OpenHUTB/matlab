classdef UnknownInstr<plccore.ladder.LadderInstruction




    properties(Access=protected)
InstrName
    end

    methods
        function obj=UnknownInstr(instr_name)
            obj@plccore.ladder.LadderInstruction('UnknownInstr','Unknown Instr',...
            [],[],[]);
            obj.InstrName=instr_name;
        end

        function ret=instrName(obj)
            ret=obj.InstrName;
        end

        function ret=toString(obj)
            ret=sprintf('%s_%s',obj.name,obj.instrName);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitUnknownInstr(obj,input);
        end
    end

end


