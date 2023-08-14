





classdef ExportSection<handle

    properties

        ExportButton matlab.ui.internal.toolstrip.Button

    end

    properties(Access=private)
Tab
    end

    methods



        function this=ExportSection(tab)
            this.Tab=tab;
            this.createWidgtes();
            this.addButtons();
        end
    end




    methods(Access=private)
        function createWidgtes(this)

            this.createExportButton();
        end


        function addButtons(this)

            section=addSection(this.Tab,getString(message('lidar:lidarViewer:ExportSection')));

            column=section.addColumn();
            column.add(this.ExportButton);

        end


        function createExportButton(this)

            import matlab.ui.internal.toolstrip.Icon.*;

            icon=CONFIRM_24;
            label=getString(message('lidar:lidarViewer:ExportBtn'));
            this.ExportButton=matlab.ui.internal.toolstrip.Button(label,icon);
            this.ExportButton.Tag='exportBtn';
            this.ExportButton.Description=getString(message('lidar:lidarViewer:ExportDescription'));
        end
    end

end