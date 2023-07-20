classdef ViewSection<vision.internal.uitools.NewToolStripSection&...
    vision.internal.labeler.tool.sections.ViewSection




    methods
        function this=ViewSection(tool)
            this=this@vision.internal.labeler.tool.sections.ViewSection();
        end
    end
    methods(Access=protected)
        function createLayout(this)
            layoutCol=this.addColumn();
            layoutCol.add(this.ShowLabelsText);
            layoutCol.add(this.ShowLabelsDropDown);
        end
    end
end
