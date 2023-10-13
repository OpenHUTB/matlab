classdef Package<classdiagram.app.core.domain.BaseObject

    properties(Constant)
        ConstantType="Package";
    end

    properties(Access=?classdiagram.app.core.ClassDiagramFactory)
        Classes=-1;
        Enums=-1;
        Subpackages=-1;
        ParentPackage=-1;
    end

    methods(Static)
        function bool=hasPackageElements(packageOrName)
            bool=false;
            if isa(packageOrName,'classdiagram.app.core.domain.Package')
                metadata=meta.package.fromName(packageOrName.getName);
            else
                metadata=meta.package.fromName(packageOrName);
            end
            if isempty(metadata)
                return;
            end
            if~isempty(metadata.ClassList)
                bool=true;
                return;
            end
            subpackages=metadata.PackageList;
            for ipkg=1:numel(subpackages)
                pkg=subpackages(ipkg);
                bool=classdiagram.app.core.domain.Package.hasPackageElements(pkg.Name);
                if bool
                    return;
                end
            end
        end
    end

    methods
        function obj=Package(packageName,globalSettingsFcn)
            obj.Type=classdiagram.app.core.domain.Package.ConstantType;
            obj.Name=packageName;
            obj.Metadata=containers.Map;
            obj.GlobalSettingsFcn=globalSettingsFcn;
        end

        function clearCaches(self)
            self.Classes=-1;
            self.Enums=-1;
            self.Subpackages=-1;
            self.ParentPackage=-1;
        end

        function loaded=enumsLoaded(self)
            loaded=classdiagram.app.core.domain.BaseObject.isLoaded(self.Enums);
        end

        function loaded=subpackagesLoaded(self)
            loaded=classdiagram.app.core.domain.BaseObject.isLoaded(self.Subpackages);
        end

        function loaded=classesLoaded(self)
            loaded=classdiagram.app.core.domain.BaseObject.isLoaded(self.Classes);
        end

        function loaded=parentLoaded(self)
            loaded=classdiagram.app.core.domain.BaseObject.isLoaded(self.ParentPackage);
        end

        function accept(self,visitor)
            visitor.visitPackage(self);
        end
    end
end
