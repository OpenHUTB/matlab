classdef RungOpFBCall<plccore.ladder.RungOp&plccore.expr.FBCallExpr




    methods
        function obj=RungOpFBCall(pou,instance,arglist)
            obj@plccore.expr.FBCallExpr(pou,instance,arglist);
            obj.Kind='RungOpFBCall';
        end

        function ret=toString(obj)
            txt=obj.toStringHeader;
            for i=1:numel(obj.argList)
                txt=[txt,obj.argList{i}.toString];%#ok<AGROW>
                if(i~=numel(obj.argList))
                    txt=[txt,sprintf(', ')];%#ok<AGROW>
                end
            end
            txt=[txt,sprintf(')')];
            ret=txt;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitRungOpFBCall(obj,input);
        end

        function ret=toStringHeader(obj)
            ret=sprintf('%s:%s(',obj.instance.toString,obj.pou.name);
        end
    end

end


