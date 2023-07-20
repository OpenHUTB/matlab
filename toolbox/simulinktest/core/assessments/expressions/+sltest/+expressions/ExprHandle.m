classdef ExprHandle<sltest.expressions.mi.ExprHandle




    properties(Dependent)
Template
Args
Value
DataType
    end

    properties(Access=private)
TemplateCached

ArgsCached
        IsArgsCached=false

ValueCached
        IsValueCached=false

DataTypeCached
        IsDataTypeCached=false
    end

    methods(Access=private)
        function obj=ExprHandle()
            obj@sltest.expressions.mi.ExprHandle();
        end
    end

    methods(Static)

        function obj=makeMoveFrom(miExprHandle)
            if~isa(miExprHandle,"sltest.expressions.mi.ExprHandle")
                error("Argment must be sltest.expressions.mi.ExprHandle.");
            end
            obj=sltest.expressions.ExprHandle;
            obj.moveFrom(miExprHandle);
        end
    end

    methods
        function template=get.Template(self)
            import sltest.expressions.*
            if isempty(self.TemplateCached)
                self.TemplateCached=TemplateHandle.makeMoveFrom(self.TemplateImpl);
            end
            template=self.TemplateCached;
        end

        function args=get.Args(self)
            import sltest.expressions.*
            if~self.IsArgsCached
                self.ArgsCached=arrayfun(@ExprHandle.makeMoveFrom,self.ArgsImpl);
                self.IsArgsCached=true;
            end
            args=self.ArgsCached;
        end

        function value=get.Value(self)
            if~self.IsValueCached
                self.ValueCached=self.ValueImpl;
                self.IsValueCached=true;
            end
            value=self.ValueCached;
        end

        function dataType=get.DataType(self)
            if~self.IsDataTypeCached
                self.DataTypeCached=self.DataTypeImpl;
                self.IsDataTypeCached=true;
            end
            dataType=self.DataTypeCached;
        end
    end
end
