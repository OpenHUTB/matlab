function varargout=p_config_xml_adapter(methodName,varargin)





    [varargout{1:nargout}]=feval(['i_',methodName],varargin{1:end});

end



function i_set_options(slHandle,xmlOpts)

    set_param(bdroot(slHandle),'AutosarSchemaVersion',xmlOpts.SchemaVersion);
    dataobj=autosar.api.getAUTOSARProperties(bdroot(slHandle),true);
    dataobj.set('XmlOptions','InterfacePackage',xmlOpts.InterfacePackage);
    dataobj.set('XmlOptions','DataTypePackage',xmlOpts.DataTypePackage);
    dataobj.set('XmlOptions','ImplementationQualifiedName',xmlOpts.ImplementationName);
    dataobj.set('XmlOptions','InternalBehaviorQualifiedName',xmlOpts.BehaviorName);
    dataobj.set('XmlOptions','ComponentQualifiedName',xmlOpts.ComponentName);

end



function xmlOpts=i_get_options(slHandle)


    xmlOpts.SchemaVersion=get_param(bdroot(slHandle),'AutosarSchemaVersion');
    dataobj=autosar.api.getAUTOSARProperties(bdroot(slHandle),true);
    xmlOpts.InterfacePackage=dataobj.get('XmlOptions','InterfacePackage');
    xmlOpts.DataTypePackage=dataobj.get('XmlOptions','DataTypePackage');
    xmlOpts.ImplementationName=dataobj.get('XmlOptions','ImplementationQualifiedName');
    xmlOpts.BehaviorName=dataobj.get('XmlOptions','InternalBehaviorQualifiedName');
    xmlOpts.ComponentName=dataobj.get('XmlOptions','ComponentQualifiedName');
    xmlOpts.ArxmlPackaging=dataobj.get('XmlOptions','ArxmlFilePackaging');

end


