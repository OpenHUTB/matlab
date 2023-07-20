function result=isModelDirty(bdHandle,includeDirtySSRefs)




    if(strcmp(get_param(bdHandle,'dirty'),'on')||...
        (includeDirtySSRefs&&~isempty(slInternal('getAllDirtySSRefBDs',bdHandle))))
        result=true;
        return;
    end
    result=false;
end
