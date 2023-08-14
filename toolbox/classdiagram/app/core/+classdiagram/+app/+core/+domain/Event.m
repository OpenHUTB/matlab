classdef Event<classdiagram.app.core.domain.BaseObject
    properties(Access=private)
        OwningClass;
    end

    properties(Constant)
        ConstantType="Event";
    end

    methods
        function obj=Event(eventName,owningClass,metadata)
            obj.Type=classdiagram.app.core.domain.Event.ConstantType;
            obj.Name=eventName;
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
            visitor.visitEvent(self);
        end
    end
end
