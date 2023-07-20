function disableWidgets(obj,ids)


    if~iscell(ids)
        ids={ids};
    end

    if~obj.batchMode
        js=sprintf('ddg.disableWidgets(%s)',jsonencode(ids));
        obj.evalJS(js);
    end

    obj.customized.disabled=union(obj.customized.disabled,ids);

