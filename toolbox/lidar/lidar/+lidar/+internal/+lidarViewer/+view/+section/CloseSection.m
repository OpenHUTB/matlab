


classdef CloseSection<handle



    properties

        CloseButton matlab.ui.internal.toolstrip.Button

    end

    properties

Tab

    end

    methods



        function this=CloseSection(tab)
            this.Tab=tab;
            this.createWidgtes();
            this.addButtons();
        end

    end




    methods(Access=private)
        function createWidgtes(this)


            icon=matlab.ui.internal.toolstrip.Icon.CLOSE_24;
            CloseLabelId=getString(message('lidar:lidarViewer:CloseBtn'));
            this.CloseButton=matlab.ui.internal.toolstrip.Button(CloseLabelId,icon);
            this.CloseButton.Tag='closeMeasurementBtn';
            this.CloseButton.Enabled=false;
            this.CloseButton.Description=getString(message('lidar:lidarViewer:CloseBtnDescription'));

        end


        function addButtons(this)

            section=addSection(this.Tab,getString(message('lidar:lidarViewer:CloseSection')));

            column=section.addColumn();
            column.add(this.CloseButton);

        end
    end

end
