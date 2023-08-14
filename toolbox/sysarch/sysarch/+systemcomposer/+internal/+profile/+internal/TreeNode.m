classdef TreeNode<handle




    properties
        ID;
        Source;
        Parent;
        Factory;
    end

    methods
        function this=TreeNode(source,parent,factory)




            if~isa(source.obj,'systemcomposer.internal.profile.Profile')&&...
                ~isa(source.obj,'systemcomposer.internal.profile.Prototype')&&...
                ~isa(source.obj,'systemcomposer.property.PropertySet')
                error('Invalid argument to TreeNode.create');
            end

            this.Source=source.obj;
            this.ID=source.id;
            if nargin>1
                this.Parent=parent;
            end
            if nargin>2
                this.Factory=factory;
            end
        end

        function id=getID(this)
            id=this.ID;
        end

        function label=getDisplayLabel(this)
            label=this.Source.p_Name;
            if this.isProfile()
                if this.Source.dirty
                    label=[label,'*'];
                end
            end
        end

        function icon=getDisplayIcon(this)
            icon='';
            if this.isProfile()
                if this.Source.isUnhealthyOnLoad
                    icon=this.resource('profileNodeError');
                else
                    icon=this.resource('profileNode');
                end
            elseif this.isPrototype()&&~isempty(this.Source.icon)
                if systemcomposer.internal.profile.PrototypeIcon.CUSTOM~=this.Source.icon
                    iconName=systemcomposer.internal.profile.internal.PrototypeIconPicker.iconEnum2Name(this.Source.icon);
                    icon=systemcomposer.internal.profile.internal.PrototypeIconPicker.iconName2FilePath(iconName,this.Source.getExtendedElement);
                else
                    try
                        icon=this.Source.getCustomIconPath;
                    catch ex
                        MSLDiagnostic('SystemArchitecture:ProfileDesigner:CustomIconError',ex.message).reportAsWarning;
                        icon=this.Source.getInvalidIconPath;
                    end
                end
            end
        end

        function has=hasChildren(this)



            has=false;
            if this.isProfile()
                has=(this.Source.prototypes.Size>0)||(this.Source.propertySets.Size>0);
            end
        end

        function children=getHierarchicalChildren(this)


            assert(this.isProfile());
            children={};
            prototypes=this.Source.prototypes.toArray;
            propertySets=this.Source.propertySets.toArray;
            if slfeature('ZCPropertySets')
                if~isempty(prototypes)
                    children{1}=this.Factory.createStereotypeNode(this.Source);
                end
                if~isempty(propertySets)
                    children{end+1}=this.Factory.createPropertySetNode(this.Source);

                end
            else
                children=(cell(1,length(prototypes)));

                for idx=1:length(prototypes)
                    source.obj=prototypes(idx);
                    source.fqn=source.obj.fullyQualifiedName;
                    children{idx}=this.Factory.createTreeNode(source,this);
                end
            end
        end
    end

    methods(Access=private)
        function is=isProfile(this)
            is=isa(this.Source,'systemcomposer.internal.profile.Profile');
        end

        function is=isPrototype(this)
            is=isa(this.Source,'systemcomposer.internal.profile.Prototype');
        end

        function is=isPropertySet(this)
            is=isa(this.Source,'systemcomposer.property.PropertySet');
        end

        function filepath=resource(~,filename)
            filepath=fullfile(matlabroot,'toolbox','sysarch','sysarch','+systemcomposer','+internal','+profile','resources',[filename,'.png']);
        end
    end

end
