


classdef MeasurementSection<handle



    properties

        DistanceButton matlab.ui.internal.toolstrip.ToggleButton
        ElevationButton matlab.ui.internal.toolstrip.ToggleButton
        PointButton matlab.ui.internal.toolstrip.ToggleButton
        AngleButton matlab.ui.internal.toolstrip.ToggleButton
        VolumeButton matlab.ui.internal.toolstrip.ToggleButton

    end

    properties

    end

    properties
Tab

NameMap

    end

    methods



        function this=MeasurementSection(tab)
            this.Tab=tab;
            this.createWidgtes();
            this.addButtons();
        end


        function idx=getIdxFromName(this,name)


            try
                idx=this.NameMap(name);
            catch
                idx=[];
            end
        end
    end




    methods(Access=private)
        function createWidgtes(this)

            import matlab.ui.internal.toolstrip.*
            import matlab.ui.internal.toolstrip.Icon.*;

            icon=fullfile(matlabroot,'toolbox','lidar','lidar','+lidar',...
            '+internal','+lidarViewer','+view','+icons','distance_24.png');
            toolName={};


            distanceLabelId=getString(message('lidar:lidarViewer:DistanceBtn'));
            this.DistanceButton=matlab.ui.internal.toolstrip.ToggleButton(distanceLabelId,icon);
            this.DistanceButton.Tag='distanceBtn';
            this.DistanceButton.Description=getString(message('lidar:lidarViewer:DistanceBtnDescription'));
            toolName{end+1}='Distance Tool';

            icon=fullfile(matlabroot,'toolbox','lidar','lidar','+lidar',...
            '+internal','+lidarViewer','+view','+icons','elevation_24.png');


            elevationLabelId=getString(message('lidar:lidarViewer:ElevationBtn'));
            this.ElevationButton=matlab.ui.internal.toolstrip.ToggleButton(elevationLabelId,icon);
            this.ElevationButton.Tag='elevationBtn';
            this.ElevationButton.Description=getString(message('lidar:lidarViewer:ElevationBtnDescription'));
            toolName{end+1}='Elevation Tool';


            icon=fullfile(matlabroot,'toolbox','lidar','lidar','+lidar',...
            '+internal','+lidarViewer','+view','+icons','point_24.png');

            pointLabelId=getString(message('lidar:lidarViewer:PointBtn'));
            this.PointButton=matlab.ui.internal.toolstrip.ToggleButton(pointLabelId,icon);
            this.PointButton.Tag='pointBtn';
            this.PointButton.Description=getString(message('lidar:lidarViewer:PointBtnDescription'));
            toolName{end+1}='Point Tool';


            icon=fullfile(matlabroot,'toolbox','lidar','lidar','+lidar',...
            '+internal','+lidarViewer','+view','+icons','angle_24.png');
            angleLabelId=getString(message('lidar:lidarViewer:AngleBtn'));
            this.AngleButton=matlab.ui.internal.toolstrip.ToggleButton(angleLabelId,icon);
            this.AngleButton.Tag='angleBtn';
            this.AngleButton.Description=getString(message('lidar:lidarViewer:AngleBtnDescription'));
            toolName{end+1}='Angle Tool';


            icon=fullfile(matlabroot,'toolbox','lidar','lidar','+lidar',...
            '+internal','+lidarViewer','+view','+icons','volume_24.png');
            volumeLabelId=getString(message('lidar:lidarViewer:VolumeBtn'));
            this.VolumeButton=matlab.ui.internal.toolstrip.ToggleButton(volumeLabelId,icon);
            this.VolumeButton.Tag='volumeBtn';
            this.VolumeButton.Description=getString(message('lidar:lidarViewer:VolumeBtnDescription'));
            toolName{end+1}='Volume Tool';

            this.NameMap=containers.Map(toolName,(1:numel(toolName)));

        end


        function addButtons(this)

            section=addSection(this.Tab,getString(message('lidar:lidarViewer:MeasurementSection')));

            column=section.addColumn();
            column.add(this.DistanceButton);

            column=section.addColumn();
            column.add(this.ElevationButton);

            column=section.addColumn();
            column.add(this.PointButton);

            column=section.addColumn();
            column.add(this.AngleButton);

            column=section.addColumn();
            column.add(this.VolumeButton);

        end
    end

end
