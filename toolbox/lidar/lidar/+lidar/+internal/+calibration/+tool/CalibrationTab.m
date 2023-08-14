classdef CalibrationTab<handle





    properties
        Tab;

        FileSection;
        IntrinsicsSection;
        DetectSection;
        CalibrateSection;
        DisplayOptionsSection;
        LayoutSection;
        ExportSection;
    end

    methods

        function this=CalibrationTab()

            import lidar.internal.calibration.tool.sections.*;

            import matlab.ui.internal.toolstrip.*
            this.Tab=Tab(string(message('lidar:lidarCameraCalibrator:calibrationTabName')));
            this.Tab.Tag='tab_calib';

            this.FileSection=FileSection(this.Tab);
            this.IntrinsicsSection=IntrinsicsSection(this.Tab);
            this.DetectSection=DetectSection(this.Tab);
            this.CalibrateSection=CalibrateSection(this.Tab);
            this.DisplayOptionsSection=DisplayOptionsSection(this.Tab);
            this.LayoutSection=LayoutSection(this.Tab);
            this.ExportSection=ExportSection(this.Tab);

        end
    end
end
