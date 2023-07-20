function setFormalTitlePlacement(this,formalType,titleLoc,dlgH)




    if isnumeric(titleLoc)


        if titleLoc==0
            titleLoc='before';
        else
            titleLoc='after';
        end
    end

    try
        if rptgen.use_java
            com.mathworks.toolbox.rptgen.xml.StylesheetEditor.setFormalTitlePlacement(this.JavaHandle,...
            formalType,titleLoc);
        else
            mlreportgen.re.internal.ui.StylesheetEditor.setFormalTitlePlacement(this.JavaHandle,...
            formalType,titleLoc);
        end
    catch ME
        warning(ME.message);
    end

    if nargin>3
        this.dlgUpdatePreview(dlgH);
    end