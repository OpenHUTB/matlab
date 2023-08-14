classdef(Abstract)BaseRequirement<oslc.internal.BaseResource



    properties(Hidden)
        linkTagName='j.0:Link';
        linkNameSpaceURI='http://www.ibm.com/xmlns/rdm/types/';
    end

    methods
        function out=getSLRequirements(this)
            out=slreq.find('type','Reference','ArtifactId',this.ResourceUrl);
        end

        function addLink(this,target)
            target=convertStringsToChars(target);
            if isa(target,'oslc.internal.BaseResource')
                targetResourceUrl=target.ResourceUrl;
            elseif ischar(target)
                targetResourceUrl=target;
            else
                error(message('Slvnv:oslc:InvalidLinkTarget'));
            end
            if~this.IsFetched
                error(message('Slvnv:oslc:MethodNeedConnected','addLink'));
            end

            resourceNode=this.rdfMgr.findNodesByTagAttrNameValue('rdf:type','rdf:resource',this.typeUri);
            requirementNode=resourceNode.getParentNode;


            this.rdfMgr.addPropertyNSWithAttributeUnder(requirementNode,this.linkTagName,this.linkNameSpaceURI,'rdf:resource',targetResourceUrl);
            topNode=requirementNode.getParentNode;


            linkNode=this.rdfMgr.addPropertyWithAttributeUnder(topNode,'rdf:Description','','');
            this.rdfMgr.addPropertyWithAttributeUnder(linkNode,'rdf:subject','rdf:resource',this.ResourceUrl);
            this.rdfMgr.addPropertyWithAttributeUnder(linkNode,'rdf:object','rdf:resource',targetResourceUrl);
            this.rdfMgr.addPropertyWithAttributeUnder(linkNode,'rdf:type','rdf:resource','http://www.w3.org/1999/02/22-rdf-syntax-ns#Statement');

            this.Dirty=true;
        end

        function out=getLinks(this)
            out=this.getResourceProperty(this.linkTagName);
        end

        function removeLink(this,url)
            url=convertStringsToChars(url);
            this.removeResourceProperty(this.linkTagName,url);
        end
    end
end


