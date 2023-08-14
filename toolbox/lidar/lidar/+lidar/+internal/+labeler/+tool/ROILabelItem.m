classdef ROILabelItem<vision.internal.labeler.tool.ROILabelItem




    properties
        VoxelLabelSelectCData;
        VoxelLabelUnselectCData;
    end
    methods


        function this=ROILabelItem(parent,idx,data)
            this=this@vision.internal.labeler.tool.ROILabelItem(parent,idx,data);
        end

        function computeROITypeIconsCData(this,isALabel,isCuboidSupported)

            if isALabel
                rectROIIconFile=getrectROIIconFile(this,isCuboidSupported);
                lineROIIconPath='ROI_lineBW_Label.png';
                voxelLabelROIIconFile='RGB_voxelBW_Label.png';
            else
                rectROIIconFile='ROI_rectBW_Sublabel.png';
                lineROIIconPath='ROI_lineBW_Sublabel.png';
                voxelLabelROIIconFile='RGB_voxelBW_Label.png';
            end

            rectROIIconPath=getrectROIIconPath(this,rectROIIconFile);
            [rectROIIconData,~,alpha]=imread(rectROIIconPath);
            rectROIIconData=rectROIIconData(:,:,1);
            this.RectSelectCData=blendAlphaImageWithBG(this,rectROIIconData,this.SelectedBGColor,alpha);
            this.RectUnselectCData=blendAlphaImageWithBG(this,rectROIIconData,this.UnselectedBGColor,alpha);

            lineROIIconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons',lineROIIconPath);
            lineROIIconData=imread(lineROIIconPath);
            this.LineSelectCData=blendImageWithBG(this,lineROIIconData,this.SelectedBGColor);
            this.LineUnselectCData=blendImageWithBG(this,lineROIIconData,this.UnselectedBGColor);

            voxelLabelROIIconPath=fullfile(toolboxdir('lidar'),'lidar','+lidar','+internal','+labeler','+tool','+icons',voxelLabelROIIconFile);
            [voxelLabelROIIconData,~,alpha]=imread(voxelLabelROIIconPath);
            voxelLabelROIIconData=voxelLabelROIIconData(:,:,1);
            this.VoxelLabelSelectCData=blendAlphaImageWithBG(this,voxelLabelROIIconData,this.SelectedBGColor,alpha);
            this.VoxelLabelUnselectCData=blendAlphaImageWithBG(this,voxelLabelROIIconData,this.UnselectedBGColor,alpha);
        end

        function rectROIIconFile=getrectROIIconFile(~,~)
            rectROIIconFile='RGB_cubeBW_Label.png';
        end

        function rectROIIconPath=getrectROIIconPath(~,rectROIIconFile)
            rectROIIconPath=fullfile(toolboxdir('lidar'),'lidar','+lidar','+internal','+labeler','+tool','+icons',rectROIIconFile);
        end


        function roiTypeCdata=getROITypeSelectedCData(this)

            switch this.Data.ROI
            case labelType.Rectangle
                roiTypeCdata=this.RectSelectCData;
            case labelType.Line
                roiTypeCdata=this.LineSelectCData;
            case lidarLabelType.Voxel
                roiTypeCdata=this.VoxelLabelSelectCData;
            otherwise
                error('unsupported label type');
            end

        end

        function roiTypeCdata=getROITypeUnselectedCData(this)

            switch this.Data.ROI
            case labelType.Rectangle
                roiTypeCdata=this.RectUnselectCData;
            case labelType.Line
                roiTypeCdata=this.LineUnselectCData;
            case lidarLabelType.Voxel
                roiTypeCdata=this.VoxelLabelUnselectCData;
            otherwise
                error('unsupported label type');
            end

        end

    end
end
