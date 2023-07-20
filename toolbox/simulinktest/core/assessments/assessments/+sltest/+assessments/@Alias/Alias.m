


classdef(Sealed)Alias<sltest.assessments.Expression
    properties(SetAccess=immutable)
expr
aliasArgs
    end

    properties(Hidden)
        CollapseUnaryChain=true
    end

    methods
        function self=Alias(expr,varargin)
            self.expr=expr;
            self.aliasArgs=varargin;
            self=self.initializeInternal();
        end

        function res=children(self)
            res=self.aliasArgs(cellfun(@(e)isa(e,'sltest.assessments.Expression'),self.aliasArgs));
        end
    end

    methods
        function visit(self,functionHandle)
            functionHandle(self);
            cellfun(@(x)x.visit(functionHandle),self.children());
        end

        function res=getResultData(self,startTime,endTime)



            res=self.expr.getResultData(startTime,endTime);

            res.Name=self.internal.stringLabel;
            assert(length(res.Time)>1||startTime==endTime||(isinf(startTime)&&isinf(endTime)));
        end

        function res=transform(self,functionHandle)








            node=self;
            children=node.children();
            while node.CollapseUnaryChain&&length(children)==1
                node=children{1};
                children=node.children();
                if~isa(node,'sltest.assessments.Alias')
                    break;
                end
            end
            if isequal(node,self)
                node=[];
            end
            res=functionHandle(self,node);
            if~isempty(children)
                res.children=cellfun(@(x)x.transform(functionHandle),children,'UniformOutput',false);
            end
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            function arg=exprToInternal(arg)
                if isa(arg,'sltest.assessments.Expression')
                    arg=arg.internal;
                end
            end
            args=cellfun(@exprToInternal,self.aliasArgs,'UniformOutput',false);
            internal=self.expr.internal.alias(args{:});
        end
    end
end
