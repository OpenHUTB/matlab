function valueStored=setVarname(h,proposedValue)




    valueStored='';
    if rptgen.use_java
        com.mathworks.toolbox.rptgen.xml.StylesheetEditor.setVarpairID(h.JavaHandle,proposedValue);
    else
        mlreportgen.re.internal.ui.StylesheetEditor.setVarpairID(h.JavaHandle,proposedValue);
    end

