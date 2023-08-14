function dirtyWidget(obj,id,dirty)


    js=sprintf('api.dirtyWidget(''%s'', %d)',id,dirty);
    obj.evalJS(js);

