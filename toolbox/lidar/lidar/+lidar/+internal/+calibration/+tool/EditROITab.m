classdef EditROITab<handle




    properties
        Tab;

        ActionSection;
        CloseSection;
    end

    methods
        function this=EditROITab()
            this.Tab=matlab.ui.internal.toolstrip.Tab(string(message('lidar:lidarCameraCalibrator:editROITabName')));
            this.Tab.Tag='tab_editROI';

            this.ActionSection=lidar.internal.calibration.tool.sections.ActionSection(this.Tab);
            this.CloseSection=lidar.internal.calibration.tool.sections.CloseSection(this.Tab);
        end
    end
end
