function out=getComboBoxText(obj,tag)



    js=sprintf('ddg.getComboBoxText("%s")',tag);
    out=obj.evalJS(js);


