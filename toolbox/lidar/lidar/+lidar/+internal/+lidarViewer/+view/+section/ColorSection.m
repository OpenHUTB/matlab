





classdef ColorSection<handle

    properties
        ColormapLabel matlab.ui.internal.toolstrip.Label

        ColormapDropDown matlab.ui.internal.toolstrip.DropDownButton

        ColormapValLabel matlab.ui.internal.toolstrip.Label

        ColormapValDropDown matlab.ui.internal.toolstrip.DropDownButton

        ColorVariationLabel matlab.ui.internal.toolstrip.Label

        ColorVariationDropDown matlab.ui.internal.toolstrip.DropDownButton

        BackgroundColorButton matlab.ui.internal.toolstrip.Button

        PointSizeLabel matlab.ui.internal.toolstrip.Label

        PointSizeSpinner matlab.ui.internal.toolstrip.Spinner
    end

    properties(Access=private)
Tab


IsHomeTab
    end

    methods



        function this=ColorSection(tab,isHomeTab)
            this.Tab=tab;
            this.IsHomeTab=isHomeTab;

            this.createWidgtes();
            this.addButtons();
        end
    end




    methods(Access=private)
        function createWidgtes(this)

            this.createColormapDropDown();
            this.createColormapValDropDown();
            this.createColorVariationDropDown();
            this.createBackgroundColorButton();
            this.createPointSizeSpinner();

        end


        function addButtons(this)

            section=addSection(this.Tab,getString(message('lidar:lidarViewer:Color')));

            column=section.addColumn('HorizontalAlignment','right');
            column.add(this.ColormapLabel);
            column.add(this.ColormapValLabel);
            column.add(this.ColorVariationLabel);

            column=section.addColumn('HorizontalAlignment','right','Width',70);
            column.add(this.ColormapDropDown);
            column.add(this.ColormapValDropDown);
            column.add(this.ColorVariationDropDown);

            column=section.addColumn();
            column.add(this.BackgroundColorButton);


            column=section.addColumn('HorizontalAlignment','right','Width',50);
            column.add(this.PointSizeLabel);
            column.add(this.PointSizeSpinner);

        end


        function createColormapDropDown(this)

            import matlab.ui.internal.toolstrip.Icon.*;

            labelId=getString(message('lidar:lidarViewer:Colormap'));
            this.ColormapLabel=matlab.ui.internal.toolstrip.Label(labelId);
            this.ColormapLabel.Tag='colormapLabel';
            this.ColormapLabel.Description=getString(message('lidar:lidarViewer:ColormapDescription'));

            labelId=getString(message('lidar:lidarViewer:ColormapRedWhiteBlue'));
            this.ColormapDropDown=matlab.ui.internal.toolstrip.DropDownButton(labelId);
            this.ColormapDropDown.Tag='ColormapDropdown';
            this.ColormapDropDown.Description=getString(message('lidar:lidarViewer:ColormapDescription'));

        end


        function createColormapValDropDown(this)

            import matlab.ui.internal.toolstrip.Icon.*;

            labelId=getString(message('lidar:lidarViewer:ColormapValue'));
            this.ColormapValLabel=matlab.ui.internal.toolstrip.Label(labelId);
            this.ColormapValLabel.Tag='ColormapValLabel';
            this.ColormapValLabel.Description=getString(message('lidar:lidarViewer:ColormapValueDescription'));

            labelId=getString(message('lidar:lidarViewer:ColormapValueZ'));
            this.ColormapValDropDown=matlab.ui.internal.toolstrip.DropDownButton(labelId);
            this.ColormapValDropDown.Tag='ColormapValDropdown';
            this.ColormapValDropDown.Description=getString(message('lidar:lidarViewer:ColormapValueDescription'));
        end

        function createColorVariationDropDown(this)

            import matlab.ui.internal.toolstrip.Icon.*;

            labelId=getString(message('lidar:lidarViewer:ColorVariation'));
            this.ColorVariationLabel=matlab.ui.internal.toolstrip.Label(labelId);
            this.ColorVariationLabel.Tag='ColorVariationLabel';
            this.ColorVariationLabel.Description=getString(message('lidar:lidarViewer:ColorVariationDescription'));

            labelId=getString(message('lidar:lidarViewer:Linear'));
            this.ColorVariationDropDown=matlab.ui.internal.toolstrip.DropDownButton(labelId);
            this.ColorVariationDropDown.Tag='ColorVariationDropdown';
            this.ColorVariationDropDown.Description=getString(message('lidar:lidarViewer:ColorVariationDescription'));

        end


        function createBackgroundColorButton(this)

            import matlab.ui.internal.toolstrip.Icon.*;
            labelId=getString(message('lidar:lidarViewer:BackgroundColor'));
            this.BackgroundColorButton=matlab.ui.internal.toolstrip.Button(labelId);
            this.BackgroundColorButton.Tag='backgroundColorbttn';
            this.BackgroundColorButton.Description=getString(message('lidar:lidarViewer:BackgroundColorDescription'));
        end



        function createPointSizeSpinner(this)

            import matlab.ui.internal.toolstrip.Icon.*;

            labelId=getString(message('lidar:lidarViewer:PointSize'));
            this.PointSizeLabel=matlab.ui.internal.toolstrip.Label(labelId);
            this.PointSizeLabel.Tag='pointSizeLabel';
            this.PointSizeLabel.Description=getString(message('lidar:lidarViewer:PointSizeDescription'));

            this.PointSizeSpinner=matlab.ui.internal.toolstrip.Spinner();
            this.PointSizeSpinner.DecimalFormat='0f';
            this.PointSizeSpinner.Limits=[1,100];
            this.PointSizeSpinner.Value=1;
            this.PointSizeSpinner.Tag='pointSizeSpinner';
            this.PointSizeSpinner.Description=getString(message('lidar:lidarViewer:PointSizeVal',this.PointSizeSpinner.Value));
        end
    end

end
