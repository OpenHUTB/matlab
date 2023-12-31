function createEvolutionReportBody(reportObj,testObj,parentObj,section)




    if reportObj.GenerateArtifactFileReport
        evolutionRptr=evolutions.internal.report.EvolutionReporter('Object',testObj,...
        'parentObj',parentObj,...
        'ReportTempDir',reportObj.WorkingPath,...
        'IncludeEvolutionNameHeading',reportObj.IncludeEvolutionNameHeading,...
        'IncludeEvolutionFileTable',reportObj.IncludeEvolutionFileTable,...
        'IncludeEvolutionParent',reportObj.IncludeEvolutionParent,...
        'IncludeEvolutionChildren',reportObj.IncludeEvolutionChildren,...
        'IncludeEvolutionDetailsTable',reportObj.IncludeEvolutionDetailsTable,...
        'IncludeEvolutionArtifactHyperlinks',reportObj.IncludeEvolutionArtifactHyperlinks,...
        'IncludeEvolutionBackToEvolutionTreeHyperlink',reportObj.IncludeEvolutionBackToEvolutionTreeHyperlink);



    elseif~reportObj.GenerateArtifactFileReport
        evolutionRptr=evolutions.internal.report.EvolutionReporter('Object',testObj,...
        'parentObj',parentObj,...
        'ReportTempDir',reportObj.WorkingPath,...
        'IncludeEvolutionNameHeading',reportObj.IncludeEvolutionNameHeading,...
        'IncludeEvolutionFileTable',reportObj.IncludeEvolutionFileTable,...
        'IncludeEvolutionParent',reportObj.IncludeEvolutionParent,...
        'IncludeEvolutionChildren',reportObj.IncludeEvolutionChildren,...
        'IncludeEvolutionDetailsTable',reportObj.IncludeEvolutionDetailsTable,...
        'IncludeEvolutionArtifactHyperlinks',false,...
        'IncludeEvolutionBackToEvolutionTreeHyperlink',reportObj.IncludeEvolutionBackToEvolutionTreeHyperlink);


    end
    add(section,evolutionRptr);


    hr=mlreportgen.dom.HorizontalRule();
    hr.Border='solid';
    hr.BorderColor='lightgray';
    add(section,hr);


    add(section,mlreportgen.dom.PageBreak);
end


