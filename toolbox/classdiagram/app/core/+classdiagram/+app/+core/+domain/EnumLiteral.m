classdef EnumLiteral<classdiagram.app.core.domain.BaseObject



    properties(Constant)
        ConstantType="EnumLiteral";
    end

    properties(Access=private)
        Value;
        OwningEnum;
    end

    methods
        function obj=EnumLiteral(name,owningEnum)
            obj.Type=classdiagram.app.core.domain.EnumLiteral.ConstantType;
            obj.Name=name;
            obj.OwningEnum=owningEnum;
            obj.Metadata=containers.Map;
            obj.GlobalSettingsFcn=owningEnum.GlobalSettingsFcn;
        end

        function accept(self,visitor)
            visitor.visitEnumLiteral(self);
        end

        function value=getValue(self)
            value=self.Value;
        end

        function setValue(self,value)
            self.Value=value;
        end

        function owningEnum=getOwningEnum(self)
            owningEnum=self.OwningEnum;
        end
    end
end
