classdef FileSection<vision.internal.labeler.tool.sections.FileSection

    methods
        function this=FileSection()
            this@vision.internal.labeler.tool.sections.FileSection();
        end
    end

    methods(Access=protected)
        function addSignalsTitleID=getSignalItem(~)
            addSignalsTitleID=vision.getMessage('lidar:labeler:AddRemoveSignals');
        end
    end
end