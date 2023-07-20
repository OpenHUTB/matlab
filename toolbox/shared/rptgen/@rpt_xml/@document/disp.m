function disp(d)




    if rptgen.use_java
        disp(xmlwrite(java(d)));
    else
        writer=matlab.io.xml.dom.DOMWriter;
        str=writeToString(writer,d.Document);
        disp(str);
    end