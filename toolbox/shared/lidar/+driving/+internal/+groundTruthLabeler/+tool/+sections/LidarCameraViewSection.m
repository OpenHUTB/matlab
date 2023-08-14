classdef LidarCameraViewSection<vision.internal.uitools.NewToolStripSection




    properties
ProjectedView
ProjectedViewIcon
HomeView
XYView
YZView
XZView
BirdsEyeView
ChaseView
EgoView
EgoDirection
EgoDirectionLabel
    end

    properties(Constant)
        IconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons');
        ProjectedViewIconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+videoLabeler','+tool');
    end

    methods
        function enable(this)
            this.ProjectedView.Enabled=true;
        end

        function switchOff(this)
            this.ProjectedView.Value=false;
        end

        function switchOn(this)
            this.ProjectedView.Value=true;
        end

        function disable(this)
            this.ProjectedView.Enabled=false;
        end
    end

    methods
        function this=LidarCameraViewSection()
            this.createSection();
            this.layoutSection();
        end
    end

    methods(Access=protected)
        function createSection(this)
            lidarCameraViewSectionTitle=getString(message('vision:labeler:LidarCameraView'));
            lidarCameraViewSectionTag='sectionLidarCameraView';

            this.Section=matlab.ui.internal.toolstrip.Section(lidarCameraViewSectionTitle);
            this.Section.Tag=lidarCameraViewSectionTag;
        end

        function layoutSection(this)
            this.addViewButtons();

            colAddSession=this.addColumn('HorizontalAlignment','center');
            colAddSession.add(this.ProjectedView);

            colAddSession=this.addColumn(...
            'HorizontalAlignment','center');
            colAddSession.add(this.HomeView);

            colAddSession=this.addColumn();
            colAddSession.add(this.XYView);
            colAddSession.add(this.YZView);
            colAddSession.add(this.XZView);

            colAddSession=this.addColumn();
            colAddSession.add(this.BirdsEyeView);
            colAddSession.add(this.ChaseView);
            colAddSession.add(this.EgoView);

            colAddSession=this.addColumn('HorizontalAlignment','center');
            colAddSession.add(this.EgoDirectionLabel);
            colAddSession.add(this.EgoDirection);

        end

        function addViewButtons(this)
            import matlab.ui.internal.toolstrip.*;


            titleID='vision:labeler:LidarProjectedView';
            tag='btnMultiView';
            toolTipID='vision:labeler:LidarProjectedViewToolTip';

            icon=fullfile(this.ProjectedViewIconPath,'lidarProjectedView_24.png');
            this.ProjectedView=this.createToggleButton(icon,titleID,tag);
            this.setToolTipText(this.ProjectedView,toolTipID);


            titleID='vision:labeler:LidarDefaultView';
            tag='btnHomeView';
            icon=fullfile(this.IconPath,'Restore_24.png');
            this.HomeView=this.createButton(icon,titleID,tag);
            this.setToolTipText(this.HomeView,'vision:labeler:LidarCameraViewTooltip');



            icon=fullfile(this.IconPath,'XYView.png');
            this.XYView=matlab.ui.internal.toolstrip.Button(...
            vision.getMessage('vision:labeler:LidarXYView'),icon);
            this.XYView.Tag='btnXYView';
            this.setToolTipText(this.XYView,'vision:labeler:LidarXYViewTooltip');

            icon=fullfile(this.IconPath,'YZView.png');
            this.YZView=matlab.ui.internal.toolstrip.Button(...
            vision.getMessage('vision:labeler:LidarYZView'),icon);
            this.YZView.Tag='btnYZView';
            this.setToolTipText(this.YZView,'vision:labeler:LidarYZViewTooltip');

            icon=fullfile(this.IconPath,'XZView.png');
            this.XZView=matlab.ui.internal.toolstrip.Button(...
            vision.getMessage('vision:labeler:LidarXZView'),icon);
            this.XZView.Tag='btnXZView';
            this.setToolTipText(this.XZView,'vision:labeler:LidarXZViewTooltip');


            icon=fullfile(this.IconPath,'BirdView_16.png');
            this.BirdsEyeView=matlab.ui.internal.toolstrip.Button(...
            vision.getMessage('vision:labeler:LidarBirdsEyeView'),icon);
            this.BirdsEyeView.Tag='btnBirdsEyeView';
            this.setToolTipText(this.BirdsEyeView,'vision:labeler:LidarCameraViewTooltip');


            icon=fullfile(this.IconPath,'ChaseView_16.png');
            this.ChaseView=matlab.ui.internal.toolstrip.Button(...
            vision.getMessage('vision:labeler:LidarChaseView'),icon);
            this.ChaseView.Tag='btnChaseView';
            this.setToolTipText(this.ChaseView,'vision:labeler:LidarCameraViewTooltip');


            icon=fullfile(this.IconPath,'EgoView_16.png');
            this.EgoView=matlab.ui.internal.toolstrip.Button(...
            vision.getMessage('vision:labeler:LidarDriversView'),icon);
            this.EgoView.Tag='btnDriversView';
            this.setToolTipText(this.EgoView,'vision:labeler:LidarCameraViewTooltip');


            labelId='vision:labeler:LidarEgoDirection';
            this.EgoDirectionLabel=this.createLabel(labelId);
            toolTipID='vision:labeler:LidarEgoDirectionToolTip';
            this.setToolTipText(this.EgoDirectionLabel,toolTipID);

            tag='btnEgoDirection';
            list={'+x';'-x';'+y';'-y'};
            this.EgoDirection=this.createDropDown(list,tag,toolTipID);
            this.EgoDirection.SelectedIndex=1;

        end

    end
end
