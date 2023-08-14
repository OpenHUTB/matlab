classdef GrabCutSection<handle




    properties
GrabCutForegroundButton
GrabCutBackgroundButton
GrabCutEraseButton

Panel
Popup
    end

    properties(Constant)
        IconPath=fullfile(toolboxdir('images'),'icons');
    end

    methods
        function this=GrabCutSection()
            this.createSection();
            this.layoutSection();
        end
    end

    methods(Access=private)
        function createSection(this)

            this.Panel=toolpack.component.TSPanel('f:p','f:p:g,f:p:g,f:p:g');

        end

        function layoutSection(this)
            this.addGrabCutDrawingButtons();

            this.Panel.add(this.GrabCutForegroundButton,'xy(1,1)');
            this.Panel.add(this.GrabCutBackgroundButton,'xy(1,2)');
            this.Panel.add(this.GrabCutEraseButton,'xy(1,3)');

            this.Popup=toolpack.component.TSTearOffPopup(this.Panel);
            this.Popup.Title=getString(message('vision:labeler:GrabCutEditor'));
        end

        function addGrabCutDrawingButtons(this)
            import matlab.ui.internal.toolstrip.*;


            addGrabCutForegroundTitleId=getString(message('vision:labeler:DrawGrabCutForeground'));
            addGrabCutForegroundIcon=fullfile(this.IconPath,'GrabCut_Foreground_16.png');
            addGrabCutForegroundTag='btnAddGrabCutForeground';
            this.GrabCutForegroundButton=toolpack.component.TSToggleButton(addGrabCutForegroundTitleId,...
            toolpack.component.Icon(addGrabCutForegroundIcon));
            this.GrabCutForegroundButton.Name=addGrabCutForegroundTag;
            toolTipID=getString(message('vision:labeler:DrawGrabCutForegroundTooltip'));
            setToolTipText(this.GrabCutForegroundButton.Peer,toolTipID);


            addGrabCutBackgroundTitleId=getString(message('vision:labeler:DrawGrabCutBackground'));
            addGrabCutBackgroundIcon=fullfile(this.IconPath,'GrabCut_Background_16.png');
            addGrabCutBackgroundTag='btnAddGrabCutBackground';
            this.GrabCutBackgroundButton=toolpack.component.TSToggleButton(addGrabCutBackgroundTitleId,...
            toolpack.component.Icon(addGrabCutBackgroundIcon));
            this.GrabCutBackgroundButton.Name=addGrabCutBackgroundTag;
            toolTipID=getString(message('vision:labeler:DrawGrabCutBackgroundTooltip'));
            setToolTipText(this.GrabCutBackgroundButton.Peer,toolTipID);


            addGrabCutEraseTitleId=getString(message('vision:labeler:EraseGrabCut'));
            addGrabCutEraseIcon=fullfile(this.IconPath,'GrabCut_Erase_16.png');
            addGrabCutEraseTag='btnAddGrabCutErase';
            this.GrabCutEraseButton=toolpack.component.TSToggleButton(addGrabCutEraseTitleId,...
            toolpack.component.Icon(addGrabCutEraseIcon));
            this.GrabCutEraseButton.Name=addGrabCutEraseTag;
            toolTipID=getString(message('vision:labeler:EraseGrabCutTooltip'));
            setToolTipText(this.GrabCutEraseButton.Peer,toolTipID);
        end
    end
end