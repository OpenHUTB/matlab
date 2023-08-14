classdef ROILabelerClipBoard<vision.internal.labeler.tool.ROILabelerClipBoard




    methods

        function roiVisibilityChange(this,newItemInfo)
            for i=1:length(this.CopiedROIs)
                if~isempty(this.CopiedROIs{i})
                    obj=this.CopiedROIs{i};
                    if isa(newItemInfo,'lidar.internal.labeler.ROILabel')
                        labelName=newItemInfo.Label;
                    else
                        labelName=newItemInfo.Sublabel;
                    end
                    if isequal(obj.Label,labelName)
                        obj.Visible=newItemInfo.ROIVisibility;
                    end
                    this.CopiedROIs{i}=obj;
                end
            end
        end
    end
end
