function notify_reallocation(alloc_obj,resource,value)












    if isa(alloc_obj.realloc_callback,'function_handle')...
        ||(isa(alloc_obj.realloc_callback,'cell')&&...
        isa(alloc_obj.realloc_callback{1},'function_handle'))













        savedWarningState=warning;
        [savedLastMsg,savedLastId]=lastwarn;
        warning off;

        if isa(alloc_obj.realloc_callback,'function_handle')
            feval(alloc_obj.realloc_callback,alloc_obj.host_object,...
            resource,value);
        else
            feval(alloc_obj.realloc_callback{1},alloc_obj.host_object,...
            resource,value,alloc_obj....
            realloc_callback{2:end});
        end
        lastwarn(savedLastMsg,savedLastId);
        warning(savedWarningState)
    else
        error(message('TargetSupportPackage:target:InvalidAutoAllocationObj'));
    end
