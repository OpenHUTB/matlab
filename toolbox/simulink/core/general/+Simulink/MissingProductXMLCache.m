classdef MissingProductXMLCache<handle




    properties(Access=private)
        mDoc;
        mNodes;
        mNames;
    end

    methods(Access=public)



        function obj=MissingProductXMLCache(filename,elementName,attrName)

            xmlfile=slfullfile(matlabroot,'toolbox','simulink',...
            'missing_product_identification',filename);
            if isempty(Simulink.loadsave.resolveFile(xmlfile))

                fprintf('simulink_missing_product_indentification component not installed: %s\n',xmlfile);
                return;
            end

            parser=matlab.io.xml.dom.Parser;
            obj.mDoc=parseFile(parser,xmlfile);
            obj.mNodes=obj.mDoc.getElementsByTagName(elementName);
            obj.mNames=strings(obj.mNodes.getLength,1);
            for i=1:numel(obj.mNames)
                obj.mNames(i)=obj.mNodes.item(i-1).getAttribute(attrName);
            end
        end

        function out=query(obj,name,attr)
            if isempty(obj.mDoc)

                out="";
                return;
            end
            ind=find(obj.mNames==name);
            if~isempty(ind)

                node=obj.mNodes.item(ind-1);
                if~isempty(attr)
                    out=string(node.getAttribute(attr));
                else
                    out=string(node.getTextContent);
                end
            else
                out="";
            end
        end

    end
end
