function setWidgetValue(obj,tag,val)


    json=jsonencode(val);
    js=sprintf('ddg.setWidgetValue("%s", %s)',tag,json);
    obj.evalJS(js);
