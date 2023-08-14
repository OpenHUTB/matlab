classdef PropertySetTreeNode<handle




    properties
Profile
Factory
    end

    properties(Constant)
        ID=300;
    end

    methods

        function this=PropertySetTreeNode(profile,factory)
            this.Profile=profile;
            this.Factory=factory;
        end

        function id=getID(this)
            id=this.ID+this.Factory.getID(this.Profile.getName);
        end

        function label=getDisplayLabel(~)
            label=DAStudio.message('SystemArchitecture:ProfileDesigner:PropertySetNodeName');
        end

        function has=hasChildren(this)


            has=~isempty(this.Profile.propertySets.toArray);
        end

        function children=getHierarchicalChildren(this)
            propSets=this.Profile.propertySets.toArray;
            children=cell(1,length(propSets));
            for idx=1:length(propSets)
                source.obj=propSets(idx);
                source.fqn=source.obj.fullyQualifiedName;
                children{idx}=this.Factory.createTreeNode(source,this);
            end
        end

    end
end
