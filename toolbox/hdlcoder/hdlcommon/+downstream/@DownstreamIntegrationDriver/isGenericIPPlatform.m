function result=isGenericIPPlatform(obj)


    if obj.isIPWorkflow&&~obj.isBoardEmpty
        result=obj.hIP.isGenericIPPlatform;
    else
        result=false;
    end
end
