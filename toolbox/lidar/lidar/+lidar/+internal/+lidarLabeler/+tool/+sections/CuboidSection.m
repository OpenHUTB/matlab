classdef CuboidSection<vision.internal.uitools.NewToolStripSection&...
    driving.internal.groundTruthLabeler.tool.sections.CuboidSection




    properties
UsePCFitCuboid
    end

    methods
        function enable(this)


            this.ClusterData.Enabled=true;
            this.ShrinkCuboid.Enabled=true;
            enableClusterSettings(this);
            this.UsePCFitCuboid.Enabled=true;
        end

        function disable(this)

            this.ClusterData.Enabled=false;
            this.ShrinkCuboid.Enabled=false;
            enableClusterSettings(this);
            this.UsePCFitCuboid.Enabled=false;
        end
    end
    methods(Access=protected)


        function layoutSection(this)

            this.addCuboidShrinkCheckbox();
            this.addClusterData();
            this.addClusterDataSetttings();
            this.addPCFitToggleButton();

            colAddSession=this.addColumn(...
            'HorizontalAlignment','left');
            colAddSession.add(this.ShrinkCuboid);
            colAddSession.add(this.UsePCFitCuboid);

            colAddSession=this.addColumn(...
            'HorizontalAlignment','left');
            colAddSession.add(this.ClusterData);
            colAddSession.add(this.ClusterSettings);

        end

        function addPCFitToggleButton(this)

            import matlab.ui.internal.toolstrip.*;
            titleID='lidar:labeler:pcFit';
            tag='btnAutoAlign';
            toolTipID='lidar:labeler:pcFitToolTip';
            this.UsePCFitCuboid=this.createCheckBox(titleID,tag,toolTipID);

        end

        function addCuboidShrinkCheckbox(this)
            import matlab.ui.internal.toolstrip.*;


            icon=fullfile(this.IconPath,'ShrinkToFit_24.png');
            titleID='lidar:labeler:LidarShrinkCuboid';
            tag='btnShrinkCuboid';
            this.ShrinkCuboid=this.createToggleButton(icon,titleID,tag);
            toolTipID='vision:labeler:LidarShrinkCuboidTooltip';
            this.setToolTipText(this.ShrinkCuboid,toolTipID);

            this.ShrinkCuboid.Value=true;

        end

        function addClusterData(this)

            icon=fullfile(this.IconPath,'SnapToCluster_24.png');
            titleID='lidar:labeler:LidarClusterData';
            tag='btnClusterData';
            this.ClusterData=this.createToggleButton(icon,titleID,tag);
            toolTipID='vision:labeler:LidarClusterDataTooltip';
            this.setToolTipText(this.ClusterData,toolTipID);

        end

        function addClusterDataSetttings(this)

            icon=matlab.ui.internal.toolstrip.Icon.SETTINGS_24;
            titleID='lidar:labeler:LidarClusterDataSettings';
            tag='btnClusteringSettings';
            this.ClusterSettings=this.createButton(icon,titleID,tag);
            toolTipID='vision:labeler:LidarClusterDataSettingsTooltip';
            this.setToolTipText(this.ClusterSettings,toolTipID);

        end
    end
end
