classdef View<matlab.apps.AppBase








    properties(Access=public)
        UIFigure matlab.ui.Figure
        GridLayout matlab.ui.container.GridLayout
        UIAxes matlab.ui.control.UIAxes
        VoltageSlider matlab.ui.control.Slider
        VoltageSliderLabel matlab.ui.control.Label
        TemperatureSlider matlab.ui.control.Slider
        TemperatureSliderLabel matlab.ui.control.Label
    end


    methods(Access=public)

        function app=View()

            app.createComponents()
        end
    end


    methods(Access=private)

        function createComponents(app)


            app.UIFigure=uifigure();
            app.UIFigure.Visible='off';
            app.UIFigure.Position=[100,100,640,640];


            app.GridLayout=uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth={'1x','3x'};
            app.GridLayout.RowHeight={'7x','1x','1x'};


            app.UIAxes=uiaxes(app.GridLayout);
            title(app.UIAxes,getString(message('physmod:ee:library:comments:utils:mask:plotMotorDriveEfficiencyMap:title_UIAxes')));
            xlabel(app.UIAxes,getString(message('physmod:ee:library:comments:utils:mask:plotMotorDriveEfficiencyMap:xlabel_UIAxes')));
            ylabel(app.UIAxes,getString(message('physmod:ee:library:comments:utils:mask:plotMotorDriveEfficiencyMap:ylabel_UIAxes')));
            app.UIAxes.Layout.Row=1;
            app.UIAxes.Layout.Column=[1,2];


            app.VoltageSlider=uislider(app.GridLayout);
            app.VoltageSlider.Visible='off';
            app.VoltageSlider.Layout.Row=2;
            app.VoltageSlider.Layout.Column=2;


            app.VoltageSliderLabel=uilabel(app.GridLayout);
            app.VoltageSliderLabel.HorizontalAlignment='right';
            app.VoltageSliderLabel.Text=getString(message('physmod:ee:library:comments:utils:mask:plotMotorDriveEfficiencyMap:label_VoltageSlider'));
            app.VoltageSliderLabel.Visible='off';
            app.VoltageSliderLabel.Layout.Row=2;
            app.VoltageSliderLabel.Layout.Column=1;


            app.TemperatureSlider=uislider(app.GridLayout);
            app.TemperatureSlider.Visible='off';
            app.TemperatureSlider.Layout.Row=3;
            app.TemperatureSlider.Layout.Column=2;


            app.TemperatureSliderLabel=uilabel(app.GridLayout);
            app.TemperatureSliderLabel.HorizontalAlignment='right';
            app.TemperatureSliderLabel.Text=getString(message('physmod:ee:library:comments:utils:mask:plotMotorDriveEfficiencyMap:label_TemperatureSlider'));
            app.TemperatureSliderLabel.Visible='off';
            app.TemperatureSliderLabel.Layout.Row=3;
            app.TemperatureSliderLabel.Layout.Column=1;

        end
    end
end



