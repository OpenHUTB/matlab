classdef RungOpAtom<plccore.ladder.RungOp&plccore.expr.CallExpr




    properties(Access=protected)
Instr
    end

    methods
        function obj=RungOpAtom(instr,inputs,outputs)
            obj@plccore.expr.CallExpr(instr,inputs,outputs);
            obj.Kind='RungOpAtom';
            obj.Instr=instr;
        end

        function ret=toString(obj)
            if isa(obj.instr,'plccore.ladder.UnknownInstr')
                txt=sprintf('%s(',obj.instr.toString);
            else
                txt=sprintf('%s(',obj.Instr.name);
            end
            for i=1:numel(obj.inputs)
                txt=[txt,obj.inputs{i}.toString];%#ok<AGROW>
                if(i~=numel(obj.inputs))
                    txt=[txt,sprintf(', ')];%#ok<AGROW>
                end
            end
            txt=[txt,sprintf(')')];
            if numel(obj.outputs)
                txt=[txt,sprintf(' -> (')];
                for i=1:numel(obj.outputs)
                    txt=[txt,obj.outputs{i}.toString];%#ok<AGROW>
                    if(i~=numel(obj.outputs))
                        txt=[txt,sprintf(', ')];%#ok<AGROW>
                    end
                end
                txt=[txt,sprintf(')')];
            end
            ret=txt;
        end

        function ret=instr(obj)
            ret=obj.Instr;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitRungOpAtom(obj,input);
        end
    end

end


