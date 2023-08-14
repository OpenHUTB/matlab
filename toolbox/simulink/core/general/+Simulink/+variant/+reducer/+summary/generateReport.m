function generateReport(rManager)




    rptName='variantReducerRpt';
    modelName=rManager.getOptions().TopModelName;
    source=fullfile(matlabroot,'toolbox','simulink','core','general','+Simulink','+variant','+reducer','+summary','@VRedSummary','two_webviews.htmtx');
    destination=rManager.getOptions().AbsOutDirPath;
    copyfile(source,destination);
    rptgen=Simulink.variant.reducer.summary.VRedSummary(rptName,modelName,rManager.ReportDataObj);
    fill(rptgen);
    close(rptgen);
    rptview([rptName,filesep,'report.html']);
end


