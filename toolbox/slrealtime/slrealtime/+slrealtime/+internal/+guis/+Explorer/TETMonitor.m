classdef TETMonitor<matlab.apps.AppBase


    properties(Access=public)
        UIFigure matlab.ui.Figure
        GridLayout matlab.ui.container.GridLayout
        HTML matlab.ui.control.HTML
    end


    methods(Access=private)


        function createComponents(app)


            app.GridLayout=uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth={'1x'};
            app.GridLayout.RowHeight={'1x'};


            app.HTML=uihtml(app.GridLayout);
            app.HTML.Layout.Row=1;
            app.HTML.Layout.Column=1;
            app.HTML.HTMLSource=slrealtime.TETMonitor.getURL;


            app.UIFigure.Visible='on';
        end
    end


    methods(Access=public)


        function app=TETMonitor(huifigure)



            app.UIFigure=huifigure;
            app.UIFigure.Visible='off';

            createComponents(app)

            if nargout==0
                clear app
            end
        end
    end
end