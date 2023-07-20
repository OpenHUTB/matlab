function previewText=dlgUpdatePreview(this,dlgH)




    try
        if rptgen.use_java
            previewText=char(com.mathworks.toolbox.rptgencore.tools.StylesheetMaker.previewParameter(this.JavaHandle));%#ok<JAPIMATHWORKS> 
        else
            previewText=mlreportgen.re.internal.db.StylesheetMaker.previewParameter(this.JavaHandle);
        end

    catch ME
        previewText=ME.message;
    end

    if nargin>1
        dlgH.setWidgetValue('XmlPreview',previewText);
    end


