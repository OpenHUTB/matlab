function cp=parseComponentXml(xmlFile,varargin)





    cp=configset.internal.data.Component;
    cp.parse(xmlFile,varargin{:});
