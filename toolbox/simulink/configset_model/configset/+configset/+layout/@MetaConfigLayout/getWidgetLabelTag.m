function tag=getWidgetLabelTag(obj,name,cs)


    [group,index]=obj.getWidgetGroup(name,false);
    if group.ChildNeedsLabel(index)
        w=group.Children{index};
        if ischar(w)
            adp=configset.internal.getConfigSetAdapter(cs);
            w=obj.MetaCS.findWidget(w,adp,cs);
        end
        tag=w.getTag(cs);
        tag=[tag,'Lbl'];
    else
        tag='';
    end

