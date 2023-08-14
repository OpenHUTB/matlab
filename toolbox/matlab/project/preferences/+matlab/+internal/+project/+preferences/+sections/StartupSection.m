classdef StartupSection<matlab.internal.project.preferences.sections.PreferencesSection




    methods
        function obj=StartupSection(panelGrid)
            obj=obj@matlab.internal.project.preferences.sections.PreferencesSection(...
            panelGrid,i_getMessage("Header"),1);

            obj.Preferences=matlab.internal.project.preferences.widgets.BooleanWidget(...
            obj.SectionGrid,...
            i_getMessage("DetectShadowedFilesLabel"),...
            settings().matlab.project.startup.DetectShadowedFilesEnabled);
        end
    end
end


function value=i_getMessage(resource)
    value=string(message("MATLAB:project:preferences:Startup"+resource));
end
