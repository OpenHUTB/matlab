function castValueAsString(this,javaHandle,propName)








    this.Casted=true;

    if nargin<2
        javaHandle=this.JavaHandle;
    end
    if nargin<3
        propName='Value';
    end

    if rptgen.use_java
        xValue=com.mathworks.toolbox.rptgen.xml.StylesheetEditor.getParameter(javaHandle);
        tValue=com.mathworks.toolbox.rptgencore.tools.RgXmlUtils.getNodeText(xValue);

        com.mathworks.toolbox.rptgen.xml.StylesheetEditor.setParameter(javaHandle,tValue);
        this.(propName)=char(tValue);
    else
        xValue=mlreportgen.re.internal.ui.StylesheetEditor.getParameter(javaHandle);
        tValue=xValue.TextContent;

        mlreportgen.re.internal.ui.StylesheetEditor.setParameter(javaHandle,tValue);
        this.(propName)=char(tValue);
    end
    this.ErrorMessage='';
