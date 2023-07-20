classdef IntrinsicsSection<handle




    properties
        Tab;

        ComputeIntrinsicsRBtn;
        UseFixedIntrinsicsRBtn;
        LoadIntrinsicsBtn;

        ColumnWidth=40;
    end

    methods
        function this=IntrinsicsSection(tab)
            this.Tab=tab;
            addColumns(this);
            setEnableState(this,false);
        end

        function setEnableState(this,value)
            this.ComputeIntrinsicsRBtn.Enabled=value;
            this.UseFixedIntrinsicsRBtn.Enabled=value;
            this.LoadIntrinsicsBtn.Enabled=false;
            if(value)


                this.ComputeIntrinsicsRBtn.Value=true;
                this.UseFixedIntrinsicsRBtn.Value=false;
                this.LoadIntrinsicsBtn.Enabled=false;
            end
        end

        function addColumns(this)

            import matlab.ui.internal.toolstrip.*

            section=this.Tab.addSection(upper(string(message('lidar:lidarCameraCalibrator:intrinsicsSectionName'))));
            section.Tag='sec_Intrinsics';

            columnIntrinsics=section.addColumn('Width',this.ColumnWidth);



            grp=matlab.ui.internal.toolstrip.ButtonGroup;
            this.ComputeIntrinsicsRBtn=matlab.ui.internal.toolstrip.RadioButton(grp,string(message('lidar:lidarCameraCalibrator:computeRBtnName')));
            this.ComputeIntrinsicsRBtn.Value=true;
            this.ComputeIntrinsicsRBtn.Description=string(message('lidar:lidarCameraCalibrator:computeRBtnDesc'));
            this.ComputeIntrinsicsRBtn.Tag='rBtnComputeIntrinsics';

            this.UseFixedIntrinsicsRBtn=matlab.ui.internal.toolstrip.RadioButton(grp,string(message('lidar:lidarCameraCalibrator:useFixedRBtnName')));
            this.UseFixedIntrinsicsRBtn.Tag='rBtnUseFixedIntrinsics';
            this.UseFixedIntrinsicsRBtn.Description=string(message('lidar:lidarCameraCalibrator:useFixedRBtnDesc'));

            this.LoadIntrinsicsBtn=matlab.ui.internal.toolstrip.Button(string(message('lidar:lidarCameraCalibrator:loadIntrinsicsBtnName')));
            this.LoadIntrinsicsBtn.Tag='pBtnLoadIntrinsics';
            this.LoadIntrinsicsBtn.Description=string(message('lidar:lidarCameraCalibrator:loadIntrinsicsBtnDesc'));

            columnIntrinsics.add(this.ComputeIntrinsicsRBtn);
            columnIntrinsics.add(this.UseFixedIntrinsicsRBtn);
            columnIntrinsics.add(this.LoadIntrinsicsBtn);
        end
    end

end
