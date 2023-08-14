function format=loadFormat(xmlStr)
    reader=java.io.StringReader(xmlStr);
    src=org.xml.sax.InputSource(reader);
    factory=javax.xml.parsers.DocumentBuilderFactory.newInstance();
    builder=factory.newDocumentBuilder();
    doc=builder.parse(src);
    elFormat=doc.getDocumentElement();
    format=Rptgen.TitlePage.Format.load(elFormat);
end


