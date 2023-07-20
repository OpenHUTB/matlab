function hideWidgets(obj,ids)


    if~iscell(ids)
        ids={ids};
    end

    if~obj.batchMode
        js=sprintf('ddg.hideWidgets(%s)',jsonencode(ids));
        obj.evalJS(js);
    end

    obj.customized.hidden=union(obj.customized.hidden,ids);
