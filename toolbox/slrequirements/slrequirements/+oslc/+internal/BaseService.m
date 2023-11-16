classdef BaseService<handle

    properties(Hidden)
        dom;
    end

    properties(Dependent)
        title;
        resourceType;
    end

    methods

        function out=get.title(this)
            node=this.dom.getElementsByTagName('dcterms:title');
            out=node.node(1).TextContent;
        end

        function out=get.resourceType(this)
            out={};
            nodeList=this.dom.getElementsByTagName('oslc:resourceType');
            for n=1:nodeList.Length
                out{n}=nodeList.node(n).getAttribute('rdf:resource');%#ok<AGROW>
            end
        end
    end
end

