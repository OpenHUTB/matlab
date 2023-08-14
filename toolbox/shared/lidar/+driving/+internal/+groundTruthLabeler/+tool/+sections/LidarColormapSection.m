classdef LidarColormapSection<vision.internal.uitools.NewToolStripSection




    properties
Colormap
ColormapValue

ColormapLabel
ColormapValueLabel

BackgroundColor
    end

    properties(Constant)
        IconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons');
    end

    methods
        function this=LidarColormapSection()
            this.createSection();
            this.layoutSection();
        end
        function enable(this)
            this.Colormap.Enabled=true;
            this.ColormapValue.Enabled=true;
        end

        function disable(this)


            this.Colormap.Enabled=false;
            this.ColormapValue.Enabled=false;
        end
    end

    methods(Access=protected)
        function createSection(this)
            lidarColormapSectionTitle=getString(message('vision:labeler:LidarColormap'));
            lidarColormapSectionTag='sectionLidarColormap';

            this.Section=matlab.ui.internal.toolstrip.Section(lidarColormapSectionTitle);
            this.Section.Tag=lidarColormapSectionTag;
        end

        function layoutSection(this)
            this.addColormapDropdown();
            this.addColormapValueDropdown();
            this.addBackgroundColorButton();

            colAddSession=this.addColumn(...
            'HorizontalAlignment','right');
            colAddSession.add(this.ColormapLabel);
            colAddSession.add(this.ColormapValueLabel);

            colAddSession=this.addColumn('width',100,...
            'HorizontalAlignment','center');
            colAddSession.add(this.Colormap);
            colAddSession.add(this.ColormapValue);

            colAddSession=this.addColumn();
            colAddSession.add(this.BackgroundColor);
        end

        function addColormapDropdown(this)
            import matlab.ui.internal.toolstrip.*;


            labelId='vision:labeler:LidarColormap';
            this.ColormapLabel=this.createLabel(labelId);
            toolTipID='vision:labeler:LidarColormapTooltip';
            this.setToolTipText(this.ColormapLabel,toolTipID);


            tag='btnColormap';
            list={getString(message('vision:labeler:ColormapRedWhiteBlue'));...
            getString(message('vision:labeler:ColormapParula'));...
            getString(message('vision:labeler:ColormapJet'));...
            getString(message('vision:labeler:ColormapHot'));...
            getString(message('vision:labeler:ColormapSpring'))};
            this.Colormap=this.createDropDown(list,tag,toolTipID);
            this.Colormap.SelectedIndex=1;

        end

        function addColormapValueDropdown(this)
            import matlab.ui.internal.toolstrip.*;


            labelId='vision:labeler:LidarColormapValue';
            this.ColormapValueLabel=this.createLabel(labelId);
            toolTipID='vision:labeler:LidarColormapValueTooltip';
            this.setToolTipText(this.ColormapValueLabel,toolTipID);


            tag='btnColormapValue';
            list={getString(message('vision:labeler:ColormapValueZ'));...
            getString(message('vision:labeler:ColormapValueRadial'))};
            this.ColormapValue=this.createDropDown(list,tag,toolTipID);
            this.ColormapValue.SelectedIndex=1;

        end

        function addBackgroundColorButton(this)
            import matlab.ui.internal.toolstrip.Icon.*;


            labelId=getString(message('vision:labeler:LidarBackgroundColor'));
            this.BackgroundColor=matlab.ui.internal.toolstrip.Button(labelId);
            this.BackgroundColor.Tag='btnBackgroundColor';
            toolTipID='vision:labeler:LidarBackgroundColorTooltip';
            this.setToolTipText(this.BackgroundColor,toolTipID);
        end
    end
end
