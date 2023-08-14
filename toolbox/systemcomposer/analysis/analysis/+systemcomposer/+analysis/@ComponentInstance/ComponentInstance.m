classdef ComponentInstance<systemcomposer.analysis.NodeInstance


    properties(SetAccess=private,Dependent)
Parent
Specification
    end

    methods(Access='protected')
        function qualifiedName=getQualifiedName(this)
            escapedName=strrep(this.Name,'/','//');
            qualifiedName=[this.Parent.getQualifiedName(),'/',escapedName];
        end
    end

    methods
        function specification=get.Specification(this)
            specification=systemcomposer.arch.BaseComponent.empty;
            try
                if~isempty(this.InstElementImpl.specification)
                    specification=systemcomposer.internal.getWrapperForImpl(this.InstElementImpl.specification);
                end
            catch
            end
        end

        function parent=get.Parent(this)
            parentImpl=this.InstElementImpl.parent;
            if isempty(parentImpl.parent)

                parent=this.getWrapperForImpl(parentImpl.instanceModel,'systemcomposer.analysis.ArchitectureInstance');
            else
                parent=this.getWrapperForImpl(parentImpl,'systemcomposer.analysis.ComponentInstance');
            end
        end

    end


end

