classdef(Sealed=true)Class<classdiagram.app.core.domain.PackageElement

    properties(Constant)
        ConstantType="Class";
    end

    properties(Access=private)
        OwningPackage;
        SuperclassNames;
    end

    properties(Access=?classdiagram.app.core.ClassDiagramFactory)
        Superclasses=-1;
        Properties=-1;
        Methods=-1;
        Events=-1;
    end

    methods
        function obj=Class(varargin)
            obj=obj@classdiagram.app.core.domain.PackageElement(varargin{:});
            obj.Type=classdiagram.app.core.domain.Class.ConstantType;
        end

        function clearCaches(self)
            self.Superclasses=-1;
            self.Properties=-1;
            self.Methods=-1;
            self.Events=-1;
            self.InheritsFromHandle=-1;
        end

        function nonQualifiedName=getNonQualifiedName(self)
            nonQualifiedName=self.Name;
            if~isempty(self.OwningPackage)
                nonQualifiedName=regexprep(self.Name,self.OwningPackage.getName+"\.",'');
            end
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

        function accept(self,visitor)
            visitor.visitClass(self);
        end
    end
end
