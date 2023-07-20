function out=getWidgetType(obj,tag)


    js=sprintf('ddg.getWidgetType("%s")',tag);
    out=obj.evalJS(js);

