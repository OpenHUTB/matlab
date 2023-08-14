function xmlDoc=type2xml(itc,userDefined,inputNames,xmlDoc,rootElement)


    serializer=coder.internal.TypeSerializerStrategy.create();

    if nargin==3
        xmlDoc=serializer.createXMLDocument('Input');
        rootElement=serializer.getXMLRootNode();
    end

    serializer.setUserDefined(userDefined);
    serializer.serialize(xmlDoc,rootElement,itc,inputNames);

end

