classdef ActionSection<handle




    properties
        Tab;
        SnapToROIBtn;

        ColumnWidth=40;
    end
    methods
        function this=ActionSection(tab)
            this.Tab=tab;
            addColumns(this);
            setEnableState(this,true);
        end

        function setEnableState(this,value)
            this.SnapToROIBtn.Enabled=value;
        end

        function addColumns(this)
            import matlab.ui.internal.toolstrip.*

            section=this.Tab.addSection(upper(string(message('lidar:lidarCameraCalibrator:editROIActionSectionName'))));
            section.Tag='sec_Action';

            column1=section.addColumn('Width',40);
            iconFile=fullfile(toolboxdir('lidar'),'lidar','+lidar','+internal','+calibration','+tool','+icons','SnapToROIBtn_24.png');
            this.SnapToROIBtn=ToggleButton(string(message('lidar:lidarCameraCalibrator:snapToROIBtnName')),iconFile);
            this.SnapToROIBtn.Tag='tBtnEditROITab_SnapToROI';
            this.SnapToROIBtn.Description=string(message('lidar:lidarCameraCalibrator:snapToROIBtnDesc'));
            column1.add(this.SnapToROIBtn);
        end
    end
end