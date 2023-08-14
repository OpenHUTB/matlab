classdef CalibrateSection<handle




    properties
        Tab;
        InitialTransformBtn;
        CalibrateBtn;

        ColumnWidth=40;
    end

    methods
        function this=CalibrateSection(tab)
            this.Tab=tab;
            addColumns(this);
            setEnableState(this,false);
        end

        function setEnableState(this,value)
            this.InitialTransformBtn.Enabled=value;
            this.CalibrateBtn.Enabled=value;
        end

        function addColumns(this)
            import matlab.ui.internal.toolstrip.*

            section=this.Tab.addSection(upper(string(message('lidar:lidarCameraCalibrator:calibrateSectionName'))));
            section.Tag='sectionCalibrate';

            columnInitialTranform=section.addColumn('Width',this.ColumnWidth);
            iconFile=fullfile(toolboxdir('lidar'),'lidar','+lidar','+internal','+calibration','+tool','+icons','InitialTransformBtn_24.png');
            this.InitialTransformBtn=Button(string(message('lidar:lidarCameraCalibrator:initialTformBtnName')),iconFile);
            this.InitialTransformBtn.Tag='pBtnInitialTransform';

            this.InitialTransformBtn.Description=string(message('lidar:lidarCameraCalibrator:initialTformBtnDesc'));
            columnInitialTranform.add(this.InitialTransformBtn);

            columnCalibrateBtn=section.addColumn('Width',this.ColumnWidth+30);
            this.CalibrateBtn=Button(string(message('lidar:lidarCameraCalibrator:calibrateBtnName')),Icon.RUN_24);
            this.CalibrateBtn.Tag='pBtnCalibrate';
            this.CalibrateBtn.Description=string(message('lidar:lidarCameraCalibrator:calibrateBtnDesc'));
            columnCalibrateBtn.add(this.CalibrateBtn);
        end
    end

end
