





classdef MeasurementButtonSection<handle



    properties

        MeasurementButton matlab.ui.internal.toolstrip.Button

    end

    properties(Access=private)
Tab
    end

    methods



        function this=MeasurementButtonSection(tab)
            this.Tab=tab;
            this.createWidgtes();
            this.addButtons();
        end
    end




    methods(Access=private)
        function createWidgtes(this)

            this.createMeasurementButton();

        end


        function addButtons(this)

            section=addSection(this.Tab,getString(message('lidar:lidarViewer:MeasureSection')));

            column=section.addColumn();
            column.add(this.MeasurementButton);

        end


        function createMeasurementButton(this)

            import matlab.ui.internal.toolstrip.Icon.*;

            icon=fullfile(matlabroot,'toolbox','lidar','lidar','+lidar',...
            '+internal','+lidarViewer','+view','+icons','measurements_24.png');
            labelId=getString(message('lidar:lidarViewer:MeasureBtn'));
            this.MeasurementButton=matlab.ui.internal.toolstrip.Button(labelId,icon);
            this.MeasurementButton.Tag='measurementBtn';
            this.MeasurementButton.Description=getString(message('lidar:lidarViewer:MeasureBtnToolTip'));
        end
    end

end