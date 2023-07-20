classdef ParametersPanel<slrealtime.internal.guis.Explorer.ContentsPanel




    methods(Access=public)


        function this=ParametersPanel(hApp,huifigure)
            this=this@slrealtime.internal.guis.Explorer.ContentsPanel(hApp,huifigure);
        end

    end


    methods(Access=protected)

        function FilterContentsEditFieldValueChanged(app,EditField,event)
            value=app.FilterContentsEditField.Value;

            selectedTargetName=app.App.TargetManager.getSelectedTargetName();
            target=app.App.TargetManager.getTargetFromMap(selectedTargetName);
            target.filters.parametersFilterContents=value;
            app.App.TargetManager.targetMap(selectedTargetName)=target;

            app.App.UpdateApp.ForTargetApplicationParametersFilterContents();
            app.App.UpdateApp.ForTargetApplicationParameters(selectedTargetName);
        end

    end

end
