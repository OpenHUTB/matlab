classdef ComplianceCheckReport<mlreportgen.dom.LockedDocument

    methods
        function rpt=ComplianceCheckReport(model,sfuncNames,categories,checkResults,reportPath,targetBlockMap,isTestharness)

            type='html';
            template=fullfile(matlabroot,'toolbox','simulink','core','general','+Simulink','+sfunction','+analyzer','report','ComplianceCheckReportTemplate.htmtx');
            report=fullfile(reportPath,[regexprep(model,'[ /\f\n\t\r:?<>".,;!''*^%$#@&|\[\]\{\}+-()=\\]','_'),'_report']);
            rpt@mlreportgen.dom.LockedDocument(report,type,template);
            key=Simulink.sfunction.analyzer.internal.getComplianceReportKey();
            open(rpt,key);
            Simulink.sfunction.analyzer.internal.generateComplianceReport(rpt,model,sfuncNames,categories,...
            checkResults,targetBlockMap,isTestharness);
        end

    end
end

