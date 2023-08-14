classdef(Abstract)ToolstripPanel<matlab.ui.internal.FigurePanel







    properties(Abstract,Constant)
        Name char;
        TagName char;
    end

    properties(SetAccess=immutable)
UIGrid
    end

    properties

        Visible(1,1)string{mustBeMember(Visible,["on","off"])}="off";
    end

    methods(Abstract,Access=protected)
        createComponents(this);
        layout(this);
    end

    methods
        function this=ToolstripPanel
            this@matlab.ui.internal.FigurePanel;


            this.Title=this.Name;
            this.Tag=this.TagName;
            this.UIGrid=uigridlayout(this.Figure,'RowHeight',this.GridRows,...
            'ColumnWidth',this.GridColumns,'Scrollable',true);


            createComponents(this);


            layout(this);
        end
    end

    methods(Access=protected)
        function configurePanel(this)
            this.Title=this.Name;
            this.Tag=this.TagName;
        end
    end
end


