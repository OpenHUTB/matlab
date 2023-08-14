





classdef FileSection<handle

    properties
        NewSessionButton matlab.ui.internal.toolstrip.Button

        ImportButton matlab.ui.internal.toolstrip.DropDownButton
    end

    properties(Access=private)
Tab
    end

    methods



        function this=FileSection(tab)
            this.Tab=tab;
            this.createWidgtes();
            this.addButtons();
        end
    end




    methods(Access=private)
        function createWidgtes(this)

            this.createNewSessionButton();
            this.createImportButton();
        end


        function addButtons(this)

            section=addSection(this.Tab,getString(message('lidar:lidarViewer:File')));

            column=section.addColumn();
            column.add(this.NewSessionButton);

            column=section.addColumn();
            column.add(this.ImportButton);
        end


        function createNewSessionButton(this)

            import matlab.ui.internal.toolstrip.Icon.*;
            icon=NEW_24;
            label=getString(message('lidar:lidarViewer:NewSession'));
            this.NewSessionButton=matlab.ui.internal.toolstrip.Button(label,icon);
            this.NewSessionButton.Tag='newSessionBtn';
            this.NewSessionButton.Description=getString(message('lidar:lidarViewer:NewSessionDescription'));
        end


        function createImportButton(this)

            import matlab.ui.internal.toolstrip.Icon.*;
            icon=IMPORT_24;
            label=getString(message('lidar:lidarViewer:Import'));
            this.ImportButton=matlab.ui.internal.toolstrip.DropDownButton(label,icon);
            this.ImportButton.Tag='importBtn';
            this.ImportButton.Description=getString(message('lidar:lidarViewer:ImportDescription'));
        end
    end

end