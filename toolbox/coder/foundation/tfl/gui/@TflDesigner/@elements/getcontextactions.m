function actions=getcontextactions(handle)%#ok




    persistent actionItems;

    if isempty(actionItems)

        actionItems={};
        actionItems{end+1}='EDIT_CUT';
        actionItems{end+1}='EDIT_COPY';
        actionItems{end+1}='EDIT_PASTE';
        actionItems{end+1}='SEPARATOR';
        actionItems{end+1}='EDIT_DELETE';
        actionItems{end+1}='SEPARATOR';
        actionItems{end+1}='EDIT_COPYBUILDINFO';
        actionItems{end+1}='EDIT_PASTEBUILDINFO';
        actionItems{end+1}='SEPARATOR';
        actionItems{end+1}='VALIDATE_ENTRY';
    end

    actions=actionItems;


