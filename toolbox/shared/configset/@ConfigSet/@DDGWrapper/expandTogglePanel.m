function out=expandTogglePanel(obj,id,bool)



    js=sprintf('ddg.expandTogglePanel("%s", %s)',id,jsonencode(bool));
    out=obj.evalJS(js);


