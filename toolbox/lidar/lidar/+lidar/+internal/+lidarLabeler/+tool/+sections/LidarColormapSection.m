classdef LidarColormapSection<vision.internal.uitools.NewToolStripSection&...
    driving.internal.groundTruthLabeler.tool.sections.LidarColormapSection




    methods
        function this=LidarColormapSection()
            this@driving.internal.groundTruthLabeler.tool.sections.LidarColormapSection;
        end
    end

    methods(Access=protected)
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
            getString(message('vision:labeler:ColormapSpring'));...
            getString(message('lidar:labeler:ColormapColor'))};
            this.Colormap=this.createDropDown(list,tag,toolTipID);
            this.Colormap.SelectedIndex=1;

        end
    end

    methods

        function enable(this)
            this.Colormap.Enabled=true;
            this.ColormapValue.Enabled=true;
            if strcmp(this.Colormap.Value,getString(message('lidar:labeler:ColormapColor')))
                this.ColormapValue.Enabled=false;
            end
        end
    end
end
