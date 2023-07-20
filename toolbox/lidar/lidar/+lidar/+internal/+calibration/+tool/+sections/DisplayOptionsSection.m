classdef DisplayOptionsSection<handle




    properties
        Tab;
        SnapToROIBtn;
        HideROIBtn;
        ColumnWidth=40;
    end

    methods
        function this=DisplayOptionsSection(tab)
            this.Tab=tab;
            addColumns(this);
            setEnableState(this,false);
        end

        function setEnableState(this,value)
            this.SnapToROIBtn.Enabled=value;
            this.HideROIBtn.Enabled=false;


            this.SnapToROIBtn.Value=true;
            this.HideROIBtn.Value=false;
        end

        function addColumns(this)

            import matlab.ui.internal.toolstrip.*

            section=this.Tab.addSection(upper(string(message('lidar:lidarCameraCalibrator:displayOptionsSectionName'))));
            section.Tag='sec_dispOptions';

            column1=section.addColumn('Width',this.ColumnWidth+20);
            iconFile=fullfile(toolboxdir('lidar'),'lidar','+lidar','+internal','+calibration','+tool','+icons','SnapToROIBtn_24.png');
            this.SnapToROIBtn=ToggleButton(string(message('lidar:lidarCameraCalibrator:snapToROIBtnName')),iconFile);
            this.SnapToROIBtn.Tag='tBtnSnapToROI';
            this.SnapToROIBtn.Description=string(message('lidar:lidarCameraCalibrator:snapToROIBtnDesc'));
            this.SnapToROIBtn.Value=true;
            column1.add(this.SnapToROIBtn);

            column2=section.addColumn('Width',this.ColumnWidth+30);
            iconFile=fullfile(toolboxdir('lidar'),'lidar','+lidar','+internal','+calibration','+tool','+icons','HideROICuboidBtn_24.png');
            this.HideROIBtn=ToggleButton(string(message('lidar:lidarCameraCalibrator:hideCuboidROIBtnName')),iconFile);
            this.HideROIBtn.Tag='tBtnHideROI';
            this.HideROIBtn.Value=true;
            this.HideROIBtn.Description=string(message('lidar:lidarCameraCalibrator:hideCuboidROIBtnDesc'));
            column2.add(this.HideROIBtn);
        end
    end

end
