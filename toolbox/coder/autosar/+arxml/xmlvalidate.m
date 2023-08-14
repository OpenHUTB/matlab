function[valid,errMsg,errStruct]=xmlvalidate(xmlfile,namespaceXsd,versionXsd)



















    valid=true;
    errMsg='';

    parser=matlab.io.xml.dom.Parser;


    parser.Configuration.EntityResolver=...
    arxml.SchemaDefinitionResolver(namespaceXsd,versionXsd);


    errorHandler=arxml.ARXMLValidationErrorHandler;
    parser.Configuration.ErrorHandler=...
    errorHandler;
    parser.Configuration.Validate=true;
    parser.Configuration.Schema=true;
    parser.Configuration.Namespaces=true;
    parser.Configuration.LoadSchema=true;
    parser.parseFile(xmlfile);

    errStruct=errorHandler.Errors;

    if~isempty(errStruct)
        valid=false;
        errMsg=errorHandler.getFormattedErrorMessage(xmlfile);
    end


