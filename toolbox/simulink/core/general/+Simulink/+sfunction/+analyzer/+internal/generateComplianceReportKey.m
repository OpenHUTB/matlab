function[output_args]=generateComplianceReportKey(input_args)


    templateFile=fullfile(matlabroot,'toolbox','simulink','core','general','+Simulink','+sfunction','+analyzer','report','ComplianceCheckReportTemplate.htmtx');
    key=getLockedDocumentKey('Simulink.sfunction.analyzer.internal.ComplianceCheckReport',templateFile);
    outputScriptFile=fullfile(matlabroot,'toolbox','simulink','core','general','+Simulink','+sfunction','+analyzer','+internal','getComplianceReportKey.m');
    writeKeyScript(key,outputScriptFile);

end

