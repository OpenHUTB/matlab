function expandItems=getExpandTreeItems(this,currentItem,modelName,type)
    expandItems={currentItem};
    if~contains(currentItem,modelName)
        return;
    end
    while~strcmp(currentItem,modelName)
        if type==0
            currentItem=get_param(currentItem,'Parent');
        else
            currentItem=fileparts(currentItem);
        end
        expandItems=[currentItem,expandItems];%#ok
    end
end