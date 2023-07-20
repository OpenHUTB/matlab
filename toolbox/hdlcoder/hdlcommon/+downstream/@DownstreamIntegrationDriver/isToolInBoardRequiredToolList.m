function isIn=isToolInBoardRequiredToolList(obj,toolName,boardName)



    requiredToolList=obj.getRequiredTool(boardName);
    isIn=any(strcmpi(requiredToolList,toolName));
end
