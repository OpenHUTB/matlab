classdef SmartPolygonSection<vision.internal.uitools.NewToolStripSection




    properties
SmartPolygonButton
GrabCutForegroundButton
GrabCutBackgroundButton
GrabCutEraseButton
    end

    properties(Constant)
        IconPath=fullfile(toolboxdir('images'),'icons');
    end

    methods
        function this=SmartPolygonSection()
            this.createSection();
            this.layoutSection();
        end
    end

    methods(Access=private)
        function createSection(this)

            GrabCutSectionTitle='Smart Polygon';
            GrabCutSectionTag='sectionGrabCut';

            this.Section=matlab.ui.internal.toolstrip.Section(GrabCutSectionTitle);
            this.Section.Tag=GrabCutSectionTag;

        end

        function layoutSection(this)

            this.addSmartPolygonButton();
            colSmartPolygon=this.addColumn();
            colSmartPolygon.add(this.SmartPolygonButton);

            this.addGrabCutDrawingButtons();
            colGrabCut=this.addColumn();
            colGrabCut.add(this.GrabCutForegroundButton);
            colGrabCut.add(this.GrabCutBackgroundButton);
            colGrabCut.add(this.GrabCutEraseButton);
        end

        function addSmartPolygonButton(this)
            import matlab.ui.internal.toolstrip.*;


            addSmartPolygonTitleId='vision:labeler:AddSmartPolygon';
            addSmartPolygonIcon=fullfile(toolboxdir('images'),'icons','GrabCut_24.png');
            addSmartPolygonTag='btnAddSmartPolygon';
            this.SmartPolygonButton=this.createToggleButton(addSmartPolygonIcon,...
            addSmartPolygonTitleId,addSmartPolygonTag);
            toolTipID='vision:labeler:AddSmartPolygonTooltip';
            this.setToolTipText(this.SmartPolygonButton,toolTipID);
        end

        function addGrabCutDrawingButtons(this)
            import matlab.ui.internal.toolstrip.*;


            addGrabCutForegroundTitleId=getString(message('vision:labeler:DrawGrabCutForeground'));
            addGrabCutForegroundTag='btnAddGrabCutForeground';
            addGrabCutForegroundIcon=fullfile(this.IconPath,'GrabCut_Foreground_16.png');
            this.GrabCutForegroundButton=ToggleButton();
            this.GrabCutForegroundButton.Text=addGrabCutForegroundTitleId;
            this.GrabCutForegroundButton.Tag=addGrabCutForegroundTag;
            toolTipID=getString(message('vision:labeler:DrawGrabCutForegroundTooltip'));
            this.GrabCutForegroundButton.Description=toolTipID;
            this.GrabCutForegroundButton.Icon=addGrabCutForegroundIcon;


            addGrabCutBackgroundTitleId=getString(message('vision:labeler:DrawGrabCutBackground'));
            addGrabCutBackgroundTag='btnAddGrabCutBackground';
            addGrabCutBackgroundIcon=fullfile(this.IconPath,'GrabCut_Background_16.png');
            this.GrabCutBackgroundButton=ToggleButton();
            this.GrabCutBackgroundButton.Text=addGrabCutBackgroundTitleId;
            this.GrabCutBackgroundButton.Tag=addGrabCutBackgroundTag;
            toolTipID=getString(message('vision:labeler:DrawGrabCutBackgroundTooltip'));
            this.GrabCutBackgroundButton.Description=toolTipID;
            this.GrabCutBackgroundButton.Icon=addGrabCutBackgroundIcon;


            addGrabCutEraseTitleId=getString(message('vision:labeler:EraseGrabCut'));
            addGrabCutEraseTag='btnAddGrabCutErase';
            addGrabCutEraseIcon=fullfile(this.IconPath,'GrabCut_Erase_16.png');
            this.GrabCutEraseButton=ToggleButton();
            this.GrabCutEraseButton.Text=addGrabCutEraseTitleId;
            this.GrabCutEraseButton.Tag=addGrabCutEraseTag;
            this.GrabCutEraseButton.Description=getString(message('vision:labeler:EraseGrabCutTooltip'));
            this.GrabCutEraseButton.Icon=addGrabCutEraseIcon;

        end
    end
end