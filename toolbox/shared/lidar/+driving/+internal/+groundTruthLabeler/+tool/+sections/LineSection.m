classdef LineSection<vision.internal.uitools.NewToolStripSection




    properties
SnapToPoint
    end

    properties(Constant)
        IconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons');
    end

    methods
        function this=LineSection()
            this.createSection();
            this.layoutSection();
        end

        function enable(this)

            this.SnapToPoint.Enabled=true;
        end

        function disable(this)

            this.SnapToPoint.Enabled=false;
        end

    end

    methods(Access=protected)
        function createSection(this)
            lidarLineSectionTitle=getString(message('vision:labeler:LineSection'));
            lidarLineSectionTag='sectionLidarLine';

            this.Section=matlab.ui.internal.toolstrip.Section(lidarLineSectionTitle);
            this.Section.Tag=lidarLineSectionTag;
        end

        function layoutSection(this)
            this.addLineSection();

            colAddSession=this.addColumn();
            colAddSession.add(this.SnapToPoint);
        end

        function addLineSection(this)
            import matlab.ui.internal.toolstrip.*;


            icon=fullfile(this.IconPath,'ShrinkToFit_24.png');
            titleID='vision:labeler:SnapToPoint';
            tag='btnSnapToPoint';
            this.SnapToPoint=this.createToggleButton(icon,titleID,tag);
            toolTipID='vision:labeler:LidarSnapToPointTooltip';
            this.setToolTipText(this.SnapToPoint,toolTipID);

            this.SnapToPoint.Value=true;
        end

    end
end
