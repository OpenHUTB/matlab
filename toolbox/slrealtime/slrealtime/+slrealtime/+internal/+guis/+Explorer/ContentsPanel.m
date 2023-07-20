classdef ContentsPanel<matlab.apps.AppBase





    properties(Access=public)
App
        UIFigure matlab.ui.Figure
        GridLayout matlab.ui.container.GridLayout
        Panel matlab.ui.container.Panel
        TopGridLayout matlab.ui.container.GridLayout
        FilterCurrentSystemAndBelowButton matlab.ui.control.StateButton
        FilterContentsOfLabel matlab.ui.control.Label
        FilterSystemLabel matlab.ui.control.Label
        SearchImage matlab.ui.control.Image
        FilterContentsEditField matlab.ui.control.EditField
    end


    methods(Access=public)


        function this=ContentsPanel(hApp,huifigure)
            this.App=hApp;



            this.UIFigure=huifigure;
            this.UIFigure.Visible='off';






            this.GridLayout=uigridlayout(this.UIFigure);
            this.GridLayout.ColumnWidth={'1x'};
            this.GridLayout.RowHeight={35,'4x'};


            this.Panel=uipanel(this.GridLayout);
            this.Panel.Layout.Row=1;
            this.Panel.Layout.Column=1;


            this.TopGridLayout=uigridlayout(this.Panel);
            this.TopGridLayout.ColumnWidth={28,66,'1x',28,160};
            this.TopGridLayout.RowHeight={'1x'};
            this.TopGridLayout.ColumnSpacing=1;
            this.TopGridLayout.RowSpacing=1;
            this.TopGridLayout.Padding=[1,1,1,1];


            this.FilterCurrentSystemAndBelowButton=uibutton(this.TopGridLayout,'state');
            this.FilterCurrentSystemAndBelowButton.ValueChangedFcn=@this.FilterCurrentSystemAndBelowButtonValueChanged;
            this.FilterCurrentSystemAndBelowButton.Icon=this.App.Icons.currentSystemIcon;
            this.FilterCurrentSystemAndBelowButton.Text='';
            this.FilterCurrentSystemAndBelowButton.Layout.Row=1;
            this.FilterCurrentSystemAndBelowButton.Layout.Column=1;


            this.FilterContentsOfLabel=uilabel(this.TopGridLayout);
            this.FilterContentsOfLabel.Layout.Row=1;
            this.FilterContentsOfLabel.Layout.Column=2;
            this.FilterContentsOfLabel.Text=getString(message(this.App.Messages.filterContentsOfLabelTextMsgId));


            this.FilterSystemLabel=uilabel(this.TopGridLayout);
            this.FilterSystemLabel.FontWeight='bold';
            this.FilterSystemLabel.Layout.Row=1;
            this.FilterSystemLabel.Layout.Column=3;
            this.FilterSystemLabel.Text='';


            this.SearchImage=uiimage(this.TopGridLayout);
            this.SearchImage.ScaleMethod='none';
            this.SearchImage.Layout.Row=1;
            this.SearchImage.Layout.Column=4;
            this.SearchImage.ImageSource=this.App.Icons.searchIcon;


            this.FilterContentsEditField=uieditfield(this.TopGridLayout,'text');
            this.FilterContentsEditField.ValueChangedFcn=@this.FilterContentsEditFieldValueChanged;
            this.FilterContentsEditField.Layout.Row=1;
            this.FilterContentsEditField.Layout.Column=5;


            this.UIFigure.Visible='on';
        end

        function enable(app)
            app.FilterCurrentSystemAndBelowButton.Enable='on';

            app.FilterCurrentSystemAndBelowButton.Icon=app.App.Icons.currentSystemIcon;
            app.FilterContentsOfLabel.Enable='on';
            app.FilterSystemLabel.Enable='on';
            app.FilterContentsEditField.Enable='on';
        end

        function disable(app)

            app.FilterCurrentSystemAndBelowButton.Enable='off';
            app.FilterCurrentSystemAndBelowButton.Icon=app.App.Icons.currentSystemIcon;
            app.FilterContentsOfLabel.Enable='off';
            app.FilterSystemLabel.Enable='off';
            app.FilterContentsEditField.Enable='off';

        end

    end


    methods(Access=protected)

        function FilterCurrentSystemAndBelowButtonValueChanged(app,Button,event)
            value=app.FilterCurrentSystemAndBelowButton.Value;

            selectedTargetName=app.App.TargetManager.getSelectedTargetName();
            target=app.App.TargetManager.getTargetFromMap(selectedTargetName);
            target.filters.currentSystemAndBelow=value;
            app.App.TargetManager.targetMap(selectedTargetName)=target;

            app.App.UpdateApp.ForTargetApplicationFilterButton();
            app.App.UpdateApp.ForTargetApplicationSignals(selectedTargetName);
            app.App.UpdateApp.ForTargetApplicationParameters(selectedTargetName);

        end

        function FilterContentsEditFieldValueChanged(app,EditField,event)

        end

    end


end
