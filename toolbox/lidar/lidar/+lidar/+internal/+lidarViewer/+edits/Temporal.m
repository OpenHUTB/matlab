








classdef Temporal<handle
    properties(Access=protected,Hidden)

SelectedFrameIndices
    end

    methods(Access={?lidar.internal.lidarViewer.edits.EditsManager})

        function setSelectedFrameIndices(this,selectedFrameIdx)



            this.SelectedFrameIndices=selectedFrameIdx;
        end
    end
end