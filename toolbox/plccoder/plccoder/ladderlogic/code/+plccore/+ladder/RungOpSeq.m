classdef RungOpSeq<plccore.ladder.RungOpComposite




    methods
        function obj=RungOpSeq(rungop_list)
            obj@plccore.ladder.RungOpComposite(rungop_list);
            obj.Kind='RungOpSeq';
        end

        function ret=toString(obj)
            txt=sprintf('seq(');
            for i=1:numel(obj.RungOpList)
                txt=[txt,obj.RungOpList{i}.toString];%#ok<AGROW>
                if(i~=numel(obj.RungOpList))
                    txt=[txt,sprintf(' ')];%#ok<AGROW>
                end
            end
            txt=[txt,sprintf(')')];
            ret=txt;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitRungOpSeq(obj,input);
        end
    end

end

