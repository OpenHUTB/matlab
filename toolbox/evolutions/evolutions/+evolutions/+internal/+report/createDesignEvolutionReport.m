function createDesignEvolutionReport(inArgs)




    processingArgs(inArgs);

end

function processingArgs(inArgs)



    if isempty(matlab.project.rootProject)

        error('Project must me open');
    end

    testObjList=inArgs.Content;
    outputFile=inArgs.OutputFile;


    defaultFileFormat='.zip';
    [outputFile,outputExt]=validateFilePath(outputFile,defaultFileFormat);


    if(~strcmpi(outputExt,'.zip')&&~strcmpi(outputExt,'.docx')&&~strcmpi(outputExt,'.pdf'))

        error('UnsupportedFileType');
    end


    outputFile=evolutions.internal.report.incrementFilePath(outputFile);


    reportWrapperObj=evolutions.internal.report.EvolutionReportWrapper;

    reportWrapperObj.OutputFile=outputFile;

    reportWrapperObj.Content=testObjList;

    reportWrapperObj.ReportTitle=inArgs.ReportTitle;

    reportWrapperObj.AuthorName=inArgs.AuthorName;


    reportWrapperObj.GenerateEvolutionTreeReport=inArgs.GenerateEvolutionTreeReport;

    reportWrapperObj.GenerateEvolutionReport=inArgs.GenerateEvolutionReport;

    reportWrapperObj.GenerateArtifactFileReport=inArgs.GenerateArtifactFileReport;


    reportWrapperObj.IncludeEvolutionTreeNameHeading=inArgs.IncludeEvolutionTreeNameHeading;

    reportWrapperObj.IncludeEvolutionTreeTopInfoTable=inArgs.IncludeEvolutionTreeTopInfoTable;

    reportWrapperObj.IncludeEvolutionTreePlot=inArgs.IncludeEvolutionTreePlot;

    reportWrapperObj.IncludeEvolutionTreeEvolutionHyperlinks=inArgs.IncludeEvolutionTreeEvolutionHyperlinks;

    reportWrapperObj.IncludeEvolutionTreeDetailsTable=inArgs.IncludeEvolutionTreeDetailsTable;


    reportWrapperObj.IncludeEvolutionNameHeading=inArgs.IncludeEvolutionNameHeading;

    reportWrapperObj.IncludeEvolutionFileTable=inArgs.IncludeEvolutionFileTable;

    reportWrapperObj.IncludeEvolutionParent=inArgs.IncludeEvolutionParent;

    reportWrapperObj.IncludeEvolutionChildren=inArgs.IncludeEvolutionChildren;

    reportWrapperObj.IncludeEvolutionDetailsTable=inArgs.IncludeEvolutionDetailsTable;

    reportWrapperObj.IncludeEvolutionArtifactHyperlinks=inArgs.IncludeEvolutionArtifactHyperlinks;

    reportWrapperObj.IncludeEvolutionBackToEvolutionTreeHyperlink=inArgs.IncludeEvolutionBackToEvolutionTreeHyperlink;


    reportWrapperObj.IncludeArtifactFileNameHeading=inArgs.IncludeArtifactFileNameHeading;

    reportWrapperObj.IncludeArtifactFileWebView=inArgs.IncludeArtifactFileWebView;

    reportWrapperObj.IncludeArtifactFileBackToEvolutionHyperlinks=inArgs.IncludeArtifactFileBackToEvolutionHyperlinks;

    reportWrapperObj.IncludeArtifactFileBackToEvolutionTreeHyperlink=inArgs.IncludeArtifactFileBackToEvolutionTreeHyperlink;


    reportWrapperObj.LaunchReport=inArgs.LaunchReport;


    reportWrapperObj.createReport();

end


function[filePath,outputExt]=validateFilePath(filePath,defaultExtension)
    [outputPath,outputName,outputExt]=fileparts(filePath);
    if(isempty(outputPath))
        outputPath=pwd();
    end

    if(isempty(outputExt))
        filePath=fullfile(outputPath,strcat(outputName,defaultExtension));
        outputExt=defaultExtension;
    end

end


