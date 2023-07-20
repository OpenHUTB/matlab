function out=getUserData(obj,tag)


    js=sprintf('ddg.getUserData("%s")',tag);
    out=obj.evalJS(js);




