



















































































classdef ChangeRequest<oslc.internal.BaseResource




    properties(Constant,Hidden)
        typeUri='http://open-services.net/ns/cm#ChangeRequest';
        resourceTag='oslc_cm:ChangeRequest';
        creationTemplate=['<?xml version="1.0" encoding="UTF-8"?> ',newline...
        ,'<rdf:RDF '...
        ,' xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"'...
        ,' xmlns:dcterms="http://purl.org/dc/terms/"'...
        ,' xmlns:oslc="http://open-services.net/ns/core#"'...
        ,' xmlns:rtc_cm="http://jazz.net/xmlns/prod/jazz/rtc/cm/1.0/"'...
        ,' xmlns:oslc_cm="http://open-services.net/ns/cm#">',newline...
        ,'     <oslc_cm:ChangeRequest>',newline...
        ,'    </oslc_cm:ChangeRequest>',newline...
        ,'</rdf:RDF>'];
    end

    methods
        function this=ChangeRequest()
        end
    end
end


