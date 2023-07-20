classdef GroundSection<vision.internal.uitools.NewToolStripSection



    properties
HideGround
HideGroundSettings
    end

    properties(Constant)
        IconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons');
    end

    methods
        function this=GroundSection()
            this.createSection();
            this.layoutSection();
        end

        function enable(this)


            this.HideGround.Enabled=true;
            enableGroundSettings(this);
        end

        function enableGroundSettings(this)
            this.HideGroundSettings.Enabled=this.HideGround.Value;
        end

    end

    methods(Access=protected)
        function createSection(this)
            lidarGroundSectionTitle=getString(message('vision:labeler:LidarHideGroundSection'));
            lidarGroundSectionTag='sectionLidarGround';

            this.Section=matlab.ui.internal.toolstrip.Section(lidarGroundSectionTitle);
            this.Section.Tag=lidarGroundSectionTag;
        end

        function layoutSection(this)

            this.addHideGround();
            this.addHideGroundSettings();

            colAddSession=this.addColumn(...
            'HorizontalAlignment','left');
            colAddSession.add(this.HideGround);

            colAddSession=this.addColumn(...
            'HorizontalAlignment','left');
            colAddSession.add(this.HideGroundSettings);

        end

        function addHideGround(this)

            icon=fullfile(this.IconPath,'HideGround_24.png');
            titleID='vision:labeler:LidarHideGround';
            tag='btnHideGround';
            this.HideGround=this.createToggleButton(icon,titleID,tag);
            toolTipID='vision:labeler:LidarHideGroundTooltip';
            this.setToolTipText(this.HideGround,toolTipID);

        end

        function addHideGroundSettings(this)

            icon=matlab.ui.internal.toolstrip.Icon.SETTINGS_24;
            titleID='vision:labeler:LidarHideGroundSettings';
            tag='btnHideGroundSettings';
            this.HideGroundSettings=this.createButton(icon,titleID,tag);
            toolTipID='vision:labeler:LidarHideGroundSettingsTooltip';
            this.setToolTipText(this.HideGroundSettings,toolTipID);

        end
    end
end