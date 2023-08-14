function thisCopy=doCopy(this)




    if rptgen.use_java
        newJavaHandle=com.mathworks.toolbox.rptgen.xml.StylesheetEditor.copyParameter(this.JavaHandle);%#ok<JAPIMATHWORKS> 
    else
        newJavaHandle=mlreportgen.re.internal.ui.StylesheetEditor.copyParameter(this.JavaHandle);
    end

    thisClass=class(this);

    if(strcmp(thisClass,'RptgenML.StylesheetElement'))
        thisCopy=feval(thisClass);
        thisCopy.init([],newJavaHandle);
    else
        thisCopy=feval(thisClass,...
        [],...
        newJavaHandle);
    end

