classdef(Sealed=true)JavaFreeTypeSerializer<coder.internal.TypeSerializerStrategy
    methods(Access=public)
        function doc=createXMLDocument(obj,name)
            obj.xmlDoc=matlab.io.xml.dom.Document(name);
            doc=obj.xmlDoc;
        end

        function node=createXMLNode(obj,name)
            node=obj.xmlDoc.createElement(name);
        end

        function node=getXMLRootNode(obj)
            node=obj.xmlDoc.getDocumentElement();
        end

        function setXMLNodeTextContent(~,node,content)
            node.setTextContent(content);
        end

        function setXMLNodeAttribute(~,node,attr,value)
            node.setAttributeNode(obj.xmlDoc.createAttribute(attr));
            node.setAttribute(attr,value);
        end

        function appendXMLNodeChild(~,parent,child)
            parent.appendChild(child);
        end

        function xml=writeXML(obj)%#ok<STOUT> 

            w=matlab.io.xml.dom.DOMWriter;
            w.Configuration.FormatPrettyPrint=true;
            w.Configuration.XMLDeclaration=false;
            w.writeToFile(obj.xmlDoc,obj.fileName);
        end
    end
end