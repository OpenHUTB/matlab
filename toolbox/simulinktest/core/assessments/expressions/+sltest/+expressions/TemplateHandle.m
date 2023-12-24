classdef TemplateHandle<sltest.expressions.mi.TemplateHandle

    properties(Dependent)
Parent
Definition
OwnArgs
AllArgs
    end


    properties(Access=private)
ParentCached
        IsParentCached=false

DefinitionCached
        IsDefinitionCached=false

OwnArgsCached
        IsOwnArgsCached=false

AllArgsCached
        IsAllArgsCached=false
    end


    methods(Access=private)
        function obj=TemplateHandle()
            obj@sltest.expressions.mi.TemplateHandle();
        end
    end


    methods(Static)
        function obj=makeMoveFrom(miTemplateHandle)
            if~isa(miTemplateHandle,"sltest.expressions.mi.TemplateHandle")
                error("Argment must be sltest.expressions.mi.TemplateHandle.");
            end
            obj=sltest.expressions.TemplateHandle;
            obj.moveFrom(miTemplateHandle);
        end
    end


    methods

        function parent=get.Parent(self)
            import sltest.expressions.*
            if~self.IsParentCached
                parentImpl=self.ParentImpl;
                if~isempty(parentImpl)
                    self.ParentCached=TemplateHandle.makeMoveFrom(parentImpl);
                end
                self.IsParentCached=true;
            end
            parent=self.ParentCached;
        end


        function definition=get.Definition(self)
            import sltest.expressions.*
            if~self.IsDefinitionCached
                definitionImpl=self.DefinitionImpl;
                if~isempty(definitionImpl)
                    self.DefinitionCached=ExprHandle.makeMoveFrom(definitionImpl);
                end
                self.IsDefinitionCached=true;
            end
            definition=self.DefinitionCached;
        end


        function ownArgs=get.OwnArgs(self)
            import sltest.expressions.*
            if~self.IsOwnArgsCached
                self.OwnArgsCached=arrayfun(@ArgumentHandle.makeMoveFrom,self.OwnArgsImpl);
                self.IsOwnArgsCached=true;
            end
            ownArgs=self.OwnArgsCached;
        end


        function allArgs=get.AllArgs(self)
            import sltest.expressions.*
            if~self.IsAllArgsCached
                self.AllArgsCached=arrayfun(@ArgumentHandle.makeMoveFrom,self.AllArgsImpl);
                self.IsAllArgsCached=true;
            end
            allArgs=self.AllArgsCached;
        end

    end
end
