function initToolStr=getInitToolStr(obj)



    if obj.hAvailableToolList.isToolListEmpty
        initToolStr=obj.NoAvailableToolStr;
    else
        initToolStr=obj.EmptyToolStr;
    end
end
