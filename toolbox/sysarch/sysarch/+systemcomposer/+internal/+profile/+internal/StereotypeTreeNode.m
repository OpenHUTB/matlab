classdef StereotypeTreeNode<handle




    properties
Profile
Factory
    end

    properties(Constant)
        ID=200;
    end

    methods

        function this=StereotypeTreeNode(profile,factory)
            this.Profile=profile;
            this.Factory=factory;
        end

        function id=getID(this)
            id=this.ID+this.Factory.getID(this.Profile.getName);
        end

        function label=getDisplayLabel(~)
            label=DAStudio.message('SystemArchitecture:ProfileDesigner:StereotypeNodeName');
        end

        function has=hasChildren(this)


            has=~isempty(this.Profile.prototypes.toArray);
        end

        function children=getHierarchicalChildren(this)
            prototypes=this.Profile.prototypes.toArray;
            children=cell(1,length(prototypes));
            for idx=1:length(prototypes)
                source.obj=prototypes(idx);
                source.fqn=source.obj.fullyQualifiedName;
                children{idx}=this.Factory.createTreeNode(source,this);
            end
        end

    end
end
