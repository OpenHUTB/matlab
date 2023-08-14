classdef CuboidSection<vision.internal.uitools.NewToolStripSection



    properties
ClusterData
ClusterSettings
ShrinkCuboid
    end

    properties(Constant)
        IconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons');
    end

    methods
        function this=CuboidSection()
            this.createSection();
            this.layoutSection();
        end

        function enable(this)


            this.ClusterData.Enabled=true;
            this.ShrinkCuboid.Enabled=true;
            enableClusterSettings(this);
        end

        function disable(this)

            this.ClusterData.Enabled=false;
            this.ShrinkCuboid.Enabled=false;
            enableClusterSettings(this);
        end

        function enableClusterSettings(this)
            this.ClusterSettings.Enabled=this.ClusterData.Value;
        end

    end

    methods(Access=protected)
        function createSection(this)
            lidarCuboidSectionTitle=getString(message('vision:labeler:LidarCuboid'));
            lidarCuboidSectionTag='sectionLidarCuboid';

            this.Section=matlab.ui.internal.toolstrip.Section(lidarCuboidSectionTitle);
            this.Section.Tag=lidarCuboidSectionTag;
        end

        function layoutSection(this)
            this.addCuboidShrinkCheckbox();
            this.addClusterData();
            this.addClusterDataSetttings();

            colAddSession=this.addColumn(...
            'HorizontalAlignment','left');
            colAddSession.add(this.ShrinkCuboid);

            colAddSession=this.addColumn(...
            'HorizontalAlignment','left');
            colAddSession.add(this.ClusterData);

            colAddSession=this.addColumn(...
            'HorizontalAlignment','left');
            colAddSession.add(this.ClusterSettings);
        end

        function addCuboidShrinkCheckbox(this)
            import matlab.ui.internal.toolstrip.*;


            icon=fullfile(this.IconPath,'ShrinkToFit_24.png');
            titleID='vision:labeler:LidarShrinkCuboid';
            tag='btnShrinkCuboid';
            this.ShrinkCuboid=this.createToggleButton(icon,titleID,tag);
            toolTipID='vision:labeler:LidarShrinkCuboidTooltip';
            this.setToolTipText(this.ShrinkCuboid,toolTipID);

            this.ShrinkCuboid.Value=true;

        end

        function addClusterData(this)

            icon=fullfile(this.IconPath,'SnapToCluster_24.png');
            titleID='vision:labeler:LidarClusterData';
            tag='btnClusterData';
            this.ClusterData=this.createToggleButton(icon,titleID,tag);
            toolTipID='vision:labeler:LidarClusterDataTooltip';
            this.setToolTipText(this.ClusterData,toolTipID);

        end

        function addClusterDataSetttings(this)

            icon=matlab.ui.internal.toolstrip.Icon.SETTINGS_24;
            titleID='vision:labeler:LidarClusterDataSettings';
            tag='btnClusteringSettings';
            this.ClusterSettings=this.createButton(icon,titleID,tag);
            toolTipID='vision:labeler:LidarClusterDataSettingsTooltip';
            this.setToolTipText(this.ClusterSettings,toolTipID);

        end

    end
end