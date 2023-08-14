





classdef LayoutSection<handle

    properties

        DefaultLayoutButton matlab.ui.internal.toolstrip.Button

    end

    properties(Access=private)
Tab
    end

    methods



        function this=LayoutSection(tab)
            this.Tab=tab;
            this.createWidgtes();
            this.addButtons();
        end
    end




    methods(Access=private)
        function createWidgtes(this)

            this.createDefaultLayoutButton();
        end


        function addButtons(this)

            section=addSection(this.Tab,getString(message('lidar:lidarViewer:Layout')));

            column=section.addColumn();
            column.add(this.DefaultLayoutButton);

        end


        function createDefaultLayoutButton(this)

            import matlab.ui.internal.toolstrip.Icon.*;

            icon=LAYOUT_24;
            label=getString(message('lidar:lidarViewer:DefaultLayout'));
            this.DefaultLayoutButton=matlab.ui.internal.toolstrip.Button(label,icon);
            this.DefaultLayoutButton.Tag='defaultLayoutBtn';
            this.DefaultLayoutButton.Description=getString(message('lidar:lidarViewer:DefaultLayoutDescription'));
        end
    end

end