classdef AliasInfo<plccore.common.Object




    properties(Access=protected)
Scope
Name
Type
AliasRef
Required
Visible
Description
    end

    methods
        function obj=AliasInfo(scope,name,alias_ref)
            obj.Kind='AliasInfo';
            obj.Scope=scope;
            obj.Name=name;
            obj.AliasRef=alias_ref;
        end

        function obj=setName(obj,new_name)
            obj.Name=new_name;
        end

        function name=name(obj)
            name=obj.Name;
        end

        function obj=setAlias(obj,alias_ref)
            obj.AliasRef=alias_ref;
        end

        function ret=alias(obj)
            ret=obj.AliasRef;
        end


        function ret=toString(obj)
            ret=sprintf('%s (=%s)',obj.name,obj.alias);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitAliasInfo(obj,input);
        end
    end

end


