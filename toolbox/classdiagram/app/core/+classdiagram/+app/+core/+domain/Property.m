classdef Property<classdiagram.app.core.domain.BaseObject



    properties(Access=private)
        OwningClass;
        DomainType='';
        DefaultValue;
        Unit;
    end

    properties(Constant)
        ConstantType="Property";
    end

    methods
        function obj=Property(propertyName,owningClass,metadata,domainType)
            obj.Type=classdiagram.app.core.domain.Property.ConstantType;
            obj.Name=propertyName;
            obj.OwningClass=owningClass;


            obj.DomainType=domainType;
            obj.Metadata=metadata;
            obj.GlobalSettingsFcn=owningClass.GlobalSettingsFcn;
        end

        function owningClass=getOwningClass(self)
            owningClass=self.OwningClass;
        end

        function setDomainType(self,domainType)
            self.DomainType=domainType;
        end

        function domainType=getDomainType(self)
            domainType=self.DomainType;
        end

        function setDefaultValue(self,defaultValue)
            self.DefaultValue=defaultValue;
        end

        function defaultValue=getDefaultValue(self)
            defaultValue=self.DefaultValue;
        end

        function state=getState(self)
            state=self.OwningClass.getState;
        end


        function setUnit(self,unit)
            self.Unit=unit;
        end

        function unit=getUnit(self)
            unit=self.Unit;
        end

        function accept(self,visitor)
            visitor.visitProperty(self);
        end
    end
end
