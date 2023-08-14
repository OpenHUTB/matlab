classdef(Abstract)ToolstripTab<handle








    properties(Abstract,Constant)

Title

Name
    end

    properties(SetAccess=immutable)
Tab
    end

    properties(SetAccess=immutable,GetAccess=protected)
Parent
    end

    methods(Abstract,Access=protected)
        createTabComponents(this);
        layoutTab(this);
    end

    methods
        function this=ToolstripTab(parentApp)


            this.Parent=parentApp;

            this.Tab=matlab.ui.internal.toolstrip.Tab(this.Title);
            tag=strcat(getTagPrefix(parentApp),'tab_',lower(this.Name));
            this.Tab.Tag=tag;


            createTabComponents(this);
            layoutTab(this);
        end

        function tooltab=getTab(this)
            tooltab=this.Tab;
        end

        function title=getAppTitle(this)
            title=getAppTitle(this.Parent);
        end

        function tagPrefix=getTagPrefix(this)
            tagPrefix=getTagPrefix(this.Parent);
        end

        function show(this)
            this.Parent.showTab(this);
        end

        function hide(this)
            this.Parent.hideTab(this);
        end
    end

    methods(Access=protected)
        function addSection(this,section)
            this.Tab.add(getSection(section));
        end

        function parent=getParent(this)
            parent=this.Parent;
        end
    end
end
