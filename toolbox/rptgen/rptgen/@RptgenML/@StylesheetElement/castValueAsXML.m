function castValueAsXML(this,javaHandle,propName)





    this.Casted=true;

    if nargin<2
        javaHandle=this.JavaHandle;
    end
    if nargin<3
        propName='Value';
    end

    txtElement=javaHandle.getOwnerDocument.createElement('xsl:text');
    txtElement.appendChild(javaHandle.getOwnerDocument.createTextNode(this.(propName)));

    if rptgen.use_java
        com.mathworks.toolbox.rptgencore.tools.StylesheetMaker.setParameter(javaHandle,txtElement);
    else
        mlreportgen.internal.re.db.StylesheetMaker.setParameter(javaHandle,txtElement);
    end


    this.ErrorMessage='';



