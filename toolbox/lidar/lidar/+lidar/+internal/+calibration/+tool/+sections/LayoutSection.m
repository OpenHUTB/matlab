classdef LayoutSection<handle




    properties
        Tab;
        LayoutBtn;
        columnWidth=40;
    end

    methods
        function this=LayoutSection(tab)
            this.Tab=tab;
            addColumns(this);
            setEnableState(this,true);
        end

        function setEnableState(this,value)
            this.LayoutBtn.Enabled=value;
        end

        function addColumns(this)

            import matlab.ui.internal.toolstrip.*

            section=this.Tab.addSection(upper(string(message('lidar:lidarCameraCalibrator:layoutSectionName'))));
            section.Tag='sec_Layout';

            columnLayout=section.addColumn('Width',this.columnWidth+20);
            this.LayoutBtn=Button(string(message('lidar:lidarCameraCalibrator:defaultLayoutBtnName')),Icon.LAYOUT_24);
            this.LayoutBtn.Tag='pBtnLayout';
            this.LayoutBtn.Description=string(message('lidar:lidarCameraCalibrator:defaultLayoutBtnDesc'));
            columnLayout.add(this.LayoutBtn);
        end
    end

end
