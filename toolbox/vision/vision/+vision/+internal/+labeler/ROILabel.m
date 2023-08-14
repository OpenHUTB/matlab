

classdef ROILabel
    properties

        ROI labelType


Label


Description


        AttributeNames={};


Attributes


Color


PixelLabelID


Group


ROIVisibility
    end

    properties(Hidden)
        IsRectCuboid=false;
    end

    methods

        function this=ROILabel(roi,label,description,group,pixelLabelID)
            this.ROI=roi;
            this.Label=label;
            this.Description=description;
            this.Group=group;
            this.ROIVisibility=true;

            if nargin>4
                this.PixelLabelID=pixelLabelID;
            end
        end
    end
end