

classdef ROISublabel
    properties
LabelName


        ROI labelType


Sublabel


Description


        AttributeNames={};


Color


PixelSublabelID


ROIVisibility

    end

    methods

        function this=ROISublabel(labelName,roi,sublabelName,description,pixelSublabelID)
            this.LabelName=labelName;
            this.ROI=roi;
            this.Sublabel=sublabelName;
            this.Description=description;
            this.ROIVisibility=true;

            if nargin>4
                this.PixelSublabelID=pixelSublabelID;
            end
        end
    end
end