classdef SelectSection<handle




    properties
        Tab;
        SelectCheckerboardBtn;
        ClearSelectionBtn;

        ColumnWidth=40;
    end
    methods
        function this=SelectSection(tab)
            this.Tab=tab;
            addColumns(this);
            setEnableState(this,true);
        end

        function setEnableState(this,value)
            this.SelectCheckerboardBtn.Enabled=value;
            this.ClearSelectionBtn.Enabled=value;
        end

        function addColumns(this)
            import matlab.ui.internal.toolstrip.*

            section=this.Tab.addSection(upper(string(message('lidar:lidarCameraCalibrator:SelectCheckerboardSectionName'))));
            section.Tag='sec_Select';

            colSelectBtn=section.addColumn('Width',40);
            iconFile=fullfile(toolboxdir('lidar'),'lidar','+lidar','+internal','+calibration','+tool','+icons','SelectCheckerboard_24.png');
            button=ToggleButton(string(message('lidar:lidarCameraCalibrator:SelectCheckerboardPointsBtnName')),iconFile);
            button.Tag='pBtnSelectCBTab_SelectCheckerboard';
            button.Description=string(message('lidar:lidarCameraCalibrator:SelectCheckerboardPointsBtnDesc'));
            colSelectBtn.add(button);
            this.SelectCheckerboardBtn=button;

            colClearBtn=section.addColumn('Width',40);
            iconFile=fullfile(toolboxdir('lidar'),'lidar','+lidar','+internal','+calibration','+tool','+icons','EraseCheckerboard_24.png');
            button=Button(string(message('lidar:lidarCameraCalibrator:ClearSelectionBtnName')),iconFile);
            button.Tag='pBtnClearSelection';
            button.Description=string(message('lidar:lidarCameraCalibrator:ClearSelectionBtnDesc'));
            colClearBtn.add(button);
            this.ClearSelectionBtn=button;
        end
    end
end