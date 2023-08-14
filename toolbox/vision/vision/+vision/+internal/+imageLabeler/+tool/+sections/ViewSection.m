





classdef ViewSection<vision.internal.labeler.tool.sections.ViewSection

    methods
        function this=ViewSection()
            this=this@vision.internal.labeler.tool.sections.ViewSection();
        end
    end

    methods(Access=protected,Static)
        function toolTip=getToolTipMessageForShowLabels()
            toolTip='vision:imageLabeler:ShowROILabelsToolTip';
        end
    end
end

