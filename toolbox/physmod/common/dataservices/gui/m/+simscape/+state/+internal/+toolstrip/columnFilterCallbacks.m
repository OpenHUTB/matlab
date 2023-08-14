function columnFilterCallbacks(cbinfo,columnId,filterValues,...
    selectedFilters,filter,actionId)






    pm_assert(~isempty(cbinfo));
    pm_assert(~isempty(columnId));

    obj=cbinfo.Context.Object;

    if~isempty(filter)
        pm_assert(numel(filterValues)>0);
        if cbinfo.EventData
            if~isKey(obj.ColumnToFilterMap,columnId)||isempty(obj.ColumnToFilterMap(columnId))
                obj.ColumnToFilterMap(columnId)={filter};
            else
                obj.ColumnToFilterMap(columnId)=[obj.ColumnToFilterMap(columnId);{filter}];
            end
        else
            if isKey(obj.ColumnToFilterMap,columnId)
                vals=obj.ColumnToFilterMap(columnId);
                vals(ismember(vals,filter))=[];
                obj.ColumnToFilterMap(columnId)=vals;
            end
        end
    end
    if~isempty(actionId)&&strcmpi(actionId,'apply')
        if~isKey(obj.ColumnToFilterMap,columnId)
            filters=selectedFilters;
        else
            filters=obj.ColumnToFilterMap(columnId)';
        end
        values={};
        for idx=1:numel(filters)
            values{idx}.value=filters{idx};%#ok<AGROW> 
        end
        criteria.columnId=columnId;
        criteria.values=values;

        simscape_variable_viewer_apply_filters(obj.ModelHandle,jsonencode(criteria));
        remove(obj.ColumnToFilterMap,columnId);
    end
end