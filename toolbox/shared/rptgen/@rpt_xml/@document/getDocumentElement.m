function out=getDocumentElement(d)




    if rptgen.use_java
        out=javaMethod(mfilename,java(d));
    else
        out=getDocumentElement(d.Document);
    end