classdef XmlWriter<plccore.util.BaseWriter





    properties(Access=protected)
XmlDoc
    end

    methods
        function obj=XmlWriter(doc_name)
            obj.Kind='XmlWriter';
            obj.XmlDoc=PLCCoder.PLCUtils.createXMLDoc(doc_name);
        end

        function ret=getDoc(obj)
            ret=obj.XmlDoc;
        end

        function root_node=getRoot(obj)
            root_node=obj.XmlDoc.getDocumentElement();
        end

        function el_node=createElement(obj,el_name)
            el_node=obj.XmlDoc.createElement(el_name);
        end

        function txt_node=createText(obj,txt)
            txt_node=obj.XmlDoc.createCDATASection(txt);
        end

        function new_code=fixCode(obj,code)%#ok<INUSL>
            new_code=strrep(code,'&lt;','<');
            new_code=strrep(new_code,'&gt;','>');
            new_code=strrep(new_code,'__','ZZ');
        end

        function writeFile(obj,file_dir,file_name)
            xml=plcprivate('plc_dom_write',obj.XmlDoc);
            code=obj.fixCode(xml);
            obj.writeFileStr(file_dir,file_name,code);
        end

        function addChild(obj,parent,child)%#ok<INUSL>
            parent.appendChild(child);
        end
    end
end


