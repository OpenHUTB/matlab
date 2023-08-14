





classdef FinalizeSection<handle

    properties

        AcceptEditButton matlab.ui.internal.toolstrip.Button

        DiscardEditButton matlab.ui.internal.toolstrip.Button

    end

    properties(Access=private)
Tab
    end

    methods



        function this=FinalizeSection(tab)
            this.Tab=tab;
            this.createWidgtes();
            this.addButtons();
        end
    end




    methods(Access=private)
        function createWidgtes(this)

            this.createAcceptEditButton();
            this.createDiscardEditButton();
        end


        function addButtons(this)

            section=addSection(this.Tab,getString(message('lidar:lidarViewer:Finalize')));

            column=section.addColumn();
            column.add(this.AcceptEditButton);

            column=section.addColumn();
            column.add(this.DiscardEditButton);

        end


        function createAcceptEditButton(this)

            import matlab.ui.internal.toolstrip.Icon.*;

            icon=CONFIRM_24;
            labelId=getString(message('lidar:lidarViewer:AcceptBtn'));
            this.AcceptEditButton=matlab.ui.internal.toolstrip.Button(labelId,icon);
            this.AcceptEditButton.Tag='acceptEditBtn';
            this.AcceptEditButton.Description=getString(message('lidar:lidarViewer:AcceptDescription'));

        end


        function createDiscardEditButton(this)

            import matlab.ui.internal.toolstrip.Icon.*;

            icon=CLOSE_24;
            labelId=getString(message('lidar:lidarViewer:CancelBtn'));
            this.DiscardEditButton=matlab.ui.internal.toolstrip.Button(labelId,icon);
            this.DiscardEditButton.Tag='discardEditBtn';
            this.DiscardEditButton.Description=getString(message('lidar:lidarViewer:DiscardDescription'));
        end
    end
end