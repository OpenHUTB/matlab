function output=generateReport(h,currentTree)




    dialog=createCustomDialog(h,'GenerateReport',currentTree);

    uiValueSelection=dialog.run;

    if isempty(uiValueSelection)

        uiValueSelection=0;


    elseif isa(uiValueSelection,'struct')

        filePath=[uiValueSelection.FileName,'.',uiValueSelection.FileFormat];

        evolutions.internal.report.report(...
        currentTree,filePath,...
        'Author',uiValueSelection.Author,...
        'Title',uiValueSelection.Title,...
        'LaunchReport',uiValueSelection.LaunchReport,...
        'GenerateEvolutionTreeReport',uiValueSelection.GenerateEvolutionTreeReport,...
        'GenerateEvolutionReport',uiValueSelection.GenerateEvolutionReport,...
        'GenerateArtifactFileReport',uiValueSelection.GenerateArtifactFileReport,...
        'IncludeEvolutionTreeTopInfoTable',uiValueSelection.IncludeEvolutionTreeTopInfoTable,...
        'IncludeEvolutionTreeDetailsTable',uiValueSelection.IncludeEvolutionTreeDetailsTable)
    else
        output=cell.empty;
    end

    if h.TestMode
        output=uiValueSelection;
    end

end
