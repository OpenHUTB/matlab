function update(hObj,event)








    if strcmp(event,'switch_target')
        hParent=getParent(hObj);
        hConfigSet=getConfigSet(hObj);

        if~isempty(hParent)&&eq(hParent,hConfigSet)
            hCodeApp=getComponent(hParent,'Code Appearance');
            set(hCodeApp,'IgnoreCustomStorageClasses','off');
        end
    end
