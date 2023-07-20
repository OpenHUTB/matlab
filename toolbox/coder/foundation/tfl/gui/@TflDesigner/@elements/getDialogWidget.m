function widget=getDialogWidget(handle,widgetTag,returnNode)






    widget='';
    if isempty(handle)
        return;
    end


    index=ismember(handle.widgetTagList,widgetTag);
    if sum(index(:))
        widgetNode=handle.widgetStructList(index);
    else
        widgetNode=handle.createDialogWidget(widgetTag);


        handle.setWidgetProperties(widgetNode.Tag);
    end

    if nargin<3
        returnNode=false;
    end


    if returnNode
        widget=widgetNode;
    else
        widget=struct(widgetNode);

        fieldsToRemove={'Path'};
        widget=rmfield(widget,fieldsToRemove);
    end

