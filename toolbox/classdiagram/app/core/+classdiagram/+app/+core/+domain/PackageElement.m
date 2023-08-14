classdef PackageElement<classdiagram.app.core.domain.BaseObject&matlab.mixin.Heterogeneous


    properties(Access=private)
        OwningPackage;
        SuperclassNames;

        InheritanceHierarchy;
        InheritanceFlags=classdiagram.app.core.InheritanceFlags.NONE;
    end

    properties(Access=protected)
        InheritsFromHandle=-1;
    end

    methods
        function set.SuperclassNames(self,superclassNames)
            if isempty(superclassNames)
                self.SuperclassNames={};
            else
                self.SuperclassNames=superclassNames;
            end
        end

    end

    methods(Sealed)
        function obj=PackageElement(className,owningPackage,metadata,...
            superclassNames,globalSettingsFcn,state)
            obj.Name=className;
            obj.OwningPackage=owningPackage;
            obj.Metadata=metadata;
            obj.SuperclassNames=superclassNames;
            obj.GlobalSettingsFcn=globalSettingsFcn;
            if nargin==6
                obj.State=state;
            end
            classdiagram.app.core.InheritanceFlags.initializeInheritanceFlags(obj);
        end

        function owningPackage=getOwningPackage(self)
            owningPackage=self.OwningPackage;
        end

        function superclassNames=getSuperclassNames(self)
            if isempty(self.SuperclassNames)
                superclassNames='';
                return;
            end
            superclassNames=join(self.SuperclassNames,',');
            superclassNames=superclassNames{1};
        end

        function bool=inheritsFromHandle(self)
            if self.InheritsFromHandle~=-1
                bool=self.InheritsFromHandle;
                return;
            end



            try
                selfMeta=meta.class.fromName(self.Name);
                handleMeta=?handle;
                bool=selfMeta<handleMeta;
                self.InheritsFromHandle=bool;
            catch e
                bool=false;
            end
        end

        function[inheritanceFlags,fromHandle,fromMixins]=getInheritanceFlags(self)
            inheritanceFlags=self.InheritanceFlags;
            fromHandle=classdiagram.app.core.InheritanceFlags.fromHandle(...
            inheritanceFlags);
            fromMixins=classdiagram.app.core.InheritanceFlags.fromMixins(...
            inheritanceFlags);
        end

        function setInheritanceFlags(self,val)
            self.InheritanceFlags=bitor(self.InheritanceFlags,val);
        end

        function resetInheritanceFlags(self,val)
            self.InheritanceFlags=bitand(self.InheritanceFlags,bitcmp(val,'uint8'));
        end

        function bool=eq(varargin)
            bool=eq@handle(varargin{:});
        end

        function bool=ne(varargin)
            bool=ne@handle(varargin{:});
        end
    end

    methods(Abstract)
        accept(self,visitor);
    end
end
