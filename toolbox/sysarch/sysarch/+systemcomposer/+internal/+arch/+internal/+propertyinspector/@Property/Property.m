classdef Property<handle







    properties(SetAccess=immutable)
        id char;
        label char;
    end

    properties(SetAccess=private)
        isRoot logical;
    end

    properties
        value char;
        tooltip char;
        editable logical=true;
        enabled logical=true;
        comboEditable logical=true;
        rendermode char...
        {mustBeMember(rendermode,...
        {'combobox','editbox','checkbox','dualedit','dualeditcombo','none','actioncallback'})}='editbox';
        options cell={};
        children cell={};
        parentId char;

    end

    methods(Static)
        function prop=makeRootNode(tag,label)
            prop=systemcomposer.internal.arch.internal.propertyinspector.Property(tag,label);
            prop.isRoot=true;
        end

        function prop=makePropNode(tag,label)
            prop=systemcomposer.internal.arch.internal.propertyinspector.Property(tag,label);
            prop.isRoot=false;
            prop.children={};
        end

    end

    methods(Access=private)


        function this=Property(tag,label)
            this.id=tag;
            this.label=label;
        end

    end

    methods(Access=public)

        function childProp=addChildPropNode(this,tag,label)



            if this.isRoot
                childID=[this.id,':',tag];
                allChildIDs=cellfun(@(x)x.id,this.children,'UniformOutput',false);
                if~any(strcmp(allChildIDs,childID))
                    childProp=systemcomposer.internal.arch.internal.propertyinspector.Property.makePropNode(childID,label);
                    childProp.parentId=this.id;
                    this.children{end+1}=childProp;
                else
                    error(['Property with ID ''',childID,''' already exists as a child of this property. Use a different ID.'])
                end
            else

                error('Property must be a root node to add child properties');
            end
        end

        function addOptions(this,entries)

            switch this.rendermode
            case{'combobox','dualeditcombo','actioncallback'}
                this.options=entries;
            otherwise
                error(['Options not allowed for properties rendered as ',this.rendermode]);
            end
        end

    end
end