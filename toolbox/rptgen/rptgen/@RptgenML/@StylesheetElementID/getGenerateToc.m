function isGenerated=getGenerateToc(this,sectionType,genType)




    try
        if rptgen.use_java
            isGenerated=com.mathworks.toolbox.rptgen.xml.StylesheetEditor.getGenerateToc(this.JavaHandle,...
            sectionType,genType);
        else
            isGenerated=mlreportgen.re.internal.ui.StylesheetEditor.getGenerateToc(this.JavaHandle,...
            sectionType,genType);
        end
    catch
        isGenerated=false;
    end
