function pane=getPaneDisplay(obj,id)



    key=obj.getGroup(id).Key;


    if contains(key,':')&&~contains(key,' ')
        pane=configset.internal.getMessage(key);
    else
        pane=key;
    end
end