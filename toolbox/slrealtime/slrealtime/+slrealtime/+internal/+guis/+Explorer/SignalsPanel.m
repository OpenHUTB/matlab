classdef SignalsPanel<slrealtime.internal.guis.Explorer.ContentsPanel




    methods(Access=public)


        function this=SignalsPanel(hApp,huifigure)
            this=this@slrealtime.internal.guis.Explorer.ContentsPanel(hApp,huifigure);
        end

    end


    methods(Access=protected)

        function FilterContentsEditFieldValueChanged(app,EditField,event)
            value=app.FilterContentsEditField.Value;

            selectedTargetName=app.App.TargetManager.getSelectedTargetName();
            target=app.App.TargetManager.getTargetFromMap(selectedTargetName);
            target.filters.signalsFilterContents=value;
            app.App.TargetManager.targetMap(selectedTargetName)=target;

            app.App.UpdateApp.ForTargetApplicationSignalsFilterContents();
            app.App.UpdateApp.ForTargetApplicationSignals(selectedTargetName);
        end

    end

end
