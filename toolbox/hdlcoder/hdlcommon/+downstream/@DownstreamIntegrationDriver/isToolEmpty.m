function result=isToolEmpty(obj)


    toolName=obj.get('Tool');
    result=strcmp(toolName,obj.EmptyToolStr)||strcmp(toolName,obj.NoAvailableToolStr);
end
