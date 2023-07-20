function xmlStr=saveFormat(format)
    factory=javax.xml.parsers.DocumentBuilderFactory.newInstance();
    builder=factory.newDocumentBuilder();
    formatDoc=builder.newDocument();
    format.save(formatDoc);
    writer=java.io.StringWriter();
    com.mathworks.xml.XMLUtils.serializeXML(formatDoc,writer);
    xmlStr=char(writer.toString());
end


