function out=getWidgetValue(obj,tag)


    js=sprintf('ddg.getWidgetValue("%s")',tag);
    out=obj.evalJS(js);
