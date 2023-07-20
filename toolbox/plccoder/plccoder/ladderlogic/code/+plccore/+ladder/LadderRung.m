classdef LadderRung<plccore.common.Object




    properties(Access=protected)
Description
RungOpList
    end

    methods
        function obj=LadderRung(desc)
            obj.Kind='LadderRung';
            obj.RungOpList={};
            if nargin>0
                assert(isa(desc,'char'));
                obj.Description=desc;
            else
                obj.Description='';
            end
        end

        function appendRungOp(obj,rungop)
            obj.RungOpList{end+1}=rungop;
        end

        function appendRungOps(obj,rungops)
            for i=1:numel(rungops)
                obj.appendRungOp(rungops{i});
            end
        end

        function ret=description(obj)
            ret=obj.Description;
        end

        function setDescription(obj,desc)
            obj.Description=desc;
        end

        function ret=toString(obj)
            txt='';
            if~isempty(obj.Description)
                txt=sprintf('/* %s */\n',obj.Description);
            end
            for i=1:numel(obj.RungOpList)
                txt=[txt,sprintf(' '),obj.RungOpList{i}.toString];%#ok<AGROW>
            end
            ret=txt;
        end

        function clear(obj)
            obj.RungOpList={};
        end

        function ret=rungOps(obj)
            ret=obj.RungOpList;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitLadderRung(obj,input);
        end
    end

end


