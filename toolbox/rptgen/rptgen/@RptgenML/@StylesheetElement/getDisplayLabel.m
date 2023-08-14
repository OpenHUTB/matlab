function dLabel=getDisplayLabel(this)




    if isempty(this.JavaHandle)
        dLabel=['[[','undefined',']]'];
    elseif isLibrary(this)
        if rptgen.use_java
            dLabel=char(com.mathworks.toolbox.rptgen.xml.StylesheetEditor.formatParameterDisplayID(this.JavaHandle));
        else
            dLabel=mlreportgen.re.internal.ui.StylesheetEditor.formatParameterDisplayID(this.JavaHandle);
        end
    else
        if rptgen.use_java
            dLabel=char(com.mathworks.toolbox.rptgen.xml.StylesheetEditor.formatParameterDisplayLabel(this.JavaHandle));
        else
            dLabel=mlreportgen.re.internal.ui.StylesheetEditor.formatParameterDisplayLabel(this.JavaHandle);
        end
    end
