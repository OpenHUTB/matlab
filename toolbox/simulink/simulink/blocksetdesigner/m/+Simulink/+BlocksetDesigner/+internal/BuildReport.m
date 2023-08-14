classdef BuildReport<mlreportgen.dom.LockedDocument

    methods
        function rpt=BuildReport(reportPath,blockName,status,details,compiler)

            type='html';
            template=fullfile(matlabroot,'toolbox','simulink','core','general','+Simulink','+sfunction','+analyzer','report','ComplianceCheckReportTemplate.htmtx');
            report=fullfile(reportPath,[regexprep(blockName,'[ /\f\n\t\r]','_'),'BuildReport']);
            rpt@mlreportgen.dom.LockedDocument(report,type,template);
            key=Simulink.sfunction.analyzer.internal.getComplianceReportKey();
            open(rpt,key);
            Simulink.BlocksetDesigner.internal.generateBuildReport(rpt,blockName,status,details,compiler);
        end

    end
end