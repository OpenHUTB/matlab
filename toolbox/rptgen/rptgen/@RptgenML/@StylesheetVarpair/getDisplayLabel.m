function dLabel=getDisplayLabel(this)




    if isempty(this.JavaHandle)
        dLabel=['[[','undefined',']]'];
    elseif isLibrary(this)
        if rptgen.use_java
            dLabel=char(com.mathworks.toolbox.rptgen.xml.StylesheetEditor.formatVarpairDisplayID(this.JavaHandle));
        else
            dLabel=mlreportgen.re.internal.ui.StylesheetEditor.formatVarpairDisplayID(this.JavaHandle);
        end
    else
        if rptgen.use_java
            dLabel=char(com.mathworks.toolbox.rptgen.xml.StylesheetEditor.formatVarpairDisplayLabel(this.JavaHandle));
        else
            dLabel=mlreportgen.re.internal.ui.StylesheetEditor.formatVarpairDisplayLabel(this.JavaHandle);
        end
    end
