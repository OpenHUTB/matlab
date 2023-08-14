function xmlwrite(d,fName)







    if nargin<2
        if rptgen.use_java
            fName=[tempname,'.',...
            char(com.mathworks.toolbox.rptgencore.output.OutputFormat.getExtension('db'))];
        else
            fName=[tempname,'.',...
            rptgen.internal.output.OutputFormat.getFileExtension('db')];
        end
    end

    if rptgen.use_java


        tfactory=javax.xml.transform.TransformerFactory.newInstance();
        serializer=tfactory.newTransformer();
        serializer.setOutputProperty(javax.xml.transform.OutputKeys.METHOD,'xml');
        serializer.setOutputProperty(javax.xml.transform.OutputKeys.INDENT,'yes');

        errorListener=com.mathworks.toolbox.rptgencore.tools.TransformErrorListenerRG;
        serializer.setErrorListener(errorListener);

        serializer.setOutputProperty(javax.xml.transform.OutputKeys.ENCODING,'UTF-8');

        serializer.transform(com.mathworks.xml.XMLUtils.transformSourceFactory(d),...
        com.mathworks.xml.XMLUtils.transformResultFactory(fName));
    else
        d.XMLEncoding='UTF-8';
        writer=matlab.io.xml.dom.DOMWriter;
        writer.Configuration.FormatPrettyPrint=true;
        writeToURI(writer,fName);
    end
