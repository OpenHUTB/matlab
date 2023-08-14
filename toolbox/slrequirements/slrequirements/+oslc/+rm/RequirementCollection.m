




































































































classdef RequirementCollection<oslc.internal.BaseRequirement



    properties(Constant,Hidden)
        typeUri='http://open-services.net/ns/rm#RequirementCollection';
        resourceTag='oslc_rm:RequirementCollection';
        creationTemplate=['<?xml version="1.0" encoding="UTF-8"?> ',newline...
        ,'<rdf:RDF '...
        ,' xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"'...
        ,' xmlns:dcterms="http://purl.org/dc/terms/"'...
        ,' xmlns:oslc="http://open-services.net/ns/core#"'...
        ,' xmlns:oslc_rm="http://open-services.net/ns/rm#">',newline...
        ,'     <oslc_rm:RequirementCollection>',newline...
        ,'    </oslc_rm:RequirementCollection>',newline...
        ,'</rdf:RDF>'];
    end

    methods
        function this=RequirementCollection()
        end
    end
end


