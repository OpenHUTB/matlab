classdef PreferencesSection<matlab.mixin.Heterogeneous&handle




    properties
        SectionGrid;
    end

    methods
        function obj=PreferencesSection(container,headerText,nPrefs)
            obj=obj@handle;
            obj.SectionGrid=uigridlayout(container);
            obj.SectionGrid.RowHeight=repmat("fit",1,nPrefs+1);
            obj.SectionGrid.ColumnWidth=repmat("1x",1,1);

            header=uilabel(obj.SectionGrid);
            header.Text=headerText;
            header.FontWeight="bold";
        end
    end

    methods(Abstract)
        commit(obj)
    end
end
