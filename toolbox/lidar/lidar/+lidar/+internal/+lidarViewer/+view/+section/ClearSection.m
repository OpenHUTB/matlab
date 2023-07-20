


classdef ClearSection<handle



    properties

        ClearButton matlab.ui.internal.toolstrip.Button

    end

    properties

Tab

    end

    methods



        function this=ClearSection(tab)
            this.Tab=tab;
            this.createWidgtes();
            this.addButtons();
        end

    end




    methods(Access=private)
        function createWidgtes(this)

            import matlab.ui.internal.toolstrip.*
            import images.internal.app.Icon;
            import matlab.ui.internal.toolstrip.Icon.*;


            icon=Icon.CLEARALL_24;
            clearLabelId=getString(message('lidar:lidarViewer:ClearBtn'));
            this.ClearButton=matlab.ui.internal.toolstrip.Button(clearLabelId,icon);
            this.ClearButton.Tag='clearBtn';
            this.ClearButton.Enabled=false;
            this.ClearButton.Description=getString(message('lidar:lidarViewer:ClearBtnDescription'));

        end


        function addButtons(this)

            section=addSection(this.Tab,getString(message('lidar:lidarViewer:ClearSection')));

            column=section.addColumn();
            column.add(this.ClearButton);

        end
    end

end
