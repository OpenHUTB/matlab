classdef CloseSection<handle




    properties
        Tab;
        ApplyBtn;
        CancelBtn;

        ColumnWidth=40;
    end
    methods
        function this=CloseSection(tab)
            this.Tab=tab;
            addColumns(this);
            setEnableState(this,true);
        end

        function setEnableState(this,value)
            this.ApplyBtn.Enabled=value;
            this.CancelBtn.Enabled=value;
        end

        function addColumns(this)
            import matlab.ui.internal.toolstrip.*

            section=this.Tab.addSection(upper(string(message('lidar:lidarCameraCalibrator:closeSectionName'))));
            section.Tag='sec_Close';

            column1=section.addColumn('Width',40);
            button=Button(string(message('lidar:lidarCameraCalibrator:applyBtnName')),Icon.CONFIRM_24);
            button.Tag='pBtnApply';
            button.Description=string(message('lidar:lidarCameraCalibrator:applyBtnDesc'));
            column1.add(button);
            this.ApplyBtn=button;

            column2=section.addColumn('Width',40);
            button=Button(string(message('lidar:lidarCameraCalibrator:cancelBtnName')),Icon.CLOSE_24);
            button.Tag='pBtnCancel';
            button.Description=string(message('lidar:lidarCameraCalibrator:cancelBtnDesc'));
            column2.add(button);
            this.CancelBtn=button;
        end
    end
end