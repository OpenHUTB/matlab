classdef RungOpPar<plccore.ladder.RungOpComposite




    methods
        function obj=RungOpPar(rungop_list)
            obj@plccore.ladder.RungOpComposite(rungop_list);
            obj.Kind='RungOpPar';
        end

        function ret=toString(obj)
            txt=sprintf('par(');
            for i=1:numel(obj.RungOpList)
                txt=[txt,obj.RungOpList{i}.toString];%#ok<AGROW>
                if(i~=numel(obj.RungOpList))
                    txt=[txt,sprintf('| ')];%#ok<AGROW>
                end
            end
            txt=[txt,sprintf(')')];
            ret=txt;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitRungOpPar(obj,input);
        end
    end

end

