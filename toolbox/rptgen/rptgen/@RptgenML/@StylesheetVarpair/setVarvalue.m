function valueStored=setVarvalue(h,proposedValue)




    valueStored='';
    if rptgen.use_java
        com.mathworks.toolbox.rptgen.xml.StylesheetEditor.setVarpairValue(h.JavaHandle,proposedValue);
    else
        mlreportgen.re.internal.ui.StylesheetEditor.setVarpairValue(h.JavaHandle,proposedValue);
    end
