function columnCallbacks(cbInfo,userData,columnId,actionId)





    pm_assert(~isempty(cbInfo));



    if~all(isprop(cbInfo,'Context'))
        return;
    end


    pm_assert(~isempty(userData));

    obj=cbInfo.Context.Object;


    if nargin==3
        if cbInfo.EventData
            if~ismember(obj.VisibleColumns,columnId)
                obj.VisibleColumns{end+1}=columnId;
            end
        else
            obj.VisibleColumns(ismember(obj.VisibleColumns,columnId))=[];
        end
    else
        pm_assert(~isempty(actionId));
        if strcmpi(actionId,'apply')
            simscape_variable_viewer_show_columns(obj.ModelHandle,obj.VisibleColumns);
            obj.VisibleColumns={};
        end
    end
end