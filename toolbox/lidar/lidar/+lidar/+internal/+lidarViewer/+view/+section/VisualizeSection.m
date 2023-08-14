





classdef VisualizeSection<handle

    properties

        XYSliceView matlab.ui.internal.toolstrip.Button

        YZSliceView matlab.ui.internal.toolstrip.Button

        XZSliceView matlab.ui.internal.toolstrip.Button

        CustomCameraViewButton matlab.ui.internal.toolstrip.DropDownButton

        BirdsEyeView matlab.ui.internal.toolstrip.Button

        ChaseView matlab.ui.internal.toolstrip.Button

        EgoView matlab.ui.internal.toolstrip.Button

        EgoDirection matlab.ui.internal.toolstrip.DropDown

        EgoDirectionLabel matlab.ui.internal.toolstrip.Label

        RestoreView matlab.ui.internal.toolstrip.Button

        HideGround matlab.ui.internal.toolstrip.ToggleButton

        HideGroundSettings matlab.ui.internal.toolstrip.Button

        ClusterData matlab.ui.internal.toolstrip.ToggleButton

        ClusterSettingsButton matlab.ui.internal.toolstrip.Button

    end

    properties(Access=private)
Tab


IsHomeTab
    end

    methods



        function this=VisualizeSection(tab,isHomeTab)
            this.Tab=tab;
            this.IsHomeTab=isHomeTab;

            this.createWidgtes();
            this.addButtons();
        end

        function enableGroundSettings(this)
            this.HideGroundSettings.Enabled=this.HideGround.Value;
        end

        function enableClusterSettings(this)
            this.ClusterSettingsButton.Enabled=this.ClusterData.Value;
        end
    end




    methods(Access=private)
        function createWidgtes(this)

            this.createPlanarViewButton();
            this.createRestoreViewButton();

            if this.IsHomeTab
                this.createViewButtons();
                this.createCustomCameraViewSplitButton();
                this.createHideGroundButton();
                this.createHideGroundSettingsButton();
                this.addClusterData();
                this.addClusterDataSetttingsButton();

            end
        end


        function addButtons(this)

            section=addSection(this.Tab,getString(message('lidar:lidarViewer:Visualization')));

            column=section.addColumn('HorizontalAlignment','left','Width',70);
            column.add(this.XYSliceView);
            column.add(this.YZSliceView);
            column.add(this.XZSliceView);

            if this.IsHomeTab

                column=section.addColumn('HorizontalAlignment','left','Width',70);
                column.add(this.BirdsEyeView);
                column.add(this.ChaseView);
                column.add(this.EgoView);

                column=section.addColumn('HorizontalAlignment','center','Width',70);
                column.add(this.EgoDirectionLabel);
                column.add(this.EgoDirection);

                column=section.addColumn('HorizontalAlignment','center','Width',70);
                column.add(this.CustomCameraViewButton);
            end

            column=section.addColumn('HorizontalAlignment','center');
            column.add(this.RestoreView);

            if this.IsHomeTab
                column=section.addColumn('HorizontalAlignment','left','Width',70);
                column.add(this.HideGround);
                column.add(this.HideGroundSettings);

                column=section.addColumn('HorizontalAlignment','left','Width',70);
                column.add(this.ClusterData);
                column.add(this.ClusterSettingsButton);



            end
        end


        function createPlanarViewButton(this)

            import matlab.ui.internal.toolstrip.Icon.*;

            labelId=getString(message('lidar:lidarViewer:PlanarViewXY'));
            icon=fullfile(toolboxdir('images'),'imuitools','+images',...
            '+internal','+app','+segmenter','+volume','+icons',...
            'Volume_XYSlice_16.png');
            this.XYSliceView=matlab.ui.internal.toolstrip.Button(labelId,icon);
            this.XYSliceView.Tag='XYViewBtn';
            this.XYSliceView.Description=getString(message('lidar:lidarViewer:PlanarViewXYDescription'));

            labelId=getString(message('lidar:lidarViewer:PlanarViewYZ'));
            icon=fullfile(toolboxdir('images'),'imuitools','+images',...
            '+internal','+app','+segmenter','+volume','+icons',...
            'Volume_YZSlice_16.png');
            this.YZSliceView=matlab.ui.internal.toolstrip.Button(labelId,icon);
            this.YZSliceView.Tag='YZViewBtn';
            this.YZSliceView.Description=getString(message('lidar:lidarViewer:PlanarViewYZDescription'));

            labelId=getString(message('lidar:lidarViewer:PlanarViewXZ'));
            icon=fullfile(toolboxdir('images'),'imuitools','+images',...
            '+internal','+app','+segmenter','+volume','+icons',...
            'Volume_XZSlice_16.png');
            this.XZSliceView=matlab.ui.internal.toolstrip.Button(labelId,icon);
            this.XZSliceView.Tag='XZViewBtn';
            this.XZSliceView.Description=getString(message('lidar:lidarViewer:PlanarViewXZDescription'));
        end


        function createCustomCameraViewSplitButton(this)

            import matlab.ui.internal.toolstrip.Icon.*;

            icon=fullfile(toolboxdir('lidar'),'lidar','+lidar',...
            '+internal','+labeler','+tool','+icons','customCameraViewIcon_24.png');
            labelId=getString(message('lidar:lidarViewer:CustomCameraView'));
            this.CustomCameraViewButton=matlab.ui.internal.toolstrip.DropDownButton(labelId,icon);
            this.CustomCameraViewButton.Tag='customCameraViewBtn';
            this.CustomCameraViewButton.Description=getString(message('lidar:lidarViewer:CustomCameraViewDescription'));
        end















        function createViewButtons(this)

            import matlab.ui.internal.toolstrip.*;


            icon=fullfile(toolboxdir('vision'),'vision','+vision',...
            '+internal','+labeler','+tool','+icons','BirdView_16.png');
            this.BirdsEyeView=matlab.ui.internal.toolstrip.Button(...
            vision.getMessage('lidar:lidarViewer:LidarBirdsEyeView'),icon);
            this.BirdsEyeView.Tag='btnBirdsEyeView';
            this.BirdsEyeView.Description=getString(message('lidar:lidarViewer:LidarBirdsEyeViewTooltip'));


            icon=fullfile(toolboxdir('vision'),'vision','+vision',...
            '+internal','+labeler','+tool','+icons','ChaseView_16.png');
            this.ChaseView=matlab.ui.internal.toolstrip.Button(...
            vision.getMessage('lidar:lidarViewer:LidarChaseView'),icon);
            this.ChaseView.Tag='btnChaseView';
            this.ChaseView.Description=getString(message('lidar:lidarViewer:LidarChaseViewTooltip'));


            icon=fullfile(toolboxdir('vision'),'vision','+vision',...
            '+internal','+labeler','+tool','+icons','EgoView_16.png');
            this.EgoView=matlab.ui.internal.toolstrip.Button(...
            vision.getMessage('lidar:lidarViewer:LidarDriversView'),icon);
            this.EgoView.Tag='btnDriversView';
            this.EgoView.Description=getString(message('lidar:lidarViewer:LidarDriversViewTooltip'));



            labelId=getString(message('lidar:lidarViewer:LidarEgoDirection'));
            this.EgoDirectionLabel=matlab.ui.internal.toolstrip.Label(labelId);
            this.EgoDirectionLabel.Description=getString(message('lidar:lidarViewer:LidarEgoDirectionToolTip'));

            list={'+x';'-x';'+y';'-y'};
            this.EgoDirection=matlab.ui.internal.toolstrip.DropDown(list);
            this.EgoDirection.Tag='btnEgoDirection';
            this.EgoDirection.Description=getString(message('lidar:lidarViewer:LidarEgoDirectionToolTip'));
            this.EgoDirection.SelectedIndex=1;
        end


        function createRestoreViewButton(this)

            icon=fullfile(toolboxdir('vision'),'vision','+vision',...
            '+internal','+labeler','+tool','+icons','Restore_24.png');
            this.RestoreView=matlab.ui.internal.toolstrip.Button(...
            vision.getMessage('lidar:lidarViewer:RestoreView'),icon);
            this.RestoreView.Tag='restoreDefaultViewBtn';
            this.RestoreView.Description=getString(message('lidar:lidarViewer:RestoreViewDescription'));
        end


        function createHideGroundButton(this)

            icon=fullfile(toolboxdir('lidar'),'lidar','+lidar',...
            '+internal','+lidarViewer','+view','+icons','hideGround_16.png');
            titleID=getString(message('lidar:lidarViewer:LidarHideGround'));
            this.HideGround=matlab.ui.internal.toolstrip.ToggleButton(titleID,icon);
            this.HideGround.Tag='btnHideGround';
            this.HideGround.Description=getString(message('lidar:lidarViewer:LidarHideGroundTooltip'));
        end


        function createHideGroundSettingsButton(this)

            icon=matlab.ui.internal.toolstrip.Icon.SETTINGS_16;
            this.HideGroundSettings=matlab.ui.internal.toolstrip.Button(...
            vision.getMessage('lidar:lidarViewer:LidarHideGroundSettings'),icon);
            this.HideGroundSettings.Tag='btnHideGroundSettings';
            this.HideGroundSettings.Description=getString(message('lidar:lidarViewer:LidarHideGroundSettingsTooltip'));
        end


        function addClusterData(this)

            icon=fullfile(toolboxdir('lidar'),'lidar','+lidar','+internal',...
            '+lidarViewer','+view','+icons','snap_16.png');
            titleID=getString(message('lidar:lidarViewer:LidarClusterData'));
            this.ClusterData=matlab.ui.internal.toolstrip.ToggleButton(titleID,icon);
            this.ClusterData.Tag='btnClusterData';
            this.ClusterData.Description=getString(message('lidar:lidarViewer:LidarClusterDataTooltip'));
        end


        function addClusterDataSetttingsButton(this)

            icon=matlab.ui.internal.toolstrip.Icon.SETTINGS_16;
            titleID=getString(message('lidar:lidarViewer:LidarClusterDataSettings'));
            this.ClusterSettingsButton=matlab.ui.internal.toolstrip.Button(titleID,icon);
            this.ClusterSettingsButton.Tag='btnClusteringSettings';
            this.ClusterSettingsButton.Description=getString(message('lidar:lidarViewer:LidarClusterDataSettingsTooltip'));
        end
    end

end