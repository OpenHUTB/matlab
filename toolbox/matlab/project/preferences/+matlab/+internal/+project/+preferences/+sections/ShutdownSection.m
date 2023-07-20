classdef ShutdownSection<matlab.internal.project.preferences.sections.PreferencesSection




    methods
        function obj=ShutdownSection(panelGrid)
            obj=obj@matlab.internal.project.preferences.sections.PreferencesSection(...
            panelGrid,i_getMessage("Header"),2);

            shutdownSettings=settings().matlab.project.shutdown;

            unsavedFilesWarningPref=matlab.internal.project.preferences.widgets.BooleanWidget(...
            obj.SectionGrid,...
            i_getMessage("InterruptLabel"),...
            shutdownSettings.UnsavedFilesWarningEnabled);

            closeOpenFilesPref=matlab.internal.project.preferences.widgets.BooleanWidget(...
            obj.SectionGrid,...
            i_getMessage("CloseOpenFilesLabel"),...
            shutdownSettings.CloseSavedFilesEnabled);

            obj.Preferences=[...
unsavedFilesWarningPref
closeOpenFilesPref
            ];
        end
    end
end


function value=i_getMessage(resource)
    value=string(message("MATLAB:project:preferences:Shutdown"+resource));
end
