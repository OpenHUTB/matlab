function onFocusChange(obj,~)













    obj.focusFcnCallCounter=obj.focusFcnCallCounter+1;
    if obj.focusFcnCallCounter==1&&isempty(obj.studio.getActiveComponent)
        sfprivate('eml_man','update_data',obj.objectId);
    end

    if obj.focusFcnCallCounter==2
        obj.focusFcnCallCounter=0;
    end
end