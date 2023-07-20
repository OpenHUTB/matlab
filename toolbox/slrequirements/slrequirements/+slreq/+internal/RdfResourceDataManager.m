classdef RdfResourceDataManager<handle





    properties
origRDF
dom
    end

    methods
        function this=RdfResourceDataManager(rdf)
            this.origRDF=rdf;
            this.parse;
        end

        function parse(this)
            parser=matlab.io.xml.dom.Parser;
            this.dom=parser.parseString(this.origRDF);
        end

        function out=getProperty(this,propName,typeUri,resourceTag)
            typeNode=this.findTypeNode(typeUri,resourceTag);
            nodeList=typeNode.getElementsByTagName(propName);
            if nodeList.Length==0
                error(message('Slvnv:slreq:FailedGetPropertyNoElement',propName));
            elseif nodeList.Length==1
                out=nodeList.node(1).TextContent;
            else
                out={};
                for n=1:nodeList.Length
                    out{n}=nodeList.node(n).TextContent;%#ok<AGROW>
                end
            end
        end

        function setProperty(this,propName,propValue,typeUri,resourceTag)
            typeNode=this.findTypeNode(typeUri,resourceTag);
            nodeList=typeNode.getElementsByTagName(propName);
            if nodeList.Length==0
                error(message('Slvnv:slreq:FailedSetPropertyNoElement',propName));
            elseif nodeList.Length>1
                error(message('Slvnv:slreq:FailedSetPropertyMultiElements',propName));
            end

            node=nodeList.node(1);
            node.TextContent=propValue;
        end

        function addResourcePropertyByTag(this,resourceTag,propName,resourceUrl)

            typeNode=this.findTypeNode('',resourceTag);
            newElem=this.dom.createElement(propName);
            newElem.setAttribute('rdf:resource',resourceUrl);
            typeNode.appendChild(newElem);
        end

        function addResourcePropertyByTypeUri(this,typeUri,propName,resourceUrl)



            typeNode=this.findTypeNode(typeUri,'');
            newElem=this.dom.createElement(propName);
            newElem.setAttribute('rdf:resource',resourceUrl);
            typeNode.appendChild(newElem);
        end

        function addTextProperty(this,propName,resourceTag,typeUri,text)
            typeNode=this.findTypeNode(typeUri,resourceTag);
            newElem=this.dom.createElement(propName);
            newElem.TextContent=text;
            typeNode.appendChild(newElem);
        end

        function addTextPropertyNS(this,propName,resourceTag,typeUri,text,namespace)
            typeNode=this.findTypeNode(typeUri,resourceTag);
            newElem=this.dom.createElementNS(namespace,propName);
            newElem.TextContent=text;
            typeNode.appendChild(newElem);
        end

        function newElem=addPropertyWithAttributeUnder(this,parentNode,propName,attrName,attrValue)

            newElem=this.dom.createElement(propName);
            if~isempty(attrName)
                newElem.setAttribute(attrName,attrValue);
            end
            parentNode.appendChild(newElem);
        end

        function newElem=addPropertyNSWithAttributeUnder(this,parentNode,propName,namespaceURI,attrName,attrValue)

            newElem=this.dom.createElementNS(namespaceURI,propName);
            if~isempty(attrName)
                newElem.setAttribute(attrName,attrValue);
            end
            parentNode.appendChild(newElem);
        end

        function addTextPropertyUnder(this,parentNode,propName,text)
            newElem=this.dom.createElement(propName);
            newElem.TextContent=text;
            parentNode.appendChild(newElem);
        end

        function out=findNodesByTagAttrNameValue(this,tagName,attrName,attrValue)
            import matlab.io.xml.dom.*
            out=[];
            d=this.dom;
            e=d.getDocumentElement;
            resolver=createNSResolver(d,e);
            resType=matlab.io.xml.dom.XPathResult.ORDERED_NODE_SNAPSHOT_TYPE;
            xpath=sprintf('//%s',tagName);
            nodeSnapshot=evaluate(d,xpath,e,resolver,resType);

            nNodes=getSnapshotLength(nodeSnapshot);
            for i=1:nNodes
                snapshotItem(nodeSnapshot,i-1);
                node=getNodeValue(nodeSnapshot);
                if strcmp(node.getAttribute(attrName),attrValue)
                    if isempty(out)
                        out=node;
                    else
                        out(end+1)=node;%#ok<AGROW>
                    end
                end
            end
        end

        function out=findNodesByTagName(this,tagName)
            import matlab.io.xml.dom.*
            out=[];
            d=this.dom;
            e=d.getDocumentElement;
            resolver=createNSResolver(d,e);
            resType=matlab.io.xml.dom.XPathResult.ORDERED_NODE_SNAPSHOT_TYPE;
            xpath=sprintf('//%s',tagName);
            nodeSnapshot=evaluate(d,xpath,e,resolver,resType);

            nNodes=getSnapshotLength(nodeSnapshot);
            for i=1:nNodes
                snapshotItem(nodeSnapshot,i-1);
                node=getNodeValue(nodeSnapshot);
                if isempty(out)
                    out=node;
                else
                    out(i)=node;%#ok<AGROW>
                end
            end
        end

        function out=getResourceUrlsFromProperty(this,propName,typeUri)
            out={};
            typeNode=this.findNodesByTagAttrNameValue('rdf:type','rdf:resource',typeUri);
            topNode=typeNode.getParentNode;
            nodeList=topNode.getElementsByTagName(propName);
            for n=1:nodeList.Length
                attr=nodeList.node(n).getAttribute('rdf:resource');
                if~isempty(attr)
                    out{end+1}=attr;%#ok<AGROW>
                end
            end
        end

        function out=toString(this)
            w=matlab.io.xml.dom.DOMWriter;
            data=w.writeToString(this.dom);


            out=strrep(data,'UTF-16','UTF-8');
        end

        function typeNode=findTypeNode(this,typeUri,resourceTag)

            typeResNode=this.findNodesByTagAttrNameValue('rdf:type','rdf:resource',typeUri);
            if~isempty(typeResNode)

                typeNode=typeResNode.getParentNode;
            else

                typeNode=this.findNodesByTagName(resourceTag);
            end
        end
    end
end


