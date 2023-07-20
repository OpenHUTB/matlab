

































































































classdef TestCase<oslc.internal.BaseResource




    properties(Constant,Hidden)
        typeUri='http://open-services.net/ns/qm#TestCase';
        resourceTag='oslc_qm:TestCase';
        creationTemplate=['<?xml version="1.0" encoding="UTF-8"?> ',newline...
        ,'<rdf:RDF '...
        ,' xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"'...
        ,' xmlns:dcterms="http://purl.org/dc/terms/"'...
        ,' xmlns:oslc_qm="http://open-services.net/ns/qm#">',newline...
        ,'     <oslc_qm:TestCase>',newline...
        ,'    </oslc_qm:TestCase>',newline...
        ,'</rdf:RDF>'];
    end

    methods
        function this=TestCase()
        end

        function out=getRequirementLinks(this)
            out=oslc.rm.Requirement.empty;
            resourceUrls=this.getResourceProperty('oslc_qm:validatesRequirement');
            for n=1:length(resourceUrls)
                out(n)=oslc.rm.Requirement();
                out(n).setResourceUrl(resourceUrls{n});
            end
        end

        function addRequirementLink(this,reqResourceUrl)
            this.addResourceProperty('oslc_qm:validatesRequirement',reqResourceUrl);
        end

        function removeRequirementLink(this,url)
            this.removeResourceProperty('oslc_qm:validatesRequirement',url);
        end
    end
end


