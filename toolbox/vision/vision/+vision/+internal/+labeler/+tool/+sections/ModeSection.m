






classdef ModeSection<vision.internal.uitools.NewToolStripSection

    properties
ROIButton
ZoomInButton
ZoomOutButton
PanButton
    end

    methods
        function this=ModeSection()
            this.createSection();
            this.layoutSection();
        end

        function setROIIcon(this,mode)



            if strcmp(mode,'pixel')
                iconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons','pixel_label_24.png');
            else
                iconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons','ROI_Rectangle_sm_24px.png');
            end

            this.ROIButton.Icon=iconPath;
        end
    end

    methods(Access=protected)
        function tip=getROIButtonToolTip(~)


            tip='vision:labeler:ROIButtonTooltip';
        end
    end

    methods(Access=private)
        function createSection(this)

            modeSectionTitle=getString(message('vision:labeler:ModeSectionTitle'));
            modeSectionTag='sectionMode';

            this.Section=matlab.ui.internal.toolstrip.Section(modeSectionTitle);
            this.Section.Tag=modeSectionTag;
        end

        function layoutSection(this)

            modeButtonGroup=matlab.ui.internal.toolstrip.ButtonGroup;

            this.addROIButton(modeButtonGroup);
            this.addZoomButtons(modeButtonGroup);
            this.addPanButton(modeButtonGroup);

            roiCol=this.addColumn();
            roiCol.add(this.ROIButton);

            zoompanCol=this.addColumn();
            zoompanCol.add(this.ZoomInButton);
            zoompanCol.add(this.ZoomOutButton);
            zoompanCol.add(this.PanButton);
        end

        function addROIButton(this,group)

            iconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons','ROI_Rectangle_sm_24px.png');
            roiIcon=matlab.ui.internal.toolstrip.Icon(iconPath);
            roiID='vision:labeler:ROIButtonTitle';
            roiTag='btnROI';
            this.ROIButton=this.createToggleButton(roiIcon,roiID,roiTag,group);
            this.ROIButton.Value=true;
            toolTipID=this.getROIButtonToolTip();
            this.setToolTipText(this.ROIButton,toolTipID);
        end

        function addZoomButtons(this,group)

            zoomInIcon=matlab.ui.internal.toolstrip.Icon.ZOOM_IN_16;
            zoomInID='vision:uitools:ZoomInButton';
            zoomInTag='btnZoomIn';

            this.ZoomInButton=this.createToggleButton(zoomInIcon,zoomInID,zoomInTag,group);
            this.setToolTipText(this.ZoomInButton,zoomInID);

            zoomOutIcon=matlab.ui.internal.toolstrip.Icon.ZOOM_OUT_16;
            zoomOutID='vision:uitools:ZoomOutButton';
            zoomOutTag='btnZoomOut';

            this.ZoomOutButton=this.createToggleButton(zoomOutIcon,zoomOutID,zoomOutTag,group);
            this.setToolTipText(this.ZoomOutButton,zoomOutID);
        end

        function addPanButton(this,group)

            panIcon=matlab.ui.internal.toolstrip.Icon.PAN_16;
            panID='vision:uitools:PanButton';
            panTag='btnPan';

            this.PanButton=this.createToggleButton(panIcon,panID,panTag,group);
            this.setToolTipText(this.PanButton,panID);
        end
    end
end