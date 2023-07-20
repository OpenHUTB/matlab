classdef(Sealed=true)JavaTypeSerializer<coder.internal.TypeSerializerStrategy
    methods(Access=public)
        function doc=createXMLDocument(obj,name)
            obj.xmlDoc=com.mathworks.xml.XMLUtils.createDocument(name);
            doc=obj.xmlDoc;
        end

        function node=createXMLNode(obj,name)
            node=obj.xmlDoc.createElement(name);
        end

        function node=getXMLRootNode(obj)
            node=obj.xmlDoc.getDocumentElement;
        end

        function setXMLNodeTextContent(obj,node,content)
            node.appendChild(obj.xmlDoc.createTextNode(content));
        end

        function setXMLNodeAttribute(~,node,attr,value)
            node.setAttribute(attr,value);
        end

        function appendXMLNodeChild(~,parent,child)
            parent.appendChild(child);
        end

        function xml=writeXML(obj)
            xml=xmlwrite(obj.xmlDoc);
        end
    end
end