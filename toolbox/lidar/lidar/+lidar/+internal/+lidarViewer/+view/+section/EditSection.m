





classdef EditSection<handle



    properties

        EditButton matlab.ui.internal.toolstrip.Button

    end

    properties(Access=private)
Tab
    end

    methods



        function this=EditSection(tab)
            this.Tab=tab;
            this.createWidgtes();
            this.addButtons();
        end
    end




    methods(Access=private)
        function createWidgtes(this)

            this.createEditButton();

        end


        function addButtons(this)

            section=addSection(this.Tab,getString(message('lidar:lidarViewer:EditSection')));

            column=section.addColumn();
            column.add(this.EditButton);

        end


        function createEditButton(this)

            import matlab.ui.internal.toolstrip.Icon.*;

            icon=fullfile(matlabroot,'toolbox','lidar','lidar','+lidar',...
            '+internal','+lidarViewer','+view','+icons','editPointCloud_24.png');
            labelId=getString(message('lidar:lidarViewer:EditBtn'));
            this.EditButton=matlab.ui.internal.toolstrip.Button(labelId,icon);
            this.EditButton.Tag='editBtn';
            this.EditButton.Description=getString(message('lidar:lidarViewer:EditDescription'));
        end
    end

end