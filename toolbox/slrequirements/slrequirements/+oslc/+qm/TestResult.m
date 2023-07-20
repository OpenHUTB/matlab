





































































































classdef TestResult<oslc.internal.BaseResource



    properties(Constant,Hidden)
        typeUri='http://open-services.net/ns/qm#TestResult';
        resourceTag='oslc_qm:TestResult';
        creationTemplate=['<?xml version="1.0" encoding="UTF-8"?> ',newline...
        ,'<rdf:RDF '...
        ,' xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" '...
        ,' xmlns:dcterms="http://purl.org/dc/terms/"'...
        ,' xmlns:oslc_qm="http://open-services.net/ns/qm#">',newline...
        ,'     <oslc_qm:TestResult>',newline...
        ,'    </oslc_qm:TestResult>',newline...
        ,'</rdf:RDF>'];
    end

    methods
        function this=TestResult()
        end

        function out=getStatus(this)
            out=this.getProperty('oslc_qm:status');
        end

        function out=getProducedTestExecutionRecord(this)
            out=this.getResourceProperty('oslc_qm:producedByTestExecutionRecord');
        end

        function out=getReportsOnTestCase(this)
            out=this.getResourceProperty('oslc_qm:reportsOnTestCase');
        end
    end
end


