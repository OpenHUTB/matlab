classdef Method<classdiagram.app.core.domain.BaseObject
    properties(Access=private)
        OwningClass;
    end

    properties(Constant)
        ConstantType="Method";
    end

    methods
        function obj=Method(methodName,owningClass,metadata)
            obj.Type=classdiagram.app.core.domain.Method.ConstantType;
            obj.Name=methodName;
            obj.OwningClass=owningClass;
            obj.Metadata=metadata;
            obj.GlobalSettingsFcn=owningClass.GlobalSettingsFcn;
        end

        function owningClass=getOwningClass(self)
            owningClass=self.OwningClass;
        end

        function state=getState(self)
            state=self.OwningClass.getState;
        end

        function accept(self,visitor)
            visitor.visitMethod(self);
        end
    end
end
