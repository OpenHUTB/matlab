classdef ArgumentHandle<sltest.expressions.mi.ArgumentHandle

    properties(Dependent)
Types
    end


    properties(Access=private)
TypesCached
        IsTypesCached=false
    end


    methods(Access=private)
        function obj=ArgumentHandle()
            obj@sltest.expressions.mi.ArgumentHandle();
        end
    end


    methods(Static)

        function obj=makeMoveFrom(miArgumentHandle)
            if~isa(miArgumentHandle,"sltest.expressions.mi.ArgumentHandle")
                error("Argment must be sltest.expressions.mi.ArgumentHandle.");
            end
            obj=sltest.expressions.ArgumentHandle;
            obj.moveFrom(miArgumentHandle);
        end
    end


    methods

        function args=get.Types(self)
            import sltest.expressions.*
            if~self.IsTypesCached
                self.TypesCached=arrayfun(@TemplateHandle.makeMoveFrom,self.TypesImpl);
                self.IsTypesCached=true;
            end
            args=self.TypesCached;
        end

    end
end
