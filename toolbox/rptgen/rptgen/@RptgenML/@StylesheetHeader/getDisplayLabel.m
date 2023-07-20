function dLabel=getDisplayLabel(this)




    if isempty(this.JavaHandle)
        dLabel=['[[',getString(message('rptgen:RptgenML_StylesheetHeader:undefinedLabel')),']]'];
    else
        if rptgen.use_java
            dLabel=char(com.mathworks.toolbox.rptgen.xml.StylesheetEditor.formatParameterDisplayID(this.JavaHandle));
        else
            dLabel=mlreportgen.re.internal.ui.StylesheetEditor.formatParameterDisplayID(this.JavaHandle);
        end
    end

