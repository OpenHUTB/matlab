classdef XMLParser<handle





    properties(Access=protected)
FilePath
XMLDoc
    end

    methods
        function obj=XMLParser(file_path)
            obj.FilePath=file_path;
            obj.XMLDoc=PLCCoder.PLCUtils.parseXMLDoc(obj.FilePath);
        end

        function ret=root(obj)
            ret=obj.XMLDoc.getDocumentElement;
        end

        function ret=name(obj,node)%#ok<INUSL>
            ret=char(node.getNodeName);
        end

        function ret=hasAttrib(obj,node,name)%#ok<INUSL>
            ret=node.hasAttribute(name);
        end

        function ret=attrib(obj,node,name)
            assert(obj.hasAttrib(node,name));
            ret=char(node.getAttribute(name));
        end

        function ret=childList(obj,node)%#ok<INUSL>
            child_list=node.getChildNodes;
            child_list_sz=child_list.getLength;
            ret=cell(1,child_list_sz);
            for i=0:child_list_sz-1
                ret{i+1}=child_list.item(i);
            end
        end

        function visitChildren(obj,node,fh)
            child_list=obj.childList(node);
            for i=1:length(child_list)
                child=child_list{i};
                fh(child);
            end
        end

        function ret=cdata(obj,node)

            ret='';
            child_list=obj.childList(node);
            for i=1:length(child_list)
                child=child_list{i};
                if strcmp(obj.name(child),'#cdata-section')
                    ret=char(child.getData);
                    return;
                end
            end
        end
    end
end
