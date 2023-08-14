function tf=togglePanelHandler(methodOrDialog,tagName,toggleState)




    tf=false;

    persistent statusMap

    if isempty(statusMap)
        statusMap=containers.Map('KeyType','char','ValueType','logical');
    end

    if isempty(tagName)

        return;
    end

    if isa(methodOrDialog,'DAStudio.Dialog')

        statusMap(tagName)=toggleState;
        methodOrDialog.refresh
        return;
    end

    switch methodOrDialog
    case 'get'
        if isKey(statusMap,tagName)
            tf=statusMap(tagName);
        else


            tf=toggleState;
            statusMap(tagName)=tf;
        end
    case 'set'
        statusMap(tagName)=toggleState;
    case 'clear'
        statusMap.remove(statusMap.keys);
    end
end
