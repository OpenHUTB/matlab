classdef SelectCheckerboardTab<handle




    properties
        Tab;

        SelectSection;
        CloseSection;
    end

    methods
        function this=SelectCheckerboardTab()
            this.Tab=matlab.ui.internal.toolstrip.Tab(string(message('lidar:lidarCameraCalibrator:SelectCheckerboardTabName')));
            this.Tab.Tag='tab_selectCheckerboard';

            this.SelectSection=lidar.internal.calibration.tool.sections.SelectSection(this.Tab);
            this.CloseSection=lidar.internal.calibration.tool.sections.CloseSection(this.Tab);
        end
    end
end