classdef PreferencesSection<matlab.mixin.Heterogeneous




    properties
        SectionGrid;
        Preferences(1,:)matlab.internal.project.preferences.widgets.PreferenceWidget;
    end

    methods
        function obj=PreferencesSection(container,headerText,nPrefs)
            obj.SectionGrid=matlab.internal.project.preferences.utils.makeFitGridLayout(container,nPrefs+1,1);

            header=uilabel(obj.SectionGrid);
            header.Text=headerText;
            header.FontWeight="bold";
        end

        function commit(obj)
            arrayfun(@(pref)pref.commit(),obj.Preferences);
        end
    end
end
