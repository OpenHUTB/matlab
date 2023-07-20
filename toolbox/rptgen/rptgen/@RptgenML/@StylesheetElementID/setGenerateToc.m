function setGenerateToc(this,sectionType,genType,isGenerated,dlgH)




    try
        if rptgen.use_java
            com.mathworks.toolbox.rptgen.xml.StylesheetEditor.setGenerateToc(this.JavaHandle,...
            sectionType,genType,isGenerated);
        else
            mlreportgen.re.internal.db.StylesheetEditor.setGenerateToc(this.JavaHandle,...
            sectionType,genType,isGenerated);
        end
    catch ME
        warning(ME.message);
    end

    if nargin>4
        this.dlgUpdatePreview(dlgH);
    end