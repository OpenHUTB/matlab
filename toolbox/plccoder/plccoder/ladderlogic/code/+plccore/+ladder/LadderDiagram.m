classdef LadderDiagram<plccore.common.POUImplementation




    properties(Access=protected)
Rungs
    end

    methods(Static)
        function ld=createLadderDiagram(pou)
            ld=plccore.ladder.LadderDiagram;
            ld.setOwner(pou);
        end
    end

    methods
        function obj=LadderDiagram
            obj.Kind='LadderDiagram';
            obj.Rungs={};
        end

        function rung=createRung(obj,desc)
            if nargin>1
                rung=plccore.ladder.LadderRung(desc);
            else
                rung=plccore.ladder.LadderRung;
            end
            obj.Rungs{end+1}=rung;
        end

        function ret=toString(obj)
            txt=sprintf('Ladder Rungs:\n');
            for i=1:numel(obj.Rungs)
                txt=[txt,sprintf('Rung %d:\n%s\n',i,obj.Rungs{i}.toString)];%#ok<AGROW>
            end
            ret=txt;
        end

        function clear(obj)
            obj.Rungs={};
        end

        function r=rungAt(obj,idx)
            assert(idx>0);
            assert(idx<=numel(obj.Rungs));
            r=obj.Rungs{idx};
        end

        function ret=rungs(obj)
            ret=obj.Rungs;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitLadderDiagram(obj,input);
        end
    end
end


