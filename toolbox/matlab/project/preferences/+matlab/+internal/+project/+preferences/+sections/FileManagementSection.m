classdef FileManagementSection<matlab.internal.project.preferences.sections.PreferencesSection




    methods
        function obj=FileManagementSection(panelGrid)
            obj=obj@matlab.internal.project.preferences.sections.PreferencesSection(...
            panelGrid,i_getMessage("Header"),1);

            refactoring=settings().matlab.project.refactoring;

            preferences=matlab.internal.project.preferences.widgets.PreferenceWidget.empty(1,0);

            preferences(end+1)=matlab.internal.project.preferences.widgets.BooleanWidget(...
            obj.SectionGrid,...
            i_getMessage("RefactoringEnabled"),...
            refactoring.AutoRenameEnabled);

            if i_isSimulinkInstalled()
                preferences(end+1)=matlab.internal.project.preferences.widgets.BooleanWidget(...
                obj.SectionGrid,...
                i_getMessage("BusRefactoringEnabled"),...
                refactoring.BusRenameEnabled);
            end

            preferences(end+1)=matlab.internal.project.preferences.widgets.MultipleChoiceWidget(...
            obj.SectionGrid,...
            i_getMessage("PathRefactoringLabel"),...
            ["yes","ask","no"],...
            arrayfun(@i_getMessage,"PathRefactoring"+["Yes","Ask","No"]),...
            refactoring.AutomaticallyRefactorPath);

            obj.Preferences=preferences;
        end
    end
end


function value=i_getMessage(resource)
    value=string(message("MATLAB:project:preferences:FileManagement"+resource));
end

function installed=i_isSimulinkInstalled()
    finder=dependencies.internal.analysis.toolbox.ToolboxFinder;
    sl=finder.fromBaseCode("SL");
    installed=sl.IsInstalled;
end
