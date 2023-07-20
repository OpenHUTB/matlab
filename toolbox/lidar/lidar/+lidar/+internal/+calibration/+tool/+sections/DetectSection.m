classdef DetectSection<handle




    properties
        Tab;
        EditROIBtn;
        SelectCheckerboardBtn;
        RemoveGroundBtn;
        ClusterThrLabel;
        ClusterThrSpnr;
        DimTolernceLabel;
        DimensionToleranceSpnr;
        DetectBtn;
        ColumnWidth=40;
    end

    methods

        function this=DetectSection(tab)
            this.Tab=tab;
            addColumns(this);
            setEnableState(this,false);
        end

        function setEnableState(this,value)
            this.EditROIBtn.Enabled=value;
            this.SelectCheckerboardBtn.Enabled=value;
            this.RemoveGroundBtn.Enabled=value;
            this.ClusterThrSpnr.Enabled=value;
            this.DimensionToleranceSpnr.Enabled=value;
            this.DetectBtn.Enabled=false;
            this.ClusterThrLabel.Enabled=value;
            this.DimTolernceLabel.Enabled=value;
        end

        function addColumns(this)
            import matlab.ui.internal.toolstrip.*

            section=this.Tab.addSection(upper(string(message('lidar:lidarCameraCalibrator:detectSectionName'))));
            section.Tag='sec_detect';


            columnTuneROI=section.addColumn('Width',this.ColumnWidth+10);
            iconFile=fullfile(toolboxdir('lidar'),'lidar','+lidar','+internal','+calibration','+tool','+icons','EditROIBtn_24.png');
            this.EditROIBtn=Button(string(message('lidar:lidarCameraCalibrator:editROIBtnName')),iconFile);
            this.EditROIBtn.Tag='pBtnEditROI';
            this.EditROIBtn.Description=string(message('lidar:lidarCameraCalibrator:editROIBtnDesc'));
            columnTuneROI.add(this.EditROIBtn);


            columnManualSelection=section.addColumn('Width',this.ColumnWidth+50);
            iconFile=fullfile(toolboxdir('lidar'),'lidar','+lidar','+internal','+calibration','+tool','+icons','SelectCheckerboard_24.png');
            this.SelectCheckerboardBtn=Button(string(message('lidar:lidarCameraCalibrator:selectCheckerboardBtnName')),iconFile);
            this.SelectCheckerboardBtn.Tag='pBtnSelectCheckerboard';
            this.SelectCheckerboardBtn.Description=string(message('lidar:lidarCameraCalibrator:selectCheckerboardBtnDesc'));
            columnManualSelection.add(this.SelectCheckerboardBtn);


            columnRemoveGround=section.addColumn('Width',this.ColumnWidth+10);
            iconFile=fullfile(toolboxdir('lidar'),'lidar','+lidar','+internal','+calibration','+tool','+icons','RemoveGroundBtn_24.png');
            this.RemoveGroundBtn=ToggleButton(string(message('lidar:lidarCameraCalibrator:removeGroundBtnName')),iconFile);
            this.RemoveGroundBtn.Tag='tBtnRemoveGround';
            this.RemoveGroundBtn.Description=string(message('lidar:lidarCameraCalibrator:removeGroundBtnDesc'));
            columnRemoveGround.add(this.RemoveGroundBtn);

            columnLabels=section.addColumn('Width',this.ColumnWidth);
            this.ClusterThrLabel=matlab.ui.internal.toolstrip.Label;
            this.ClusterThrLabel.Text=string(message('lidar:lidarCameraCalibrator:clusterThrControlName'));
            this.ClusterThrLabel.Description=string(message('lidar:lidarCameraCalibrator:clusterThrControlDesc'));
            columnLabels.add(this.ClusterThrLabel);

            this.DimTolernceLabel=matlab.ui.internal.toolstrip.Label;
            this.DimTolernceLabel.Text=string(message('lidar:lidarCameraCalibrator:dimTolControlName'));
            this.DimTolernceLabel.Description=string(message('lidar:lidarCameraCalibrator:dimTolControlDesc'));
            columnLabels.add(this.DimTolernceLabel);


            columnSpnrs=section.addColumn('Width',this.ColumnWidth+40);
            this.ClusterThrSpnr=Spinner;
            this.ClusterThrSpnr.Tag='spinnerClusterThr';
            this.ClusterThrSpnr.Limits=[0,10];
            this.ClusterThrSpnr.StepSize=1e-1;
            this.ClusterThrSpnr.Value=0;
            this.ClusterThrSpnr.NumberFormat='double';
            this.ClusterThrSpnr.Description=this.ClusterThrLabel.Description;
            columnSpnrs.add(this.ClusterThrSpnr);

            this.DimensionToleranceSpnr=Spinner;
            this.DimensionToleranceSpnr.Tag='spinnerDimensionTolerance';
            this.DimensionToleranceSpnr.Limits=[0,1];
            this.DimensionToleranceSpnr.StepSize=1e-2;
            this.DimensionToleranceSpnr.DecimalFormat='5f';
            this.DimensionToleranceSpnr.Value=0;
            this.DimensionToleranceSpnr.NumberFormat='double';
            this.DimensionToleranceSpnr.Description=this.DimTolernceLabel.Description;
            columnSpnrs.add(this.DimensionToleranceSpnr);

            columnDetectBtn=section.addColumn('Width',this.ColumnWidth);
            iconFile=fullfile(toolboxdir('lidar'),'lidar','+lidar','+internal','+calibration','+tool','+icons','DetectBtn_24.png');
            this.DetectBtn=Button(string(message('lidar:lidarCameraCalibrator:detectBtnName')),iconFile);
            this.DetectBtn.Tag='pBtnDetect';
            this.DetectBtn.Description=string(message('lidar:lidarCameraCalibrator:detectBtnDesc'));
            columnDetectBtn.add(this.DetectBtn);
        end

        function setDefaults(this,removeGround,clusterThr,dimensionTolerance)
            this.RemoveGroundBtn.Value=removeGround;
            this.ClusterThrSpnr.Value=clusterThr;
            this.DimensionToleranceSpnr.Value=dimensionTolerance;
        end
    end

end