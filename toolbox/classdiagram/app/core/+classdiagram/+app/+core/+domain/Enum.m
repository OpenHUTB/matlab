classdef Enum<classdiagram.app.core.domain.PackageElement

    properties(Constant)
        ConstantType="Enum";
    end

    properties(Access=?classdiagram.app.core.ClassDiagramFactory)
        Superclasses=-1;
        Literals=-1;
        Properties=-1;
        Methods=-1;
        Events=-1;
    end

    methods
        function obj=Enum(varargin)
            obj=obj@classdiagram.app.core.domain.PackageElement(varargin{:});
            obj.Type=classdiagram.app.core.domain.Enum.ConstantType;
        end

        function clearCaches(self)
            self.Superclasses=-1;
            self.Literals=-1;
            self.Properties=-1;
            self.Methods=-1;
            self.Events=-1;
            self.InheritsFromHandle=-1;
        end

        function loaded=superclassesLoaded(self)
            loaded=classdiagram.app.core.domain.BaseObject.isLoaded(self.Superclasses);
        end

        function loaded=propertiesLoaded(self)
            loaded=classdiagram.app.core.domain.BaseObject.isLoaded(self.Properties);
        end

        function loaded=methodsLoaded(self)
            loaded=classdiagram.app.core.domain.BaseObject.isLoaded(self.Methods);
        end

        function loaded=eventsLoaded(self)
            loaded=classdiagram.app.core.domain.BaseObject.isLoaded(self.Events);
        end

        function loaded=literalsLoaded(self)
            loaded=classdiagram.app.core.domain.BaseObject.isLoaded(self.Literals);
        end

        function accept(self,visitor)
            visitor.visitEnum(self);
        end
    end
end
