function createEvolutionTreeReportBody(reportObj,testObj,section)




    if reportObj.GenerateEvolutionReport
        evolutionTreeRptr=evolutions.internal.report.EvolutionTreeReporter('Object',testObj,...
        'ReportTempDir',reportObj.WorkingPath,...
        'IncludeEvolutionTreeNameHeading',reportObj.IncludeEvolutionTreeNameHeading,...
        'IncludeEvolutionTreeTopInfoTable',reportObj.IncludeEvolutionTreeTopInfoTable,...
        'IncludeEvolutionTreePlot',reportObj.IncludeEvolutionTreePlot,...
        'IncludeEvolutionTreeEvolutionHyperlinks',reportObj.IncludeEvolutionTreeEvolutionHyperlinks,...
        'IncludeEvolutionTreeDetailsTable',reportObj.IncludeEvolutionTreeDetailsTable);



    elseif~reportObj.GenerateEvolutionReport
        evolutionTreeRptr=evolutions.internal.report.EvolutionTreeReporter('Object',testObj,...
        'ReportTempDir',reportObj.WorkingPath,...
        'IncludeEvolutionTreeNameHeading',reportObj.IncludeEvolutionTreeNameHeading,...
        'IncludeEvolutionTreeTopInfoTable',reportObj.IncludeEvolutionTreeTopInfoTable,...
        'IncludeEvolutionTreePlot',reportObj.IncludeEvolutionTreePlot,...
        'IncludeEvolutionTreeEvolutionHyperlinks',false,...
        'IncludeEvolutionTreeDetailsTable',reportObj.IncludeEvolutionTreeDetailsTable);

    end

    add(section,evolutionTreeRptr);


    hr=mlreportgen.dom.HorizontalRule();
    hr.Border='solid';
    hr.BorderColor='lightgray';
    add(section,hr);


    add(section,mlreportgen.dom.PageBreak);
end


