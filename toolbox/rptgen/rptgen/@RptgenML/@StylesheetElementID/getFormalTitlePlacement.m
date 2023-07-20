function titleLoc=getFormalTitlePlacement(this,formalType)




    try
        if rptgen.use_java
            titleLoc=char(com.mathworks.toolbox.rptgen.xml.StylesheetEditor.getFormalTitlePlacement(this.JavaHandle,...
            formalType));
        else
            titleLoc=mlreportgen.re.internal.ui.StylesheetEditor.getFormalTitlePlacement(this.JavaHandle,...
            formalType);
        end
    catch ME
        warning(ME.message);
        titleLoc='above';
    end