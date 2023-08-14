




















































































classdef TestPlan<oslc.internal.BaseResource




    properties(Constant,Hidden)
        typeUri='http://open-services.net/ns/qm#TestPlan';
        resourceTag='oslc_qm:TestPlan';
        creationTemplate=['<?xml version="1.0" encoding="UTF-8"?> ',newline...
        ,'<rdf:RDF '...
        ,' xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"'...
        ,' xmlns:dcterms="http://purl.org/dc/terms/"'...
        ,' xmlns:oslc_qm="http://open-services.net/ns/qm#">',newline...
        ,'     <oslc_qm:TestPlan>',newline...
        ,'    </oslc_qm:TestPlan>',newline...
        ,'</rdf:RDF>'];
    end

    methods
        function this=TestPlan()
        end
    end
end


