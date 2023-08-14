



classdef ROILabel
    properties

ROI


Label


Description


        AttributeNames={};


Attributes


Color


VoxelLabelID


Group


ROIVisibility
    end

    properties(Hidden)
        IsRectCuboid=false;
    end

    methods

        function this=ROILabel(roi,label,description,group,voxelLabelID)
            this.ROI=roi;
            this.Label=label;
            this.Description=description;
            this.Group=group;
            this.ROIVisibility=true;

            if nargin>4
                this.VoxelLabelID=voxelLabelID;
            end
        end
    end
end
