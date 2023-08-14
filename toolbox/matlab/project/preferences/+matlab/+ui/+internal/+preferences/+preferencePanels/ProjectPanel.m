classdef ProjectPanel<handle




    properties(Access=public)
        UIFigure(1,1);
        Sections(1,:)matlab.internal.project.preferences.sections.PreferencesSection;
    end

    methods(Access=public)
        function obj=ProjectPanel()
            obj.UIFigure=uifigure;
            panelGrid=uigridlayout(obj.UIFigure);
            panelGrid.RowHeight="fit";
            panelGrid.ColumnWidth="fit";

            obj.Sections=[...
            matlab.internal.project.preferences.sections.NewProjectsSection(panelGrid)
            matlab.internal.project.preferences.sections.StartupSection(panelGrid)
            matlab.internal.project.preferences.sections.ShutdownSection(panelGrid)
            matlab.internal.project.preferences.sections.FileManagementSection(panelGrid)
            ];

            panelGrid.RowHeight=repmat("fit",1,length(obj.Sections));
        end

        function result=commit(obj)
            arrayfun(@(section)section.commit,obj.Sections);
            result=true;
        end

        function delete(obj)
            delete(obj.UIFigure);
        end
    end
end
