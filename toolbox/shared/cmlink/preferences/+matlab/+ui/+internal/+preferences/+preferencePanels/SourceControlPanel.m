classdef SourceControlPanel<handle


    properties(Access=public)
        UIFigure(1,1);
        EnableJavaSourceControlAdapters;
    end

    methods(Access=public)
        function obj=SourceControlPanel()
            obj.UIFigure=uifigure;
            panelGrid=uigridlayout(obj.UIFigure);
            panelGrid.RowHeight="fit";
            panelGrid.ColumnWidth="1x";

            obj.EnableJavaSourceControlAdapters=uicheckbox(panelGrid);
            obj.EnableJavaSourceControlAdapters.Text=i_getMessage("EnableJavaSourceControlAdapters");
            obj.EnableJavaSourceControlAdapters.Value=...
            settings().matlab.sourcecontrol.EnableJavaSourceControlAdaptersInRemoteClient.ActiveValue;
        end

        function result=commit(obj)
            result=true;
            s=settings().matlab.sourcecontrol;
            s.EnableJavaSourceControlAdaptersInRemoteClient.PersonalValue=...
            obj.EnableJavaSourceControlAdapters.Value;
        end

        function delete(obj)
            delete(obj.UIFigure);
        end
    end
end

function value=i_getMessage(resource)
    value=string(message("shared_cmlink:preferences:"+resource));
end
