classdef GitPanel<handle




    properties(Access=public)
        UIFigure(1,1);
        Sections(1,:)matlab.internal.cmlink.preferences.sections.PreferencesSection;
    end

    methods(Access=public)
        function obj=GitPanel()
            import matlab.internal.cmlink.git.preferences.sections.CredentialsSection
            import matlab.internal.cmlink.git.preferences.sections.SSHSection
            import matlab.internal.cmlink.git.preferences.sections.UserInfoSection
            import matlab.internal.cmlink.git.preferences.sections.WindowsSection

            obj.UIFigure=uifigure;
            panelGrid=uigridlayout(obj.UIFigure);
            panelGrid.RowHeight="fit";
            panelGrid.ColumnWidth="1x";

            obj.Sections=[UserInfoSection(panelGrid)];
            obj.Sections=[obj.Sections,CredentialsSection(panelGrid)];
            obj.Sections=[obj.Sections,SSHSection(panelGrid)];
            if ispc
                obj.Sections=[obj.Sections,WindowsSection(panelGrid)];
            end

            panelGrid.RowHeight=repmat("fit",1,length(obj.Sections));
        end

        function result=commit(obj)
            try
                arrayfun(@(section)section.commit,obj.Sections);
                result=true;
            catch ME
                result=false;
            end
        end

        function delete(obj)
            delete(obj.UIFigure);
        end
    end
end
