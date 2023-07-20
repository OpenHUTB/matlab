classdef(Abstract)AppToolstripTabGroup<handle









    properties(Abstract,Constant)

Name
        Contextual logical
    end

    properties(SetAccess=immutable)
TabGroup
    end

    properties(SetAccess=immutable,GetAccess=protected)
Parent
    end

    methods(Abstract,Access=protected)
        createComponents(this);
        layout(this);
    end

    methods
        function this=AppToolstripTabGroup(parentApp)


            this.Parent=parentApp;

            this.TabGroup=matlab.ui.internal.toolstrip.TabGroup();
            tag=strcat(getTagPrefix(parentApp),'tabgroup_',lower(this.Name));
            this.TabGroup.Tag=tag;
            this.TabGroup.Contextual=this.Contextual;

            createComponents(this);
            layout(this);
        end

        function tooltab=getTabGroup(this)
            tooltab=this.TabGroup;
        end

        function title=getAppTitle(this)
            title=getAppTitle(this.Parent);
        end

        function tagPrefix=getTagPrefix(this)
            tagPrefix=getTagPrefix(this.Parent);
        end

        function tag=getTag(this)
            tag=this.TabGroup.Tag;
        end

        function show(this)
            this.Parent.showTab(this);
        end

        function hide(this)
            this.Parent.hideTab(this);
        end

        function addTab(this,tab)
            this.TabGroup.add(getTab(tab));
        end

        function hideTab(this,tab)

            this.TabGroup.remove(getTab(tab));
        end

        function showTab(this,tab)

            this.TabGroup.add(getTab(tab));
        end
    end

    methods(Access=protected)
        function parent=getParent(this)
            parent=this.Parent;
        end

        function createModalContext(this)
            modalContext=matlab.ui.container.internal.appcontainer.ContextDefinition();
            modalContext.Tag=getTag(this);
            modalContext.ToolstripTabGroupTags=getTag(this);


            addContext(this.Parent,modalContext);
        end
    end
end


