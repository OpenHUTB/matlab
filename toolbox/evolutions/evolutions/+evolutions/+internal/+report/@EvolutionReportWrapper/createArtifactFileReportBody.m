function createArtifactFileReportBody(reportObj,testObj,parentObj,section)





    if reportObj.GenerateEvolutionReport
        artifactFileRptr=evolutions.internal.report.ArtifactFileReporter('Object',testObj,...
        'parentObj',parentObj,...
        'ReportTempDir',reportObj.WorkingPath,...
        'IncludeArtifactFileNameHeading',reportObj.IncludeArtifactFileNameHeading,...
        'IncludeArtifactFileWebView',reportObj.IncludeArtifactFileWebView,...
        'IncludeArtifactFileBackToEvolutionHyperlinks',reportObj.IncludeArtifactFileBackToEvolutionHyperlinks,...
        'IncludeArtifactFileBackToEvolutionTreeHyperlink',reportObj.IncludeArtifactFileBackToEvolutionTreeHyperlink);



    elseif~reportObj.GenerateEvolutionReport
        artifactFileRptr=evolutions.internal.report.ArtifactFileReporter('Object',testObj,...
        'parentObj',parentObj,...
        'ReportTempDir',reportObj.WorkingPath,...
        'IncludeArtifactFileNameHeading',reportObj.IncludeArtifactFileNameHeading,...
        'IncludeArtifactFileWebView',reportObj.IncludeArtifactFileWebView,...
        'IncludeArtifactFileBackToEvolutionHyperlinks',false,...
        'IncludeArtifactFileBackToEvolutionTreeHyperlink',reportObj.IncludeArtifactFileBackToEvolutionTreeHyperlink);
    end
    add(section,artifactFileRptr);


    hr=mlreportgen.dom.HorizontalRule();
    hr.Border='solid';
    hr.BorderColor='lightgray';
    add(section,hr);

    add(section,mlreportgen.dom.PageBreak);

end


