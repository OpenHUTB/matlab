classdef LayoutSection<vision.internal.uitools.NewToolStripSection&...
    vision.internal.videoLabeler.tool.sections.LayoutSection




    methods
        function this=LayoutSection(tool)
            this=this@vision.internal.videoLabeler.tool.sections.LayoutSection(tool);
        end
    end
    methods(Access=protected)
        function createMultisignalLayout(this)
            layoutCol=this.addColumn();
            addLayoutButton(this);
            layoutCol.add(this.LayoutButton);
            refreshLayoutPopup(this);
        end
    end
end